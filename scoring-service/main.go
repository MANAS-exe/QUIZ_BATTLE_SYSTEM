package main

import (
	"context"
	"log"
	"net"
	"os"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"quiz-battle/scoring/handlers"
	"quiz-battle/scoring/rabbitmq"
	rdb "quiz-battle/scoring/redis"
	"quiz-battle/shared/middleware"
)

func main() {
	grpcAddr := getEnv("GRPC_ADDR", ":50053")
	redisAddr := getEnv("REDIS_ADDR", "localhost:6379")
	amqpURL := getEnv("RABBITMQ_URL", "amqp://guest:guest@localhost:5672/")
	mongoURI := getEnv("MONGO_URI", "mongodb://localhost:27017")

	// ── Redis ─────────────────────────────────────────────────
	redisPool := rdb.NewPool(redisAddr)
	defer redisPool.Close()

	conn := redisPool.Get()
	if _, err := conn.Do("PING"); err != nil {
		log.Fatalf("❌ Cannot connect to Redis at %s: %v", redisAddr, err)
	}
	conn.Close()
	log.Printf("✅ Redis connected: %s", redisAddr)

	// ── MongoDB ───────────────────────────────────────────────
	mongoClient, err := mongo.Connect(context.Background(), options.Client().ApplyURI(mongoURI))
	if err != nil {
		log.Fatalf("❌ Cannot connect to MongoDB at %s: %v", mongoURI, err)
	}
	defer mongoClient.Disconnect(context.Background()) //nolint:errcheck
	log.Printf("✅ MongoDB connected: %s", mongoURI)

	mongoDB := mongoClient.Database("quizdb")

	// ── gRPC server ───────────────────────────────────────────
	lis, err := net.Listen("tcp", grpcAddr)
	if err != nil {
		log.Fatalf("❌ Failed to listen on %s: %v", grpcAddr, err)
	}

	grpcServer := grpc.NewServer(
		grpc.UnaryInterceptor(middleware.AuthUnaryInterceptor),
		grpc.StreamInterceptor(middleware.AuthStreamInterceptor),
	)

	// Register scoring handler
	scoringHandler := handlers.NewScoringHandler(redisPool, mongoDB)
	scoringHandler.Register(grpcServer)

	reflection.Register(grpcServer)

	// ── Answer consumer ───────────────────────────────────────
	consumer, err := rabbitmq.NewConsumer(amqpURL, redisPool, mongoDB)
	if err != nil {
		log.Fatalf("❌ Cannot start answer consumer: %v", err)
	}
	defer consumer.Close()

	go func() {
		if err := consumer.Start(context.Background()); err != nil {
			log.Printf("❌ Consumer stopped: %v", err)
		}
	}()

	// ── Match-finished consumer ───────────────────────────────
	// Declares match-finished-queue (bound to match.finished routing key).
	// Logs match completion events and is the extension point for post-match
	// processing (rating recalculation, push notifications, etc.).
	matchConsumer, err := rabbitmq.NewMatchFinishedConsumer(amqpURL)
	if err != nil {
		log.Fatalf("❌ Cannot start match-finished consumer: %v", err)
	}
	defer matchConsumer.Close()

	go func() {
		if err := matchConsumer.Start(context.Background()); err != nil {
			log.Printf("❌ Match-finished consumer stopped: %v", err)
		}
	}()

	// ── Analytics consumer ────────────────────────────────────
	// Declares match-analytics-queue (also bound to match.finished). Receives
	// an independent copy of each match.finished event for analytics logging.
	analyticsConsumer, err := rabbitmq.NewAnalyticsConsumer(amqpURL)
	if err != nil {
		log.Fatalf("❌ Cannot start analytics consumer: %v", err)
	}
	defer analyticsConsumer.Close()

	go func() {
		if err := analyticsConsumer.Start(context.Background()); err != nil {
			log.Printf("❌ Analytics consumer stopped: %v", err)
		}
	}()

	log.Printf("🚀 Scoring gRPC server listening on %s", grpcAddr)
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("❌ gRPC server error: %v", err)
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
