package handlers

import (
	"context"
	"encoding/json"
	"log"
	"net/http"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// LeaderboardEntry is one row in the global leaderboard.
type LeaderboardEntry struct {
	Rank     int    `json:"rank"`
	UserID   string `json:"user_id"`
	Username string `json:"username"`
	Rating   int    `json:"rating"`
}

// leaderboardUserDoc is the MongoDB projection — only fields we need.
type leaderboardUserDoc struct {
	ID       primitive.ObjectID `bson:"_id"`
	Username string             `bson:"username"`
	Rating   int                `bson:"rating"`
}

// LeaderboardHTTPHandler serves GET /leaderboard.
type LeaderboardHTTPHandler struct {
	users *mongo.Collection
}

func NewLeaderboardHTTPHandler(mongoDB *mongo.Database) *LeaderboardHTTPHandler {
	return &LeaderboardHTTPHandler{users: mongoDB.Collection("users")}
}

// ServeHTTP handles GET /leaderboard
// Returns top 50 players sorted by rating descending.
func (h *LeaderboardHTTPHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Content-Type", "application/json")

	if r.Method == http.MethodOptions {
		w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 5000000000) // 5s
	defer cancel()

	opts := options.Find().
		SetSort(bson.D{{Key: "rating", Value: -1}}).
		SetLimit(50).
		SetProjection(bson.M{"_id": 1, "username": 1, "rating": 1})

	cursor, err := h.users.Find(ctx, bson.M{}, opts)
	if err != nil {
		log.Printf("❌ leaderboard query: %v", err)
		http.Error(w, "database error", http.StatusInternalServerError)
		return
	}
	defer cursor.Close(ctx) //nolint:errcheck

	var entries []LeaderboardEntry
	rank := 1
	for cursor.Next(ctx) {
		var doc leaderboardUserDoc
		if err := cursor.Decode(&doc); err != nil {
			continue
		}
		entries = append(entries, LeaderboardEntry{
			Rank:     rank,
			UserID:   doc.ID.Hex(),
			Username: doc.Username,
			Rating:   doc.Rating,
		})
		rank++
	}

	if entries == nil {
		entries = []LeaderboardEntry{}
	}

	json.NewEncoder(w).Encode(entries) //nolint:errcheck
}
