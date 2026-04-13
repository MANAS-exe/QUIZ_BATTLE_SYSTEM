# Quiz Battle — Architecture & Audit

## System Architecture

```
Flutter App
  ├── gRPC :50051 ──► Matchmaking Service   (Auth + Matchmaking + Referral)
  ├── gRPC :50052 ──► Quiz Engine Service   (Game loop + questions)
  ├── gRPC :50053 ──► Scoring Service       (Leaderboard + stats)
  ├── HTTP :8081  ──► Payment Service       (Razorpay + subscriptions)
  └── FCM  ◄──────── Notification Worker    (Push notifications)

RabbitMQ Exchange: sx (topic, durable)
  match.created      → quiz-match-created-queue     (Quiz Engine)
  answer.submitted   → answer-processing-queue      (Scoring Worker)
                     → answer-processing-dlq        (Dead letter)
  round.completed    → round-completed-queue        (Quiz Engine logging)
  match.finished     → match-finished-queue         (Scoring: persistence)
                     → match-analytics-queue        (Scoring: analytics stub)
                     → notification-match-queue      (Notification Worker: referral conversion)
  notification.*     → notification-worker-queue     (Notification Worker: push notifications)
  payment.success    → payment-success-queue         (Payment Service: post-capture event)
```

---

## Services

| Service | Port | Binary | Responsibilities |
|---------|------|--------|-----------------|
| Matchmaking | `:50051` (gRPC) `:8080` (HTTP) | `matchmaking-service/main.go` | Register/Login/Google OAuth, JoinMatchmaking, SubscribeToMatch, Referral, Device Token |
| Quiz Engine | `:50052` | `quiz-service/main.go` | StreamGameEvents, SubmitAnswer, question selection, game loop |
| Scoring | `:50053` | `scoring-service/main.go` | CalculateScore, GetLeaderboard (capped for free users) |
| Payment | `:8081` | `payment-service/main.go` | CreateOrder, VerifyPayment, Webhook, GetStatus, GetHistory |
| Notification Worker | — (no port) | `notification-worker/main.go` | FCM push notifications, RabbitMQ consumers, cron scheduler |

---

## Event Flow

```
1.  Player registers/logs in (email/password or Google) → JWT issued
2.  _loadLocalStats() runs → login streak incremented via _updateLoginStreak()
3.  If pendingReward != null → HomeScreen shows daily reward dialog
4.  Player calls JoinMatchmaking → added to Redis sorted set (matchmaking:pool) keyed by rating
5.  Pool reaches ≥2 players → tryCreateRoom acquires Redis lock → ZPOPMIN → CreateRoom
6.  Room persisted to Redis (room:{id}:players, room:{id}:state) with 30-min TTL
7.  Matchmaking publishes match.created → RabbitMQ
8.  Quiz Engine consumes match.created → SelectForRoom → stores question IDs in room:{id}:questions
9.  MatchFound received by Flutter → consumeDailyQuiz() called
10. Players call StreamGameEvents → first subscriber triggers game loop (sync.Once)
11. Game loop: RunRound × totalRounds
    a. LPOP next question from room:{id}:questions
    b. Broadcast QuestionBroadcast event to all subscribers
    c. 30-second countdown (TimerSync every second)
    d. SETNX room:{id}:round:{n}:closed — only first goroutine proceeds (dedup guard)
    e. Publish round.completed → RabbitMQ
    f. Wait 2s for scoring consumer to process answers
    g. Broadcast RoundResult + LeaderboardUpdate
       → client updates currentWinStreak (correct AND fastest = win streak +1)
12. SubmitAnswer → HSETNX room:{id}:submitted:{round} (idempotency) → publish answer.submitted
13. Scoring Worker consumes answer.submitted → validates vs MongoDB → Lua atomic UpdateScore
14. After all rounds → publish match.finished → broadcast MatchEnd
15. saveMatchHistory writes full document to MongoDB match_history collection
```

---

## Redis Key Ownership

| Service | Keys | TTL |
|---------|------|-----|
| Matchmaking | `matchmaking:pool`, `player:{id}`, `room:{id}:state`, `room:{id}:players`, `room:lock:{id}` | 30 min |
| Quiz Engine | `room:{id}:questions`, `room:{id}:submitted:{round}`, `room:{id}:round:{n}:started_at`, `room:{id}:round:{n}:closed` | 30 min |
| Scoring | `room:{id}:leaderboard`, `room:{id}:answers:{round}`, `room:{id}:correct_counts`, `room:{id}:response_sum`, `room:{id}:response_count` | 30 min |
| User/Premium | `user:{id}:plan` → `free\|premium`, `user:{id}:daily_quota` → remaining games or "unlimited" | plan: 1 day, quota: end of day |
| Referral | `referral:code:{code}` → `{userId}` | no TTL |
| Streak | `user:{id}:streak` hash → `{current, longest, last_login}` | no TTL |

Populated by `PopulateUserRedisKeys()` on every login (Google, email/password, register) and by `enforceQuotaAndIncrement()` on each matchmaking join.

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
| `notification-worker-queue` | `notification.*` | Notification Worker | Dispatches FCM push notifications |
| `notification-match-queue` | `match.finished` | Notification Worker | Sends referral-conversion FCM notification |
| `payment-success-queue` | `payment.success` | Payment Service | Published after Razorpay webhook captures a payment |

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
  "google_id": "string (Google sub, optional)",
  "email": "string",
  "picture_url": "string (Google CDN URL, optional)",
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
60 questions seeded: 20 easy, 20 medium, 20 hard across 12 topics.

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

### payments
```json
{
  "_id": ObjectId,
  "userId": "string",
  "orderId": "string (Razorpay)",
  "paymentId": "string (Razorpay)",
  "plan": "monthly|yearly",
  "status": "pending|captured|failed",
  "amount": 49900,
  "expiresAt": ISODate,
  "createdAt": ISODate
}
```

**Indexes:**
- `users.username` — UNIQUE
- `questions.difficulty` — for sampling by difficulty
- `match_history.players.userId` — for fetching seen questions per player
- `payments.userId` — for status lookups

---

## Seed Data

### Questions (mongo-init/init.js)
- 60 questions, 3 difficulty levels, 12 topics
- Run: `make seed`

### Test Users (matchmaking-service/cmd/seed/main.go)
| Username | Password | Rating |
|----------|----------|--------|
| alice | speakx123 | 1200 |
| bob | speakx123 | 1050 |
| charlie | speakx123 | 1380 |
| diana | speakx123 | 975 |
| evan | speakx123 | 1520 |
| fiona | speakx123 | 890 |

Run: `make seed-users`

---

## Flutter Client

### Architecture
- **3 gRPC channels**: matchmaking (50051), quiz (50052), scoring (50053)
- **1 HTTP client**: payment service (8081)
- **Auth**: JWT stored via SharedPreferences, sent as `Authorization: Bearer <token>` metadata
- **State**: Riverpod `StateNotifier` (`GameNotifier`, `AuthNotifier`)
- **Reconnection**: `ReconnectService` wraps `StreamGameEvents` with exponential backoff (1s→2s→4s→8s→16s, max 5 retries)
- **Timer**: Server-driven via `TimerSync` events (uses `DeadlineMs` absolute timestamp, not local drift-prone timer)
- **Idempotent answers**: Double-tap guard via `_answerSubmitted` flag in `QuizScreen`

### AuthState — key fields

| Field | Type | Description |
|-------|------|-------------|
| `isPremium` | bool | Paid Razorpay subscription |
| `isEffectivelyPremium` | bool (getter) | `isPremium OR active premiumTrial` |
| `dailyQuizUsed` | int | Games played today (resets at midnight) |
| `bonusGamesRemaining` | int | Extra games from daily rewards; carry-over |
| `isQuotaExhausted` | bool (getter) | True when free + bonus = 0 and not effectively premium |
| `coins` | int | Total coins earned, never decreases |
| `currentStreak` | int | Consecutive login-day streak |
| `loginHistory` | List\<String\> | ISO dates of last 30 logins |
| `premiumTrialExpiresAt` | String? | ISO datetime; sentinel copyWith for nullable clear |
| `dailyRewardClaimedDate` | String? | ISO date of last claim; prevents double-claiming |
| `pendingReward` | DailyReward? (getter) | Non-null = show popup today |

### GameState — streak fields

| Field | Description |
|-------|-------------|
| `currentAnswerStreak` | Consecutive correct answers this match |
| `maxAnswerStreak` | Best answer streak this match |
| `currentWinStreak` | Consecutive rounds won (correct AND fastest) |
| `maxWinStreak` | Best win streak this match |

Win streak is tracked in `GameNotifier._onRoundResult()` using
`RoundResultEvent.fastestUserId`. Displayed in `leaderboard_screen.dart`
(between-round screen) as a gold ⚡ badge when `currentWinStreak >= 2`.

---

## Phase 1 Audit — All 16 Requirements

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| 1 | Flutter connected to real backend | ✅ | Real gRPC, no mock flags |
| 2 | 3 truly separate services | ✅ | Ports 50051/50052/50053 + 8081, independent binaries |
| 3 | All RabbitMQ consumers functional | ✅ | All 6 queues declared and consuming |
| 4 | match_history persisted with full fields | ✅ | All fields including score, rank, avgResponseMs |
| 5 | Double round completion prevented | ✅ | SETNX `room:{id}:round:{n}:closed` guard |
| 6 | Reconnection with state recovery | ✅ | ReconnectService + exponential backoff |
| 7 | Leaderboard updates atomic | ✅ | Lua script: ZINCRBY + EXPIRE + ZREVRANK |
| 8 | Zombie room cleanup (TTLs) | ✅ | All room keys EXPIRE 1800s |
| 9 | Timer sync server→client | ✅ | TimerSync every 1s with DeadlineMs |
| 10 | Idempotent answer processing | ✅ | HSETNX + HEXISTS double guard |
| 11 | PlayerJoined event broadcast | ✅ | Broadcast on StreamGameEvents subscription |
| 12 | Late joiner / mid-match join | ✅ | Late joiner receives current question + TimerSync on connect |
| 13 | Proper error handling | ✅ | gRPC status codes, ACK/NACK, try/catch in Flutter |
| 14 | All proto RPCs implemented | ✅ | Register, Login, GoogleAuth, Join/Leave/Subscribe, Stream/Submit, Score/GetLeaderboard |
| 15 | Docker includes all services | ✅ | mongo + redis + rabbitmq + 4 Go services, all with healthchecks |
| 16 | Comprehensive seed data | ✅ | 60 questions + 6 test users |

Late joiners now receive the current question + TimerSync immediately on connect, so they can participate in the active round without waiting for the next one.

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

**Signature verification:**
```
HMAC-SHA256(key_secret, order_id + "|" + payment_id) == razorpay_signature
```

**Plans:** Monthly ₹499 (30 days) · Yearly ₹3,999 (365 days)

**Port:** `:8081` — Flutter uses `http://10.0.2.2:8081` (Android emulator)

See [razorpay.md](razorpay.md) for full integration details.

---

### Google Sign-In

Full OAuth 2.0 flow:
1. Flutter opens Google consent screen via `google_sign_in` SDK
2. ID token exchanged at `POST http://localhost:8080/auth/google`
3. Backend verifies with Google, upserts user in MongoDB (links accounts by email)
4. JWT returned; profile picture URL stored and shown via `CachedNetworkImage`
5. Silent re-authentication on app restart via `signInSilently()`

See [google-auth.md](google-auth.md) for full setup and security details.

---

### Daily Quota

Free users: **5 games/day**. Enforced server-side in `matchmaking-service/handlers/matchmaking.go` → `enforceQuotaAndIncrement()`.

The server checks MongoDB `subscriptions` (premium bypass) then `users.daily_quiz_used` + `users.last_quiz_date` before adding to the matchmaking pool. Returns `codes.ResourceExhausted` if the daily limit is reached. The remaining quota is also mirrored to Redis (`user:{id}:daily_quota`) for observability.

Flutter client tracks quota locally in SharedPreferences as a UI hint, but the server is the authoritative enforcer.

**Where consumed:** `matchmaking_screen.dart → _onMatchFound()` calls
`consumeDailyQuiz()` the moment a match is confirmed. Bonus games are consumed
first; `dailyQuizUsed` only increments after bonus games run out.

**Reset:** Date-based. On login, if saved date ≠ today, counter resets to 0.

---

### Premium Sync Across Devices

`AuthNotifier._syncPremiumFromServer()` is called after every login. It hits
`GET /payment/status` and updates local SharedPreferences with the server's
authoritative `is_active` value. 5-second timeout prevents blocking login if
the payment service is unreachable.

**`isEffectivelyPremium`** — computed getter checking both paid premium AND
active premium trial. All quota/upsell checks use this, not `isPremium` directly.

---

### Daily Rewards & Login Streak

A full daily engagement system. All logic is **client-side** (SharedPreferences).
Works offline.

**Streak tracking:**
- Login streak incremented at login via `_updateLoginStreak()` (not on match completion)
- Uses history-based streak computation from `loginHistory` (last 30 ISO date strings)
- Streak resets to 1 when a day is missed

**Reward system:**
- `rewardForDay(int streakDay)` returns a `DailyReward` (coins, bonus games, badge, trial)
- Weekly cycle (days 1–7) with milestones at day 14 and day 30
- Day-30 reward includes 7-day premium trial

**Popup flow:**
- `AuthState.pendingReward` getter returns non-null if today's reward is unclaimed
- `HomeScreen.initState` uses `addPostFrameCallback` to show `_DailyRewardDialog`
- `claimDailyReward()` is idempotent — calling it twice on the same day is a no-op

**Coins system:**
- Additive soft currency, never decreases
- Shown on Profile → STREAK tab

**Bonus games:**
- Stack on top of free daily 5
- Carry over between days
- Consumed before `dailyQuizUsed` increments

**Premium trial:**
- Granted by day-30 streak milestone reward
- Stored as `premiumTrialExpiresAt` (ISO datetime)
- `isEffectivelyPremium` checks expiry in real-time — no logout needed

**SharedPreferences keys added:**
- `stats_<id>_coins` — total coins
- `stats_<id>_bonusGames` — bonus games remaining
- `stats_<id>_loginHistory` — JSON array of last 30 login dates
- `stats_<id>_trialExpiry` — premium trial expiry datetime
- `stats_<id>_rewardDate` — date of last reward claim

See [daily-rewards.md](daily-rewards.md) for full spec.

---

### Win Streak (Speed Streak)

Tracked in `GameState` alongside answer streak:

| Field | Meaning |
|-------|---------|
| `currentAnswerStreak` | Consecutive rounds with any correct answer |
| `currentWinStreak` | Consecutive rounds where player was **correct AND fastest** |

Updated in `GameNotifier._onRoundResult()` using `RoundResultEvent.fastestUserId`.
Displayed in `leaderboard_screen.dart` (between-round screen) as a gold ⚡ badge
just below the 🔥 answer streak badge. Requires ≥ 2 consecutive wins to appear.

---

### Results Screen — Action Buttons

Three buttons in `results_screen.dart`:
- **Share** — copies result text to clipboard
- **Home** — resets game state and navigates to `/home`
- **Play Again** — resets game state and navigates to `/matchmaking`

---

### Profile Screen — STREAK Tab

A 4th tab added to `ProfileScreen`:
- **Streak Summary Card** — current streak + best streak
- **Coins Card** — total coins + bonus games remaining
- **30-Day Login Calendar** — 7-column grid; green = logged in, gold border = today, dim = missed
- Three new badges: Week Warrior (7d), Fortnight Fighter (14d), Monthly Master (30d)

---

## Running the Project

```bash
# Start infrastructure
make infra

# Seed questions + test users
make seed
make seed-users

# Start all services
make run-matchmaking   # terminal 1
make run-quiz          # terminal 2
make run-scoring       # terminal 3
cd payment-service && go run main.go  # terminal 4 (optional)

# OR start everything with Docker
make up

# Run Flutter app
cd flutter-app && flutter run

# Run tests
make test              # Go tests
make test-flutter      # Flutter tests (31 unit tests)
```

---

## Resolved Gaps (2026-04-13)

All previously identified gaps have been fixed. See [GAPS_AND_PLAN.md](GAPS_AND_PLAN.md) for the full change log.

| Gap | Resolution |
|-----|-----------|
| Daily quota server-side | `enforceQuotaAndIncrement()` in matchmaking checks MongoDB before pool join |
| `payment-success-queue` | Payment service now publishes `payment.success` to RabbitMQ after webhook capture |
| Redis observability keys | `PopulateUserRedisKeys()` called on every login — sets plan, quota, streak, referral keys |
| MongoDB indexes | `mongo-init/init.js` creates indexes on all collections (users, questions, match_history, payments, subscriptions, device_tokens, referrals) |
| Leaderboard cap | `GetLeaderboard()` in scoring-service caps to top 3 + own entry for free users |
| Late joiner catch-up | `StreamGameEvents()` sends current question + TimerSync to non-first subscribers |
