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

	"quiz-battle/quiz/handlers"
	"quiz-battle/quiz/rabbitmq"
	rdb "quiz-battle/quiz/redis"
	"quiz-battle/shared/middleware"
)

func main() {
	grpcAddr := getEnv("GRPC_ADDR", ":50052")
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

	// ── RabbitMQ Publisher ────────────────────────────────────
	publisher, err := rabbitmq.NewPublisher(amqpURL)
	if err != nil {
		log.Fatalf("❌ Cannot connect to RabbitMQ at %s: %v", amqpURL, err)
	}
	defer publisher.Close()
	log.Printf("✅ RabbitMQ publisher connected: %s", amqpURL)

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

	// Register quiz handler
	quizHandler := handlers.NewQuizServiceHandler(redisPool, mongoDB, publisher)
	quizHandler.Register(grpcServer)

	reflection.Register(grpcServer)

	// ── Match.created consumer ────────────────────────────────
	// Consumes match.created events from matchmaking-service to select questions.
	matchConsumer, err := rabbitmq.NewMatchConsumer(amqpURL, redisPool, mongoDB)
	if err != nil {
		log.Fatalf("❌ Cannot start match consumer: %v", err)
	}
	defer matchConsumer.Close()

	go func() {
		if err := matchConsumer.Start(context.Background()); err != nil {
			log.Printf("❌ Match consumer stopped: %v", err)
		}
	}()

	log.Printf("🚀 Quiz gRPC server listening on %s", grpcAddr)
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
