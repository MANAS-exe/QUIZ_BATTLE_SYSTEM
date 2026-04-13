# Gaps & Implementation Plan

> Generated: 2026-04-13. All gaps fixed 2026-04-13.

---

## Overall Status

| Phase | Done | Partial | Missing |
|-------|------|---------|---------|
| Phase 1 (core game) | 16/16 | 0 | 0 |
| Phase 2 (new features) | 7/7 | 0 | 0 |
| Demo requirements | 7/7 | 0 | 0 |

**All gaps have been resolved.** See change log below.

---

## Resolved Gaps (2026-04-13)

### Gap 1: Daily quota now enforced server-side ✅
- `matchmaking-service/handlers/matchmaking.go` → `enforceQuotaAndIncrement()` checks MongoDB subscription + daily_quiz_used before adding to pool
- Returns `codes.ResourceExhausted` if free user exceeds 5 games/day
- Redis key `user:{id}:daily_quota` populated on each matchmaking join for observability

### Gap 2: `payment-success-queue` now published ✅
- New `payment-service/rabbitmq/publisher.go` — RabbitMQ publisher declaring `payment-success-queue` bound to `payment.success`
- `payment-service/handlers/webhook.go` → `handlePaymentCaptured()` now publishes `payment.success` event after subscription upsert
- `docker-compose.yml` — added `RABBITMQ_URL` to payment-service environment

### Gap 3: Redis keys populated on login ✅
- New `matchmaking-service/handlers/redis_keys.go` — `PopulateUserRedisKeys()` called fire-and-forget after every login (Google, email/password, register)
- Sets: `user:{id}:plan`, `user:{id}:daily_quota`, `user:{id}:streak` (hash), `referral:code:{code}`
- `AuthHandler`, `GoogleAuthHandler`, `ReferralHandler` all wired with Redis pool via `SetRedisPool()`

### Gap 4: MongoDB indexes comprehensive ✅
- `mongo-init/init.js` now creates indexes on:
  - `users`: username (unique), email (sparse), referral_code (unique sparse)
  - `questions`: difficulty, topic
  - `match_history`: players.userId, createdAt
  - `payments`: order_id (unique), user_id
  - `subscriptions`: user_id, expires_at
  - `device_tokens`: user_id (unique)
  - `referrals`: referrer_id, referee_id (unique)

### Gap 5: Leaderboard capped for free users ✅
- `scoring-service/handlers/scoring.go` → `GetLeaderboard()` now extracts user ID from JWT context
- Free users see top 3 + their own entry; premium users see full leaderboard
- `isPremium()` helper checks MongoDB subscriptions collection

### Gap 6: Late joiner catch-up ✅
- `quiz-service/handlers/quiz_handler.go` → `gameRoom` struct gains `currentQuestion`, `currentRound`, `roundDeadlineMs` fields
- Game loop stores current QuestionBroadcast via `setCurrentQuestion()` on each round
- `StreamGameEvents()` sends current question + TimerSync to late joiners (non-first subscribers)

### Cleanup ✅
- `.gitignore` updated: added `.env`, `**/.env`, `**/google-services.json`, `**/GoogleService-Info.plist`
- Removed tracked build artifacts (`flutter-app/build/`) from git index
- Removed tracked `.env` files from git index
- Deleted `.DS_Store` files

---

## What Was Already Complete (Unchanged)

✅ Google Auth (backend token verification + Flutter SDK)
✅ Home screen (profile, stats, quota pill, streak, rewards popup, play CTA)
✅ Premium / Razorpay (order creation, HMAC webhook, subscription management)
✅ Referral system (6-char codes, anti-abuse, pending rewards, REFERRAL tab)
✅ Daily rewards & streak (30-day calendar, escalating rewards, coins)
✅ FCM push notifications (5 types, RabbitMQ consumers, cron scheduler)
✅ SETNX double round completion guard
✅ Redis Lua atomic leaderboard updates
✅ Answer idempotency (HEXISTS)
✅ PlayerJoined broadcast
✅ Reconnection with exponential backoff
✅ RabbitMQ DLQ (answer-processing-dlq)
✅ All proto RPCs implemented
✅ docker-compose with health checks for all services
✅ Webhook HMAC-SHA256 signature verification
✅ Referral anti-abuse (5 checks)
