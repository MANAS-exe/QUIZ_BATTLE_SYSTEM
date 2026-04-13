import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
// BACKGROUND MESSAGE HANDLER
// ─────────────────────────────────────────────────────────────
//
// Must be a top-level function (not a class method) — FCM requirement.
// Called when a data-only message arrives and the app is terminated/background.
// Keep it fast and free of Flutter UI code.

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No Firebase.initializeApp() needed here — firebase_messaging handles it.
  debugPrint('[FCM] Background message: ${message.messageId} type=${message.data['type']}');
}

// ─────────────────────────────────────────────────────────────
// NOTIFICATION SERVICE
// ─────────────────────────────────────────────────────────────
//
// Responsibilities:
//   1. Request OS notification permission (iOS/Android 13+)
//   2. Obtain the FCM token and register it with the backend
//   3. Refresh the token whenever FCM rotates it
//   4. Set up foreground message listener (in-app banner via onMessage)
//
// Usage — call once after login:
//   await NotificationService.instance.init(token: authToken);
//
// The service stores the last-registered FCM token in SharedPreferences
// under "fcm_token" to avoid redundant network calls on subsequent launches.

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;

  // Callback for in-app notification banners — set by HomeScreen
  void Function(String title, String body, Map<String, dynamic> data)? onForegroundMessage;

  // ── Initialise ────────────────────────────────────────────

  /// Call this once after the user successfully logs in.
  /// [token] is the JWT used to authenticate with the backend.
  Future<void> init({required String token}) async {
    // Register the background handler (idempotent)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Permission denied — notifications will not be delivered');
      return;
    }

    // Get token and register with backend
    final fcmToken = await _messaging.getToken();
    if (fcmToken != null) {
      await _registerToken(fcmToken, jwtToken: token);
    }

    // Refresh token when FCM rotates it
    _messaging.onTokenRefresh.listen((newToken) {
      _registerToken(newToken, jwtToken: token);
    });

    // Foreground messages — show an in-app banner via [onForegroundMessage]
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final title = notification?.title ?? message.data['title'] ?? '';
      final body = notification?.body ?? message.data['body'] ?? '';
      debugPrint('[FCM] Foreground message: $title');
      onForegroundMessage?.call(title, body, message.data);
    });

    // Tapped notification while app was in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message.data);
    });

    // Tapped notification that launched the app from terminated state
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleNotificationTap(initial.data);
    }

    debugPrint('[FCM] NotificationService initialised');
  }

  // ── Token registration ────────────────────────────────────

  /// Registers the FCM token with the backend (POST /device/token).
  /// Skips the network call if the token hasn't changed since last registration.
  Future<void> _registerToken(String fcmToken, {required String jwtToken}) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('fcm_token');

    if (stored == fcmToken) {
      debugPrint('[FCM] Token unchanged — skipping registration');
      return;
    }

    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

    try {
      final resp = await http
          .post(
            Uri.parse('http://$host:8080/device/token'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
            body: jsonEncode({'token': fcmToken, 'platform': platform}),
          )
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        await prefs.setString('fcm_token', fcmToken);
        debugPrint('[FCM] Token registered with backend (platform: $platform)');
      } else {
        debugPrint('[FCM] Token registration failed: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('[FCM] Token registration error: $e');
    }
  }

  // ── Notification tap routing ──────────────────────────────

  /// Routes a tapped notification to the appropriate screen.
  /// The [data] map comes from the FCM message's data payload.
  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    debugPrint('[FCM] Notification tapped — type: $type');
    // Navigation is handled by the app's router; store the pending route
    // in SharedPreferences so the router can pick it up on next build.
    // Extend this switch as new notification types are added.
    switch (type) {
      case 'streak_warning':
      case 'daily_reward':
        _setPendingRoute('/home');
        break;
      case 'referral_converted':
        _setPendingRoute('/profile');
        break;
      case 'premium_expiry':
        _setPendingRoute('/premium');
        break;
      case 'tournament_reminder':
        _setPendingRoute('/matchmaking');
        break;
    }
  }

  Future<void> _setPendingRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_notification_route', route);
  }

  /// Drains the pending notification route (called from main.dart on resume).
  /// Returns null if there is no pending route.
  Future<String?> consumePendingRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final route = prefs.getString('pending_notification_route');
    await prefs.remove('pending_notification_route');
    return route;
  }

  /// Call on logout to deregister the token locally.
  /// The backend token remains in MongoDB — it will simply never match the
  /// (now invalid) JWT on future requests. A future cleanup job can purge stale tokens.
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_token');
  }
}
