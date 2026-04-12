package rabbitmq

// round_consumer.go — declares and consumes the round-completed-queue.
//
// The quiz engine's game loop already handles round completion inline
// (broadcasts RoundResult + LeaderboardUpdate, then starts the next round).
// This consumer exists to satisfy the architectural requirement that every
// published routing key has a bound queue so messages are never silently
// discarded by RabbitMQ. It logs the event for observability and can be
// extended for analytics without touching the hot path.

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
)

const (
	roundQueue      = "round-completed-queue"
	roundRoutingKey = "round.completed"
)

// RoundConsumer binds to round-completed-queue and logs each event.
type RoundConsumer struct {
	conn    *amqp.Connection
	channel *amqp.Channel
}

// NewRoundConsumer connects to RabbitMQ, declares the exchange + queue, and
// binds the routing key. Safe to call multiple times (idempotent declarations).
func NewRoundConsumer(amqpURL string) (*RoundConsumer, error) {
	conn, err := amqp.Dial(amqpURL)
	if err != nil {
		return nil, fmt.Errorf("amqp dial: %w", err)
	}

	ch, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("open channel: %w", err)
	}

	// Exchange (idempotent — same declaration as publisher)
	if err := ch.ExchangeDeclare(exchangeName, "topic", true, false, false, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("exchange declare: %w", err)
	}

	// Durable queue — survives broker restart
	if _, err := ch.QueueDeclare(roundQueue, true, false, false, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue declare %s: %w", roundQueue, err)
	}

	if err := ch.QueueBind(roundQueue, roundRoutingKey, exchangeName, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue bind %s → %s: %w", roundRoutingKey, roundQueue, err)
	}

	// Prefetch 1 — process one event at a time
	if err := ch.Qos(1, 0, false); err != nil {
		conn.Close()
		return nil, fmt.Errorf("set QoS: %w", err)
	}

	log.Printf("✅ Round consumer ready — queue: %s, binding: %s → %s",
		roundQueue, exchangeName, roundRoutingKey)

	return &RoundConsumer{conn: conn, channel: ch}, nil
}

// Start blocks consuming messages from round-completed-queue until ctx is cancelled.
func (c *RoundConsumer) Start(ctx context.Context) error {
	msgs, err := c.channel.Consume(roundQueue, "", false, false, false, false, nil)
	if err != nil {
		return fmt.Errorf("consume %s: %w", roundQueue, err)
	}

	log.Printf("▶  Round consumer consuming from %s", roundQueue)

	for {
		select {
		case <-ctx.Done():
			log.Println("Round consumer stopping")
			return nil
		case msg, ok := <-msgs:
			if !ok {
				return fmt.Errorf("consumer channel closed")
			}
			c.handle(msg)
		}
	}
}

func (c *RoundConsumer) handle(msg amqp.Delivery) {
	// Parse just enough to log; extend here for analytics / audit trail.
	var ev struct {
		RoomID      string    `json:"room_id"`
		RoundNumber int       `json:"round_number"`
		CompletedAt time.Time `json:"completed_at"`
	}
	if err := json.Unmarshal(msg.Body, &ev); err != nil {
		log.Printf("⚠️  round_consumer: malformed payload: %v", err)
		msg.Ack(false)
		return
	}

	log.Printf("🔔 round.completed — room: %s round: %d at: %s",
		ev.RoomID, ev.RoundNumber, ev.CompletedAt.Format(time.RFC3339))

	msg.Ack(false)
}

// Close cleans up the AMQP connection.
func (c *RoundConsumer) Close() {
	if c.channel != nil {
		c.channel.Close()
	}
	if c.conn != nil {
		c.conn.Close()
	}
}
