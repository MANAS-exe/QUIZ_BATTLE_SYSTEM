import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../proto/quiz.pb.dart' as pb;
import '../proto/quiz.pbgrpc.dart' as pbgrpc;

// ─────────────────────────────────────────
// AUTH STATE
// ─────────────────────────────────────────

class AuthState {
  final String? token;
  final String? userId;
  final String? username;
  final int rating;
  final bool isLoggedIn;
  final int matchesPlayed;
  final int matchesWon;
  final int currentStreak;      // consecutive days played
  final int maxStreak;          // max daily login streak
  final int maxQuestionStreak;  // best answer streak ever

  const AuthState({
    this.token,
    this.userId,
    this.username,
    this.rating = 1000,
    this.isLoggedIn = false,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.maxQuestionStreak = 0,
  });

  AuthState copyWith({
    String? token,
    String? userId,
    String? username,
    int? rating,
    bool? isLoggedIn,
    int? matchesPlayed,
    int? matchesWon,
    int? currentStreak,
    int? maxStreak,
    int? maxQuestionStreak,
  }) {
    return AuthState(
      token: token ?? this.token,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      rating: rating ?? this.rating,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      matchesWon: matchesWon ?? this.matchesWon,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      maxQuestionStreak: maxQuestionStreak ?? this.maxQuestionStreak,
    );
  }
}

// ─────────────────────────────────────────
// AUTH NOTIFIER
// ─────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  late final pbgrpc.AuthServiceClient _client;
  bool _initialized = false;

  void init(ClientChannel channel) {
    if (_initialized) return;
    _client = pbgrpc.AuthServiceClient(channel);
    _initialized = true;
  }

  /// Try to restore saved credentials and auto-login.
  Future<bool> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('saved_username');
    final password = prefs.getString('saved_password');
    if (username == null || password == null) return false;

    final err = await login(username, password);
    return err == null;
  }

  /// Get saved username for pre-filling login form.
  Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_username');
  }

  Future<String?> register(String username, String password) async {
    try {
      final req = pb.AuthRequest()
        ..username = username
        ..password = password;
      final res = await _client.register(req);
      if (res.success) {
        state = AuthState(
          token: res.token,
          userId: res.userId,
          username: res.username,
          rating: res.rating,
          isLoggedIn: true,
        );
        await _saveCredentials(username, password);
        return null;
      }
      return res.message;
    } on GrpcError catch (e) {
      debugPrint('[AuthService] register error: ${e.codeName} — ${e.message}');
      return e.message ?? 'Registration failed';
    }
  }

  Future<String?> login(String username, String password) async {
    try {
      final req = pb.AuthRequest()
        ..username = username
        ..password = password;
      final res = await _client.login(req);
      if (res.success) {
        state = AuthState(
          token: res.token,
          userId: res.userId,
          username: res.username,
          rating: res.rating,
          isLoggedIn: true,
        );
        await _saveCredentials(username, password);
        // Load local stats
        await _loadLocalStats();
        return null;
      }
      return res.message;
    } on GrpcError catch (e) {
      debugPrint('[AuthService] login error: ${e.codeName} — ${e.message}');
      return e.message ?? 'Login failed';
    }
  }

  /// Called after a match ends to update local stats.
  void recordMatchResult({required bool won, required int newRating, int matchMaxStreak = 0}) {
    final played = state.matchesPlayed + 1;
    final wins = state.matchesWon + (won ? 1 : 0);
    final bestQStreak = matchMaxStreak > state.maxQuestionStreak ? matchMaxStreak : state.maxQuestionStreak;
    state = state.copyWith(
      rating: newRating,
      matchesPlayed: played,
      matchesWon: wins,
      maxQuestionStreak: bestQStreak,
    );
    _updateDailyStreak();
    _saveLocalStats();
  }

  Future<void> _updateDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'stats_${state.userId}';
    final lastPlayedStr = prefs.getString('${key}_lastPlayed');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastPlayedStr == today) return; // already counted today

    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
    int newStreak;
    if (lastPlayedStr == yesterday) {
      newStreak = state.currentStreak + 1;
    } else {
      newStreak = 1; // streak broken or first day
    }
    final newMax = newStreak > state.maxStreak ? newStreak : state.maxStreak;

    state = state.copyWith(currentStreak: newStreak, maxStreak: newMax);
    await prefs.setString('${key}_lastPlayed', today);
  }

  void logout() {
    state = const AuthState();
  }

  Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_username', username);
    await prefs.setString('saved_password', password);
  }

  Future<void> _saveLocalStats() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'stats_${state.userId}';
    await prefs.setInt('${key}_rating', state.rating);
    await prefs.setInt('${key}_played', state.matchesPlayed);
    await prefs.setInt('${key}_won', state.matchesWon);
    await prefs.setInt('${key}_streak', state.currentStreak);
    await prefs.setInt('${key}_maxStreak', state.maxStreak);
    await prefs.setInt('${key}_maxQStreak', state.maxQuestionStreak);
  }

  Future<void> _loadLocalStats() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'stats_${state.userId}';
    // Use locally-saved rating if higher than server rating (server rating
    // is the baseline from login; local rating accumulates match XP).
    final savedRating = prefs.getInt('${key}_rating') ?? state.rating;
    state = state.copyWith(
      rating: savedRating > state.rating ? savedRating : state.rating,
      matchesPlayed: prefs.getInt('${key}_played') ?? 0,
      matchesWon: prefs.getInt('${key}_won') ?? 0,
      currentStreak: prefs.getInt('${key}_streak') ?? 0,
      maxStreak: prefs.getInt('${key}_maxStreak') ?? 0,
      maxQuestionStreak: prefs.getInt('${key}_maxQStreak') ?? 0,
    );
  }
}

// ─────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
