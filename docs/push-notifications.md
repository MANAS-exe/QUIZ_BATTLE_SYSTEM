# Push Notifications — Full Stack Documentation

## Architecture Overview

```
Flutter App
    │
    │  1. Login succeeds
    │  2. Request OS permission
    │  3. Get FCM token
    │  4. POST /device/token  ──────────────────────────────► matchmaking-service (:8080)
    │                                                               │
    │                                                               │ upsert device_tokens
    │                                                               ▼
    │                                                           MongoDB (device_tokens)
    │
    │  ◄──── FCM push notification ─────────────────────────── Firebase Cloud Messaging
    │                                                               ▲
    │                                                               │ Send via Admin SDK
    │                                                           notification-worker
    │                                                               ▲
    │                                              ┌────────────────┴──────────────────┐
    │                                        RabbitMQ consumers                    Cron jobs
    │                                         match.finished                      (scheduler)
    │                                         notification.*
    │
quiz-service ──► match.finished ──► RabbitMQ (sx exchange) ──► notification-match-queue
                                                              └► notification-worker-queue
```

---

## Notification Types

| Type | Trigger | Target | RabbitMQ? | Cron? |
|------|---------|--------|-----------|-------|
| `streak_warning` | 7pm IST daily | All users | No | ✅ daily |
| `daily_reward` | 8am IST daily | All users | No | ✅ daily |
| `premium_expiry` | 9am IST daily | Expiring-soon users | No | ✅ daily |
| `referral_converted` | match.finished event | Referrer only | ✅ | No |
| `tournament_reminder` | Publish notification.tournament_reminder event | All or specific users | ✅ | No |

---

## One-Time Setup

### 1. Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com) → select/create a project
2. Add Android app: package name `com.example.quiz_battle`
3. Download `google-services.json` → place at `flutter-app/android/app/google-services.json`
4. *(iOS only)* Add iOS app, download `GoogleService-Info.plist` → place at `flutter-app/ios/Runner/GoogleService-Info.plist`

### 2. Firebase Service Account (backend)

1. Firebase Console → Project Settings → Service Accounts
2. Click **Generate new private key** → download the JSON file
3. Set the environment variable (do NOT commit this file):

```bash
# For local dev — create notification-worker/.env
FIREBASE_CREDENTIALS_JSON='{ "type": "service_account", "project_id": "...", ... }'
```

For Docker Compose, set `FIREBASE_CREDENTIALS_JSON` in `docker-compose.yml` (or use a `.env` file with `env_file:` directive — never commit secrets).

### 3. Android configuration

`flutter-app/android/build.gradle.kts` (project-level) must include:
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

`flutter-app/android/app/build.gradle.kts` already includes:
```kotlin
id("com.google.gms.google-services")
```

Create `flutter-app/android/app/src/main/res/values/notification_channel.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_notification_channel_id" translatable="false">quiz_battle_channel</string>
    <string name="default_notification_channel_name" translatable="false">Quiz Battle</string>
</resources>
```

### 4. MongoDB index (if already running)

```js
mongosh mongodb://localhost:27017/quizdb
db.device_tokens.createIndex({ user_id: 1 }, { unique: true });
```

The `mongo-init/init.js` already contains this index for fresh deployments.

---

## Running the Notification Worker

### Local development

```bash
# Create .env file
cat > notification-worker/.env << 'EOF'
RABBITMQ_URL=amqp://guest:guest@localhost:5672/
MONGO_URI=mongodb://localhost:27017
FIREBASE_CREDENTIALS_JSON=<paste raw JSON here>
EOF

make run-notification-worker
```

### Docker Compose

```bash
# Set FIREBASE_CREDENTIALS_JSON in docker-compose.yml, then:
docker compose up --build notification-worker
```

### Verify it's running

Open RabbitMQ Management UI at http://localhost:15672 (guest/guest):
- Queues tab → you should see:
  - `notification-worker-queue` (bound to `notification.*`)
  - `notification-match-queue` (bound to `match.finished`)

---

## How Each Notification Works

### Streak Warning & Daily Reward (Cron)

The scheduler runs daily at fixed times (UTC). It:
1. Queries `device_tokens` for all registered tokens
2. Calls `SendMulticast` in batches of 500 (FCM limit)

Schedules (edit `notification-worker/worker/scheduler.go` → `Start()` to change):
| Job | Cron (UTC) | IST equivalent |
|-----|-----------|----------------|
| `streak_warning` | `0 30 13 * * *` | 7:00 PM |
| `daily_reward` | `0 30 2 * * *` | 8:00 AM |
| `premium_expiry` | `0 30 3 * * *` | 9:00 AM |

### Referral Conversion (Event-driven)

When `match.finished` is published to RabbitMQ:
1. Worker looks up players in `match_history`
2. For each player, checks `users.referred_by` (were they referred by someone?)
3. Checks `users.referee_first_match_notified` (already notified?)
4. Atomically sets `referee_first_match_notified = true` (prevents double-send)
5. Looks up referrer's FCM token from `device_tokens`
6. Sends: *"Your referral is paying off! Alice just completed their first quiz battle!"*

### Tournament Reminder (On-demand via RabbitMQ)

Publish a `notification.tournament_reminder` event to trigger a broadcast.
Any service can publish this event to the `sx` exchange:

```go
// From any Go service with a RabbitMQ channel:
body, _ := json.Marshal(map[string]any{
    "type":  "tournament_reminder",
    "title": "Tournament starts in 15 minutes! ⚡",
    "body":  "Your opponents are ready. Join now to secure your spot.",
    // "user_ids": []string{"uid1", "uid2"} — omit for broadcast to all
})
ch.Publish("sx", "notification.tournament_reminder", false, false, amqp.Publishing{
    ContentType:  "application/json",
    DeliveryMode: amqp.Persistent,
    Body:         body,
})
```

---

## Flutter Integration

### Permission prompt

The OS permission dialog appears automatically on first login. On iOS it's required. On Android 13+ (API 33) it's required; on older Android it's granted automatically.

### Foreground notifications

When the app is open, Firebase does NOT show a system notification. Instead, `notification_service.dart` fires `onForegroundMessage`. To show an in-app banner:

```dart
// In HomeScreen.initState():
NotificationService.instance.onForegroundMessage = (title, body, data) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$title: $body')),
  );
};
```

### Background / terminated

System tray notification is shown automatically by the OS. On tap:
- Background: `onMessageOpenedApp` fires → `_handleNotificationTap` routes to screen
- Terminated: `getInitialMessage` picks it up on app start → routes to screen

Pending routes are stored in SharedPreferences under `pending_notification_route`. The app router checks this on startup.

### Notification tap routing

| `data.type` | Navigates to |
|-------------|-------------|
| `streak_warning` | `/home` |
| `daily_reward` | `/home` |
| `referral_converted` | `/profile` |
| `premium_expiry` | `/premium` |
| `tournament_reminder` | `/matchmaking` |

---

## Services to Restart

| Service | Why | Command |
|---------|-----|---------|
| **matchmaking-service** | New `POST /device/token` endpoint | `make run-matchmaking` |
| **notification-worker** | New service entirely | `make run-notification-worker` |
| **Flutter app** | New packages (firebase_core, firebase_messaging) | Full rebuild: `flutter run` |
| **MongoDB** | New `device_tokens` index | Manual: see above, or `make seed` on fresh DB |

No changes required to: quiz-service, scoring-service, payment-service.

---

## Testing

### Register a device token manually

```bash
TOKEN=$(curl -s -X POST http://localhost:8080/auth/... | jq -r .token)

curl -X POST http://localhost:8080/device/token \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"token": "fake-test-token-abc123", "platform": "android"}'
```

### Trigger a test notification manually (RabbitMQ UI)

> **Important:** Put the app in the **background** before triggering — FCM does not show system notifications while the app is in the foreground.

1. Open http://localhost:15672 → log in with `guest` / `guest`
2. Go to **Exchanges** → click `sx`
3. Scroll down to **Publish message**
4. Fill in:
   - **Routing key:** `notification.streak_warning`
   - **Payload:**
     ```json
     {
       "type": "streak_warning",
       "title": "Don't break your streak! 🔥",
       "body": "You haven't played today. Keep your streak alive!"
     }
     ```
5. Click **Publish message**
6. Your phone should receive the notification within seconds

**Confirm it worked** — check worker logs:
```bash
docker compose logs notification-worker --tail=20
```
You should see:
```
✅ notification event — type: streak_warning target_users: 0
✅ FCM multicast — success: 1 / 1
```

**Other notification types you can trigger the same way:**

| Routing key | type value | Who receives it |
|-------------|-----------|-----------------|
| `notification.streak_warning` | `streak_warning` | All users |
| `notification.daily_reward` | `daily_reward` | All users |
| `notification.tournament_reminder` | `tournament_reminder` | All users |

For a targeted notification (specific users only), add `"user_ids"` to the payload:
```json
{
  "type": "tournament_reminder",
  "title": "Tournament starts in 15 minutes! ⚡",
  "body": "Your opponents are ready. Join now to secure your spot.",
  "user_ids": ["69dbbc63fe8806dca4710183"]
}
```

### Verify referral conversion

1. Register User B, apply User A's referral code
2. User B plays and finishes a match
3. Worker log should show:
   ```
   🎉 Referral conversion notified — referee: <uid_B> referrer: <uid_A>
   ```
4. User A's device receives: *"Your referral is paying off! ..."*

---

## RabbitMQ Topology After This Feature

```
Exchange: sx (topic, durable)
│
├── match.created         → match-created-queue (quiz-service)
├── answer.submitted      → answer-processing-queue (scoring-service)
├── round.completed       → (consumed by scoring consumers)
├── match.finished        → match-finished-queue (scoring-service)
│                         → notification-match-queue (notification-worker) ← NEW
└── notification.*        → notification-worker-queue (notification-worker) ← NEW
```

Multiple queues bound to the same routing key each get an **independent copy** of the message — standard RabbitMQ fan-out via topic exchange. No existing consumers are affected.
