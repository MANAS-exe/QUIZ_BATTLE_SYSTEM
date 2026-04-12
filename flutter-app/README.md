# Quiz Battle — Flutter App

The Flutter frontend for Quiz Battle. Connects to 3 gRPC backend services and
1 HTTP payment service.

> **Full documentation:** see the [root README](../README.md) for architecture,
> setup instructions, environment variables, and feature details.

---

## Structure

```
lib/
├── main.dart                    # GoRouter (8 routes), theme, auth init
├── models/
│   └── game_event.dart          # Sealed event classes (9 types)
├── services/
│   ├── auth_service.dart        # AuthState + AuthNotifier — JWT, Google, streaks, coins, daily rewards
│   ├── game_service.dart        # gRPC clients for 3 services (50051/50052/50053)
│   └── reconnect_service.dart   # Exponential backoff stream wrapper
├── providers/
│   └── game_provider.dart       # Game state machine (8 phases, answer streak, win streak)
├── screens/
│   ├── login_screen.dart        # Email/password + Google Sign-In
│   ├── home_screen.dart         # Dashboard — quota, streak pill, daily reward popup
│   ├── matchmaking_screen.dart  # Lobby with player avatars + countdown
│   ├── quiz_screen.dart         # Question + answers + timer
│   ├── leaderboard_screen.dart  # Between-round — answer streak + win streak badges
│   ├── results_screen.dart      # Final scores — Share / Home / Play Again
│   ├── spectating_screen.dart   # Read-only view for forfeited players
│   ├── profile_screen.dart      # 4 tabs: Profile / Last Match / Badges / Streak
│   ├── premium_screen.dart      # Razorpay checkout flow
│   └── global_leaderboard_screen.dart
└── theme/
    └── colors.dart              # App colour palette
```

---

## Running

```bash
# From this directory:
flutter pub get
flutter run -d <device-id>

# Hot restart after initState changes:
# Press Shift+R in the terminal (not 'r' hot reload)
```

---

## Tests

```bash
flutter test test/widget_test.dart
```

31 unit tests covering:
- `GameState` defaults and `copyWith`
- Win streak logic
- Daily quota + bonus games
- `isEffectivelyPremium` (including expired/malformed trial)
- `rewardForDay` reward table
- `pendingReward` edge cases
- `copyWith` sentinel for nullable `premiumTrialExpiresAt`

---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Declarative routing + auth guards |
| `grpc` / `protobuf` | gRPC client channels |
| `google_sign_in` | Google OAuth flow |
| `shared_preferences` | JWT + stats + streaks + coins local storage |
| `cached_network_image` | Google profile picture CDN caching |
| `flutter_animate` | Streak pill, reward dialog, screen entrance animations |
| `razorpay_flutter` | Razorpay payment SDK |
| `fixnum` | Int64 for protobuf timestamp fields |
| `http` | HTTP calls to payment service (:8081) and Google auth (:8080) |

---

## What services must be running

| Need | Services |
|------|---------|
| Login / register | `matchmaking-service` |
| Google Sign-In | `matchmaking-service` |
| Play a match | `matchmaking-service` + `quiz-service` + `scoring-service` + Redis + RabbitMQ + MongoDB |
| Premium / Razorpay | `payment-service` |
| Daily rewards popup | *none* — fully client-side |
| Streak calendar | *none* — fully client-side |

```bash
# Start everything (from repo root):
make infra          # MongoDB + Redis + RabbitMQ
make run-matchmaking
make run-quiz
make run-scoring
cd payment-service && go run main.go   # only if testing premium
```
