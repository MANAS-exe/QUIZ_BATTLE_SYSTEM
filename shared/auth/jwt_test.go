package auth

import (
	"testing"
)

func TestGenerateAndValidateToken(t *testing.T) {
	token, err := GenerateToken("user123", "testuser")
	if err != nil {
		t.Fatalf("GenerateToken failed: %v", err)
	}
	if token == "" {
		t.Fatal("GenerateToken returned empty token")
	}

	userID, username, err := ValidateToken(token)
	if err != nil {
		t.Fatalf("ValidateToken failed: %v", err)
	}
	if userID != "user123" {
		t.Errorf("expected userID 'user123', got '%s'", userID)
	}
	if username != "testuser" {
		t.Errorf("expected username 'testuser', got '%s'", username)
	}
}

func TestValidateToken_Invalid(t *testing.T) {
	_, _, err := ValidateToken("invalid.token.here")
	if err == nil {
		t.Fatal("expected error for invalid token, got nil")
	}
}

func TestValidateToken_Empty(t *testing.T) {
	_, _, err := ValidateToken("")
	if err == nil {
		t.Fatal("expected error for empty token, got nil")
	}
}
