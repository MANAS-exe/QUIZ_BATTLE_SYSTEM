package questions

import (
	"context"
	"fmt"
	"math"
	"math/rand/v2"
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

// SelectForRoom picks unique questions from MongoDB and stores them in Redis.
//
// Strategy:
//  1. Load all question IDs seen by these players in previous matches (to avoid
//     cross-match repeats).
//  2. For each difficulty bucket (40% easy, 40% medium, 20% hard), fetch ALL
//     eligible IDs from Mongo and shuffle in Go — this guarantees zero intra-match
//     duplicates (MongoDB $sample is documented to repeat docs on small collections).
//  3. Each bucket excludes both previously-seen IDs AND IDs already picked by
//     earlier buckets, so there is no way for the same question to appear twice.
//  4. If the pool is too small to fill a bucket, the fill step draws from any
//     difficulty as a fallback.
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
		// Exclude both cross-match seen IDs AND IDs already picked this match.
		excluded := append(seenIDs, questionIDs...)
		ids, err := sampleQuestions(ctx, db, p.difficulty, p.n, excluded)
		if err != nil {
			return nil, fmt.Errorf("sample %s questions: %w", p.difficulty, err)
		}
		questionIDs = append(questionIDs, ids...)
	}

	// Safety-net deduplicate (should be a no-op with the above logic).
	questionIDs = deduplicate(questionIDs)

	// Fill remaining slots if any bucket came up short (small pool).
	if len(questionIDs) < count {
		remaining := count - len(questionIDs)
		fillIDs, err := sampleQuestions(ctx, db, "", remaining, questionIDs)
		if err == nil && len(fillIDs) > 0 {
			questionIDs = append(questionIDs, fillIDs...)
			questionIDs = deduplicate(questionIDs)
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

// sampleQuestions fetches ALL eligible question IDs from MongoDB matching the
// given difficulty (empty = any), excludes seenIDs, then shuffles the result
// in Go and returns the first n.
//
// WHY not $sample:
//   MongoDB's $sample pipeline stage can return duplicate documents when the
//   requested size is more than ~5% of the collection (it falls back to a
//   random in-memory scan that re-visits documents). For a quiz with a small
//   question bank this caused the same question to appear multiple times in
//   one match. Fetching all IDs and shuffling in Go is O(pool) but guarantees
//   strict uniqueness regardless of collection size.
func sampleQuestions(ctx context.Context, db *mongo.Database, difficulty string, n int, seenIDs []string) ([]string, error) {
	if n <= 0 {
		return nil, nil
	}

	col := db.Collection("questions")

	filter := bson.M{}
	if difficulty != "" {
		filter["difficulty"] = difficulty
	}
	if len(seenIDs) > 0 {
		excludeOIDs := make([]primitive.ObjectID, 0, len(seenIDs))
		for _, sid := range seenIDs {
			if oid, err := primitive.ObjectIDFromHex(sid); err == nil {
				excludeOIDs = append(excludeOIDs, oid)
			}
		}
		if len(excludeOIDs) > 0 {
			filter["_id"] = bson.M{"$nin": excludeOIDs}
		}
	}

	// Fetch only _id — minimal data transfer.
	cursor, err := col.Find(ctx, filter, options.Find().SetProjection(bson.M{"_id": 1}))
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx) //nolint:errcheck

	var pool []string
	for cursor.Next(ctx) {
		var doc struct {
			ID primitive.ObjectID `bson:"_id"`
		}
		if err := cursor.Decode(&doc); err != nil {
			continue
		}
		pool = append(pool, doc.ID.Hex())
	}
	if err := cursor.Err(); err != nil {
		return nil, err
	}

	if len(pool) == 0 {
		return nil, nil
	}

	// Fisher-Yates shuffle — cryptographically seeded by math/rand/v2 default source.
	rand.Shuffle(len(pool), func(i, j int) { pool[i], pool[j] = pool[j], pool[i] })

	if n > len(pool) {
		n = len(pool)
	}
	return pool[:n], nil
}

func deduplicate(ids []string) []string {
	seen := make(map[string]struct{}, len(ids))
	out := make([]string, 0, len(ids))
	for _, id := range ids {
		if _, ok := seen[id]; !ok {
			seen[id] = struct{}{}
			out = append(out, id)
		}
	}
	return out
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
