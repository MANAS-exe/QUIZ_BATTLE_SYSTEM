package worker

// fcm.go — Firebase Cloud Messaging sender.
//
// Wraps the Firebase Admin SDK. Initialised once at startup from the
// FIREBASE_CREDENTIALS_JSON environment variable (raw service-account JSON).
//
// Usage:
//   sender, err := NewFCMSender(credentialsJSON)
//   err = sender.Send(ctx, token, "Title", "Body", nil)
//   err = sender.SendMulticast(ctx, tokens, "Title", "Body", nil)

import (
	"context"
	"fmt"
	"log"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

// FCMSender wraps the Firebase messaging client.
type FCMSender struct {
	client *messaging.Client
}

// NewFCMSender initialises the Firebase Admin app and returns a sender.
// credentialsJSON must be the raw bytes of a Firebase service-account JSON file.
func NewFCMSender(credentialsJSON []byte) (*FCMSender, error) {
	app, err := firebase.NewApp(
		context.Background(),
		nil,
		option.WithCredentialsJSON(credentialsJSON),
	)
	if err != nil {
		return nil, fmt.Errorf("firebase.NewApp: %w", err)
	}

	client, err := app.Messaging(context.Background())
	if err != nil {
		return nil, fmt.Errorf("app.Messaging: %w", err)
	}

	log.Println("✅ Firebase Messaging client initialised")
	return &FCMSender{client: client}, nil
}

// Send dispatches a single FCM notification to one device token.
// data is optional — pass nil for notification-only messages.
func (s *FCMSender) Send(ctx context.Context, token, title, body string, data map[string]string) error {
	msg := &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				ChannelID: "quiz_battle_channel",
				Sound:     "default",
			},
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{Sound: "default"},
			},
		},
	}
	if len(data) > 0 {
		msg.Data = data
	}

	resp, err := s.client.Send(ctx, msg)
	if err != nil {
		return fmt.Errorf("FCM Send: %w", err)
	}
	log.Printf("📲 FCM sent → %s (msg: %s)", token[:min(8, len(token))]+"...", resp)
	return nil
}

// SendMulticast dispatches the same notification to up to 500 tokens at once.
// Tokens with permanent errors (invalid/unregistered) are logged for cleanup.
func (s *FCMSender) SendMulticast(ctx context.Context, tokens []string, title, body string, data map[string]string) error {
	if len(tokens) == 0 {
		return nil
	}

	msg := &messaging.MulticastMessage{
		Tokens: tokens,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				ChannelID: "quiz_battle_channel",
				Sound:     "default",
			},
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{Sound: "default"},
			},
		},
	}
	if len(data) > 0 {
		msg.Data = data
	}

	resp, err := s.client.SendEachForMulticast(ctx, msg)
	if err != nil {
		return fmt.Errorf("FCM SendMulticast: %w", err)
	}

	log.Printf("📲 FCM multicast — success: %d / %d", resp.SuccessCount, len(tokens))
	for i, r := range resp.Responses {
		if !r.Success {
			log.Printf("  ⚠️  token[%d] failed: %v", i, r.Error)
		}
	}
	return nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
