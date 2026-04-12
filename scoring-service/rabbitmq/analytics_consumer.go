package rabbitmq

// analytics_consumer.go — match-analytics-queue stub.
//
// Both match-finished-queue AND match-analytics-queue bind to the
// match.finished routing key. RabbitMQ delivers a copy of each event to both
// queues — they are independent consumers of the same event stream.
//
// This consumer is a stub that logs analytics data to stdout. It can be
// extended to push data to a time-series DB, data warehouse, or event
// tracking system without any changes to the quiz engine or scoring service.

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
)

const (
	analyticsQueue      = "match-analytics-queue"
	analyticsRoutingKey = "match.finished" // same routing key as match-finished-queue
)

// AnalyticsConsumer binds to match-analytics-queue and logs match analytics.
type AnalyticsConsumer struct {
	conn    *amqp.Connection
	channel *amqp.Channel
}

// NewAnalyticsConsumer connects to RabbitMQ and declares queue + binding.
func NewAnalyticsConsumer(amqpURL string) (*AnalyticsConsumer, error) {
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

	if _, err := ch.QueueDeclare(analyticsQueue, true, false, false, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue declare %s: %w", analyticsQueue, err)
	}

	// Both match-finished-queue and match-analytics-queue bind to match.finished.
	// Each queue receives its own independent copy of the message.
	if err := ch.QueueBind(analyticsQueue, analyticsRoutingKey, exchangeName, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue bind %s → %s: %w", analyticsRoutingKey, analyticsQueue, err)
	}

	if err := ch.Qos(1, 0, false); err != nil {
		conn.Close()
		return nil, fmt.Errorf("set QoS: %w", err)
	}

	log.Printf("✅ Analytics consumer ready — queue: %s, binding: %s → %s",
		analyticsQueue, exchangeName, analyticsRoutingKey)

	return &AnalyticsConsumer{conn: conn, channel: ch}, nil
}

// Start blocks consuming until ctx is cancelled.
func (c *AnalyticsConsumer) Start(ctx context.Context) error {
	msgs, err := c.channel.Consume(analyticsQueue, "", false, false, false, false, nil)
	if err != nil {
		return fmt.Errorf("consume %s: %w", analyticsQueue, err)
	}

	log.Printf("▶  Analytics consumer consuming from %s", analyticsQueue)

	for {
		select {
		case <-ctx.Done():
			log.Println("Analytics consumer stopping")
			return nil
		case msg, ok := <-msgs:
			if !ok {
				return fmt.Errorf("consumer channel closed")
			}
			c.handle(msg)
		}
	}
}

func (c *AnalyticsConsumer) handle(msg amqp.Delivery) {
	var ev struct {
		RoomID      string    `json:"room_id"`
		TotalRounds int       `json:"total_rounds"`
		FinishedAt  time.Time `json:"finished_at"`
	}
	if err := json.Unmarshal(msg.Body, &ev); err != nil {
		log.Printf("⚠️  analytics_consumer: malformed payload: %v", err)
		msg.Ack(false)
		return
	}

	// STUB: log match analytics to stdout.
	// Replace with your analytics backend (ClickHouse, BigQuery, Mixpanel, etc.)
	log.Printf("[ANALYTICS] match_finished room=%s rounds=%d duration=%.0fs",
		ev.RoomID, ev.TotalRounds, time.Since(ev.FinishedAt).Seconds())

	msg.Ack(false)
}

// Close cleans up the AMQP connection.
func (c *AnalyticsConsumer) Close() {
	if c.channel != nil {
		c.channel.Close()
	}
	if c.conn != nil {
		c.conn.Close()
	}
}
