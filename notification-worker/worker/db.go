package worker

// db.go — MongoDB helpers for the notification worker.
//
// Provides lean queries for:
//   - Device token lookup (by user_id)
//   - User info lookup (referred_by, username)
//   - Match history lookup (players by room_id)
//   - Active subscription lookup (for premium expiry scheduler)
//   - Bulk token fetch (for scheduler multicast)

import (
	"context"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// ── Device tokens ─────────────────────────────────────────────────────────

// DeviceToken mirrors the document stored in the device_tokens collection.
type DeviceToken struct {
	UserID    string    `bson:"user_id"`
	Token     string    `bson:"token"`
	Platform  string    `bson:"platform"` // "android" | "ios"
	UpdatedAt time.Time `bson:"updated_at"`
}

// GetToken returns the most recently updated FCM token for a user.
// Returns ("", nil) if the user has no registered token.
func GetToken(ctx context.Context, db *mongo.Database, userID string) (string, error) {
	var dt DeviceToken
	opts := options.FindOne().SetSort(bson.D{{Key: "updated_at", Value: -1}})
	err := db.Collection("device_tokens").FindOne(ctx, bson.M{"user_id": userID}, opts).Decode(&dt)
	if err == mongo.ErrNoDocuments {
		return "", nil
	}
	return dt.Token, err
}

// GetTokensForUsers returns a map of userID → FCM token for a slice of user IDs.
// Users with no registered token are absent from the returned map.
func GetTokensForUsers(ctx context.Context, db *mongo.Database, userIDs []string) (map[string]string, error) {
	cursor, err := db.Collection("device_tokens").Find(ctx, bson.M{"user_id": bson.M{"$in": userIDs}})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx) //nolint:errcheck

	result := make(map[string]string, len(userIDs))
	for cursor.Next(ctx) {
		var dt DeviceToken
		if err := cursor.Decode(&dt); err == nil {
			result[dt.UserID] = dt.Token
		}
	}
	return result, cursor.Err()
}

// GetAllTokens returns every FCM token currently in the device_tokens collection.
// Used by schedulers to broadcast notifications to all registered users.
func GetAllTokens(ctx context.Context, db *mongo.Database) ([]string, error) {
	cursor, err := db.Collection("device_tokens").Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx) //nolint:errcheck

	var tokens []string
	for cursor.Next(ctx) {
		var dt DeviceToken
		if err := cursor.Decode(&dt); err == nil && dt.Token != "" {
			tokens = append(tokens, dt.Token)
		}
	}
	return tokens, cursor.Err()
}

// ── User lookup ───────────────────────────────────────────────────────────

// UserInfo is the minimal projection used by the notification worker.
type UserInfo struct {
	ID                        primitive.ObjectID `bson:"_id"`
	Username                  string             `bson:"username"`
	ReferredBy                string             `bson:"referred_by"`
	RefereeFirstMatchNotified bool               `bson:"referee_first_match_notified"`
}

// GetUserInfo fetches notification-relevant fields for a single user.
func GetUserInfo(ctx context.Context, db *mongo.Database, userID string) (*UserInfo, error) {
	oid, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		return nil, err
	}
	opts := options.FindOne().SetProjection(bson.M{
		"username":                      1,
		"referred_by":                   1,
		"referee_first_match_notified":  1,
	})
	var u UserInfo
	err = db.Collection("users").FindOne(ctx, bson.M{"_id": oid}, opts).Decode(&u)
	if err != nil {
		return nil, err
	}
	return &u, nil
}

// MarkFirstMatchNotified atomically sets referee_first_match_notified = true so
// the referral-conversion notification is never sent twice.
func MarkFirstMatchNotified(ctx context.Context, db *mongo.Database, userID string) error {
	oid, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		return err
	}
	_, err = db.Collection("users").UpdateOne(ctx,
		bson.M{"_id": oid},
		bson.M{"$set": bson.M{"referee_first_match_notified": true}},
	)
	return err
}

// ── Match history lookup ──────────────────────────────────────────────────

// MatchPlayer is one entry in match_history.players.
type MatchPlayer struct {
	UserID   string `bson:"userId"`
	Username string `bson:"username"`
}

// GetMatchPlayers looks up the players who participated in a given room.
// Returns nil, nil if no match history exists for that room.
func GetMatchPlayers(ctx context.Context, db *mongo.Database, roomID string) ([]MatchPlayer, error) {
	var doc struct {
		Players []MatchPlayer `bson:"players"`
	}
	opts := options.FindOne().SetProjection(bson.M{"players": 1})
	err := db.Collection("match_history").FindOne(ctx, bson.M{"roomId": roomID}, opts).Decode(&doc)
	if err == mongo.ErrNoDocuments {
		return nil, nil
	}
	return doc.Players, err
}

// ── Subscription lookup ───────────────────────────────────────────────────

// ExpiringSubscription holds user_id + expiry date for premium expiry notifications.
type ExpiringSubscription struct {
	UserID    string     `bson:"user_id"`
	ExpiresAt *time.Time `bson:"expires_at"`
}

// GetSubscriptionsExpiringSoon returns active subscriptions expiring within the
// given window [from, to]. Used by the premium-expiry cron scheduler.
func GetSubscriptionsExpiringSoon(ctx context.Context, db *mongo.Database, from, to time.Time) ([]ExpiringSubscription, error) {
	cursor, err := db.Collection("subscriptions").Find(ctx, bson.M{
		"status":     "active",
		"expires_at": bson.M{"$gte": from, "$lte": to},
	}, options.Find().SetProjection(bson.M{"user_id": 1, "expires_at": 1}))
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx) //nolint:errcheck

	var subs []ExpiringSubscription
	if err := cursor.All(ctx, &subs); err != nil {
		return nil, err
	}
	return subs, nil
}
