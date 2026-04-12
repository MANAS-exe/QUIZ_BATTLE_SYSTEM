# Home Screen — Full Stack Documentation

## What is it?

The Home Screen (`flutter-app/lib/screens/home_screen.dart`) is the primary
landing page after a user logs in. It gives a player everything they need at a
glance: who they are, how many games they can play today, their progress, the
most important action (Play), and their daily reward if unclaimed.

---

## Why a Home Screen (instead of jumping straight to matchmaking)?

Research on mobile games shows that **60–70% of daily-active users open the app
to check stats or progress**, not necessarily to play immediately. A dedicated
home screen serves this behaviour:

- **Retention signal:** Players see their streak every day they open the app.
  Even on "just checking" days, they're reminded to play to keep the streak.
- **Daily reward hook:** The popup appears on first open of the day — immediately
  rewarding the user for coming back. This creates a Pavlovian loop: open app → get reward.
- **Freemium driver:** The daily quota bar creates urgency. When nearly full,
  players feel compelled to use remaining games. When exhausted, the premium
  upsell is contextually placed right where the blocked user is looking.
- **Identity reinforcement:** Seeing your avatar, rating, and W/L record builds
  investment. Players who can see their progress are more likely to return.

---

## Widget Type

`HomeScreen` is a `ConsumerStatefulWidget` (not `ConsumerWidget`).

**Why stateful?**
The daily reward popup must be shown in `initState` via `addPostFrameCallback`.
This requires a `State` object with a `BuildContext` and lifecycle. A
`ConsumerWidget` has no `initState` — the popup trigger would have to live in
`build()`, which fires on every rebuild (showing the dialog repeatedly).

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    final reward = ref.read(authProvider).pendingReward;
    if (reward != null) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _DailyRewardDialog(reward: reward),
      );
    }
  });
}
```

`addPostFrameCallback` defers the dialog until the widget tree is fully built,
preventing the "can't show dialog during build" error.

---

## Screen Layout

```
┌─────────────────────────────────┐
│  Good morning, Alice   🔥7  🔔  │  ← top bar (greeting + streak pill + bell)
│                                 │
│  ┌─────────────────────────┐    │
│  │ 👤 Alice       ⚡PRO    │    │  ← profile card
│  │ BEGINNER  ★ 1 240       │    │
│  │ W 12  L 5  WR 70%       │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 📅 Daily Games  2 rem   │    │  ← daily quota card
│  │ ████████░░  3/5  +2 bonus│   │    (shows bonus games if any)
│  └─────────────────────────┘    │
│                                 │
│  ▶ PLAY NOW                     │  ← primary CTA button
│                                 │
│  🔥7d   🎮 17   🎯 70%         │  ← quick stats row
│                                 │
│  ⚡ Go Premium                  │  ← upsell (free users without active trial)
│                                 │
│  🔥 7-day streak                │  ← streak card
│  "One week strong! 🔥"          │
│                                 │
│  🏆 Top Players   See All →     │  ← leaderboard preview
│  #1 alice   ★ 2400              │    (top 3 free / full list premium)
│  #2 bob     ★ 2100              │
│  ...                            │
└─────────────────────────────────┘
│ 🏠 Home │ ▶ Play │ 🏆 LB │ 👤 │  ← bottom navigation
└─────────────────────────────────┘
```

On first open of the day (if `pendingReward != null`), a modal dialog appears
before any of the above is interactable:

```
          ┌───────────────────────┐
          │        🔥             │  ← pulsing flame (or trophy for milestones)
          │   Day 3 Streak!       │
          │  100 coins + 1 game   │
          │  [💰 +100]  [🎮 +1]  │  ← reward chips
          │  [Later]  [Claim ✓]  │
          └───────────────────────┘
```

---

## Sections

### 1. Top Bar

**File:** `_TopBar` widget

**What:** Shows a time-sensitive greeting ("Good morning/afternoon/evening") with
the user's first name. When `currentStreak > 0`, a **flame pill** is shown to
the left of the notification bell:

```
Good morning, Alice    🔥 7    🔔
```

**Streak pill design:**
- Orange background tint, orange border
- `Icons.local_fire_department_rounded` + streak number
- Only rendered when `auth.currentStreak > 0` (no clutter for new users)
- Informational only — tapping does nothing (users navigate to Profile → STREAK tab for details)

**Why the streak is in the top bar:**
The top bar is the first thing the eye lands on. Showing the streak here creates
an immediate "don't break it" feeling before the user reads anything else on
the screen.

---

### 2. Profile Card

**File:** `_ProfileCard` widget

**What:** Avatar (Google photo or initial letter), username, tier badge, rating,
W/L record, premium badge.

**Avatar strategy:**
- `pictureUrl` set (Google user) → `CachedNetworkImage` with circular clip + initials fallback
- `pictureUrl` null (email/password user) → first letter of username on coral background
- Consistent across Home / Matchmaking / Profile screens

**Tier system:**

| Rating | Tier | Colour |
|---|---|---|
| 0 – 49 999 | BEGINNER | White |
| 50 000 – 99 999 | INTERMEDIATE | Teal |
| 100 000 – 149 999 | ADVANCED | Blue |
| 150 000 – 199 999 | EXPERT | Purple |
| 200 000 – 249 999 | MASTER | Gold |
| 250 000+ | GRANDMASTER | Coral |

---

### 3. Daily Quota Card

**File:** `_DailyQuotaCard` widget

**What:** A horizontal progress bar showing how many of 5 daily free games have
been used. Bonus games (earned from daily rewards) are shown inline.

**Variants:**
- `isEffectivelyPremium == true` → "Unlimited games ∞" (gold tinted card)
- Free user with bonus games → shows `X / 5 games played today  ·  +N bonus`
- Free user exhausted → red border, lock icon, "Limit reached"

**Note:** The check is `auth.isEffectivelyPremium`, **not** `auth.isPremium`.
This means users on a day-30 streak premium trial see the unlimited variant even
if they haven't paid.

**Reset logic:**
```dart
// _loadLocalStats() — called after every login
final savedDqDate = prefs.getString('${key}_dq_date');
final dqUsed = savedDqDate == _today()
    ? (prefs.getInt('${key}_dq_used') ?? 0)
    : 0;  // new day → reset to 0
```

**Bonus games:**
Bonus games from daily rewards are consumed first (before `dailyQuizUsed`
increments). A user with 2 bonus games and 0 used gets effectively 7 games
today (5 free + 2 bonus), shown as `0 / 5  ·  +2 bonus`.

---

### 4. Play Button

**File:** `_PlayButton` widget

**What:** Full-width button. Label changes based on quota:
- Quota available → `▶ Play Now` (coral, active)
- Quota exhausted → `🔒 Upgrade to Play More` (dimmed, disabled)

**Why not an alert:**
When the quota is exhausted, showing a modal alert is annoying. Instead,
the button label communicates the next action directly. The premium upsell
card is visible just below.

**Navigation:** Taps `context.goNamed('matchmaking')`. The Play button does
**not** call `consumeDailyQuiz()`. The quota is consumed in
`matchmaking_screen.dart → _onMatchFound()` the moment a match is confirmed,
so a failed matchmaking attempt (no opponents found, timeout) does not waste a daily game.

**Exhaustion check:** Uses `auth.isQuotaExhausted`, which is only `true` when
`!isEffectivelyPremium AND dailyQuizUsed >= 5 AND bonusGamesRemaining == 0`.

---

### 5. Quick Stats Row

**File:** `_QuickStats` widget

**What:** Three small tiles: current login streak, total matches played, win rate.

**Why these three:**
- **Streak** → daily return driver ("don't break the chain")
- **Matches played** → progress / investment
- **Win rate** → skill signal, most players want to see this improve

---

### 6. Premium Upsell Card

**File:** `_PremiumUpsellCard` widget

**What:** Gold-tinted card with "Go Premium — Unlimited games · Priority queue".

**Visibility condition:** `!auth.isEffectivelyPremium` — hidden for both paid
premium users **and** users on an active premium trial.

**Tap action:** Opens `premium_screen.dart` (Razorpay checkout).

---

### 7. Streak Card

**File:** `_StreakCard` widget

**What:** Fire icon + current login streak count + motivational message + personal best.

**How streak is incremented:** On login via `_updateLoginStreak()` in
`auth_service.dart`. The streak increments **once per calendar day** when the
user opens the app. It does **not** require playing a match.

**Streak messages:**

| Streak | Message |
|---|---|
| 0 | "Play a game to start your streak!" |
| 1–2 | "Just getting started — keep it up!" |
| 3–6 | "You're on a roll! Don't stop now." |
| 7–13 | "One week strong! 🔥" |
| 14–29 | "Two-week warrior! Incredible." |
| 30+ | "UNSTOPPABLE. Legendary streak!" |

---

### 8. Leaderboard Preview

**File:** `_LeaderboardPreview` widget

**What:** A compact ranked list of top players. Uses `globalLeaderboardProvider`.

**Free vs Effectively Premium:**
- Free users (and expired trials) → **top 3** + "Upgrade to see full rankings"
- Effectively premium users → **full list**, no restriction banner

The check is `auth.isEffectivelyPremium`, so premium trial users also get the
full leaderboard.

---

### 9. Bottom Navigation

**File:** `_BottomNav` widget

| Tab | Icon | Route |
|---|---|---|
| Home | 🏠 | `/home` (already here, no-op) |
| Play | ▶ | `/matchmaking` |
| Leaderboard | 🏆 | `/global-leaderboard` |
| Profile | 👤 | `/profile` |

---

### 10. Daily Reward Dialog

**File:** `_DailyRewardDialog` + `_RewardChip` widgets

**Trigger:** `HomeScreen.initState` → `addPostFrameCallback` → checks
`authProvider.pendingReward != null`.

`pendingReward` returns non-null when:
1. `isLoggedIn == true`
2. `currentStreak > 0`
3. `dailyRewardClaimedDate != today`

**Cannot be dismissed by tapping outside** (`barrierDismissible: false`).
This ensures the user consciously claims or skips — not accidentally dismissed.

**Buttons:**
- **Later** — closes without claiming. `dailyRewardClaimedDate` stays unset,
  so the popup reappears next time the home screen is built during the same day.
- **Claim Reward** — calls `ref.read(authProvider.notifier).claimDailyReward()`,
  then pops the dialog. The reward is now reflected immediately in `AuthState`
  (coins, bonusGames, premiumTrial).

**Milestone styling:** Day 7, 14, and 30 use a gold theme with a trophy icon
instead of the default coral + flame. This makes milestones feel special.

**Reward chips:** One chip per reward type (coins, bonus games, badge, premium trial),
shown in a `Wrap` so they flow onto multiple lines on small screens.

---

## State

All state comes from `authProvider` (Riverpod `StateNotifierProvider<AuthNotifier, AuthState>`).

**Key `AuthState` fields used by the home screen:**

| Field | Purpose |
|---|---|
| `username`, `pictureUrl` | Greeting + profile card + avatar |
| `rating` | Rating display + tier |
| `isPremium` | Profile card badge |
| `isEffectivelyPremium` | Quota card variant, upsell visibility, leaderboard limit |
| `dailyQuizUsed`, `bonusGamesRemaining` | Quota card progress bar + bonus label |
| `dailyQuizRemaining`, `isQuotaExhausted` | Play button state |
| `currentStreak`, `maxStreak` | Streak pill in top bar + streak card |
| `coins` | (accessed via Profile → STREAK tab) |
| `pendingReward` | Daily reward popup trigger |
| `matchesPlayed`, `matchesWon` | Quick stats + W/L record |

---

## Navigation into the Home Screen

**From login:** Both Google and email/password paths call `context.goNamed('home')`
on success.

**Redirect guard (`main.dart`):**
```dart
if (auth.isLoggedIn && path == '/login') return '/home';
```

**Back button:** `PopScope(canPop: false)` prevents the Android back gesture
from popping to `/login`, which would redirect back to `/home` in an infinite loop.

---

## Real-World Walkthroughs

### Day 3 — first daily reward

1. Alice opens the app. It's her 3rd consecutive day.
2. Home screen builds. `pendingReward` returns `DailyReward(coins:100, bonusGames:1, title:"Day 3 Streak!")`.
3. Dialog appears automatically: "🔥 Day 3 Streak! · 100 coins + 1 bonus game".
4. She taps **Claim Reward**. `claimDailyReward()` runs:
   - `coins` goes from 75 → 175
   - `bonusGamesRemaining` goes from 0 → 1
   - `dailyRewardClaimedDate` = today
5. Dialog closes. Quota card now shows `0 / 5  ·  +1 bonus`.

### Day 7 — Week Warrior milestone

1. Streak reaches 7. Dialog shows with **gold** theme, trophy icon.
2. Reward: 250 coins + 3 bonus games + "Week Warrior" badge.
3. User claims. Flame pill in top bar shows `🔥 7`.
4. Badge appears unlocked in Profile → BADGES tab.

### Quota exhausted → upsell

1. Bob has played 5/5 free games (no bonus games).
2. Play button shows "🔒 Upgrade to Play More".
3. `_PremiumUpsellCard` is visible below.
4. Bob taps it → `premium_screen.dart` → Razorpay.
5. After payment, `setPremium(true)` → `isEffectivelyPremium == true`.
6. Quota card changes to "∞ Unlimited games". Play button re-enables.

### Premium trial (day-30 streak reward)

1. Carol reaches a 30-day streak. Reward dialog shows gold theme with bolt icon.
2. Reward: 1000 coins + 7 bonus games + 7-day Premium trial + "Monthly Master" badge.
3. She claims. `premiumTrialExpiresAt` = 7 days from now.
4. `isEffectivelyPremium` returns `true` (trial active).
5. Premium upsell card disappears. Leaderboard preview shows full rankings.
6. 7 days later the trial expires. `isEffectivelyPremium` returns `false` again.
   The upsell card reappears. No logout required.
