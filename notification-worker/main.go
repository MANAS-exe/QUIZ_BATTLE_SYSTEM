package main

// notification-worker — Firebase Cloud Messaging dispatch service.
//
// Wires together three subsystems:
//   1. NotificationConsumer       — RabbitMQ consumer for notification.* events
//   2. MatchFinishedConsumer      — RabbitMQ consumer for match.finished (referral conversion)
//   3. Scheduler                  — Cron jobs (streak warning, daily reward, premium expiry)
//
// Required environment variables:
//   FIREBASE_CREDENTIALS_JSON    — Raw JSON content of a Firebase service-account key
//   RABBITMQ_URL                 — AMQP connection string (default: amqp://guest:guest@localhost:5672/)
//   MONGO_URI                    — MongoDB connection string (default: mongodb://localhost:27017)
//
// See docs/push-notifications.md for setup instructions.

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"quiz-battle/notification-worker/worker"
)

func main() {
	amqpURL := getEnv("RABBITMQ_URL", "amqp://guest:guest@localhost:5672/")
	mongoURI := getEnv("MONGO_URI", "mongodb://localhost:27017")
	credJSON := getEnv("FIREBASE_CREDENTIALS_JSON", "")

	if credJSON == "" {
		log.Fatal("❌ FIREBASE_CREDENTIALS_JSON is required — set it to the raw JSON of your Firebase service-account key")
	}

	// ── MongoDB ───────────────────────────────────────────────
	mongoClient, err := mongo.Connect(context.Background(), options.Client().ApplyURI(mongoURI))
	if err != nil {
		log.Fatalf("❌ MongoDB connect: %v", err)
	}
	if err := mongoClient.Ping(context.Background(), nil); err != nil {
		log.Fatalf("❌ MongoDB ping: %v", err)
	}
	defer mongoClient.Disconnect(context.Background()) //nolint:errcheck
	log.Printf("✅ MongoDB connected: %s", mongoURI)

	db := mongoClient.Database("quizdb")

	// ── Firebase FCM ──────────────────────────────────────────
	fcm, err := worker.NewFCMSender([]byte(credJSON))
	if err != nil {
		log.Fatalf("❌ Firebase init: %v", err)
	}

	// ── RabbitMQ consumers ────────────────────────────────────
	notifConsumer, err := worker.NewNotificationConsumer(amqpURL, fcm, db)
	if err != nil {
		log.Fatalf("❌ NotificationConsumer: %v", err)
	}
	defer notifConsumer.Close()

	matchConsumer, err := worker.NewMatchFinishedNotificationConsumer(amqpURL, fcm, db)
	if err != nil {
		log.Fatalf("❌ MatchFinishedNotificationConsumer: %v", err)
	}
	defer matchConsumer.Close()

	// ── Scheduler ─────────────────────────────────────────────
	scheduler := worker.NewScheduler(fcm, db)
	scheduler.Start()
	defer scheduler.Stop()

	// ── Start consumers ───────────────────────────────────────
	ctx, cancel := context.WithCancel(context.Background())

	go func() {
		if err := notifConsumer.Start(ctx); err != nil {
			log.Printf("❌ NotificationConsumer stopped: %v", err)
		}
	}()

	go func() {
		if err := matchConsumer.Start(ctx); err != nil {
			log.Printf("❌ MatchFinishedNotificationConsumer stopped: %v", err)
		}
	}()

	log.Println("🚀 Notification worker running — waiting for events")

	// ── Graceful shutdown ─────────────────────────────────────
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("⏳ Shutting down notification worker...")
	cancel()
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
