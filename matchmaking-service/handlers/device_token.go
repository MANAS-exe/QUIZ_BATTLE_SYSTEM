package handlers

// device_token.go — POST /device/token
//
// Registers or updates the FCM device token for the authenticated user.
// Called by the Flutter app after login and whenever the FCM token refreshes.
//
// The token is stored (upserted) in the device_tokens collection:
//   { user_id, token, platform, updated_at }
//
// One token per user — a new registration overwrites the previous one.
// Multi-device support can be added later by indexing (user_id, token) instead.

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"quiz-battle/shared/auth"
)

// DeviceTokenHandler handles FCM token registration.
type DeviceTokenHandler struct {
	tokens *mongo.Collection
}

func NewDeviceTokenHandler(db *mongo.Database) *DeviceTokenHandler {
	return &DeviceTokenHandler{tokens: db.Collection("device_tokens")}
}

// ServeHTTP handles POST /device/token.
// Body: { "token": "<fcm_token>", "platform": "android" | "ios" }
func (h *DeviceTokenHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Extract JWT
	authHeader := r.Header.Get("Authorization")
	if len(authHeader) < 8 || authHeader[:7] != "Bearer " {
		http.Error(w, "missing Authorization header", http.StatusUnauthorized)
		return
	}
	userID, _, err := auth.ValidateToken(authHeader[7:])
	if err != nil {
		http.Error(w, "invalid token", http.StatusUnauthorized)
		return
	}

	var body struct {
		Token    string `json:"token"`
		Platform string `json:"platform"` // "android" | "ios"
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil || body.Token == "" {
		http.Error(w, "token is required", http.StatusBadRequest)
		return
	}
	if body.Platform == "" {
		body.Platform = "android"
	}

	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	// Upsert: one token per user (last write wins)
	_, err = h.tokens.UpdateOne(ctx,
		bson.M{"user_id": userID},
		bson.M{"$set": bson.M{
			"user_id":    userID,
			"token":      body.Token,
			"platform":   body.Platform,
			"updated_at": time.Now(),
		}},
		options.Update().SetUpsert(true),
	)
	if err != nil {
		log.Printf("⚠️  DeviceToken: upsert failed for user %s: %v", userID, err)
		http.Error(w, "database error", http.StatusInternalServerError)
		return
	}

	log.Printf("📱 Device token registered — user: %s platform: %s", userID, body.Platform)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]any{"success": true}) //nolint:errcheck
}
