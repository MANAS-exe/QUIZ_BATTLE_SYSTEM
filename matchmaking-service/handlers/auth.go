package handlers

import (
	"context"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"golang.org/x/crypto/bcrypt"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	quiz "github.com/yourorg/quiz-battle/proto/quiz"
	"quiz-battle/shared/auth"
)

// User document stored in MongoDB.
type User struct {
	ID           primitive.ObjectID `bson:"_id,omitempty"`
	Username     string             `bson:"username"`
	PasswordHash string             `bson:"password_hash"`
	Rating       int                `bson:"rating"`
	CreatedAt    time.Time          `bson:"created_at"`
}

// AuthHandler implements quiz.AuthServiceServer.
type AuthHandler struct {
	quiz.UnimplementedAuthServiceServer
	users *mongo.Collection
}

func NewAuthHandler(mongoDB *mongo.Database) *AuthHandler {
	return &AuthHandler{
		users: mongoDB.Collection("users"),
	}
}

func (h *AuthHandler) RegisterService(s *grpc.Server) {
	quiz.RegisterAuthServiceServer(s, h)
	log.Println("✅ AuthService registered")
}

// ── Register ─────────────────────────────────────────────────

func (h *AuthHandler) Register(ctx context.Context, req *quiz.AuthRequest) (*quiz.AuthResponse, error) {
	if req.Username == "" || req.Password == "" {
		return nil, status.Error(codes.InvalidArgument, "username and password are required")
	}
	if len(req.Username) < 3 {
		return nil, status.Error(codes.InvalidArgument, "username must be at least 3 characters")
	}
	if len(req.Password) < 4 {
		return nil, status.Error(codes.InvalidArgument, "password must be at least 4 characters")
	}

	var existing User
	err := h.users.FindOne(ctx, bson.M{"username": req.Username}).Decode(&existing)
	if err == nil {
		return &quiz.AuthResponse{
			Success: false,
			Message: "Username already taken",
		}, nil
	}
	if err != mongo.ErrNoDocuments {
		return nil, status.Errorf(codes.Internal, "db lookup: %v", err)
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "hash password: %v", err)
	}

	user := User{
		Username:     req.Username,
		PasswordHash: string(hash),
		Rating:       1000,
		CreatedAt:    time.Now(),
	}

	result, err := h.users.InsertOne(ctx, user)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "insert user: %v", err)
	}

	userID := result.InsertedID.(primitive.ObjectID).Hex()
	token, err := auth.GenerateToken(userID, req.Username)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "generate token: %v", err)
	}

	log.Printf("✅ New user registered: %s (%s)", req.Username, userID)

	return &quiz.AuthResponse{
		Success:  true,
		Token:    token,
		UserId:   userID,
		Username: req.Username,
		Rating:   1000,
		Message:  "Registration successful",
	}, nil
}

// ── Login ────────────────────────────────────────────────────

func (h *AuthHandler) Login(ctx context.Context, req *quiz.AuthRequest) (*quiz.AuthResponse, error) {
	if req.Username == "" || req.Password == "" {
		return nil, status.Error(codes.InvalidArgument, "username and password are required")
	}

	var user User
	err := h.users.FindOne(ctx, bson.M{"username": req.Username}).Decode(&user)
	if err == mongo.ErrNoDocuments {
		return &quiz.AuthResponse{
			Success: false,
			Message: "Invalid username or password",
		}, nil
	}
	if err != nil {
		return nil, status.Errorf(codes.Internal, "db lookup: %v", err)
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return &quiz.AuthResponse{
			Success: false,
			Message: "Invalid username or password",
		}, nil
	}

	userID := user.ID.Hex()
	token, err := auth.GenerateToken(userID, user.Username)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "generate token: %v", err)
	}

	log.Printf("✅ User logged in: %s (%s)", user.Username, userID)

	return &quiz.AuthResponse{
		Success:  true,
		Token:    token,
		UserId:   userID,
		Username: user.Username,
		Rating:   int32(user.Rating),
		Message:  "Login successful",
	}, nil
}
