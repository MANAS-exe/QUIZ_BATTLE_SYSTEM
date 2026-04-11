package questions

import (
	"context"
	"fmt"
	"math"
	"time"

	goredis "github.com/gomodule/redigo/redis"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type MatchHistory struct {
	RoundQuestions []string `bson:"questionIds"`
}

// SelectForRoom samples questions from MongoDB (avoiding previously seen ones)
// and stores the ordered list in Redis under room:{id}:questions.
func SelectForRoom(pool *goredis.Pool, db *mongo.Database, roomID string, players []string, count int) ([]string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	seenIDs, err := fetchSeenQuestionIDs(ctx, db, players)
	if err != nil {
		return nil, fmt.Errorf("fetch seen questions: %w", err)
	}

	easy := int(math.Round(float64(count) * 0.40))
	medium := int(math.Round(float64(count) * 0.40))
	hard := count - easy - medium

	type pick struct {
		difficulty string
		n          int
	}
	picks := []pick{
		{"easy", easy},
		{"medium", medium},
		{"hard", hard},
	}

	var questionIDs []string
	for _, p := range picks {
		ids, err := sampleQuestions(ctx, db, p.difficulty, p.n, seenIDs)
		if err != nil {
			return nil, fmt.Errorf("sample %s questions: %w", p.difficulty, err)
		}
		questionIDs = append(questionIDs, ids...)
	}

	// If not enough unseen questions, fill remaining slots by allowing repeats
	if len(questionIDs) < count {
		remaining := count - len(questionIDs)
		fillIDs, err := sampleQuestions(ctx, db, "", remaining, nil)
		if err == nil && len(fillIDs) > 0 {
			questionIDs = append(questionIDs, fillIDs...)
		}
	}

	if len(questionIDs) == 0 {
		return nil, fmt.Errorf("no questions returned — check your questions collection")
	}

	if err := storeInRedis(pool, roomID, questionIDs); err != nil {
		return nil, fmt.Errorf("redis store: %w", err)
	}

	return questionIDs, nil
}

func fetchSeenQuestionIDs(ctx context.Context, db *mongo.Database, players []string) ([]string, error) {
	col := db.Collection("match_history")
	filter := bson.M{"players.userId": bson.M{"$in": players}}
	findOpts := options.Find().SetProjection(bson.M{"questionIds": 1, "_id": 0})

	cursor, err := col.Find(ctx, filter, findOpts)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx) //nolint:errcheck

	seen := make(map[string]struct{})
	for cursor.Next(ctx) {
		var h MatchHistory
		if err := cursor.Decode(&h); err != nil {
			continue
		}
		for _, id := range h.RoundQuestions {
			seen[id] = struct{}{}
		}
	}
	if err := cursor.Err(); err != nil {
		return nil, err
	}

	seenSlice := make([]string, 0, len(seen))
	for id := range seen {
		seenSlice = append(seenSlice, id)
	}
	return seenSlice, nil
}

func sampleQuestions(ctx context.Context, db *mongo.Database, difficulty string, n int, seenIDs []string) ([]string, error) {
	if n <= 0 {
		return nil, nil
	}

	col := db.Collection("questions")

	matchFilter := bson.M{}
	if difficulty != "" {
		matchFilter["difficulty"] = difficulty
	}
	if len(seenIDs) > 0 {
		excludeIDs := make([]primitive.ObjectID, 0, len(seenIDs))
		for _, sid := range seenIDs {
			oid, err := primitive.ObjectIDFromHex(sid)
			if err == nil {
				excludeIDs = append(excludeIDs, oid)
			}
		}
		matchFilter["_id"] = bson.M{"$nin": excludeIDs}
	}

	pipeline := mongo.Pipeline{
		{{Key: "$match", Value: matchFilter}},
		{{Key: "$sample", Value: bson.M{"size": n}}},
		{{Key: "$project", Value: bson.M{"_id": 1}}},
	}

	cursor, err := col.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx) //nolint:errcheck

	var ids []string
	for cursor.Next(ctx) {
		var result struct {
			ID primitive.ObjectID `bson:"_id"`
		}
		if err := cursor.Decode(&result); err != nil {
			continue
		}
		ids = append(ids, result.ID.Hex())
	}
	if err := cursor.Err(); err != nil {
		return nil, err
	}
	return ids, nil
}

func storeInRedis(pool *goredis.Pool, roomID string, questionIDs []string) error {
	conn := pool.Get()
	defer conn.Close()

	key := fmt.Sprintf("room:%s:questions", roomID)

	if err := conn.Send("DEL", key); err != nil {
		return err
	}

	rpushArgs := make([]interface{}, 0, len(questionIDs)+1)
	rpushArgs = append(rpushArgs, key)
	for _, id := range questionIDs {
		rpushArgs = append(rpushArgs, id)
	}
	if err := conn.Send("RPUSH", rpushArgs...); err != nil {
		return err
	}

	if err := conn.Send("EXPIRE", key, 30*60); err != nil {
		return err
	}

	if err := conn.Flush(); err != nil {
		return err
	}

	for i := 0; i < 3; i++ {
		if _, err := conn.Receive(); err != nil {
			return err
		}
	}
	return nil
}
