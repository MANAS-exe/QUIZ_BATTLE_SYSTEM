package rabbitmq

// match_consumer.go — declares and consumes the match-finished-queue.
//
// Consumes match.finished events published by the quiz engine after all
// rounds complete. The quiz engine already writes match_history to MongoDB
// inline; this consumer provides an additional persistence confirmation,
// logs final match stats for observability, and is the extension point for
// post-match processing (rating recalculation, notifications, etc.).

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
)

const (
	matchFinishedQueue      = "match-finished-queue"
	matchFinishedRoutingKey = "match.finished"
)

// MatchFinishedConsumer binds to match-finished-queue and logs each event.
type MatchFinishedConsumer struct {
	conn    *amqp.Connection
	channel *amqp.Channel
}

// NewMatchFinishedConsumer connects to RabbitMQ and declares queue + binding.
func NewMatchFinishedConsumer(amqpURL string) (*MatchFinishedConsumer, error) {
	conn, err := amqp.Dial(amqpURL)
	if err != nil {
		return nil, fmt.Errorf("amqp dial: %w", err)
	}

	ch, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("open channel: %w", err)
	}

	// Exchange (idempotent)
	if err := ch.ExchangeDeclare(exchangeName, "topic", true, false, false, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("exchange declare: %w", err)
	}

	if _, err := ch.QueueDeclare(matchFinishedQueue, true, false, false, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue declare %s: %w", matchFinishedQueue, err)
	}

	if err := ch.QueueBind(matchFinishedQueue, matchFinishedRoutingKey, exchangeName, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue bind %s → %s: %w", matchFinishedRoutingKey, matchFinishedQueue, err)
	}

	if err := ch.Qos(1, 0, false); err != nil {
		conn.Close()
		return nil, fmt.Errorf("set QoS: %w", err)
	}

	log.Printf("✅ Match-finished consumer ready — queue: %s, binding: %s → %s",
		matchFinishedQueue, exchangeName, matchFinishedRoutingKey)

	return &MatchFinishedConsumer{conn: conn, channel: ch}, nil
}

// Start blocks consuming until ctx is cancelled.
func (c *MatchFinishedConsumer) Start(ctx context.Context) error {
	msgs, err := c.channel.Consume(matchFinishedQueue, "", false, false, false, false, nil)
	if err != nil {
		return fmt.Errorf("consume %s: %w", matchFinishedQueue, err)
	}

	log.Printf("▶  Match-finished consumer consuming from %s", matchFinishedQueue)

	for {
		select {
		case <-ctx.Done():
			log.Println("Match-finished consumer stopping")
			return nil
		case msg, ok := <-msgs:
			if !ok {
				return fmt.Errorf("consumer channel closed")
			}
			c.handle(msg)
		}
	}
}

func (c *MatchFinishedConsumer) handle(msg amqp.Delivery) {
	var ev struct {
		RoomID      string    `json:"room_id"`
		TotalRounds int       `json:"total_rounds"`
		FinishedAt  time.Time `json:"finished_at"`
	}
	if err := json.Unmarshal(msg.Body, &ev); err != nil {
		log.Printf("⚠️  match_consumer: malformed payload: %v", err)
		msg.Ack(false)
		return
	}

	log.Printf("🏁 match.finished — room: %s rounds: %d finished_at: %s",
		ev.RoomID, ev.TotalRounds, ev.FinishedAt.Format(time.RFC3339))

	// Extension point: trigger post-match tasks here (rating update, push
	// notifications, leaderboard archival, etc.) without blocking the quiz
	// engine's hot path.

	msg.Ack(false)
}

// Close cleans up the AMQP connection.
func (c *MatchFinishedConsumer) Close() {
	if c.channel != nil {
		c.channel.Close()
	}
	if c.conn != nil {
		c.conn.Close()
	}
}
