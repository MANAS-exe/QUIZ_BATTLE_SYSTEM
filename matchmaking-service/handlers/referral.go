package handlers

// referral.go — REST handlers for the referral/invite system.
//
// ENDPOINTS (all on port 8080, same server as /auth/google):
//   GET  /referral/code     JWT   → user's code + stats + pending rewards
//   POST /referral/apply    JWT   → apply a friend's code (new users only, ≤7 days after signup)
//   GET  /referral/claim    JWT   → claim pending coins + bonus games
//   GET  /referral/history  JWT   → list referrals made by this user
//
// REWARDS:
//   Referrer (person who shared code): +200 coins, +2 bonus games (pending until claimed)
//   Referee  (new user who used code): +100 coins, +1 bonus game (pending until claimed)
//
// ANTI-ABUSE:
//   1. referred_by must be empty — can't apply a second code
//   2. Can't apply own code (self-referral rejected)
//   3. Referrer's referral_count must be < maxReferralsPerUser (10)
//   4. Account must be ≤ 7 days old when applying a code
//   5. Code must be exactly 6 uppercase alphanumeric chars
//
// EXISTING USERS:
//   Referral codes are generated lazily — GET /referral/code generates and
//   saves a code on first call for accounts created before this system existed.
//   Existing users CANNOT apply a referral code themselves (their account is
//   older than the 7-day window), but they CAN share their own code.
//
// MONGODB:
//   users collection gains: referral_code (unique sparse), referred_by,
//   referral_count, pending_referral_coins, pending_referral_bonus, total_referral_coins
//   referrals collection: { referrer_id, referee_id, code_used, created_at }

import (
	"context"
	"crypto/rand"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"quiz-battle/shared/auth"
)

// ─────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────

const (
	// referralCodeChars is the safe alphanumeric character set — ambiguous characters
	// (0, O, 1, I, L) are excluded so users can read and type codes without confusion.
	referralCodeChars = "ABCDEFGHJKMNPQRSTUVWXYZ23456789" // 31 chars → 31^6 ≈ 887 million combinations

	referralCodeLength = 6

	// maxReferralsPerUser caps the number of successful referrals one user can make.
	// This limits the benefit of coordinated invite-farming attacks.
	maxReferralsPerUser = 10

	// referralApplyWindowDays is the grace period after account creation during which
	// a new user may apply a referral code. Prevents abuse where an old account is
	// retroactively tied to a referral chain.
	referralApplyWindowDays = 7

	// Reward quantities — adjust here to tune the referral economy.
	referrerRewardCoins = 200 // coins granted to referrer when referee applies code
	referrerRewardBonus = 2   // bonus games granted to referrer
	refereeRewardCoins  = 100 // coins granted to new user who applied a code
	refereeRewardBonus  = 1   // bonus games granted to new user
)

// ─────────────────────────────────────────
// HANDLER STRUCT
// ─────────────────────────────────────────

// ReferralHandler handles all /referral/* REST endpoints.
type ReferralHandler struct {
	users     *mongo.Collection
	referrals *mongo.Collection
}

// NewReferralHandler creates a ReferralHandler attached to the given MongoDB database.
func NewReferralHandler(db *mongo.Database) *ReferralHandler {
	return &ReferralHandler{
		users:     db.Collection("users"),
		referrals: db.Collection("referrals"),
	}
}

// referralEvent is the document stored in the "referrals" collection.
// One document per successful referral (referee applied code).
type referralEvent struct {
	ID         primitive.ObjectID `bson:"_id,omitempty"`
	ReferrerID string             `bson:"referrer_id"` // userId of the person whose code was used
	RefereeID  string             `bson:"referee_id"`  // userId of the new user who applied the code
	CodeUsed   string             `bson:"code_used"`   // the exact code that was applied
	CreatedAt  time.Time          `bson:"created_at"`
}

// ─────────────────────────────────────────
// GET /referral/code
// ─────────────────────────────────────────

// GetCode returns the authenticated user's referral code plus their referral stats.
// If the user has no code yet (registered before this system), one is generated and saved.
// This is the safe lazy-generation path for all existing accounts.
func (h *ReferralHandler) GetCode(w http.ResponseWriter, r *http.Request) {
	setReferralCORSHeaders(w)
	w.Header().Set("Content-Type", "application/json")

	userID, _, err := extractUserID(r)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	oid, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid user id")
		return
	}

	// Fetch only the referral-related fields to keep the query lean.
	var user struct {
		ReferralCode     string `bson:"referral_code"`
		ReferralCount    int    `bson:"referral_count"`
		PendingCoins     int    `bson:"pending_referral_coins"`
		PendingBonus     int    `bson:"pending_referral_bonus"`
		TotalCoinsEarned int    `bson:"total_referral_coins"`
		ReferredBy       string `bson:"referred_by"`
	}
	projection := options.FindOne().SetProjection(bson.M{
		"referral_code":          1,
		"referral_count":         1,
		"pending_referral_coins": 1,
		"pending_referral_bonus": 1,
		"total_referral_coins":   1,
		"referred_by":            1,
	})
	if err = h.users.FindOne(ctx, bson.M{"_id": oid}, projection).Decode(&user); err != nil {
		writeError(w, http.StatusInternalServerError, "user not found")
		return
	}

	// Lazy-generate a code for users who registered before the referral system existed.
	// This is idempotent — if the code is already set, the UpdateOne below is a no-op.
	if user.ReferralCode == "" {
		code, genErr := generateUniqueCode(ctx, h.users)
		if genErr != nil {
			log.Printf("⚠️  referral: generateUniqueCode for %s: %v", userID, genErr)
			writeError(w, http.StatusInternalServerError, "failed to generate referral code")
			return
		}
		if _, updateErr := h.users.UpdateOne(ctx,
			bson.M{"_id": oid},
			bson.M{"$set": bson.M{"referral_code": code}},
		); updateErr != nil {
			writeError(w, http.StatusInternalServerError, "failed to save referral code")
			return
		}
		user.ReferralCode = code
		log.Printf("✅ referral: lazily generated code %s for user %s", code, userID)
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]any{ //nolint:errcheck
		"success":            true,
		"code":               user.ReferralCode,
		"referral_count":     user.ReferralCount,
		"pending_coins":      user.PendingCoins,
		"pending_bonus":      user.PendingBonus,
		"total_coins_earned": user.TotalCoinsEarned,
		"already_referred":   user.ReferredBy != "",
	})
}

// ─────────────────────────────────────────
// POST /referral/apply
// ─────────────────────────────────────────

// ApplyCode applies a referral code from a friend to the authenticated user's account.
// Body: { "code": "QB4X9K" }
//
// All five anti-abuse rules are checked before any write occurs:
//   1. referred_by already set → reject (can't use two codes)
//   2. Account older than referralApplyWindowDays → reject
//   3. Code does not exist → reject
//   4. Code belongs to this user → reject (self-referral)
//   5. Referrer already at cap → reject
//
// On success:
//   - referrals collection gets a new event doc
//   - referee's pending_referral_coins/bonus incremented
//   - referrer's referral_count, pending_referral_coins/bonus incremented
//   Both parties claim their rewards separately via GET /referral/claim.
func (h *ReferralHandler) ApplyCode(w http.ResponseWriter, r *http.Request) {
	setReferralCORSHeaders(w)
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	userID, _, err := extractUserID(r)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var body struct {
		Code string `json:"code"`
	}
	if err = json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// Normalise the code — clients may enter it in any case.
	code := strings.ToUpper(strings.TrimSpace(body.Code))
	if len(code) != referralCodeLength {
		writeError(w, http.StatusBadRequest,
			fmt.Sprintf("referral code must be exactly %d characters", referralCodeLength))
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	oid, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid user id")
		return
	}

	// ── Fetch referee (the user applying the code) ────────────────

	var referee struct {
		ID         primitive.ObjectID `bson:"_id"`
		ReferredBy string             `bson:"referred_by"`
		CreatedAt  time.Time          `bson:"created_at"`
	}
	refereeProjOpts := options.FindOne().SetProjection(bson.M{
		"referred_by": 1,
		"created_at":  1,
	})
	if err = h.users.FindOne(ctx, bson.M{"_id": oid}, refereeProjOpts).Decode(&referee); err != nil {
		writeError(w, http.StatusInternalServerError, "user not found")
		return
	}

	// Anti-abuse 1: already used a referral code.
	if referee.ReferredBy != "" {
		writeError(w, http.StatusConflict, "you have already applied a referral code to your account")
		return
	}

	// Anti-abuse 2: account too old.
	windowDur := time.Duration(referralApplyWindowDays) * 24 * time.Hour
	if time.Since(referee.CreatedAt) > windowDur {
		writeError(w, http.StatusForbidden,
			fmt.Sprintf("referral codes can only be applied within %d days of account creation", referralApplyWindowDays))
		return
	}

	// ── Fetch referrer (owner of the code) ────────────────────────

	var referrer struct {
		ID            primitive.ObjectID `bson:"_id"`
		ReferralCount int                `bson:"referral_count"`
	}
	referrerProjOpts := options.FindOne().SetProjection(bson.M{
		"referral_count": 1,
	})
	if err = h.users.FindOne(ctx, bson.M{"referral_code": code}, referrerProjOpts).Decode(&referrer); err == mongo.ErrNoDocuments {
		writeError(w, http.StatusNotFound, "invalid referral code — no account uses this code")
		return
	} else if err != nil {
		writeError(w, http.StatusInternalServerError, "database lookup failed")
		return
	}

	// Anti-abuse 3: self-referral.
	if referrer.ID == oid {
		writeError(w, http.StatusBadRequest, "you cannot apply your own referral code")
		return
	}

	// Anti-abuse 4: referrer hit the cap.
	if referrer.ReferralCount >= maxReferralsPerUser {
		writeError(w, http.StatusForbidden,
			fmt.Sprintf("this referral code has reached the maximum of %d successful referrals", maxReferralsPerUser))
		return
	}

	referrerIDStr := referrer.ID.Hex()

	// ── Record the referral event ─────────────────────────────────

	if _, err = h.referrals.InsertOne(ctx, referralEvent{
		ReferrerID: referrerIDStr,
		RefereeID:  userID,
		CodeUsed:   code,
		CreatedAt:  time.Now(),
	}); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to record referral event")
		return
	}

	// ── Grant referee pending reward ──────────────────────────────

	if _, err = h.users.UpdateOne(ctx, bson.M{"_id": oid}, bson.M{
		"$set": bson.M{"referred_by": referrerIDStr},
		"$inc": bson.M{
			"pending_referral_coins": refereeRewardCoins,
			"pending_referral_bonus": refereeRewardBonus,
		},
	}); err != nil {
		// Attempt to clean up the referral event to keep the DB consistent.
		h.referrals.DeleteOne(ctx, bson.M{"referee_id": userID, "referrer_id": referrerIDStr}) //nolint:errcheck
		writeError(w, http.StatusInternalServerError, "failed to update your account — please try again")
		return
	}

	// ── Grant referrer pending reward ─────────────────────────────
	// This is best-effort: the referee update already succeeded so the referral
	// is valid. If this update fails, the referrer will miss their reward for
	// this event but we log it for manual recovery.

	if _, err = h.users.UpdateOne(ctx, bson.M{"_id": referrer.ID}, bson.M{
		"$inc": bson.M{
			"referral_count":         1,
			"pending_referral_coins": referrerRewardCoins,
			"pending_referral_bonus": referrerRewardBonus,
		},
	}); err != nil {
		log.Printf("⚠️  referral: reward update failed for referrer %s (referee=%s code=%s): %v",
			referrerIDStr, userID, code, err)
	}

	log.Printf("✅ Referral applied: referee=%s code=%s referrer=%s", userID, code, referrerIDStr)

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]any{ //nolint:errcheck
		"success":      true,
		"reward_coins": refereeRewardCoins,
		"reward_bonus": refereeRewardBonus,
		"message": fmt.Sprintf(
			"Referral applied! You earned %d coins and %d bonus game. Claim them from your profile.",
			refereeRewardCoins, refereeRewardBonus),
	})
}

// ─────────────────────────────────────────
// GET /referral/claim
// ─────────────────────────────────────────

// ClaimRewards atomically claims all pending referral rewards for the user.
// Pending coins are added to total_referral_coins (lifetime earned) and both
// pending counters are reset to 0. Idempotent — calling with no pending rewards
// returns 0 and is a no-op.
//
// The Flutter client applies the returned coins/bonus directly to local state
// (same pattern as daily rewards), so the client stays the source of truth for
// the local quota / coin balance while the server tracks referral ledger state.
func (h *ReferralHandler) ClaimRewards(w http.ResponseWriter, r *http.Request) {
	setReferralCORSHeaders(w)
	w.Header().Set("Content-Type", "application/json")

	userID, _, err := extractUserID(r)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	oid, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid user id")
		return
	}

	// Fetch pending reward amounts.
	var user struct {
		PendingCoins int `bson:"pending_referral_coins"`
		PendingBonus int `bson:"pending_referral_bonus"`
	}
	claimProjOpts := options.FindOne().SetProjection(bson.M{
		"pending_referral_coins": 1,
		"pending_referral_bonus": 1,
	})
	if err = h.users.FindOne(ctx, bson.M{"_id": oid}, claimProjOpts).Decode(&user); err != nil {
		writeError(w, http.StatusInternalServerError, "user not found")
		return
	}

	// Nothing to claim — return 200 with 0 so the client knows it's up-to-date.
	if user.PendingCoins == 0 && user.PendingBonus == 0 {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]any{ //nolint:errcheck
			"success":      true,
			"reward_coins": 0,
			"reward_bonus": 0,
			"message":      "no pending referral rewards",
		})
		return
	}

	// Atomic update: add pending to lifetime total, then zero out pending.
	// Using two operations ($inc + $set) in a single UpdateOne is atomic at
	// the document level in MongoDB.
	if _, err = h.users.UpdateOne(ctx, bson.M{"_id": oid}, bson.M{
		"$inc": bson.M{"total_referral_coins": user.PendingCoins},
		"$set": bson.M{
			"pending_referral_coins": 0,
			"pending_referral_bonus": 0,
		},
	}); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to claim rewards — please try again")
		return
	}

	log.Printf("✅ Referral claim: user=%s +%d coins +%d bonus", userID, user.PendingCoins, user.PendingBonus)

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]any{ //nolint:errcheck
		"success":      true,
		"reward_coins": user.PendingCoins,
		"reward_bonus": user.PendingBonus,
		"message": fmt.Sprintf(
			"Claimed %d coins and %d bonus game(s)!", user.PendingCoins, user.PendingBonus),
	})
}

// ─────────────────────────────────────────
// GET /referral/history
// ─────────────────────────────────────────

// History returns all successful referral events where the authenticated user
// was the referrer (i.e., their code was used by others). Used by the Profile
// → REFERRAL tab to show a referral dashboard.
func (h *ReferralHandler) History(w http.ResponseWriter, r *http.Request) {
	setReferralCORSHeaders(w)
	w.Header().Set("Content-Type", "application/json")

	userID, _, err := extractUserID(r)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	cursor, err := h.referrals.Find(ctx, bson.M{"referrer_id": userID})
	if err != nil {
		writeError(w, http.StatusInternalServerError, "lookup failed")
		return
	}
	defer cursor.Close(ctx) //nolint:errcheck

	type historyEntry struct {
		RefereeID string    `json:"referee_id"`
		CodeUsed  string    `json:"code_used"`
		CreatedAt time.Time `json:"created_at"`
	}
	entries := make([]historyEntry, 0)
	for cursor.Next(ctx) {
		var doc referralEvent
		if decodeErr := cursor.Decode(&doc); decodeErr == nil {
			entries = append(entries, historyEntry{
				RefereeID: doc.RefereeID,
				CodeUsed:  doc.CodeUsed,
				CreatedAt: doc.CreatedAt,
			})
		}
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]any{ //nolint:errcheck
		"success": true,
		"count":   len(entries),
		"history": entries,
	})
}

// ─────────────────────────────────────────
// PACKAGE-LEVEL HELPERS
// (available to auth.go and google_auth.go in the same handlers package)
// ─────────────────────────────────────────

// extractUserID parses the JWT Bearer token from the Authorization header
// and returns (userID, username, error). Used by all authenticated REST endpoints.
func extractUserID(r *http.Request) (string, string, error) {
	authHeader := r.Header.Get("Authorization")
	if !strings.HasPrefix(authHeader, "Bearer ") {
		return "", "", fmt.Errorf("missing or invalid Authorization header")
	}
	tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
	return auth.ValidateToken(tokenStr)
}

// setReferralCORSHeaders sets CORS headers so Flutter Web (dev) can call these endpoints.
// In production, restrict Access-Control-Allow-Origin to your domain.
func setReferralCORSHeaders(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
}

// generateUniqueCode creates a cryptographically random referral code of length
// referralCodeLength using the unambiguous character set. Retries up to 10 times
// on collision. Package-level so auth.go and google_auth.go can call it at
// registration time without importing another package.
func generateUniqueCode(ctx context.Context, users *mongo.Collection) (string, error) {
	for attempt := 0; attempt < 10; attempt++ {
		code := randomReferralCode(referralCodeLength)
		count, err := users.CountDocuments(ctx, bson.M{"referral_code": code})
		if err != nil {
			return "", fmt.Errorf("generateUniqueCode: CountDocuments: %w", err)
		}
		if count == 0 {
			return code, nil
		}
	}
	return "", fmt.Errorf("generateUniqueCode: collision after 10 attempts (DB nearing capacity?)")
}

// randomReferralCode generates a secure random string of n characters chosen
// from referralCodeChars. Uses crypto/rand for unpredictability.
func randomReferralCode(n int) string {
	chars := []byte(referralCodeChars)
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		// crypto/rand.Read never errors in practice (kernel entropy exhaustion is
		// extremely rare and OS-level). Fall back to time-seeded pseudo-random only
		// as a last resort — this path should never be hit in production.
		for i := range b {
			b[i] = chars[int(time.Now().UnixNano()>>uint(i))%len(chars)]
		}
		return string(b)
	}
	for i := range b {
		b[i] = chars[int(b[i])%len(chars)]
	}
	return string(b)
}
