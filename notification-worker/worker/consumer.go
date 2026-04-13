package worker

// consumer.go — RabbitMQ consumers for the notification worker.
//
// Two consumers run concurrently:
//
//   NotificationConsumer (notification-worker-queue → notification.*)
//     Handles explicit notification events published by other services.
//     Currently supported event types:
//       notification.tournament_reminder — broadcast to all registered tokens
//       (extensible: add more event types in handleNotificationEvent)
//
//   MatchFinishedConsumer (notification-match-queue → match.finished)
//     Detects referral-conversion events: when a referred user completes their
//     first quiz, the referrer gets a push notification.
//     Uses referee_first_match_notified flag (atomic set) to guarantee
//     exactly-once delivery even if the worker restarts mid-processing.

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
	"go.mongodb.org/mongo-driver/mongo"
)

const exchangeName = "sx"

// ── Generic notification consumer ────────────────────────────────────────

// NotificationConsumer handles events on the notification.* routing key.
type NotificationConsumer struct {
	conn    *amqp.Connection
	channel *amqp.Channel
	fcm     *FCMSender
	db      *mongo.Database
}

func NewNotificationConsumer(amqpURL string, fcm *FCMSender, db *mongo.Database) (*NotificationConsumer, error) {
	conn, err := amqp.Dial(amqpURL)
	if err != nil {
		return nil, fmt.Errorf("amqp dial: %w", err)
	}
	ch, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("open channel: %w", err)
	}
	if err := declareExchange(ch); err != nil {
		conn.Close()
		return nil, err
	}

	const queueName = "notification-worker-queue"
	if _, err := ch.QueueDeclare(queueName, true, false, false, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue declare %s: %w", queueName, err)
	}
	// Bind to all notification.* events (wildcard topic binding)
	if err := ch.QueueBind(queueName, "notification.*", exchangeName, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue bind notification.*: %w", err)
	}
	if err := ch.Qos(1, 0, false); err != nil {
		conn.Close()
		return nil, fmt.Errorf("set QoS: %w", err)
	}

	log.Printf("✅ Notification consumer ready — queue: %s, binding: notification.*", queueName)
	return &NotificationConsumer{conn: conn, channel: ch, fcm: fcm, db: db}, nil
}

func (c *NotificationConsumer) Start(ctx context.Context) error {
	msgs, err := c.channel.Consume("notification-worker-queue", "", false, false, false, false, nil)
	if err != nil {
		return fmt.Errorf("consume notification-worker-queue: %w", err)
	}
	log.Println("▶  Notification consumer listening on notification-worker-queue")
	for {
		select {
		case <-ctx.Done():
			return nil
		case msg, ok := <-msgs:
			if !ok {
				return fmt.Errorf("channel closed")
			}
			c.handle(ctx, msg)
		}
	}
}

func (c *NotificationConsumer) handle(ctx context.Context, msg amqp.Delivery) {
	var ev struct {
		Type    string            `json:"type"`    // e.g. "tournament_reminder"
		Title   string            `json:"title"`
		Body    string            `json:"body"`
		UserIDs []string          `json:"user_ids"` // empty = broadcast to all
		Data    map[string]string `json:"data"`
	}
	if err := json.Unmarshal(msg.Body, &ev); err != nil {
		log.Printf("⚠️  notification consumer: malformed payload: %v", err)
		msg.Ack(false)
		return
	}

	log.Printf("🔔 notification event — type: %s target_users: %d", ev.Type, len(ev.UserIDs))

	timeout, cancel := context.WithTimeout(ctx, 15*time.Second)
	defer cancel()

	var tokens []string
	var err error

	if len(ev.UserIDs) > 0 {
		tokenMap, e := GetTokensForUsers(timeout, c.db, ev.UserIDs)
		if e != nil {
			log.Printf("⚠️  notification consumer: token lookup failed: %v", e)
			msg.Nack(false, true) // requeue
			return
		}
		for _, t := range tokenMap {
			tokens = append(tokens, t)
		}
	} else {
		// Broadcast to all registered devices
		tokens, err = GetAllTokens(timeout, c.db)
		if err != nil {
			log.Printf("⚠️  notification consumer: GetAllTokens failed: %v", err)
			msg.Nack(false, true)
			return
		}
	}

	if len(tokens) == 0 {
		msg.Ack(false)
		return
	}

	if err := c.fcm.SendMulticast(timeout, tokens, ev.Title, ev.Body, ev.Data); err != nil {
		log.Printf("⚠️  notification consumer: FCM multicast failed: %v", err)
	}

	msg.Ack(false)
}

func (c *NotificationConsumer) Close() {
	if c.channel != nil {
		c.channel.Close()
	}
	if c.conn != nil {
		c.conn.Close()
	}
}

// ── Match-finished consumer (referral conversion) ─────────────────────────

// MatchFinishedNotificationConsumer subscribes to match.finished events and
// sends a push notification to the referrer when a referred user plays their
// first quiz.
type MatchFinishedNotificationConsumer struct {
	conn    *amqp.Connection
	channel *amqp.Channel
	fcm     *FCMSender
	db      *mongo.Database
}

func NewMatchFinishedNotificationConsumer(amqpURL string, fcm *FCMSender, db *mongo.Database) (*MatchFinishedNotificationConsumer, error) {
	conn, err := amqp.Dial(amqpURL)
	if err != nil {
		return nil, fmt.Errorf("amqp dial: %w", err)
	}
	ch, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("open channel: %w", err)
	}
	if err := declareExchange(ch); err != nil {
		conn.Close()
		return nil, err
	}

	const queueName = "notification-match-queue"
	if _, err := ch.QueueDeclare(queueName, true, false, false, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue declare %s: %w", queueName, err)
	}
	if err := ch.QueueBind(queueName, "match.finished", exchangeName, false, nil); err != nil {
		conn.Close()
		return nil, fmt.Errorf("queue bind match.finished: %w", err)
	}
	if err := ch.Qos(1, 0, false); err != nil {
		conn.Close()
		return nil, fmt.Errorf("set QoS: %w", err)
	}

	log.Printf("✅ Match-finished notification consumer ready — queue: %s", queueName)
	return &MatchFinishedNotificationConsumer{conn: conn, channel: ch, fcm: fcm, db: db}, nil
}

func (c *MatchFinishedNotificationConsumer) Start(ctx context.Context) error {
	msgs, err := c.channel.Consume("notification-match-queue", "", false, false, false, false, nil)
	if err != nil {
		return fmt.Errorf("consume notification-match-queue: %w", err)
	}
	log.Println("▶  Match-finished notification consumer listening")
	for {
		select {
		case <-ctx.Done():
			return nil
		case msg, ok := <-msgs:
			if !ok {
				return fmt.Errorf("channel closed")
			}
			c.handle(ctx, msg)
		}
	}
}

func (c *MatchFinishedNotificationConsumer) handle(ctx context.Context, msg amqp.Delivery) {
	var ev struct {
		RoomID string `json:"room_id"`
	}
	if err := json.Unmarshal(msg.Body, &ev); err != nil {
		log.Printf("⚠️  match-notification: malformed payload: %v", err)
		msg.Ack(false)
		return
	}

	timeout, cancel := context.WithTimeout(ctx, 15*time.Second)
	defer cancel()

	// Look up which players participated in this match
	players, err := GetMatchPlayers(timeout, c.db, ev.RoomID)
	if err != nil {
		log.Printf("⚠️  match-notification: GetMatchPlayers(%s): %v", ev.RoomID, err)
		msg.Nack(false, true)
		return
	}
	if len(players) == 0 {
		// match_history not written yet — small race; safe to retry once
		log.Printf("⚠️  match-notification: no match_history for room %s (may retry)", ev.RoomID)
		msg.Nack(false, true)
		return
	}

	// For each player, check if they were referred AND this is their first match
	for _, player := range players {
		c.checkAndNotifyReferrer(timeout, player)
	}

	msg.Ack(false)
}

// checkAndNotifyReferrer sends a push to the referrer if this is the first
// quiz the referred user (referee) has completed.
func (c *MatchFinishedNotificationConsumer) checkAndNotifyReferrer(ctx context.Context, player MatchPlayer) {
	info, err := GetUserInfo(ctx, c.db, player.UserID)
	if err != nil || info == nil {
		return
	}
	// Not referred, or notification already sent
	if info.ReferredBy == "" || info.RefereeFirstMatchNotified {
		return
	}

	// Atomically mark notified — prevents double-send on worker restart
	if err := MarkFirstMatchNotified(ctx, c.db, player.UserID); err != nil {
		log.Printf("⚠️  match-notification: MarkFirstMatchNotified(%s): %v", player.UserID, err)
		return
	}

	// Look up the referrer's FCM token
	referrerToken, err := GetToken(ctx, c.db, info.ReferredBy)
	if err != nil || referrerToken == "" {
		return // referrer has no device token — skip silently
	}

	title := "Your referral is paying off! 🎉"
	body := fmt.Sprintf("%s just completed their first quiz battle!", player.Username)

	if err := c.fcm.Send(ctx, referrerToken, title, body, map[string]string{
		"type": "referral_converted",
	}); err != nil {
		log.Printf("⚠️  match-notification: FCM send to referrer %s: %v", info.ReferredBy, err)
	} else {
		log.Printf("🎉 Referral conversion notified — referee: %s referrer: %s", player.UserID, info.ReferredBy)
	}
}

func (c *MatchFinishedNotificationConsumer) Close() {
	if c.channel != nil {
		c.channel.Close()
	}
	if c.conn != nil {
		c.conn.Close()
	}
}

// ── Shared helpers ────────────────────────────────────────────────────────

func declareExchange(ch *amqp.Channel) error {
	return ch.ExchangeDeclare(exchangeName, "topic", true, false, false, false, nil)
}
