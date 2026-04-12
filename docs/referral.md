# Referral System — Full Stack Documentation

## What it is

Every user gets a unique 6-character referral code (e.g. `QB4X9K`). When a
**new** user signs up and enters a friend's code during registration, both
parties earn in-app rewards (coins + bonus games).

---

## Why a Referral System?

| Problem | How the referral system solves it |
|---|---|
| New user acquisition | Existing players become incentivised brand ambassadors |
| Cold-start (no opponents) | More registered players = shorter matchmaking queues |
| Retention | Referrer has social stake in the invited friend's activity |
| Coins utility | Gives users a reason to share outside the app |

---

## Flow Diagram

```
Referrer (Alice)               Backend (Go, :8080)            MongoDB
    │                                │                            │
    │  GET /referral/code ──────────►│                            │
    │◄── { code: "QB4X9K", ... } ────│◄── users.referral_code ────│
    │                                │                            │
    │  Shares "QB4X9K" to Bob        │                            │
    │  (copy link, WhatsApp, etc.)   │                            │
    │                                │                            │
Referee (Bob — new user)            │                            │
    │                                │                            │
    │  Registers with email/password  │                            │
    │  + enters "QB4X9K" in form     │                            │
    │                                │                            │
    │  POST /auth/register ─────────►│                            │
    │◄── { token, user_id } ─────────│─── InsertOne (new user) ──►│
    │                                │    (referral_code generated)│
    │                                │                            │
    │  POST /referral/apply ────────►│                            │
    │  { "code": "QB4X9K" }          │  FindOne {referral_code}──►│
    │                                │  Anti-abuse checks          │
    │                                │  InsertOne referrals ──────►│
    │                                │  UpdateOne referee          │
    │                                │  (pending_coins +100) ─────►│
    │                                │  UpdateOne referrer         │
    │                                │  (referral_count +1,        │
    │                                │   pending_coins +200) ─────►│
    │◄── { success, reward_coins,    │                            │
    │      reward_bonus, message } ──│                            │
    │                                │                            │
    │  GET /referral/claim ─────────►│                            │
    │  (both Alice and Bob call      │  UpdateOne: clear pending   │
    │   this to collect rewards)     │  → total_referral_coins ──►│
    │◄── { reward_coins, reward_     │                            │
    │      bonus, message } ─────────│                            │
    │                                │                            │
    │  Flutter applies +coins,       │                            │
    │  +bonus to local AuthState     │                            │
```

---

## Reward Structure

| Who | Trigger | Coins | Bonus Games |
|-----|---------|-------|-------------|
| **Referrer** (shared the code) | Referee applies the code | +200 | +2 |
| **Referee** (new user) | Applies referral code at registration | +100 | +1 |

Rewards are held **pending** on the server until the user taps **Claim** in
Profile → REFERRAL. This is the same pattern as the daily reward claim — the
server is the source of truth for referral ledger state, while the local
`AuthState` holds the coin/bonus balance.

---

## Code Format

- **Length:** 6 characters
- **Character set:** `ABCDEFGHJKMNPQRSTUVWXYZ23456789` (31 chars)
  - Excludes ambiguous characters: `0`, `O`, `1`, `I`, `L`
  - Ensures users can read and dictate codes without confusion
- **Entropy:** 31⁶ ≈ 887 million combinations — negligible collision probability
- **Example:** `QB4X9K`, `RM3ATZ`, `PH7N2K`
- **Generation:** `crypto/rand` for cryptographic unpredictability

---

## Anti-Abuse Rules (all enforced server-side)

| Rule | Check | Error |
|------|-------|-------|
| 1. No double-dipping | `referred_by` must be empty | 409 Conflict |
| 2. Time window | Account must be ≤7 days old when applying | 403 Forbidden |
| 3. Self-referral | Referrer's userId ≠ Referee's userId | 400 Bad Request |
| 4. Referrer cap | Referrer's `referral_count` must be < 10 | 403 Forbidden |
| 5. Code format | Code must be exactly 6 uppercase alphanumeric chars | 400 Bad Request |

**Why these rules?**

- **Rule 1 (no double-dipping):** A user can only be "new" once. Retroactively
  applying multiple codes to maximise coin income is blocked.
- **Rule 2 (time window):** Prevents old dormant accounts from suddenly
  applying codes. The 7-day window covers the realistic delay between receiving
  a code and registering.
- **Rule 3 (self-referral):** A user would otherwise create a second account,
  apply their own code, and earn 200 coins for free.
- **Rule 4 (cap):** Limits coordinated farming where one user creates many fake
  accounts to refer themselves. Even with 10 fakes the payoff (2000 coins) is
  low relative to the effort.
- **Rule 5 (code format):** Fails fast before any DB lookup; prevents injection
  via oversized strings.

### Already-Registered Users

Users who existed before the referral system was added:

- **Can share their code** — their code is generated lazily on the first call
  to `GET /referral/code` and saved permanently.
- **Cannot apply a referral code** — their account creation date is older than
  the 7-day window, so Rule 2 blocks this. This is intentional: they are not
  new users.

---

## API Endpoints

All endpoints live on the matchmaking service (port **8080**), authenticated
with `Authorization: Bearer <JWT>`.

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/referral/code` | JWT | Get or lazily-generate the user's code + stats |
| `POST` | `/referral/apply` | JWT | Apply a friend's code (new users, ≤7 days old) |
| `GET` | `/referral/claim` | JWT | Claim pending rewards (idempotent) |
| `GET` | `/referral/history` | JWT | List referrals made by this user |

### GET /referral/code

```json
{
  "success": true,
  "code": "QB4X9K",
  "referral_count": 3,
  "pending_coins": 600,
  "pending_bonus": 6,
  "total_coins_earned": 400,
  "already_referred": false
}
```

- `pending_coins` / `pending_bonus`: rewards waiting to be claimed via
  `GET /referral/claim`.
- `already_referred`: true if this user applied someone else's code.
- Flutter calls this on every login via `_syncReferralFromServer()`.

### POST /referral/apply

**Request body:**
```json
{ "code": "QB4X9K" }
```

**Success (200):**
```json
{
  "success": true,
  "reward_coins": 100,
  "reward_bonus": 1,
  "message": "Referral applied! You earned 100 coins and 1 bonus game. Claim them from your profile."
}
```

**Error responses:**
- `400 Bad Request` — wrong code format or self-referral
- `403 Forbidden` — account too old or referrer at cap
- `404 Not Found` — code doesn't exist
- `409 Conflict` — already used a referral code

### GET /referral/claim

**Success with rewards (200):**
```json
{
  "success": true,
  "reward_coins": 200,
  "reward_bonus": 2,
  "message": "Claimed 200 coins and 2 bonus game(s)!"
}
```

**Success with no rewards (200):**
```json
{
  "success": true,
  "reward_coins": 0,
  "reward_bonus": 0,
  "message": "no pending referral rewards"
}
```

Calling this multiple times is safe — once pending is zeroed out, subsequent
calls return 0.

### GET /referral/history

```json
{
  "success": true,
  "count": 3,
  "history": [
    { "referee_id": "abc123", "code_used": "QB4X9K", "created_at": "2026-04-13T..." },
    ...
  ]
}
```

---

## MongoDB Schema

### users collection (new fields)

| Field | Type | Description |
|-------|------|-------------|
| `referral_code` | `string` | Unique 6-char code. Sparse unique index — null/missing OK for legacy docs |
| `referred_by` | `string` | userId of who referred this user. Empty = not referred |
| `referral_count` | `int` | Successful referrals made by this user (capped at 10) |
| `pending_referral_coins` | `int` | Coins waiting to be claimed via `/referral/claim` |
| `pending_referral_bonus` | `int` | Bonus games waiting to be claimed |
| `total_referral_coins` | `int` | Lifetime coins earned from referrals (after claiming) |

### referrals collection (new)

```json
{
  "_id": "ObjectId",
  "referrer_id": "userId-of-Alice",
  "referee_id": "userId-of-Bob",
  "code_used": "QB4X9K",
  "created_at": "2026-04-13T10:30:00Z"
}
```

**Indexes:**
```js
// Unique sparse — allows null but prevents duplicate codes among set values
db.users.createIndex({ referral_code: 1 }, { unique: true, sparse: true });

// Fast history lookup (all referrals by a given referrer)
db.referrals.createIndex({ referrer_id: 1 });

// Ensures each user can only be referred once
db.referrals.createIndex({ referee_id: 1 }, { unique: true });
```

---

## Flutter Integration

### AuthState new fields

| Field | Type | Description |
|-------|------|-------------|
| `referralCode` | `String?` | The user's own 6-char code; null until first server sync |
| `referralCount` | `int` | Successful referrals made |
| `totalReferralCoins` | `int` | Lifetime coins earned from referrals |
| `hasPendingReferralReward` | `bool` | True when server has unclaimed rewards |

### AuthNotifier methods

| Method | Description |
|--------|-------------|
| `_syncReferralFromServer()` | Called after every login. Fetches code + stats; falls back to SharedPreferences cache on network error |
| `applyReferralCode(String code)` | POSTs to `/referral/apply`; returns null on success or error string. Called from login screen after registration |
| `claimReferralRewards()` | GETs `/referral/claim`; applies granted coins + bonus to local state; returns null or error string |

### Login flow sequence (email/password)

```
register() → _loadLocalStats() → _syncPremiumFromServer()
  → _syncReferralFromServer()          ← fetches code + pending rewards
  → applyReferralCode(code) [if entered] ← applies friend's code silently
  → navigate to /home
```

For Google sign-in, the same sequence applies (minus `applyReferralCode` at
login time — Google new users apply their code from Profile → REFERRAL tab
within 7 days).

### SharedPreferences keys

| Key | Type | Description |
|-----|------|-------------|
| `stats_{userId}_referralCode` | `String` | Cached referral code (for offline display) |
| `stats_{userId}_referralCount` | `int` | Cached referral count |
| `stats_{userId}_totalReferralCoins` | `int` | Cached lifetime coins from referrals |

---

## UI Components

### Home Screen — Referral Share Card (`_ReferralShareCard`)

- Shown below the Streak Card when `auth.referralCode != null`
- Displays the code with a one-tap **Copy** button
- Tapping the card body navigates to Profile → REFERRAL tab
- Uses `GestureDetector.onTap` → `context.goNamed('profile')`

```
┌─────────────────────────────────────────┐
│ 🎁  Invite friends, earn coins          │
│     Your code: QB4X9K        [Copy]    │
└─────────────────────────────────────────┘
```

### Profile Screen — REFERRAL Tab (5th tab)

Sections in order:

1. **Your Referral Code card** — large code with copy button
2. **Referral Stats row** — Friends Invited / Coins Earned / Slots Left
3. **Pending Rewards card** — shown when `hasPendingReferralReward == true`; gold card with **Claim** button
4. **Apply a code section** — shown when user hasn't applied a code; 6-char text field + Apply button
5. **How it Works** — 4-step explanation (share → friend registers → both earn → limits)

### Registration Form (Login Screen)

When `_isRegister == true`, a new optional field appears below the password field:

```
┌─────────────────────────────────────────┐
│ 🎁 Referral code (optional)             │
└─────────────────────────────────────────┘
```

- Auto-capitalised
- After successful registration, if the field is non-empty, `applyReferralCode()`
  is called fire-and-forget (errors are logged, not surfaced — a bad code
  shouldn't block the user from entering the app)

---

## Edge Cases

| Scenario | Behaviour |
|----------|-----------|
| User leaves referral field blank | Code is not applied; user can apply from Profile later (within 7 days) |
| User types wrong code at registration | `applyReferralCode` fails silently; user can retry from Profile within 7 days |
| User types own code | Server returns 400; UI shows error in Profile tab |
| Referrer hits 10-referral cap | Server returns 403; code rejects further applications for that referrer only |
| `_syncReferralFromServer()` fails (network) | Falls back to SharedPreferences cache; `hasPendingReferralReward` stays at last known value |
| `claimReferralRewards()` called twice | Second call returns `{ reward_coins: 0 }` — no double-grant |
| User with existing email account signs in via Google | `upsertGoogleUser` links accounts; referral code was already set at original registration |
| Two users race to apply the same code simultaneously | MongoDB `referrals.referee_id` unique index blocks the second write; one succeeds, one gets a DB error → 500 |
| Referrer reward update fails after referee update | Logged with `log.Printf("⚠️ referral: reward update failed...")` for manual recovery; referee's `referred_by` is already set so the referral is not replayable |
| DB collision on code generation | `generateUniqueCode` retries up to 10 times; with 887M combinations at typical user counts, collision probability is negligible |

---

## Services to Restart

After deploying the changes:

| Service | Why | How |
|---------|-----|-----|
| **matchmaking-service** | New Go handler + 4 new REST routes | `make run-matchmaking` or `docker compose up --build matchmaking-service` |
| **Flutter app** | New Dart code; hot reload is NOT sufficient (new state fields) | Full restart: `r` → Shift+R in terminal, or stop + re-run |
| **MongoDB** | Only if running fresh from `mongo-init/init.js` (new indexes). Running instances: manually create indexes (see below) | `mongosh quizdb --eval "$(cat mongo-init/init.js)"` |

**No changes required to:** quiz-service, scoring-service, payment-service.

### Adding indexes to a running MongoDB

If MongoDB is already running with existing data, create the indexes manually:

```js
// Connect to the running instance
mongosh mongodb://localhost:27017/quizdb

// Referral code — unique sparse (allows missing field)
db.users.createIndex({ referral_code: 1 }, { unique: true, sparse: true });

// Referrals collection
db.referrals.createIndex({ referrer_id: 1 });
db.referrals.createIndex({ referee_id: 1 }, { unique: true });
```

The `sparse: true` on `referral_code` is critical: without it, MongoDB would
reject documents that don't have the field (treating two `null` values as
duplicates), breaking all pre-existing user documents.

---

## Testing

### Backend

```bash
# Register a new user (gets a referral code)
curl -X POST http://localhost:8080 ... # via gRPC-Web

# Get your referral code
curl -H "Authorization: Bearer <token>" http://localhost:8080/referral/code

# Apply a friend's code (as a new user within 7 days)
curl -X POST -H "Authorization: Bearer <referee-token>" \
  -H "Content-Type: application/json" \
  -d '{"code":"QB4X9K"}' \
  http://localhost:8080/referral/apply

# Claim pending rewards
curl -H "Authorization: Bearer <token>" http://localhost:8080/referral/claim

# View history
curl -H "Authorization: Bearer <referrer-token>" http://localhost:8080/referral/history
```

### Flutter

1. Register user A → note their referral code from Profile → REFERRAL tab
2. Register user B → enter user A's code in the "Referral code (optional)" field
3. Log in as user B → Profile → REFERRAL → tap **Claim** → coins and bonus games applied
4. Log in as user A → Profile → REFERRAL → tap **Claim** → see +200 coins +2 bonus
5. Verify Home Screen shows the referral share card with user A's code

### Anti-abuse test cases

| Test | Expected result |
|------|----------------|
| User B enters their OWN code | Error: "you cannot apply your own referral code" |
| User B enters a valid code twice | Error: "you have already applied a referral code" |
| Create user C with old `created_at` (>7 days), apply code | Error: "only within 7 days of registration" |
| Apply nonexistent code `ZZZZZZ` | Error: "invalid referral code" |
| Enter 5-char code `QB4X9` | Error: "must be exactly 6 characters" |
