import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';

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

  const AuthState({
    this.token,
    this.userId,
    this.username,
    this.rating = 1000,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    String? token,
    String? userId,
    String? username,
    int? rating,
    bool? isLoggedIn,
  }) {
    return AuthState(
      token: token ?? this.token,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      rating: rating ?? this.rating,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

// ─────────────────────────────────────────
// AUTH NOTIFIER
// ─────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  late final pbgrpc.AuthServiceClient _client;

  void init(ClientChannel channel) {
    _client = pbgrpc.AuthServiceClient(channel);
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
        return null; // no error
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
        return null; // no error
      }
      return res.message;
    } on GrpcError catch (e) {
      debugPrint('[AuthService] login error: ${e.codeName} — ${e.message}');
      return e.message ?? 'Login failed';
    }
  }

  void logout() {
    state = const AuthState();
  }
}

// ─────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
