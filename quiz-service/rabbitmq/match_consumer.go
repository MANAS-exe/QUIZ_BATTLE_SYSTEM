package rabbitmq

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	goredis "github.com/gomodule/redigo/redis"
	amqp "github.com/rabbitmq/amqp091-go"
	"go.mongodb.org/mongo-driver/mongo"

	"quiz-battle/quiz/questions"
)

const (
	matchCreatedQueue      = "quiz-match-created-queue"
	matchCreatedRoutingKey = "match.created"
)

// MatchCreatedEvent mirrors the JSON payload from matchmaking-service.
type MatchCreatedEvent struct {
	RoomID  string `json:"room_id"`
	Players []struct {
		UserID string `json:"user_id"`
	} `json:"players"`
	TotalRounds int `json:"total_rounds"`
}

// MatchConsumer listens for match.created events and selects questions for new rooms.
type MatchConsumer struct {
	conn      *amqp.Connection
	channel   *amqp.Channel
	redisPool *goredis.Pool
	mongoDB   *mongo.Database
}

func NewMatchConsumer(amqpURL string, redisPool *goredis.Pool, mongoDB *mongo.Database) (*MatchConsumer, error) {
	conn, err := amqp.Dial(amqpURL)
	if err != nil {
		return nil, fmt.Errorf("amqp dial: %w", err)
	}

	ch, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("open channel: %w", err)
	}

	if err := ch.ExchangeDeclare(exchangeName, "topic", true, false, false, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("exchange declare: %w", err)
	}

	_, err = ch.QueueDeclare(matchCreatedQueue, true, false, false, false, nil)
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue declare: %w", err)
	}

	err = ch.QueueBind(matchCreatedQueue, matchCreatedRoutingKey, exchangeName, false, nil)
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue bind: %w", err)
	}

	if err := ch.Qos(1, 0, false); err != nil {
		conn.Close()
		return nil, fmt.Errorf("set QoS: %w", err)
	}

	log.Printf("✅ Match consumer ready — queue: %s, binding: %s → %s",
		matchCreatedQueue, exchangeName, matchCreatedRoutingKey)

	return &MatchConsumer{
		conn:      conn,
		channel:   ch,
		redisPool: redisPool,
		mongoDB:   mongoDB,
	}, nil
}

func (c *MatchConsumer) Start(ctx context.Context) error {
	msgs, err := c.channel.Consume(matchCreatedQueue, "", false, false, false, false, nil)
	if err != nil {
		return fmt.Errorf("consume %s: %w", matchCreatedQueue, err)
	}

	log.Printf("▶  Match consumer consuming from %s", matchCreatedQueue)

	for {
		select {
		case <-ctx.Done():
			log.Println("Match consumer stopping")
			return nil
		case msg, ok := <-msgs:
			if !ok {
				return fmt.Errorf("match consumer channel closed")
			}
			c.handle(msg)
		}
	}
}

func (c *MatchConsumer) handle(msg amqp.Delivery) {
	var event MatchCreatedEvent
	if err := json.Unmarshal(msg.Body, &event); err != nil {
		log.Printf("⚠️  Malformed match.created payload: %v", err)
		msg.Ack(false)
		return
	}

	playerIDs := make([]string, len(event.Players))
	for i, p := range event.Players {
		playerIDs[i] = p.UserID
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	_ = ctx // used by SelectQuestionsForRoom internally

	ids, err := questions.SelectForRoom(c.redisPool, c.mongoDB, event.RoomID, playerIDs, event.TotalRounds)
	if err != nil {
		log.Printf("❌ SelectQuestionsForRoom failed for room %s: %v", event.RoomID, err)
		msg.Nack(false, true) // requeue for retry
		return
	}

	log.Printf("📚 Questions selected for room %s: %d questions", event.RoomID, len(ids))
	msg.Ack(false)
}

func (c *MatchConsumer) Close() {
	if c.channel != nil {
		c.channel.Close()
	}
	if c.conn != nil {
		c.conn.Close()
	}
	log.Println("Match consumer closed")
}
