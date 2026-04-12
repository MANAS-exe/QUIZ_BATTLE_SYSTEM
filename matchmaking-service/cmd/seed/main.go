// seed creates 6 test users in MongoDB with pre-hashed passwords.
// Run: go run ./cmd/seed [MONGO_URI]
//
// All test users have password: speakx123
// They span a range of ratings to exercise the matchmaking rating-based pool.
package main

import (
	"context"
	"log"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"golang.org/x/crypto/bcrypt"
)

type User struct {
	ID           primitive.ObjectID `bson:"_id,omitempty"`
	Username     string             `bson:"username"`
	PasswordHash string             `bson:"password_hash"`
	Rating       int                `bson:"rating"`
	CreatedAt    time.Time          `bson:"created_at"`
}

func main() {
	mongoURI := "mongodb://localhost:27017"
	if len(os.Args) > 1 {
		mongoURI = os.Args[1]
	}
	if v := os.Getenv("MONGO_URI"); v != "" {
		mongoURI = v
	}

	client, err := mongo.Connect(context.Background(), options.Client().ApplyURI(mongoURI))
	if err != nil {
		log.Fatalf("❌ MongoDB connect: %v", err)
	}
	defer client.Disconnect(context.Background()) //nolint:errcheck

	if err := client.Ping(context.Background(), nil); err != nil {
		log.Fatalf("❌ MongoDB ping: %v", err)
	}
	log.Printf("✅ Connected to MongoDB at %s", mongoURI)

	col := client.Database("quizdb").Collection("users")

	testUsers := []struct {
		username string
		rating   int
	}{
		{"alice", 1200},
		{"bob", 1050},
		{"charlie", 1380},
		{"diana", 975},
		{"evan", 1520},
		{"fiona", 890},
	}

	// Hash once — reuse the same hash for all test users (password: speakx123).
	hash, err := bcrypt.GenerateFromPassword([]byte("speakx123"), bcrypt.DefaultCost)
	if err != nil {
		log.Fatalf("❌ bcrypt: %v", err)
	}

	created, skipped := 0, 0
	for _, u := range testUsers {
		user := User{
			Username:     u.username,
			PasswordHash: string(hash),
			Rating:       u.rating,
			CreatedAt:    time.Now(),
		}

		_, err := col.InsertOne(context.Background(), user)
		if err != nil {
			// Duplicate username — unique index will reject it. That's fine on re-runs.
			if mongo.IsDuplicateKeyError(err) {
				log.Printf("⏭  Skipped %s (already exists)", u.username)
				skipped++
				continue
			}
			log.Printf("⚠️  Insert %s: %v", u.username, err)
			continue
		}
		log.Printf("✅ Created user: %-10s rating: %d", u.username, u.rating)
		created++
	}

	log.Printf("\n── Seed summary ──────────────")
	log.Printf("  Created : %d", created)
	log.Printf("  Skipped : %d (already existed)", skipped)
	log.Printf("  Password: speakx123  (all test users)")

	// Verify counts
	total, _ := col.CountDocuments(context.Background(), bson.M{})
	log.Printf("  Total users in DB: %d", total)
}
