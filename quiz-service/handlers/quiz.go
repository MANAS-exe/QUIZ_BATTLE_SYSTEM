package handlers

import (
	"context"
	"fmt"
	"log"
	"time"

	goredis "github.com/gomodule/redigo/redis"
	quiz "github.com/yourorg/quiz-battle/proto/quiz"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"

	"quiz-battle/quiz/rabbitmq"
)

// ─────────────────────────────────────────
// TYPES
// ─────────────────────────────────────────

// Question is the MongoDB document shape for the questions collection.
type Question struct {
	ID              primitive.ObjectID `bson:"_id"`
	Text            string             `bson:"text"`
	Options         []string           `bson:"options"`
	CorrectIndex    int                `bson:"correctIndex"`
	Difficulty      string             `bson:"difficulty"`
	Topic           string             `bson:"topic"`
	AvgResponseTime int                `bson:"avgResponseTimeMs"`
}

// ─────────────────────────────────────────
// QUIZ SERVICE — round orchestration
// ─────────────────────────────────────────

// BroadcastFn sends a GameEvent to all connected clients in the room.
// It is non-blocking: implementations should drop events for slow consumers.
type BroadcastFn func(event *quiz.GameEvent)

// QuizService drives round execution for a single room.
// Construct once and call RunRound for each round in sequence.
type QuizService struct {
	rdb       *goredis.Pool
	mongoDB   *mongo.Database
	publisher *rabbitmq.Publisher
}

func NewQuizService(rdb *goredis.Pool, mongoDB *mongo.Database, pub *rabbitmq.Publisher) *QuizService {
	return &QuizService{rdb: rdb, mongoDB: mongoDB, publisher: pub}
}

// RunRound executes one quiz round end-to-end:
//
//  1. Pops the next question ID from the Redis LIST  room:{id}:questions
//  2. Fetches the full question document from MongoDB
//  3. Broadcasts QuestionBroadcast to all connected clients via broadcast()
//  4. Runs a 30-second server-side countdown, emitting TimerSync every second
//  5. Exits early if all players have already answered
//  6. Publishes "round.completed" to RabbitMQ (triggers scoring + reveal)
//  7. If no questions remain, publishes "match.finished"
// RoundInfo holds data about a completed round for the caller to broadcast.
type RoundInfo struct {
	QuestionID        string
	CorrectIndex      int
	CorrectAnswerText string // the actual text of the correct option
}

func (s *QuizService) RunRound(
	ctx context.Context,
	roomID string,
	roundNum int,
	broadcast BroadcastFn,
	connectedCountFn func() int,
) (*RoundInfo, error) {
	conn := s.rdb.Get()
	defer conn.Close()

	// ── 1. Pop next question ID ────────────────────────────────────────────────
	questionsKey := fmt.Sprintf("room:%s:questions", roomID)
	questionID, err := goredis.String(conn.Do("LPOP", questionsKey))
	if err != nil {
		return nil, fmt.Errorf("pop question (room %s round %d): %w", roomID, roundNum, err)
	}

	// ── 2. Fetch question from MongoDB ─────────────────────────────────────────
	questionOID, err := primitive.ObjectIDFromHex(questionID)
	if err != nil {
		return nil, fmt.Errorf("invalid question ID %q: %w", questionID, err)
	}

	fetchCtx, fetchCancel := context.WithTimeout(ctx, 5*time.Second)
	defer fetchCancel()

	var q Question
	if err := s.mongoDB.Collection("questions").
		FindOne(fetchCtx, bson.M{"_id": questionOID}).Decode(&q); err != nil {
		return nil, fmt.Errorf("fetch question %s: %w", questionID, err)
	}

	// ── 3. Broadcast QuestionBroadcast ─────────────────────────────────────────
	const roundDuration = 30 * time.Second
	now := time.Now()
	deadline := now.Add(roundDuration)
	deadlineMs := deadline.UnixMilli()
	roundStartedAtMs := now.UnixMilli()

	startedAtKey := fmt.Sprintf("room:%s:round:%d:started_at", roomID, roundNum)
	if _, setErr := conn.Do("SET", startedAtKey, roundStartedAtMs, "EX", 30*60); setErr != nil {
		log.Printf("⚠️  Failed to store round start time room=%s round=%d: %v", roomID, roundNum, setErr)
	}

	broadcast(&quiz.GameEvent{
		Event: &quiz.GameEvent_Question{
			Question: &quiz.QuestionBroadcast{
				RoundNumber: int32(roundNum),
				Question: &quiz.Question{
					QuestionId:  questionID,
					Text:        q.Text,
					Options:     q.Options,
					Difficulty:  difficultyFromString(q.Difficulty),
					Topic:       q.Topic,
					TimeLimitMs: int32(roundDuration.Milliseconds()),
				},
				DeadlineMs: deadlineMs,
			},
		},
	})

	// ── 4 & 5. Server-side countdown — early-exit when all CONNECTED players answered
	// Use "submitted" key (written instantly by SubmitAnswer) not "answers" key
	// (written async by scoring consumer) to avoid latency in early-exit detection.
	answersKey := fmt.Sprintf("room:%s:submitted:%d", roomID, roundNum)

	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()
	timer := time.NewTimer(roundDuration)
	defer timer.Stop()

timerLoop:
	for {
		select {
		case <-ctx.Done():
			return nil, ctx.Err()

		case <-timer.C:
			break timerLoop

		case <-ticker.C:
			broadcast(&quiz.GameEvent{
				Event: &quiz.GameEvent_TimerSync{
					TimerSync: &quiz.TimerSync{
						RoundNumber:  int32(roundNum),
						ServerTimeMs: time.Now().UnixMilli(),
						DeadlineMs:   deadlineMs,
					},
				},
			})

			// Use active player count for early exit
			activeCount := int64(connectedCountFn())

			if activeCount <= 0 {
				log.Printf("⚡ No active players — skipping round %d", roundNum)
				break timerLoop
			}

			// Check BOTH submitted key (instant) and answers key (from scoring consumer)
			checkConn := s.rdb.Get()
			submitted, _ := goredis.Int64(checkConn.Do("HLEN", answersKey))
			scoredKey := fmt.Sprintf("room:%s:answers:%d", roomID, roundNum)
			scored, _ := goredis.Int64(checkConn.Do("HLEN", scoredKey))
			checkConn.Close()

			answered := submitted
			if scored > submitted {
				answered = scored // use whichever is higher
			}

			if answered >= activeCount {
				log.Printf("⚡ All %d active players answered (submitted=%d scored=%d) — advancing round %d", activeCount, submitted, scored, roundNum)
				break timerLoop
			}
		}
	}

	// ── 6. Round-completion dedup guard (SETNX) ───────────────────────────────
	// If the timer fires at the same moment as "all players answered", two
	// goroutines could both exit the loop and try to close the round. SETNX
	// ensures only the first one proceeds; the second sees key=1 and returns.
	{
		closedKey := fmt.Sprintf("room:%s:round:%d:closed", roomID, roundNum)
		guardConn := s.rdb.Get()
		n, setnxErr := goredis.Int(guardConn.Do("SETNX", closedKey, "1"))
		guardConn.Do("EXPIRE", closedKey, 30*60) //nolint:errcheck
		guardConn.Close()

		if setnxErr != nil || n == 0 {
			log.Printf("⚠️  room=%s round=%d already closed — duplicate completion ignored", roomID, roundNum)
			correctText := ""
			if q.CorrectIndex >= 0 && q.CorrectIndex < len(q.Options) {
				correctText = q.Options[q.CorrectIndex]
			}
			return &RoundInfo{
				QuestionID:        questionID,
				CorrectIndex:      q.CorrectIndex,
				CorrectAnswerText: correctText,
			}, nil
		}
	}

	// ── 7. Publish round.completed ─────────────────────────────────────────────
	if err := s.publisher.PublishRoundCompleted(
		roomID, roundNum, questionID, q.CorrectIndex, roundStartedAtMs,
	); err != nil {
		log.Printf("WARN publish round.completed room=%s round=%d: %v", roomID, roundNum, err)
	}

	// ── 8. Publish match.finished when no questions remain ─────────────────────
	remaining, err := goredis.Int64(conn.Do("LLEN", questionsKey))
	if err != nil {
		log.Printf("WARN check remaining questions room=%s: %v", roomID, err)
	}
	if remaining == 0 {
		if err := s.publisher.PublishMatchFinished(roomID, roundNum); err != nil {
			log.Printf("WARN publish match.finished room=%s: %v", roomID, err)
		}
	}

	correctText := ""
	if q.CorrectIndex >= 0 && q.CorrectIndex < len(q.Options) {
		correctText = q.Options[q.CorrectIndex]
	}

	return &RoundInfo{
		QuestionID:        questionID,
		CorrectIndex:      q.CorrectIndex,
		CorrectAnswerText: correctText,
	}, nil
}

func difficultyFromString(s string) quiz.Difficulty {
	switch s {
	case "easy":
		return quiz.Difficulty_EASY
	case "medium":
		return quiz.Difficulty_MEDIUM
	case "hard":
		return quiz.Difficulty_HARD
	default:
		return quiz.Difficulty_DIFFICULTY_UNSPECIFIED
	}
}
