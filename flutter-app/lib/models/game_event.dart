// Dart model classes that mirror the proto GameEvent oneof types.
// These are what your UI consumes — the gRPC layer maps proto → these classes.

// ─────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────

enum Difficulty { easy, medium, hard, unspecified }

enum PlayerStatus { connected, disconnected, reconnecting, unspecified }

// ─────────────────────────────────────────
// SHARED MODELS
// ─────────────────────────────────────────

class Player {
  final String userId;
  final String username;
  final int rating;
  final PlayerStatus status;

  const Player({
    required this.userId,
    required this.username,
    required this.rating,
    this.status = PlayerStatus.connected,
  });

  Player copyWith({PlayerStatus? status}) => Player(
        userId: userId,
        username: username,
        rating: rating,
        status: status ?? this.status,
      );
}

class Question {
  final String questionId;
  final String text;
  final List<String> options; // always 4 items
  final Difficulty difficulty;
  final String topic;
  final int timeLimitMs;

  const Question({
    required this.questionId,
    required this.text,
    required this.options,
    required this.difficulty,
    required this.topic,
    required this.timeLimitMs,
  });
}

class PlayerScore {
  final String userId;
  final String username;
  final int score;
  final int rank;
  final int answersCorrect;
  final int avgResponseMs;
  final bool isConnected;

  const PlayerScore({
    required this.userId,
    required this.username,
    required this.score,
    required this.rank,
    required this.answersCorrect,
    required this.avgResponseMs,
    this.isConnected = true,
  });

  // Delta score for the UI arrow indicators (▲ / ▼)
  PlayerScore copyWith({int? score, int? rank}) => PlayerScore(
        userId: userId,
        username: username,
        score: score ?? this.score,
        rank: rank ?? this.rank,
        answersCorrect: answersCorrect,
        avgResponseMs: avgResponseMs,
        isConnected: isConnected,
      );
}

// ─────────────────────────────────────────
// GAME EVENT — sealed class (mirrors proto oneof)
// ─────────────────────────────────────────

sealed class GameEvent {
  const GameEvent();
}

// Sent at the start of each round
class QuestionBroadcastEvent extends GameEvent {
  final int roundNumber;
  final Question question;
  final int deadlineMs; // absolute epoch ms when round closes

  const QuestionBroadcastEvent({
    required this.roundNumber,
    required this.question,
    required this.deadlineMs,
  });

  // Computed remaining time from now
  Duration get remainingTime {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = deadlineMs - now;
    return Duration(milliseconds: diff.clamp(0, question.timeLimitMs));
  }
}

// Sent after every score update
class LeaderboardUpdateEvent extends GameEvent {
  final String roomId;
  final int roundNumber;
  final List<PlayerScore> scores; // sorted by rank ascending

  const LeaderboardUpdateEvent({
    required this.roomId,
    required this.roundNumber,
    required this.scores,
  });
}

// Sent after all answers are in (or timer expires)
class RoundResultEvent extends GameEvent {
  final int roundNumber;
  final String questionId;
  final int correctIndex; // revealed to clients after round ends
  final List<PlayerScore> scores;
  final String fastestUserId;

  const RoundResultEvent({
    required this.roundNumber,
    required this.questionId,
    required this.correctIndex,
    required this.scores,
    required this.fastestUserId,
  });
}

// Sent once at the end of the match
class MatchEndEvent extends GameEvent {
  final String roomId;
  final String winnerUserId;
  final String winnerUsername;
  final List<PlayerScore> finalScores;
  final int totalRounds;
  final int durationSeconds;

  const MatchEndEvent({
    required this.roomId,
    required this.winnerUserId,
    required this.winnerUsername,
    required this.finalScores,
    required this.totalRounds,
    required this.durationSeconds,
  });
}

// Sent when a new player connects or reconnects
class PlayerJoinedEvent extends GameEvent {
  final Player player;
  final int roundNumber;

  const PlayerJoinedEvent({
    required this.player,
    required this.roundNumber,
  });
}

// Sent every second to keep client clocks in sync
class TimerSyncEvent extends GameEvent {
  final int roundNumber;
  final int serverTimeMs;
  final int deadlineMs;

  const TimerSyncEvent({
    required this.roundNumber,
    required this.serverTimeMs,
    required this.deadlineMs,
  });

  int get remainingSeconds {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Use server offset to correct clock drift
    final drift = now - serverTimeMs;
    final correctedNow = now - drift;
    return ((deadlineMs - correctedNow) / 1000).ceil().clamp(0, 30);
  }
}

// ── Reconnect synthetic events ────────────────────────────────
// These must live in this file because GameEvent is sealed —
// sealed classes can only be subclassed within the same library.

// Fired while the stream is down and a retry is pending
class ReconnectingEvent extends GameEvent {
  final int attempt;
  final int maxAttempts;
  final int retryInMs; // countdown ms shown in the UI banner

  const ReconnectingEvent({
    required this.attempt,
    required this.maxAttempts,
    required this.retryInMs,
  });
}

// Fired once reconnection succeeds; carries caught-up leaderboard state
class ReconnectedEvent extends GameEvent {
  final List<PlayerScore> leaderboard;
  const ReconnectedEvent({required this.leaderboard});
}

// Fired when all retries are exhausted
class ReconnectFailedEvent extends GameEvent {
  final String reason;
  const ReconnectFailedEvent({required this.reason});
}