package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	goredis "github.com/gomodule/redigo/redis"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	quiz "github.com/yourorg/quiz-battle/proto/quiz"
	rdb "quiz-battle/scoring/redis"
	"quiz-battle/shared/middleware"
)

// ScoringHandler implements quiz.ScoringServiceServer.
type ScoringHandler struct {
	quiz.UnimplementedScoringServiceServer
	redisPool *goredis.Pool
	mongoDB   *mongo.Database
}

func NewScoringHandler(pool *goredis.Pool, mongoDB *mongo.Database) *ScoringHandler {
	return &ScoringHandler{
		redisPool: pool,
		mongoDB:   mongoDB,
	}
}

func (h *ScoringHandler) Register(s *grpc.Server) {
	quiz.RegisterScoringServiceServer(s, h)
	log.Println("✅ ScoringService registered")
}

// ── CalculateScore ───────────────────────────────────────────
// Called internally or by other services. Currently scoring happens in the
// RabbitMQ consumer, but this RPC can be used for on-demand score queries.

func (h *ScoringHandler) CalculateScore(ctx context.Context, req *quiz.ScoreRequest) (*quiz.ScoreResponse, error) {
	if req.RoomId == "" || req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "room_id and user_id are required")
	}

	// Get current score and rank from leaderboard
	entries, err := rdb.GetLeaderboard(h.redisPool, req.RoomId)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "get leaderboard: %v", err)
	}

	var totalScore int32
	var rank int32
	for _, e := range entries {
		if e.UserID == req.UserId {
			totalScore = int32(e.Score)
			rank = int32(e.Rank)
			break
		}
	}

	return &quiz.ScoreResponse{
		TotalScore: totalScore,
		NewRank:    rank,
	}, nil
}

// ── GetLeaderboard ───────────────────────────────────────────

func (h *ScoringHandler) GetLeaderboard(ctx context.Context, req *quiz.LeaderboardRequest) (*quiz.LeaderboardResponse, error) {
	if req.RoomId == "" {
		return nil, status.Error(codes.InvalidArgument, "room_id is required")
	}

	scores, err := h.buildPlayerScores(req.RoomId)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "build scores: %v", err)
	}

	// ── Leaderboard cap for free users ───────────────────────
	// Free users see only top 3 + their own entry.
	// Premium users see the full leaderboard.
	userID := middleware.UserIDFromContext(ctx)
	if userID != "" && !h.isPremium(ctx, userID) && len(scores) > 3 {
		capped := scores[:3]
		// Append the calling user's entry if not already in top 3
		for _, s := range scores[3:] {
			if s.UserId == userID {
				capped = append(capped, s)
				break
			}
		}
		scores = capped
	}

	return &quiz.LeaderboardResponse{
		RoomId: req.RoomId,
		Scores: scores,
	}, nil
}

// isPremium checks if a user has an active premium subscription.
func (h *ScoringHandler) isPremium(ctx context.Context, userID string) bool {
	if h.mongoDB == nil {
		return false
	}
	subsColl := h.mongoDB.Collection("subscriptions")
	count, err := subsColl.CountDocuments(ctx, bson.M{
		"user_id":    userID,
		"status":     "active",
		"expires_at": bson.M{"$gt": time.Now()},
	})
	if err != nil {
		log.Printf("⚠️  isPremium check failed for user %s: %v", userID, err)
		return false // fail open — show full leaderboard
	}
	return count > 0
}

// buildPlayerScores fetches leaderboard + player metadata from Redis.
func (h *ScoringHandler) buildPlayerScores(roomID string) ([]*quiz.PlayerScore, error) {
	entries, err := rdb.GetLeaderboard(h.redisPool, roomID)
	if err != nil {
		return nil, err
	}

	userIDs := make([]string, len(entries))
	for i, e := range entries {
		userIDs[i] = e.UserID
	}

	usernames, correctCounts, avgResponseMs, err := rdb.GetPlayerMeta(h.redisPool, roomID, userIDs)
	if err != nil {
		log.Printf("⚠️  GetPlayerMeta room=%s: %v", roomID, err)
		usernames = map[string]string{}
		correctCounts = map[string]int{}
		avgResponseMs = map[string]int{}
	}

	scores := make([]*quiz.PlayerScore, len(entries))
	for i, e := range entries {
		scores[i] = &quiz.PlayerScore{
			UserId:         e.UserID,
			Username:       usernames[e.UserID],
			Score:          int32(e.Score),
			Rank:           int32(e.Rank),
			AnswersCorrect: int32(correctCounts[e.UserID]),
			AvgResponseMs:  int32(avgResponseMs[e.UserID]),
		}
	}
	return scores, nil
}

// playerJSON is used to extract username from Redis room player data.
type playerJSON struct {
	Username string `json:"username"`
}

// getUsernameFromRedis fetches a player's username from the room players hash.
func (h *ScoringHandler) getUsernameFromRedis(conn goredis.Conn, roomID, userID string) string {
	playersKey := fmt.Sprintf("room:%s:players", roomID)
	raw, err := goredis.Bytes(conn.Do("HGET", playersKey, userID))
	if err != nil || len(raw) == 0 {
		return userID
	}
	var p playerJSON
	if jsonErr := json.Unmarshal(raw, &p); jsonErr == nil && p.Username != "" {
		return p.Username
	}
	return userID
}
