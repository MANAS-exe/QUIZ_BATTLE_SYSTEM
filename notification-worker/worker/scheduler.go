package worker

// scheduler.go — Cron-based push notification schedulers.
//
// Jobs run inside the notification-worker process on a fixed schedule.
// Each job queries MongoDB directly and dispatches FCM via SendMulticast.
//
// Schedule (UTC — adjust TZ as needed):
//   Streak warning      — 13:30 UTC (7pm IST)  daily
//   Daily reward nudge  — 02:30 UTC (8am IST)  daily
//   Premium expiry      — 03:30 UTC (9am IST)  daily
//
// To adjust schedules, change the cron expressions in Start().

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/robfig/cron/v3"
	"go.mongodb.org/mongo-driver/mongo"
)

// Scheduler wraps the cron runner and the dependencies each job needs.
type Scheduler struct {
	cron *cron.Cron
	fcm  *FCMSender
	db   *mongo.Database
}

// NewScheduler creates the Scheduler. Call Start() to activate cron jobs.
func NewScheduler(fcm *FCMSender, db *mongo.Database) *Scheduler {
	return &Scheduler{
		cron: cron.New(cron.WithSeconds()),
		fcm:  fcm,
		db:   db,
	}
}

// Start registers all jobs and starts the cron runner.
func (s *Scheduler) Start() {
	// Streak warning — 7pm IST (13:30 UTC)
	s.mustAdd("0 30 13 * * *", "streak_warning", s.jobStreakWarning)

	// Daily reward available — 8am IST (02:30 UTC)
	s.mustAdd("0 30 2 * * *", "daily_reward", s.jobDailyReward)

	// Premium expiry check — 9am IST (03:30 UTC)
	s.mustAdd("0 30 3 * * *", "premium_expiry", s.jobPremiumExpiry)

	s.cron.Start()
	log.Println("⏰ Notification scheduler started (3 jobs)")
}

// Stop gracefully waits for running jobs to finish then stops the scheduler.
func (s *Scheduler) Stop() {
	ctx := s.cron.Stop()
	<-ctx.Done()
	log.Println("⏰ Notification scheduler stopped")
}

func (s *Scheduler) mustAdd(spec, name string, fn func()) {
	_, err := s.cron.AddFunc(spec, fn)
	if err != nil {
		log.Fatalf("❌ Scheduler: failed to register %s (%s): %v", name, spec, err)
	}
	log.Printf("⏰ Scheduled %s — %s", name, spec)
}

// ── Job: streak warning ───────────────────────────────────────────────────
// Sent every evening to ALL registered devices as a general engagement nudge.
// Server-side streak data is not available (streaks are computed client-side),
// so this is a broadcast to everyone with a device token.

func (s *Scheduler) jobStreakWarning() {
	log.Println("⏰ Running streak_warning job")
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	tokens, err := GetAllTokens(ctx, s.db)
	if err != nil {
		log.Printf("⚠️  streak_warning: GetAllTokens: %v", err)
		return
	}
	if len(tokens) == 0 {
		log.Println("streak_warning: no registered tokens")
		return
	}

	title := "Don't break your streak! 🔥"
	body := "You haven't played today. Jump in for a quick battle to keep it alive!"

	for _, batch := range batchTokens(tokens, 500) {
		if err := s.fcm.SendMulticast(ctx, batch, title, body, map[string]string{
			"type": "streak_warning",
		}); err != nil {
			log.Printf("⚠️  streak_warning: multicast error: %v", err)
		}
	}
	log.Printf("✅ streak_warning sent to %d devices", len(tokens))
}

// ── Job: daily reward nudge ───────────────────────────────────────────────
// Morning nudge: tell all users their daily reward is ready to collect.

func (s *Scheduler) jobDailyReward() {
	log.Println("⏰ Running daily_reward job")
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	tokens, err := GetAllTokens(ctx, s.db)
	if err != nil {
		log.Printf("⚠️  daily_reward: GetAllTokens: %v", err)
		return
	}
	if len(tokens) == 0 {
		return
	}

	title := "Your daily reward is waiting! 🎁"
	body := "Log in to claim your coins and bonus games. Day streaks earn bigger rewards!"

	for _, batch := range batchTokens(tokens, 500) {
		if err := s.fcm.SendMulticast(ctx, batch, title, body, map[string]string{
			"type": "daily_reward",
		}); err != nil {
			log.Printf("⚠️  daily_reward: multicast error: %v", err)
		}
	}
	log.Printf("✅ daily_reward nudge sent to %d devices", len(tokens))
}

// ── Job: premium expiry warning ───────────────────────────────────────────
// Personalised notification 3 days before premium expires.
// Queries the subscriptions collection directly.

func (s *Scheduler) jobPremiumExpiry() {
	log.Println("⏰ Running premium_expiry job")
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	now := time.Now()
	// Find subscriptions expiring in the window [2 days, 4 days from now]
	// (This catches "3 days before expiry" robustly even if the job runs slightly late)
	from := now.Add(2 * 24 * time.Hour)
	to := now.Add(4 * 24 * time.Hour)

	subs, err := GetSubscriptionsExpiringSoon(ctx, s.db, from, to)
	if err != nil {
		log.Printf("⚠️  premium_expiry: query failed: %v", err)
		return
	}
	if len(subs) == 0 {
		log.Println("premium_expiry: no expiring subscriptions in window")
		return
	}

	// Collect user IDs
	userIDs := make([]string, 0, len(subs))
	expiries := make(map[string]time.Time, len(subs))
	for _, sub := range subs {
		userIDs = append(userIDs, sub.UserID)
		if sub.ExpiresAt != nil {
			expiries[sub.UserID] = *sub.ExpiresAt
		}
	}

	tokenMap, err := GetTokensForUsers(ctx, s.db, userIDs)
	if err != nil {
		log.Printf("⚠️  premium_expiry: token lookup failed: %v", err)
		return
	}

	sent := 0
	for userID, token := range tokenMap {
		exp := expiries[userID]
		daysLeft := int(time.Until(exp).Hours()/24) + 1
		body := fmt.Sprintf("Your Premium plan expires in %d day(s). Renew now to keep unlimited games!", daysLeft)

		if err := s.fcm.Send(ctx, token,
			"Premium expiring soon ⏳", body,
			map[string]string{"type": "premium_expiry", "user_id": userID},
		); err != nil {
			log.Printf("⚠️  premium_expiry: send to %s: %v", userID, err)
		} else {
			sent++
		}
	}
	log.Printf("✅ premium_expiry sent to %d/%d users", sent, len(subs))
}

// batchTokens splits a token slice into batches of at most size n.
// FCM multicast accepts max 500 tokens per call.
func batchTokens(tokens []string, n int) [][]string {
	var batches [][]string
	for len(tokens) > 0 {
		end := n
		if end > len(tokens) {
			end = len(tokens)
		}
		batches = append(batches, tokens[:end])
		tokens = tokens[end:]
	}
	return batches
}
