# Razorpay Payment Integration

## Overview

Quiz Battle uses Razorpay for premium subscription payments (₹499/month or ₹3,999/year).  
The integration uses **client-side signature verification** — no webhook or ngrok required.

## Flow

```
Flutter                    Payment Service               MongoDB
  │                              │                          │
  ├─ POST /payment/create-order ─►                          │
  │  { plan: "monthly" }         │                          │
  │                              ├─ Call Razorpay API ─►    │
  │                              │  POST /v1/orders         │
  │                              │◄─ { order_id, amount }   │
  │                              ├─ Save pending payment ──►│
  │◄─ { order_id, amount, key } ─┤                          │
  │                              │                          │
  ├─ Open Razorpay SDK           │                          │
  │  (user enters card/UPI)      │                          │
  │                              │                          │
  ├─ Payment success callback    │                          │
  │  { payment_id, order_id,     │                          │
  │    signature }               │                          │
  │                              │                          │
  ├─ POST /payment/verify ──────►│                          │
  │  { payment_id, order_id,     │                          │
  │    signature }               │                          │
  │                              ├─ HMAC verify signature   │
  │                              ├─ Update payment=captured►│
  │                              ├─ Upsert subscription ───►│
  │                              ├─ Set users.premium=true ►│
  │◄─ { success, expires_at } ───┤                          │
  │                              │                          │
  ├─ setPremium(true) locally    │                          │
```

## Signature Verification

Razorpay generates a signature on successful payment:

```
HMAC-SHA256(razorpay_key_secret, razorpay_order_id + "|" + razorpay_payment_id)
```

The backend recalculates this and compares — any tampering will fail verification.

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/payment/create-order` | JWT | Create a Razorpay order, save pending record |
| POST | `/payment/verify` | JWT | Verify signature, activate subscription |
| GET | `/payment/status` | JWT | Check current plan (free/premium) |
| GET | `/payment/history` | JWT | List past payments |

## Credentials

Stored in `payment-service/.env`:
```
RAZORPAY_KEY_ID=rzp_test_...
RAZORPAY_KEY_SECRET=...
PORT=:8081
MONGO_URI=mongodb://localhost:27017
```

**Never commit real production keys.** Add `.env` to `.gitignore`.

## Plans

| Plan | Amount | Duration |
|------|--------|----------|
| Monthly | ₹499 (49900 paise) | 30 days |
| Yearly | ₹3,999 (399900 paise) | 365 days |

## Running the Payment Service

```bash
# Local dev (uses .env)
make run-payment

# Via Docker
docker compose up --build payment-service
```

Service listens on `:8081`. Flutter uses `http://10.0.2.2:8081` (Android emulator).

## Payment Methods

The checkout shows UPI first, then card/netbanking/wallet:

| Method | Enabled |
|--------|---------|
| UPI (GPay, PhonePe, Paytm) | Yes — shown first |
| Debit/Credit Card | Yes |
| Net Banking | Yes |
| Wallets | Yes |
| EMI | No |

## Payment Failure Handling

- **User cancelled** (code 0): silent dismiss — no dialog shown
- **Payment failed** (any other code): shows a dialog with the error message, error code, and a **"Try Again"** button that reopens the same order without creating a new one
- **Verification failed** (server rejects HMAC): shows a SnackBar — the Razorpay payment went through but our backend rejected it (shouldn't happen in practice)

## Premium vs Premium Trial

The app has two separate "premium" paths:

| Source | Field | Duration | How activated |
|--------|-------|----------|---------------|
| Razorpay payment | `isPremium = true` | 30 or 365 days (server-tracked) | `POST /payment/verify` → payment service writes `expiresAt` to MongoDB |
| Day-30 login streak reward | `premiumTrialExpiresAt` | 7 days (client-tracked) | `claimDailyReward()` sets datetime in SharedPreferences |

Both are checked via `isEffectivelyPremium`:
```dart
bool get isEffectivelyPremium {
  if (isPremium) return true;
  if (premiumTrialExpiresAt == null) return false;
  return DateTime.tryParse(premiumTrialExpiresAt!)?.isAfter(DateTime.now()) ?? false;
}
```

A user can stack both: a paid subscriber who also earned a trial will remain
on paid premium after the trial expires. `_syncPremiumFromServer()` keeps the
`isPremium` flag authoritative from the server; it never overrides a trial.

---

## Testing

Use Razorpay test credentials:

| Method | Value | Result |
|--------|-------|--------|
| Card | `4111 1111 1111 1111` — any future expiry — any CVV | Success |
| Card | `4000 0000 0000 0002` | Failure (tests retry dialog) |
| UPI | `success@razorpay` | Success |
| UPI | `failure@razorpay` | Failure (tests retry dialog) |

> **Tip:** Use `success@razorpay` as the UPI ID to test the full premium activation flow end-to-end without a real bank account.
