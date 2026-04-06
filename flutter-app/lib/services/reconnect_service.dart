import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_event.dart';
import 'game_service.dart';

// ─────────────────────────────────────────
// RECONNECT STATE
// ─────────────────────────────────────────

enum ReconnectStatus {
  connected,
  reconnecting,
  failed, // max retries exceeded
}

class ReconnectState {
  final ReconnectStatus status;
  final int attempt;       // current attempt number (0 = not retrying)
  final int maxAttempts;
  final int nextRetryInMs; // countdown shown in UI banner
  final String? errorMessage;

  const ReconnectState({
    this.status = ReconnectStatus.connected,
    this.attempt = 0,
    this.maxAttempts = 5,
    this.nextRetryInMs = 0,
    this.errorMessage,
  });

  bool get isReconnecting => status == ReconnectStatus.reconnecting;
  bool get isFailed       => status == ReconnectStatus.failed;
  bool get isConnected    => status == ReconnectStatus.connected;

  ReconnectState copyWith({
    ReconnectStatus? status,
    int? attempt,
    int? nextRetryInMs,
    String? errorMessage,
    bool clearError = false,
  }) => ReconnectState(
    status:        status        ?? this.status,
    attempt:       attempt       ?? this.attempt,
    maxAttempts:   maxAttempts,
    nextRetryInMs: nextRetryInMs ?? this.nextRetryInMs,
    errorMessage:  clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

// ─────────────────────────────────────────
// RECONNECT SERVICE
// ReconnectingEvent, ReconnectedEvent, ReconnectFailedEvent are defined in
// models/game_event.dart (sealed classes must be subclassed in the same file)
// ─────────────────────────────────────────

class ReconnectService {
  final GameService _gameService;

  // Backoff delays: 1s, 2s, 4s, 8s, 16s
  static const _backoffDelays = [1000, 2000, 4000, 8000, 16000];
  static const _maxRetries = 5;

  ReconnectService(this._gameService);

  /// Wraps a gRPC game-event stream with exponential-backoff reconnection.
  ///
  /// [roomId] and [userId] are used to re-establish the stream on reconnect.
  /// [onStateChange] fires whenever reconnect status changes so the UI
  /// can show/hide the reconnecting banner independently of the event stream.
  Stream<GameEvent> watchStream({
    required String roomId,
    required String userId,
    void Function(ReconnectState)? onStateChange,
  }) {
    return _buildResilientStream(
      roomId: roomId,
      userId: userId,
      onStateChange: onStateChange,
    );
  }

  Stream<GameEvent> _buildResilientStream({
    required String roomId,
    required String userId,
    void Function(ReconnectState)? onStateChange,
  }) async* {
    int attempt = 0;

    while (true) {
      try {
        // ── Notify: connected ──────────────────────────────
        if (attempt > 0) {
          // We just reconnected — catch up state before resuming
          final leaderboard = await _catchUpState(roomId);

          onStateChange?.call(const ReconnectState(
            status: ReconnectStatus.connected,
          ));

          yield ReconnectedEvent(leaderboard: leaderboard);
        }

        // ── Subscribe to (or re-subscribe to) the stream ──
        final source = _gameService.streamGameEvents(roomId, userId);

        await for (final event in source) {
          attempt = 0; // reset on successful receive
          yield event;

          // Stop retrying once the match is legitimately over
          if (event is MatchEndEvent) return;
        }

        // Stream closed cleanly (server ended it) — stop retrying
        return;

      } catch (e) {
        attempt++;

        if (attempt > _maxRetries) {
          // ── Max retries exceeded ───────────────────────
          final failState = ReconnectState(
            status: ReconnectStatus.failed,
            attempt: attempt,
            errorMessage: 'Connection lost after $_maxRetries retries.',
          );
          onStateChange?.call(failState);

          yield ReconnectFailedEvent(
            reason: 'Connection lost after $_maxRetries retries. '
                    'Please rejoin the match.',
          );
          return;
        }

        // ── Schedule retry with backoff ────────────────
        final delayMs = _backoffDelay(attempt);

        final retryState = ReconnectState(
          status: ReconnectStatus.reconnecting,
          attempt: attempt,
          nextRetryInMs: delayMs,
          errorMessage: e.toString(),
        );
        onStateChange?.call(retryState);

        yield ReconnectingEvent(
          attempt:      attempt,
          maxAttempts:  _maxRetries,
          retryInMs:    delayMs,
        );

        // ── Emit countdown ticks (UI can show "Retry in 3s…") ──
        yield* _countdownTicks(attempt, delayMs, onStateChange);
      }
    }
  }

  // ── Countdown ticks during backoff wait ──────────────────────

  Stream<GameEvent> _countdownTicks(
    int attempt,
    int totalDelayMs,
    void Function(ReconnectState)? onStateChange,
  ) async* {
    final end = DateTime.now().add(Duration(milliseconds: totalDelayMs));

    while (DateTime.now().isBefore(end)) {
      await Future.delayed(const Duration(milliseconds: 500));
      final remaining = end.difference(DateTime.now()).inMilliseconds.clamp(0, totalDelayMs);

      onStateChange?.call(ReconnectState(
        status: ReconnectStatus.reconnecting,
        attempt: attempt,
        nextRetryInMs: remaining,
      ));

      // Re-yield a fresh ReconnectingEvent so the UI banner updates
      yield ReconnectingEvent(
        attempt:     attempt,
        maxAttempts: _maxRetries,
        retryInMs:   remaining,
      );
    }
  }

  // ── State catch-up after reconnect ───────────────────────────

  /// Calls GetLeaderboard to restore current scores before resuming the stream.
  /// This ensures a reconnected player sees accurate state, not stale data.
  Future<List<PlayerScore>> _catchUpState(String roomId) async {
    try {
      return await _gameService.getLeaderboard(roomId);
    } catch (e) {
      debugPrint('[ReconnectService] catchUpState failed: $e');
      return []; // non-fatal — resume stream without scores
    }
  }

  // ── Exponential backoff ───────────────────────────────────────

  /// Returns delay in ms for attempt N.
  /// Attempt 1 → 1000ms, 2 → 2000ms, 3 → 4000ms, 4 → 8000ms, 5 → 16000ms
  int _backoffDelay(int attempt) {
    final idx = (attempt - 1).clamp(0, _backoffDelays.length - 1);
    return _backoffDelays[idx];
  }
}

// ─────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────

final reconnectServiceProvider = Provider<ReconnectService>((ref) {
  final gameService = ref.watch(gameServiceProvider);
  return ReconnectService(gameService);
});

/// Reconnect state notifier — drives the UI banner.
final reconnectStateProvider =
    StateNotifierProvider<ReconnectStateNotifier, ReconnectState>(
  (ref) => ReconnectStateNotifier(),
);

class ReconnectStateNotifier extends StateNotifier<ReconnectState> {
  ReconnectStateNotifier() : super(const ReconnectState());

  void update(ReconnectState newState) => state = newState;
  void reset() => state = const ReconnectState();
}

/// Resilient stream provider — use this instead of gameEventStreamProvider
/// in screens that need reconnection logic.
///
/// Usage:
/// ```dart
/// final stream = ref.watch(resilientGameStreamProvider(('roomId', 'userId')));
/// ```
final resilientGameStreamProvider =
    StreamProvider.family<GameEvent, (String, String)>(
  (ref, args) {
    final (roomId, userId) = args;
    final reconnectService = ref.watch(reconnectServiceProvider);
    final stateNotifier    = ref.read(reconnectStateProvider.notifier);

    return reconnectService.watchStream(
      roomId:        roomId,
      userId:        userId,
      onStateChange: stateNotifier.update,
    );
  },
);