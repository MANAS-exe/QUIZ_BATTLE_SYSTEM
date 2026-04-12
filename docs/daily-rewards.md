# Daily Rewards & Login Streak

## Overview

The Daily Rewards system incentivises players to open the app every day by
granting escalating rewards for consecutive logins. A reward is granted the
**first time the user logs in on a given calendar day**. Rewards are claimed
via an animated popup that appears automatically on the home screen.

---

## Core Concepts

### Login Streak vs Answer Streak

| Term | Meaning |
|------|---------|
| **Login streak** (`currentStreak`) | Consecutive *calendar days* the user has opened the app. Incremented once per day at login time, not per match played. |
| **Answer streak** (`maxQuestionStreak`) | Consecutive correct answers within a single match. Tracked by `GameState` in `game_provider.dart`. |
| **Win streak** (`currentWinStreak`) | Consecutive rounds won (correct *and* fastest) in the current match. Also tracked by `GameState`. |

### Calendar-day granularity

Streak comparisons use `YYYY-MM-DD` date strings derived from
`DateTime.now().toIso8601String().substring(0, 10)`. This means:
- A player who opens the app at 11:58 PM and again at 12:02 AM gets credit for
  **two separate days** — the counter resets at midnight local time.
- A player who opens the app twice in the same day gets credit only **once**.

---

## Reward Table

Rewards escalate as streaks grow. Days 1–7 cycle; milestones override the
cycle on exact day numbers.

| Streak Day | Coins | Bonus Games | Badge | Premium Trial |
|------------|-------|-------------|-------|---------------|
| 1 | 50 | 0 | — | — |
| 2 | 75 | 0 | — | — |
| 3 | 100 | 1 | — | — |
| 4 | 125 | 0 | — | — |
| 5 | 150 | 2 | — | — |
| 6 | 200 | 0 | — | — |
| 7 | 250 | 3 | `week_warrior` | — |
| 14 *(milestone)* | 500 | 5 | `fortnight_fighter` | — |
| 30 *(milestone)* | 1 000 | 7 | `monthly_master` | 7 days |
| 8–13 (cycle) | day%7 row | — | — | — |
| 15–29 (cycle) | day%7 row | — | — | — |
| 31+ (cycle) | day%7 row | — | — | — |

`rewardForDay(int streakDay)` implements the lookup (milestones checked first,
then `(streakDay - 1) % 7 + 1` for the weekly cycle).

---

## Coins System

Coins are a client-side soft currency stored in `SharedPreferences` under
`stats_<userId>_coins`. They currently serve as a **progress / prestige metric**
(visible on the Profile screen) and are used to unlock future cosmetic features.

| Source | Amount |
|--------|--------|
| Daily reward (day 1) | 50 |
| Daily reward (day 7) | 250 |
| Daily reward (day 30) | 1 000 |

Coins are **additive** — they never decrease and carry over across days.

---

## Bonus Games

`bonusGamesRemaining` is an extra daily-game allowance that stacks on top of
the free quota:

```
effective quota = kFreeQuotaPerDay (5) + bonusGamesRemaining
```

When `consumeDailyQuiz()` is called:
1. If `bonusGamesRemaining > 0`, decrement bonus first.
2. Otherwise increment `dailyQuizUsed`.

Bonus games **carry over between days** (not date-reset). They expire only
when fully consumed.

`isQuotaExhausted` is true only when **both** `dailyQuizUsed >= kFreeQuotaPerDay`
**and** `bonusGamesRemaining == 0` (and user is not effectively premium).

---

## Premium Trial

`premiumTrialExpiresAt` is a nullable ISO-8601 datetime string
(`YYYY-MM-DDTHH:MM:SS`). When non-null and in the future, the user is treated
as effectively premium.

`isEffectivelyPremium` getter:
```dart
bool get isEffectivelyPremium {
  if (isPremium) return true;
  if (premiumTrialExpiresAt == null) return false;
  return DateTime.tryParse(premiumTrialExpiresAt!)?.isAfter(DateTime.now()) ?? false;
}
```

Only `isEffectivelyPremium` (not `isPremium`) is used for quota checks. When a
trial-day reward is claimed, `premiumTrialExpiresAt` is set to
`DateTime.now().add(Duration(days: rewardDays)).toIso8601String()`.

The sentinel pattern in `copyWith` lets callers **explicitly** set
`premiumTrialExpiresAt` to `null` (to clear an expired trial) without the usual
`??` short-circuit masking the null:

```dart
static const _unset = Object();

AuthState copyWith({
  Object? premiumTrialExpiresAt = _unset,
  ...
}) => AuthState(
  premiumTrialExpiresAt: premiumTrialExpiresAt == _unset
      ? this.premiumTrialExpiresAt
      : premiumTrialExpiresAt as String?,
  ...
);
```

---

## Login History

`loginHistory` is a `List<String>` of ISO date strings for the last 30 distinct
days the user opened the app. It is stored as a JSON array in SharedPreferences:

```
key: stats_<userId>_loginHistory
value: ["2026-04-01","2026-04-02","2026-04-05", ...]   // up to 30 entries
```

On every login (`_loadLocalStats`):
1. Load `loginHistory` from prefs (decode JSON; default `[]`).
2. Append today's date if not already present.
3. Truncate to the last 30 entries.
4. Compute `currentStreak` and `maxStreak` from the history.
5. Save back to prefs.

The streak computation (`_computeStreakFromHistory`) walks backwards from today:
- Count consecutive days with an entry.
- Stop as soon as a gap is found.

This approach is robust to clock drift and app uninstalls — the history is the
single source of truth.

---

## Daily Reward Claim Flow

```
Login
  └─ _loadLocalStats()
       └─ _updateLoginStreak()      // updates currentStreak, loginHistory
  └─ checkDailyReward()             // returns DailyReward? if unclaimed today

HomeScreen.initState
  └─ addPostFrameCallback
       └─ ref.read(authProvider).pendingReward != null
            └─ showDialog(_DailyRewardDialog)

_DailyRewardDialog
  └─ Tap "Claim"
       └─ ref.read(authProvider.notifier).claimDailyReward()
            └─ grants coins, bonusGames, premiumTrial
            └─ sets dailyRewardClaimedDate = today
            └─ saves to SharedPreferences
       └─ dialog dismissed
```

### `pendingReward` getter

`AuthState` exposes:
```dart
DailyReward? get pendingReward {
  if (!isLoggedIn) return null;
  if (dailyRewardClaimedDate == _today()) return null;
  if (currentStreak == 0) return null;
  return rewardForDay(currentStreak);
}
```

The popup is shown if and only if `pendingReward != null`. This prevents:
- Showing the popup on first-ever login before a streak is established.
- Showing it twice in the same day.
- Showing it while the user is logged out.

### Double-claim prevention

`dailyRewardClaimedDate` is persisted to `stats_<userId>_rewardDate`.
`claimDailyReward()` is a no-op if `dailyRewardClaimedDate == today`.

---

## SharedPreferences Keys

All keys are namespaced by user ID to support multi-account scenarios.

| Key | Type | Description |
|-----|------|-------------|
| `stats_<id>_coins` | int | Total coins earned |
| `stats_<id>_bonusGames` | int | Bonus games remaining |
| `stats_<id>_loginHistory` | String (JSON) | ISO dates of last 30 logins |
| `stats_<id>_trialExpiry` | String (ISO datetime) | Premium trial expiry; absent = no trial |
| `stats_<id>_rewardDate` | String (ISO date) | Date of last reward claim |

---

## Streak Reset Logic

| Scenario | Result |
|----------|--------|
| Login today (first of day) | Streak +1 |
| Login today (already logged in) | No change |
| Miss exactly 1 day, login today | Streak resets to 1 |
| Miss 2+ days, login today | Streak resets to 1 |

The "miss" check: if the latest entry in `loginHistory` is neither today nor
yesterday, the streak resets to 1.

---

## UI Components

### Home Screen — streak counter

A small pill in the `_TopBar` row shows the current login streak:

```
🔥 7  (flame icon + streak number)
```

Tapping it is a no-op (informational only). It does not appear if streak == 0.

### Daily Reward Popup — `_DailyRewardDialog`

Shown automatically via `showDialog` in `HomeScreen.initState`. Cannot be
dismissed by tapping outside — the user must tap **Claim** or **Skip** (skip
does not grant the reward and does not mark it as claimed, so it will reappear
on next app open during the same day).

Popup contents:
- Large animated flame / star icon (day-dependent)
- "Day N Streak!" title
- Reward breakdown: coins, bonus games, badge (if any), premium trial (if any)
- **Claim** button (coral)

### Profile Screen — STREAK tab

A 4th tab labelled **STREAK** is added to the profile `TabBar`. It contains:

1. **Streak Summary Card** — current streak, max streak, coins total
2. **30-Day Login Calendar** — 7-column grid showing the past 30 days
   - Green filled circle = logged in that day
   - Dimmed circle = missed day
   - Gold border = today
3. **Coins Card** — total coins with a brief note about upcoming uses

---

## Edge Cases

| Case | Handling |
|------|---------|
| User changes device timezone | Date strings are local-time; a 1-hour timezone shift could shift the date boundary. Acceptable trade-off — no server time dependency. |
| App killed before `claimDailyReward()` saved | `dailyRewardClaimedDate` not persisted → popup reappears next open. Idempotency: claiming again on the same day is blocked by the date check at the start of `claimDailyReward()`. |
| User claims on day 7, misses next day | Streak resets to 1 on next login. Milestone badge already awarded — badges are additive and not removed. |
| Premium trial expires mid-session | `isEffectivelyPremium` is a computed getter checked on every read, so it reflects real-time expiry without requiring a logout/login cycle. |
| `loginHistory` JSON corrupt in prefs | `jsonDecode` wrapped in try/catch; falls back to `[]`. Streak resets to 1 on next login. |
| Day-30 milestone re-claimable? | No — the table cycles back to day-1 rewards after day-30 streak. The premium trial is granted once per 30-day milestone. At day 60 another 30-day block completes and grants it again. |
| Offline login (no server) | All reward logic is entirely client-side. Works fully offline. |
