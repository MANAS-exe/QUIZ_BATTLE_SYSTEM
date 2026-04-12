import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';

import '../models/game_event.dart' as app;
import '../proto/quiz.pb.dart' as pb;
import '../proto/quiz.pbgrpc.dart' as pbgrpc;
import 'auth_service.dart';

// ─────────────────────────────────────────
// CHANNELS — one per service
// ─────────────────────────────────────────

// Android emulator routes 10.0.2.2 → host machine's localhost.
// Physical device: replace with your machine's LAN IP (e.g. 192.168.x.x).
const _backendHost = 'localhost'; // overridden below for Android

String get _host {
  if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';
  return _backendHost;
}

ClientChannel _makeChannel(int port) => ClientChannel(
  _host,
  port: port,
  options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
);

final matchmakingChannelProvider = Provider<ClientChannel>((ref) {
  final ch = _makeChannel(50051);
  ref.onDispose(ch.shutdown);
  return ch;
});

final quizChannelProvider = Provider<ClientChannel>((ref) {
  final ch = _makeChannel(50052);
  ref.onDispose(ch.shutdown);
  return ch;
});

final scoringChannelProvider = Provider<ClientChannel>((ref) {
  final ch = _makeChannel(50053);
  ref.onDispose(ch.shutdown);
  return ch;
});

// Keep for backward compatibility (auth uses matchmaking channel)
final grpcChannelProvider = matchmakingChannelProvider;

// ─────────────────────────────────────────
// SERVICE CLASS
// ─────────────────────────────────────────

class GameService {
  final Ref _ref;
  late final pbgrpc.MatchmakingServiceClient _matchmakingClient;
  late final pbgrpc.QuizServiceClient _quizClient;
  late final pbgrpc.ScoringServiceClient _scoringClient;

  GameService(this._ref) {
    _matchmakingClient = pbgrpc.MatchmakingServiceClient(_ref.read(matchmakingChannelProvider));
    _quizClient = pbgrpc.QuizServiceClient(_ref.read(quizChannelProvider));
    _scoringClient = pbgrpc.ScoringServiceClient(_ref.read(scoringChannelProvider));
  }

  /// Build gRPC call options with JWT authorization header.
  CallOptions get _authOptions {
    final token = _ref.read(authProvider).token;
    if (token == null) return CallOptions();
    return CallOptions(metadata: {'authorization': 'Bearer $token'});
  }

  // ── 1. Join Matchmaking ──────────────────────────────────────

  Future<bool> joinMatchmaking(String userId, String username, double rating) async {
    try {
      final req = pb.JoinRequest()
        ..userId = userId
        ..username = username
        ..rating = rating.toInt();
      final res = await _matchmakingClient.joinMatchmaking(req, options: _authOptions);
      return res.success;
    } on GrpcError catch (e) {
      debugPrint('[GameService] joinMatchmaking error: ${e.codeName} — ${e.message}');
      rethrow;
    }
  }

  // ── 2. Subscribe to Match ────────────────────────────────────

  /// Long-lived stream that receives MatchFound / MatchCancelled.
  /// Yields [MatchmakingUpdate] objects the UI can react to.
  Stream<MatchmakingUpdate> subscribeToMatch(String userId) async* {
    final req = pb.SubscribeRequest()..userId = userId;
    try {
      await for (final event in _matchmakingClient.subscribeToMatch(req, options: _authOptions)) {
        if (event.hasMatchFound()) {
          final mf = event.matchFound;
          yield MatchmakingUpdate(
            matchFound: true,
            roomId: mf.roomId,
            totalRounds: mf.totalRounds,
            players: mf.players.map(_mapPlayer).toList(),
          );
        } else if (event.hasWaitingUpdate()) {
          final wu = event.waitingUpdate;
          yield MatchmakingUpdate(
            playersFound: wu.playersInPool,
            totalNeeded: 4,
            waitingPlayers: wu.players.map(_mapPlayer).toList(),
          );
        } else if (event.hasMatchCancelled()) {
          yield MatchmakingUpdate(cancelled: true);
        }
      }
    } on GrpcError catch (e) {
      debugPrint('[GameService] subscribeToMatch error: ${e.codeName} — ${e.message}');
      rethrow;
    }
  }

  // ── 3. Stream Game Events ────────────────────────────────────

  Stream<app.GameEvent> streamGameEvents(String roomId, String userId) {
    final req = pb.StreamRequest()
      ..roomId = roomId
      ..userId = userId;

    return _quizClient
        .streamGameEvents(req, options: _authOptions)
        .map(_mapProtoEvent)
        .where((e) => e != null)
        .cast<app.GameEvent>()
        .handleError((e) {
      debugPrint('[GameService] streamGameEvents error: $e');
      throw e;
    });
  }

  // ── 4. Submit Answer ─────────────────────────────────────────

  Future<bool> submitAnswer({
    required String roomId,
    required String userId,
    required int roundNumber,
    required String questionId,
    required int answerIndex,
  }) async {
    try {
      final req = pb.AnswerRequest()
        ..roomId = roomId
        ..userId = userId
        ..roundNumber = roundNumber
        ..questionId = questionId
        ..answerIndex = answerIndex
        ..submittedAtMs = Int64(DateTime.now().millisecondsSinceEpoch);
      final ack = await _quizClient.submitAnswer(req, options: _authOptions);
      return ack.received;
    } on GrpcError catch (e) {
      debugPrint('[GameService] submitAnswer error: ${e.codeName} — ${e.message}');
      rethrow;
    }
  }

  // ── 5. Leave Matchmaking ─────────────────────────────────────

  Future<void> leaveMatchmaking(String userId) async {
    try {
      final req = pb.LeaveRequest()..userId = userId;
      await _matchmakingClient.leaveMatchmaking(req, options: _authOptions);
    } on GrpcError catch (e) {
      debugPrint('[GameService] leaveMatchmaking error: ${e.codeName}');
    }
  }

  // ── 6. Get Leaderboard ───────────────────────────────────────

  Future<List<app.PlayerScore>> getLeaderboard(String roomId) async {
    try {
      final req = pb.LeaderboardRequest()..roomId = roomId;
      final res = await _scoringClient.getLeaderboard(req, options: _authOptions);
      return res.scores.map(_mapScore).toList();
    } on GrpcError catch (e) {
      debugPrint('[GameService] getLeaderboard error: ${e.codeName} — ${e.message}');
      return [];
    }
  }

  // ─────────────────────────────────────────
  // PROTO → DART MAPPERS
  // ─────────────────────────────────────────

  app.GameEvent? _mapProtoEvent(pb.GameEvent proto) {
    if (proto.hasQuestion()) {
      final q = proto.question;
      return app.QuestionBroadcastEvent(
        roundNumber: q.roundNumber,
        deadlineMs: q.deadlineMs.toInt(),
        question: app.Question(
          questionId: q.question.questionId,
          text: q.question.text,
          options: q.question.options.toList(),
          difficulty: _mapDifficulty(q.question.difficulty),
          topic: q.question.topic,
          timeLimitMs: q.question.timeLimitMs,
        ),
      );
    }
    if (proto.hasLeaderboard()) {
      final lb = proto.leaderboard;
      return app.LeaderboardUpdateEvent(
        roomId: lb.roomId,
        roundNumber: lb.roundNumber,
        scores: lb.scores.map(_mapScore).toList(),
      );
    }
    if (proto.hasTimerSync()) {
      final ts = proto.timerSync;
      return app.TimerSyncEvent(
        roundNumber: ts.roundNumber,
        serverTimeMs: ts.serverTimeMs.toInt(),
        deadlineMs: ts.deadlineMs.toInt(),
      );
    }
    if (proto.hasRoundResult()) {
      final rr = proto.roundResult;
      return app.RoundResultEvent(
        roundNumber: rr.roundNumber,
        questionId: rr.questionId,
        correctIndex: rr.correctIndex,
        fastestUserId: rr.fastestUserId,
        correctAnswerText: rr.correctAnswerText,
        fastestUsername: rr.fastestUsername,
        scores: rr.scores.map(_mapScore).toList(),
      );
    }
    if (proto.hasMatchEnd()) {
      final me = proto.matchEnd;
      return app.MatchEndEvent(
        roomId: me.roomId,
        winnerUserId: me.winnerUserId,
        winnerUsername: me.winnerUsername,
        totalRounds: me.totalRounds,
        durationSeconds: me.durationSeconds,
        finalScores: me.finalScores.map(_mapScore).toList(),
      );
    }
    if (proto.hasPlayerJoined()) {
      final pj = proto.playerJoined;
      return app.PlayerJoinedEvent(
        roundNumber: pj.roundNumber,
        player: _mapPlayer(pj.player),
      );
    }
    // Unknown event type — log and return null so the stream keeps running.
    debugPrint('[GameService] Unknown GameEvent type received: $proto');
    return null;
  }

  app.PlayerScore _mapScore(pb.PlayerScore s) => app.PlayerScore(
        userId: s.userId,
        username: s.username,
        score: s.score,
        rank: s.rank,
        answersCorrect: s.answersCorrect,
        avgResponseMs: s.avgResponseMs,
        isConnected: s.isConnected,
      );

  app.Player _mapPlayer(pb.Player p) => app.Player(
        userId: p.userId,
        username: p.username,
        rating: p.rating,
      );

  app.Difficulty _mapDifficulty(pb.Difficulty d) {
    switch (d) {
      case pb.Difficulty.EASY:
        return app.Difficulty.easy;
      case pb.Difficulty.MEDIUM:
        return app.Difficulty.medium;
      case pb.Difficulty.HARD:
        return app.Difficulty.hard;
      default:
        return app.Difficulty.unspecified;
    }
  }
}

// ─────────────────────────────────────────
// MATCHMAKING UPDATE MODEL
// ─────────────────────────────────────────

class MatchmakingUpdate {
  final int playersFound;
  final int totalNeeded;
  final bool matchFound;
  final bool cancelled;
  final String? roomId;
  final int totalRounds;
  final List<app.Player> players;
  final List<app.Player> waitingPlayers; // players currently in the pool

  const MatchmakingUpdate({
    this.playersFound = 1,
    this.totalNeeded = 4,
    this.matchFound = false,
    this.cancelled = false,
    this.roomId,
    this.totalRounds = 5,
    this.players = const [],
    this.waitingPlayers = const [],
  });
}

// ─────────────────────────────────────────
// RIVERPOD PROVIDERS
// ─────────────────────────────────────────

final gameServiceProvider = Provider<GameService>((ref) {
  return GameService(ref);
});

final gameEventStreamProvider =
    StreamProvider.family<app.GameEvent, (String, String)>(
  (ref, args) {
    final (roomId, userId) = args;
    final service = ref.watch(gameServiceProvider);
    return service.streamGameEvents(roomId, userId);
  },
);
