# Home Screen — Full Stack Documentation

## What is it?

The Home Screen (`flutter-app/lib/screens/home_screen.dart`) is the primary
landing page after a user logs in. It gives a player everything they need at a
glance: who they are, how many games they can play today, their progress, and
the most important action — Play.

---

## Why a Home Screen (instead of jumping straight to matchmaking)?

Research on mobile games shows that **60–70% of daily-active users open the app
to check stats or progress**, not necessarily to play immediately. A dedicated
home screen serves this behaviour:

- **Retention signal:** Players see their streak every day they open the app.
  Even on "just checking" days, they're reminded to play to keep the streak.
- **Freemium driver:** The daily quota bar creates urgency. When nearly full,
  players feel compelled to use remaining games. When exhausted, the premium
  upsell is contextually placed right where the blocked user is looking.
- **Identity reinforcement:** Seeing your avatar, rating, and W/L record
  builds investment. Players who can see their progress are more likely to
  return.

---

## Screen Layout

```
┌─────────────────────────────┐
│  Good morning, Alice    🔔  │  ← top bar (greeting + notifications)
│                             │
│  ┌───────────────────────┐  │
│  │ 👤 Alice       ⚡PRO  │  │  ← profile card
│  │ BEGINNER  ★ 1 240     │  │
│  │ W 12  L 5  WR 70%     │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ 📅 Daily Games  2 rem │  │  ← daily quota card
│  │ ████████░░  3 / 5     │  │
│  └───────────────────────┘  │
│                             │
│  ▶ PLAY NOW                 │  ← primary CTA button
│                             │
│  🔥7d   🎮 17   🎯 70%     │  ← quick stats row
│                             │
│  ⚡ Go Premium              │  ← upsell card (free users only)
│                             │
│  🔥 7-day streak            │  ← streak card
│  "One week strong! 🔥"      │
│                             │
│  🏆 Top Players   See All → │  ← leaderboard preview
│  #1 alice   ★ 2400          │    (top 3 free / top 5 premium)
│  #2 bob     ★ 2100          │
│  #3 charlie ★ 1900          │
│  [ Upgrade to see top 5 ]   │  ← only for free users
│                             │
└─────────────────────────────┘
│ 🏠 Home │ ▶ Play │ 🏆 LB │ 👤 │  ← bottom navigation
└─────────────────────────────┘
```

---

## Sections

### 1. Top Bar

**File:** `_TopBar` widget in `home_screen.dart:70`

**What:** Shows a time-sensitive greeting ("Good morning/afternoon/evening") with
the user's first name, and a notification bell icon (placeholder).

**Why:** Personalised greetings increase the perception that the app "knows" the
user. The bell is a placeholder for a future notification centre (tournament
invites, friend challenges).

**Real-world example:**
```
Good morning, Alice     🔔
```
At 9 AM. At 3 PM it shows "Good afternoon, Alice". At 8 PM: "Good evening".

---

### 2. Profile Card

**File:** `_ProfileCard` widget in `home_screen.dart:128`

**What:** Avatar (Google photo or initial letter), username, tier badge, rating,
W/L record, premium badge.

**Why show W/L here:**
Win/loss record is the single number players care most about. Showing it
prominently on the main screen gives a reason to come back and improve it.

**Avatar strategy:**
- `pictureUrl` set (Google user) → `CachedNetworkImage` with circular clip
- `pictureUrl` null (email/password user) → first letter of username on coral background
- If image fails to load → same initial letter fallback

**Tier system:**

| Rating | Tier | Colour |
|---|---|---|
| 0 – 49 999 | BEGINNER | White |
| 50 000 – 99 999 | INTERMEDIATE | Teal |
| 100 000 – 149 999 | ADVANCED | Blue |
| 150 000 – 199 999 | EXPERT | Purple |
| 200 000 – 249 999 | MASTER | Gold |
| 250 000+ | GRANDMASTER | Coral |

Tiers use ranges of 50 000 rating points so players have long-term goals.

**Real-world example:**
A new player starts at rating 1 000 as BEGINNER. After grinding to 50 000 (takes
months of wins), their badge turns teal and reads "INTERMEDIATE". This visible
progression is the core engagement loop.

---

### 3. Daily Quota Card

**File:** `_DailyQuotaCard` widget in `home_screen.dart:265`

**What:** A horizontal progress bar showing how many of 5 daily free games have
been used. Premium users see an "Unlimited games ∞" variant.

**Why freemium quota:**
- Creates scarcity → makes each game feel more valuable
- At 4/5, the user feels pressure to use the last game today
- At 5/5, the Play button locks → optimal moment for upsell conversion
- Resets at midnight (date-based, not 24h rolling) → feels fair

**State source:** `auth.dailyQuizUsed` and `auth.dailyQuizRemaining` from `AuthState`.

**Reset logic (in `auth_service.dart`):**
```dart
// _loadLocalStats() — called after every login
final savedDqDate = prefs.getString('${key}_dq_date');
final dqUsed = savedDqDate == _today()       // today's date "2024-01-15"
    ? (prefs.getInt('${key}_dq_used') ?? 0)  // use saved count
    : 0;                                      // new day → reset to 0
```

**Real-world example:**
Alice played 3 games at 11 PM. She comes back at 12:05 AM the next day. The bar
resets to 0/5. She can play 5 fresh games.

---

### 4. Play Button

**File:** `_PlayButton` widget in `home_screen.dart:370`

**What:** Full-width button. Label changes based on quota:
- Quota available → `▶ Play Now` (coral, active)
- Quota exhausted → `🔒 Upgrade to Play More` (dimmed, disabled)

**Why not an alert:**
When the quota is exhausted, showing a modal alert is annoying. Instead,
the button label communicates the next action directly. The premium upsell
card is visible just below, so the user knows exactly what to do.

**Navigation:** Taps `context.goNamed('matchmaking')` — the Play button
does **not** call `consumeDailyQuiz()`. The quota is consumed in
`matchmaking_screen.dart → _onMatchFound()` the moment a match is confirmed,
so a failed matchmaking attempt (no opponents found, timeout) does not waste a daily game.

---

### 5. Quick Stats Row

**File:** `_QuickStats` widget in `home_screen.dart:430`

**What:** Three small tiles: current day streak, total matches played, win rate.

**Why these three:**
- **Streak** → daily return driver
- **Matches played** → progress / investment (sunk cost = retention)
- **Win rate** → skill signal, most players want to see this improve

---

### 6. Premium Upsell Card

**File:** `_PremiumUpsellCard` widget in `home_screen.dart:487`

**What:** Gold-tinted card with "Go Premium — Unlimited games · Priority queue".
Only shown to free users (`!auth.isPremium`).

**When it appears:** Always visible to free users. Becomes especially prominent
when the Play button is locked (quota exhausted) — the user scrolls down and
immediately sees the upgrade option.

**Demo mode:** Tapping calls `authProvider.notifier.togglePremium()` which flips
`isPremium` in SharedPreferences. In production this would open an in-app purchase
or Stripe checkout flow.

---

### 7. Streak Card

**File:** `_StreakCard` widget in `home_screen.dart:560`

**What:** Fire icon + current streak count + motivational message + personal best.

**Streak messages by milestone:**

| Streak | Message |
|---|---|
| 0 | "Play a game to start your streak!" |
| 1–2 | "Just getting started — keep it up!" |
| 3–6 | "You're on a roll! Don't stop now." |
| 7–13 | "One week strong! 🔥" |
| 14–29 | "Two-week warrior! Incredible." |
| 30+ | "UNSTOPPABLE. Legendary streak!" |

**How streak is incremented:** `recordMatchResult()` → `_updateDailyStreak()`
in `auth_service.dart`. Streak only increases once per calendar day regardless
of how many matches are played.

---

### 8. Leaderboard Preview

**File:** `_LeaderboardPreview` widget in `home_screen.dart`

**What:** A compact ranked list of top players fetched from `GET /leaderboard` (matchmaking service, port 8080). Uses `globalLeaderboardProvider` (same as the full leaderboard screen).

**Free vs Premium:**
- Free users see **top 3** with a "Upgrade to see top 5" nudge at the bottom
- Premium users see **top 5** with no restriction banner

**"See All" link:** navigates to `/global-leaderboard`.

**Error state:** Shows a soft "server may be offline" message — never crashes or blocks the rest of the home screen.

---

### 9. Bottom Navigation

**File:** `_BottomNav` widget in `home_screen.dart`

**Tabs:**

| Tab | Icon | Route | Notes |
|---|---|---|---|
| Home | 🏠 | `/home` | Already here (no-op) |
| Play | ▶ | `/matchmaking` | `go` replaces stack; back button in matchmaking takes user back |
| Leaderboard | 🏆 | `/global-leaderboard` | Global ratings board from MongoDB |
| Profile | 👤 | `/profile` | Full profile screen (pushed, back works) |

**Why not use a ShellRoute:**
A `StatefulShellRoute` would preserve scroll position across tabs and is the
correct long-term approach. For now a standalone `BottomNavigationBar` keeps
the code simple without requiring all routes to be refactored into a shell.

---

## State

All state comes from `authProvider` (Riverpod `StateNotifierProvider<AuthNotifier, AuthState>`).
The home screen is a pure projection — no local `setState` calls.

**Key `AuthState` fields used:**

| Field | Source | Purpose |
|---|---|---|
| `username` | login | Greeting + profile card |
| `pictureUrl` | Google login | Avatar |
| `rating` | login / match result | Rating display + tier |
| `isPremium` | SharedPreferences | Quota / upsell visibility |
| `dailyQuizUsed` | SharedPreferences (date-reset) | Progress bar |
| `matchesPlayed`, `matchesWon` | SharedPreferences | W/L record |
| `currentStreak`, `maxStreak` | SharedPreferences | Streak card |

---

## Navigation into the Home Screen

**From login:** Both Google and email/password paths call `context.goNamed('home')`
on success.

**Redirect guard (main.dart):**
```dart
// Logged in — don't stay on login; send to home
if (auth.isLoggedIn && path == '/login') {
  return '/home';
}
```

Game routes (`/quiz`, `/leaderboard`, `/spectating`, `/results`) still require an
active `roomId` — they redirect to `/matchmaking` if none is set. The home screen
has no such guard, so it is always accessible when logged in.

---

## Real-World Walkthrough

**Morning session (day 5):**
1. Alice opens the app at 8 AM. She's greeted: "Good morning, Alice".
2. Profile card shows: BEGINNER · ★ 1 240 · W 12 L 5 · WR 70%.
3. Quota card shows: 2/5 games played today · 3 remaining.
4. She taps "▶ Play Now" → matchmaking screen.
5. She wins. ResultsScreen calls `recordMatchResult(won: true)`. Rating → 1 265.
6. She plays 2 more games (now 4/5).
7. Streak card shows: 5-day streak · "You're on a roll!"

**Evening — quota exhausted:**
8. She plays her 5th game (5/5). Play button dims → "🔒 Upgrade to Play More".
9. The Premium card is visible below. She taps it.
10. In production this opens Stripe. In the demo, premium is toggled on instantly.
11. Quota card changes to "Unlimited games ∞". Play button re-enables.

**Next morning:**
12. She opens the app at 7 AM. Quota resets to 0/5. Streak card shows 6-day streak.
