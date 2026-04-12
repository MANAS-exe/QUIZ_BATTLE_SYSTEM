# Quiz Battle — Architecture & Phase 1 Audit

## System Architecture

```
Flutter App
  ├── gRPC :50051 ──► Matchmaking Service   (Auth + Matchmaking)
  ├── gRPC :50052 ──► Quiz Engine Service   (Game loop + questions)
  └── gRPC :50053 ──► Scoring Service       (Leaderboard + stats)

RabbitMQ Exchange: sx (topic, durable)
  match.created      → quiz-match-created-queue     (Quiz Engine)
  answer.submitted   → answer-processing-queue      (Scoring Worker)
                     → answer-processing-dlq        (Dead letter)
  round.completed    → round-completed-queue        (Quiz Engine logging)
  match.finished     → match-finished-queue         (Scoring: persistence)
                     → match-analytics-queue        (Scoring: analytics stub)
```

---

## Services

| Service | Port | Binary | Responsibilities |
|---------|------|--------|-----------------|
| Matchmaking | `:50051` | `matchmaking-service/main.go` | Register/Login, JoinMatchmaking, SubscribeToMatch |
| Quiz Engine | `:50052` | `quiz-service/main.go` | StreamGameEvents, SubmitAnswer, GetRoomQuestions |
| Scoring | `:50053` | `scoring-service/main.go` | CalculateScore, GetLeaderboard |

---

## Event Flow

```
1. Player registers/logs in → Matchmaking Service (JWT issued)
2. Player calls JoinMatchmaking → added to Redis sorted set (matchmaking:pool) keyed by rating
3. Pool reaches ≥2 players → tryCreateRoom acquires Redis lock → ZPOPMIN → CreateRoom
4. Room persisted to Redis (room:{id}:players, room:{id}:state) with 30-min TTL
5. Matchmaking publishes match.created → RabbitMQ
6. Quiz Engine consumes match.created → SelectForRoom → stores question IDs in room:{id}:questions
7. Players call StreamGameEvents → first subscriber triggers game loop (sync.Once)
8. Game loop: RunRound × totalRounds
   a. LPOP next question from room:{id}:questions
   b. Broadcast QuestionBroadcast event to all subscribers
   c. 30-second countdown (TimerSync every second)
   d. SETNX room:{id}:round:{n}:closed — only first goroutine proceeds (dedup guard)
   e. Publish round.completed → RabbitMQ
   f. Wait 2s for scoring consumer to process answers
   g. Broadcast RoundResult + LeaderboardUpdate
9. SubmitAnswer → HSETNX room:{id}:submitted:{round} (idempotency) → publish answer.submitted
10. Scoring Worker consumes answer.submitted → validates vs MongoDB → Lua atomic UpdateScore
11. After all rounds → publish match.finished → broadcast MatchEnd
12. saveMatchHistory writes full document to MongoDB match_history collection
```

---

## Redis Key Ownership

| Service | Keys | TTL |
|---------|------|-----|
| Matchmaking | `matchmaking:pool`, `player:{id}`, `room:{id}:state`, `room:{id}:players`, `room:lock:{id}` | 30 min |
| Quiz Engine | `room:{id}:questions`, `room:{id}:submitted:{round}`, `room:{id}:round:{n}:started_at`, `room:{id}:round:{n}:closed` | 30 min |
| Scoring | `room:{id}:leaderboard`, `room:{id}:answers:{round}`, `room:{id}:correct_counts`, `room:{id}:response_sum`, `room:{id}:response_count` | 30 min |

---

## Key Concurrency Guarantees

### Matchmaking race (ZPOPMIN)
Matchmaking acquires a Redis distributed lock (`SETNX` with UUID token, released via Lua compare-and-delete) before ZPOPMIN. Prevents two goroutines from popping the same players simultaneously.

### Double round completion (SETNX guard)
```
SETNX room:{id}:round:{n}:closed "1" EX 1800
```
If the round timer fires at the same moment as "all players answered", only the first goroutine to set this key proceeds to publish `round.completed`. The second sees `n=0` and returns early.

### Idempotent answer submission
`HSETNX room:{id}:submitted:{round} {userId} {answerIndex}` — if the key already exists the answer is dropped silently. The scoring consumer performs a second `HEXISTS` check on `room:{id}:answers:{round}` before updating the leaderboard.

### Atomic leaderboard update (Lua script)
```lua
redis.call('ZINCRBY', key, points, member)
redis.call('EXPIRE', key, 1800)
local rank = redis.call('ZREVRANK', key, member)
return rank
```
All three operations execute atomically in a single Redis server round-trip.

---

## RabbitMQ Queues

| Queue | Routing Key | Service | What It Does |
|-------|-------------|---------|-------------|
| `quiz-match-created-queue` | `match.created` | Quiz Engine | SelectForRoom — pre-loads questions into Redis |
| `answer-processing-queue` | `answer.submitted` | Scoring Worker | Validates answer, updates leaderboard atomically |
| `answer-processing-dlq` | dead letter | — | Failed answer events after 3 retries land here |
| `round-completed-queue` | `round.completed` | Quiz Engine | Queue binding + observability logging |
| `match-finished-queue` | `match.finished` | Scoring Worker | Post-match processing hook |
| `match-analytics-queue` | `match.finished` | Analytics Stub | Logs match analytics to stdout |

All queues are durable (`durable=true`) and survive RabbitMQ restarts.
The `answer-processing-queue` uses dead-letter routing: after 3 failed attempts the message is NACK'd to `answer-processing-dlq`.

---

## MongoDB Collections

### users
```json
{
  "_id": ObjectId,
  "username": "string (unique index)",
  "password_hash": "bcrypt string",
  "rating": 1000,
  "created_at": ISODate
}
```

### questions
```json
{
  "_id": ObjectId,
  "question_id": "string",
  "text": "string",
  "options": ["A", "B", "C", "D"],
  "correctIndex": 0,
  "difficulty": "easy|medium|hard (indexed)",
  "topic": "string",
  "avgResponseTimeMs": 8000
}
```
30 questions seeded: 10 easy, 8 medium, 12 hard across 12 topics.

### match_history
```json
{
  "roomId": "string",
  "players": [{
    "userId": "string",
    "username": "string",
    "finalScore": 850,
    "rank": 1,
    "answersCorrect": 7,
    "avgResponseTimeMs": 4200
  }],
  "questionIds": ["hex", "hex"],
  "rounds": 10,
  "winner": "userId",
  "createdAt": ISODate,
  "durationMs": 345000
}
```
Written by `saveMatchHistory` at the end of every match (inline in game loop).
Used by question selection (`SelectForRoom`) to exclude previously-seen questions.

**Indexes:**
- `users.username` — UNIQUE
- `questions.difficulty` — for sampling by difficulty
- `match_history.players.userId` — for fetching seen questions per player

---

## Seed Data

### Questions (mongo-init/init.js)
- 30 questions, 3 difficulty levels, 12 topics
- Run: `make seed` (requires MongoDB container)

### Test Users (matchmaking-service/cmd/seed/main.go)
| Username | Password | Rating |
|----------|----------|--------|
| alice | speakx123 | 1200 |
| bob | speakx123 | 1050 |
| charlie | speakx123 | 1380 |
| diana | speakx123 | 975 |
| evan | speakx123 | 1520 |
| fiona | speakx123 | 890 |

Run: `make seed-users` (requires MongoDB running locally)

---

## Flutter Client

- **3 gRPC channels**: matchmaking (50051), quiz (50052), scoring (50053)
- **Auth**: JWT stored via SharedPreferences, sent as `Authorization: Bearer <token>` metadata
- **State**: Riverpod `StateNotifier` (`GameProvider`, `AuthNotifier`)
- **Reconnection**: `ReconnectService` wraps `StreamGameEvents` with exponential backoff (1s→2s→4s→8s→16s, max 5 retries)
- **Timer**: Server-driven via `TimerSync` events (uses `DeadlineMs` absolute timestamp, not local drift-prone timer)
- **Idempotent answers**: Double-tap guard via `_answerSubmitted` flag in `QuizScreen`

---

## Phase 1 Audit — All 16 Requirements

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| 1 | Flutter connected to real backend | ✅ | Real gRPC, no mock flags |
| 2 | 3 truly separate services | ✅ | Ports 50051/50052/50053, independent binaries |
| 3 | All RabbitMQ consumers functional | ✅ | All 6 queues declared and consuming |
| 4 | match_history persisted with full fields | ✅ | All fields including score, rank, avgResponseMs |
| 5 | Double round completion prevented | ✅ | SETNX `room:{id}:round:{n}:closed` guard |
| 6 | Reconnection with state recovery | ✅ | ReconnectService + exponential backoff |
| 7 | Leaderboard updates atomic | ✅ | Lua script: ZINCRBY + EXPIRE + ZREVRANK |
| 8 | Zombie room cleanup (TTLs) | ✅ | All room keys EXPIRE 1800s |
| 9 | Timer sync server→client | ✅ | TimerSync every 1s with DeadlineMs |
| 10 | Idempotent answer processing | ✅ | HSETNX + HEXISTS double guard |
| 11 | PlayerJoined event broadcast | ✅ | Broadcast on StreamGameEvents subscription |
| 12 | Late joiner / mid-match join | ⚠️  | Gets current stream events; last_seen_round proto field unused |
| 13 | Proper error handling | ✅ | gRPC status codes, ACK/NACK, try/catch in Flutter |
| 14 | All proto RPCs implemented | ✅ | Register, Login, Join/Leave/Subscribe, Stream/Submit/GetQuestions, Score/GetLeaderboard |
| 15 | Docker includes all services | ✅ | mongo + redis (--appendonly yes) + rabbitmq + 3 Go services, all with healthchecks |
| 16 | Comprehensive seed data | ✅ | 30 questions + 6 test users (make seed + make seed-users) |

**Known limitation (item 12):** The `last_seen_round` field in `StreamRequest` proto is not used server-side to replay missed events. A reconnecting client gets the live stream from reconnection point but does not receive replayed past questions. This is acceptable for the demo and documented here as a Phase 2 improvement.

---

## Phase 2 Additions

### Payment Service (Razorpay)

A fourth microservice handles premium subscriptions via Razorpay.

| Endpoint | Auth | What it does |
|----------|------|-------------|
| `POST /payment/create-order` | JWT | Creates Razorpay order, saves pending record in MongoDB |
| `POST /payment/verify` | JWT | HMAC-SHA256 verifies signature, activates subscription |
| `GET /payment/status` | JWT | Returns `{ is_active, plan, expires_at }` |
| `GET /payment/history` | JWT | Lists past payments |

**Signature verification (no webhook required):**
```
HMAC-SHA256(key_secret, order_id + "|" + payment_id) == razorpay_signature
```

**Plans:** Monthly ₹499 (30 days) · Yearly ₹3,999 (365 days)

**Port:** `:8081` — Flutter uses `http://10.0.2.2:8081` (Android emulator)

---

### Daily Quota

Free users: **5 games/day**. Counter is stored in SharedPreferences (`dq_used` + `dq_date`).

**Where it's consumed:** `matchmaking_screen.dart` → `_onMatchFound()` calls `authProvider.notifier.consumeDailyQuiz()` the moment a match is confirmed (not on queue entry, so failed matchmaking attempts don't burn the quota).

**Reset:** Date-based (`_today()` returns `YYYY-MM-DD`). On app start, if saved date ≠ today the counter resets to 0.

---

### Premium Sync Across Devices

`AuthNotifier._syncPremiumFromServer()` is called after every login. It hits `GET /payment/status` and overwrites the local SharedPreferences `isPremium` flag with the server's authoritative value. This ensures a premium user logging in on a new device immediately sees the correct plan.

---

### Win Streak (Speed Streak)

Tracked in `GameState` alongside answer streak:

| Field | Meaning |
|-------|---------|
| `currentAnswerStreak` | Consecutive rounds with any correct answer |
| `currentWinStreak` | Consecutive rounds where player was **correct AND fastest** |

Updated in `GameNotifier._onRoundResult()` using `RoundResultEvent.fastestUserId`.

Displayed in `leaderboard_screen.dart` (between-round screen) as a gold lightning-bolt badge just below the fire-streak badge. Requires ≥ 2 consecutive wins to appear.

---

### Results Screen — Action Buttons

Three buttons in `results_screen.dart`:
- **Share** — copies result text to clipboard
- **Home** — resets game state and navigates to `/home`
- **Play Again** — resets game state and navigates to `/matchmaking`

---

## Running the Project

```bash
# Start infrastructure
make infra

# Seed questions + test users
make seed
make seed-users

# Start all 3 services
make run-matchmaking   # terminal 1
make run-quiz          # terminal 2
make run-scoring       # terminal 3

# OR start everything with Docker
make up

# Run Flutter app
cd flutter-app && flutter run

# Run tests
make test
```
