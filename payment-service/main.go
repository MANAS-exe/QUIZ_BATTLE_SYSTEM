package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"quiz-battle/payment/handlers"
)

func main() {
	port := getEnv("PORT", ":8081")
	mongoURI := getEnv("MONGO_URI", "mongodb://localhost:27017")

	// ── MongoDB ───────────────────────────────────────────────
	mongoClient, err := mongo.Connect(context.Background(), options.Client().ApplyURI(mongoURI))
	if err != nil {
		log.Fatalf("❌ Cannot connect to MongoDB at %s: %v", mongoURI, err)
	}
	defer mongoClient.Disconnect(context.Background()) //nolint:errcheck

	if err := mongoClient.Ping(context.Background(), nil); err != nil {
		log.Fatalf("❌ MongoDB ping failed: %v", err)
	}
	log.Printf("✅ MongoDB connected: %s", mongoURI)

	db := mongoClient.Database("quizdb")

	// ── Config ────────────────────────────────────────────────
	cfg := &handlers.Config{
		RazorpayKeyID:       getEnv("RAZORPAY_KEY_ID", ""),
		RazorpayKeySecret:   getEnv("RAZORPAY_KEY_SECRET", ""),
		RazorpayWebhookSecret: getEnv("RAZORPAY_WEBHOOK_SECRET", ""),
	}

	// ── Handlers ──────────────────────────────────────────────
	paymentHandler := handlers.NewPaymentHandler(db, cfg)
	webhookHandler := handlers.NewWebhookHandler(db, cfg)

	// ── Routes ────────────────────────────────────────────────
	mux := http.NewServeMux()
	mux.HandleFunc("/payment/create-order", withCORS(paymentHandler.CreateOrder))
	mux.HandleFunc("/payment/validate-coupon", withCORS(paymentHandler.ValidateCoupon))
	mux.HandleFunc("/payment/verify", withCORS(paymentHandler.VerifyPayment))
	mux.HandleFunc("/payment/status", withCORS(paymentHandler.GetStatus))
	mux.HandleFunc("/payment/history", withCORS(paymentHandler.GetHistory))
	mux.HandleFunc("/payment/webhook", withCORS(webhookHandler.HandleWebhook)) // optional, for future use

	log.Printf("🚀 Payment service listening on %s", port)
	if err := http.ListenAndServe(port, mux); err != nil {
		log.Fatalf("❌ HTTP server error: %v", err)
	}
}

// withCORS wraps a handler to add CORS headers and handle OPTIONS preflight.
func withCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next(w, r)
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
