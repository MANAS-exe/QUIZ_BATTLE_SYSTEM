.PHONY: proto infra up down test build clean seed run-matchmaking run-quiz run-scoring kill

# ── Proto generation ────────────────────────────────────────────
proto:
	PATH="$$PATH:$$HOME/go/bin:$$HOME/.pub-cache/bin" && \
	protoc --proto_path=proto \
		--go_out=proto --go_opt=paths=source_relative \
		--go-grpc_out=proto --go-grpc_opt=paths=source_relative \
		quiz.proto && \
	protoc --proto_path=proto \
		--dart_out=grpc:flutter-app/lib/proto \
		quiz.proto

# ── Infrastructure ──────────────────────────────────────────────
infra:
	docker compose up -d mongodb redis rabbitmq

up:
	docker compose up --build

down:
	docker compose down

# ── Build all services ──────────────────────────────────────────
build:
	cd matchmaking-service && go build ./...
	cd quiz-service && go build ./...
	cd scoring-service && go build ./...
	cd flutter-app && flutter pub get

# ── Run individual services (local dev) ─────────────────────────
run-matchmaking:
	cd matchmaking-service && go run .

run-quiz:
	cd quiz-service && go run .

run-scoring:
	cd scoring-service && go run .

# ── Tests ───────────────────────────────────────────────────────
test:
	cd shared && go test ./...
	cd matchmaking-service && go test ./...
	cd quiz-service && go test ./...
	cd scoring-service && go test ./...

test-flutter:
	cd flutter-app && flutter test

# ── Database ────────────────────────────────────────────────────
seed:
	docker exec -i quiz_mongodb mongosh quizdb < mongo-init/init.js

# ── Cleanup ─────────────────────────────────────────────────────
clean:
	cd flutter-app && flutter clean
	docker compose down -v

# ── Kill ports ──────────────────────────────────────────────────
kill:
	-lsof -ti :50051 | xargs kill -9
	-lsof -ti :50052 | xargs kill -9
	-lsof -ti :50053 | xargs kill -9
	-lsof -ti :8080  | xargs kill -9
