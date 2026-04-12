# Google Sign-In — Full Stack Documentation

## What is it?

Google Sign-In lets users authenticate with their existing Google account instead
of creating a separate username/password. The user taps one button, approves a
consent screen, and is logged in. No passwords to remember, no email verification
email to wait for.

---

## Why use Google Sign-In?

| Problem with email/password | How Google Sign-In solves it |
|---|---|
| Users forget passwords | No password to forget |
| Weak passwords → security risk | Google's infrastructure handles credential security |
| Email verification adds friction | Google already verified the email |
| Can't get a profile picture | Google provides a CDN-hosted picture URL |
| User management burden | Google's `sub` field is a stable, unique user ID |

**When to use it:** Always offer it as the primary login method for consumer apps.
Reserve email/password as a fallback for users without Google accounts or for
enterprise environments that block Google OAuth.

---

## Flow Diagram

```
Flutter App                  Backend (Go, port 8080)      MongoDB
    │                               │                         │
    │  User taps "Continue with     │                         │
    │  Google"                      │                         │
    │                               │                         │
    │──── GoogleSignIn.signIn() ─→  Google OAuth2 Server      │
    │←─── GoogleSignInAccount ─────                           │
    │                               │                         │
    │  account.authentication       │                         │
    │──── .idToken ──────────────→  │                         │
    │                               │                         │
    │  POST /auth/google            │                         │
    │  { "id_token": "eyJ..." } ──→ │                         │
    │                               │  GET tokeninfo?id_token=│
    │                               │──────────────────────→  Google tokeninfo API
    │                               │←── { sub, email, name, │
    │                               │      picture, aud }     │
    │                               │                         │
    │                               │  FindOne {google_id}──→ │
    │                               │  or FindOne {email} ──→ │
    │                               │  or InsertOne (new) ──→ │
    │                               │←── userDoc ─────────── │
    │                               │                         │
    │                               │  GenerateToken(userId)  │
    │←── { token, user_id,         │                         │
    │      username, email,         │                         │
    │      picture_url, rating } ──  │                         │
    │                               │                         │
    │  Store JWT in SharedPrefs     │                         │
    │  Navigate to /home            │                         │
```

---

## Where it lives

### Backend: `matchmaking-service/handlers/google_auth.go`

Registered on the HTTP server alongside gRPC-Web (port 8080):

```go
// matchmaking-service/main.go
mux.HandleFunc("/auth/google", func(w http.ResponseWriter, r *http.Request) {
    if r.Method == http.MethodOptions {
        // CORS preflight for Flutter Web
        w.Header().Set("Access-Control-Allow-Origin", "*")
        w.WriteHeader(http.StatusNoContent)
        return
    }
    googleAuthHandler.ServeHTTP(w, r)
})
```

**Why REST, not gRPC?**
Google Sign-In is an OAuth 2.0 exchange. The client receives a signed JWT (the
"ID token") that the backend needs to verify with Google once. This is a one-off
HTTP roundtrip — not a streaming operation — so a plain `POST /auth/google` is
the correct tool. Adding it to the proto would require regenerating `.pb.go`
files and complicates the proto schema unnecessarily.

### Token verification: `verifyGoogleToken()`

```go
// Calls: https://oauth2.googleapis.com/tokeninfo?id_token=<token>
// Returns: { sub, email, email_verified, name, given_name, family_name,
//            picture, aud, iss, exp }
// Validates: issuer must be "accounts.google.com",
//            sub must be non-empty, aud must match GOOGLE_CLIENT_ID
```

**Alternative (faster):** Use the `google.golang.org/api/idtoken` package for
offline verification (verifies signature with Google's public keys locally).
The tokeninfo HTTP call adds ~100ms latency but requires no key management.
Fine for auth flows where latency is acceptable.

### MongoDB user document

```json
{
  "_id": "ObjectId(...)",
  "username": "johnd",
  "google_id": "1234567890",      // Google's stable `sub` field
  "email": "john@gmail.com",
  "picture_url": "https://lh3.googleusercontent.com/...",
  "rating": 1000,
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

**Account linking:** If a user previously registered with email/password using
the same email address, their account is linked to Google on first Google login.
The `google_id` field is added to their existing document. They can use either
method to log in.

### Flutter: `flutter-app/lib/services/auth_service.dart`

```dart
// 1. Trigger Google consent screen
final account = await _googleSignIn.signIn();

// 2. Get Google's signed ID token
final auth = await account.authentication;
final idToken = auth.idToken;  // a JWT signed by Google

// 3. Exchange with backend
final res = await _callGoogleAuthEndpoint(idToken);
// POST http://localhost:8080/auth/google
// { "id_token": "eyJ..." }

// 4. Build AuthState from response
state = AuthState(
  token: res['token'],
  userId: res['user_id'],
  username: res['username'],
  pictureUrl: res['picture_url'] ?? account.photoUrl,
  ...
);

// 5. Post-login pipeline (same as email/password)
await _saveGoogleSession(userId, idToken);
await _loadLocalStats();     // loads streak, coins, quota, login history
await _syncPremiumFromServer(); // syncs paid premium from payment service
```

After `_loadLocalStats()` returns, the login streak is already updated via
`_updateLoginStreak()`. If the user has an unclaimed daily reward, `pendingReward`
on `AuthState` will be non-null, and `HomeScreen.initState` will show the reward
dialog on the next frame.

---

## Configuration

### Environment variables

| Variable | Required | Description |
|---|---|---|
| `GOOGLE_CLIENT_ID` | Production only | The OAuth 2.0 client ID from Google Cloud Console. Used to validate the `aud` claim in the ID token. If unset, the `aud` check is skipped (dev mode). |

### Google Cloud Console setup

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. APIs & Services → Credentials → Create Credentials → OAuth 2.0 Client ID
3. Application type: **Web application** (used for backend `aud` check)
4. Also create an **Android** and/or **iOS** credential for the Flutter app
5. Set `GOOGLE_CLIENT_ID` to the web client ID (the one used by the backend)

### Flutter: `google_sign_in` SDK

```yaml
# pubspec.yaml
google_sign_in: ^6.2.1
```

For Android, add your SHA-1 fingerprint in Google Cloud Console under the
Android credential. For iOS, add the `GoogleService-Info.plist`.

For **development without real Google credentials**, use the email/password flow
(tap "Use email / password" on the login screen).

---

## Username derivation (new Google users)

When a user logs in with Google for the first time, we derive a username from
their display name:

```
"John Doe"    → "johnd"    (given + first letter of family, lowercased)
"Alice"       → "alice"    (no family name)
"María García" → "marίag"  (Unicode preserved)
```

If `"johnd"` is taken, we append the last 4 digits of their Google `sub`:
`"johnd3456"`. This runs up to 10 collision attempts before giving up.

Returning users keep their username permanently — stability over freshness.

---

## Security notes

- **Server-side verification only.** The ID token is never trusted on the client.
  All claims (email, name, picture) come from Google's tokeninfo response, not
  the Flutter app body.
- **`aud` claim validated.** In production, `GOOGLE_CLIENT_ID` must be set so
  tokens issued for other apps are rejected.
- **Email verified check.** We reject accounts where `email_verified != "true"`.
- **No Google token stored.** Only your app's own JWT is stored in SharedPreferences.
  The Google ID token is short-lived (~1 hour) and not persisted.
- **CORS.** The `/auth/google` endpoint sets `Access-Control-Allow-Origin: *` for
  Flutter Web development. Restrict to your production domain before shipping.

---

## Real-world example

1. User Alice opens the app fresh. She taps "Continue with Google".
2. Google's consent screen asks: "Quiz Battle wants to access your email address
   and basic profile info." She taps Allow.
3. The app sends her ID token to the backend. The backend verifies it, creates
   a MongoDB document `{ username: "alicej", google_id: "98765", email: "alice@gmail.com",
   picture_url: "https://lh3.googleusercontent.com/...", rating: 1000 }`, issues a JWT,
   and returns it.
4. Flutter stores the JWT in SharedPreferences, sets state, and navigates to `/home`.
5. Alice's Google profile picture appears as her avatar. Rating shows 1000. No
   password was ever created.
6. Three months later Alice's picture URL changes (Google rotates CDN URLs). On
   her next login, the backend's `upsertGoogleUser` calls `UpdateOne` to refresh
   `picture_url`. Her app shows the new photo automatically.
