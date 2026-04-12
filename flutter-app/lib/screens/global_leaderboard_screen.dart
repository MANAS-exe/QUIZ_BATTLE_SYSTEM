import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../theme/colors.dart';

// ─────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────

class _LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final int rating;

  const _LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.rating,
  });

  factory _LeaderboardEntry.fromJson(Map<String, dynamic> j) =>
      _LeaderboardEntry(
        rank: j['rank'] as int,
        userId: j['user_id'] as String,
        username: j['username'] as String,
        rating: j['rating'] as int,
      );
}

// ─────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────

String get _leaderboardUrl {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080/leaderboard';
  }
  return 'http://localhost:8080/leaderboard';
}

final globalLeaderboardProvider =
    FutureProvider.autoDispose<List<_LeaderboardEntry>>((ref) async {
  final res = await http.get(Uri.parse(_leaderboardUrl));
  if (res.statusCode != 200) throw Exception('Server error ${res.statusCode}');
  final list = jsonDecode(res.body) as List<dynamic>;
  return list
      .map((e) => _LeaderboardEntry.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────

class GlobalLeaderboardScreen extends ConsumerWidget {
  const GlobalLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final leaderboardAsync = ref.watch(globalLeaderboardProvider);

    return Scaffold(
      backgroundColor: appBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, ref),
            Expanded(
              child: leaderboardAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: appCoral),
                ),
                error: (e, _) => _buildError(context, ref, e),
                data: (entries) => _buildList(entries, auth.userId, auth.isPremium),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white70, size: 20),
            onPressed: () => context.goNamed('home'),
          ),
          const Text(
            'Global Rankings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white38, size: 22),
            onPressed: () => ref.invalidate(globalLeaderboardProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object e) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 56),
          const SizedBox(height: 16),
          const Text(
            'Could not load leaderboard',
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Make sure the server is running',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(globalLeaderboardProvider),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: appCoral,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      List<_LeaderboardEntry> entries, String? myUserId, bool isPremium) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No players yet',
          style: TextStyle(color: Colors.white38, fontSize: 15),
        ),
      );
    }

    final top3 = entries.take(3).toList();
    final rest = entries.skip(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        children: [
          _buildPodium(top3, myUserId),
          const SizedBox(height: 20),
          if (isPremium)
            // Premium: show every entry after the podium
            ...rest.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRow(e.value, myUserId,
                      Duration(milliseconds: 60 + e.key * 40)),
                ))
          else
            // Free: blur + lock the rows after top 3
            _buildLockedRest(rest, myUserId),
        ],
      ),
    );
  }

  Widget _buildLockedRest(
      List<_LeaderboardEntry> rest, String? myUserId) {
    if (rest.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        // Blurred rows underneath
        ImageFiltered(
          imageFilter: ColorFilter.mode(
            appBg.withValues(alpha: 0.01),
            BlendMode.dst,
          ),
          child: ClipRect(
            child: ImageFiltered(
              imageFilter: _blurFilter,
              child: Column(
                children: rest.take(5).toList().asMap().entries.map((e) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildRow(e.value, myUserId,
                          Duration(milliseconds: 60 + e.key * 40)),
                    )).toList(),
              ),
            ),
          ),
        ),
        // Gradient fade + upgrade card on top
        Column(
          children: [
            // Transparent space so the blur is visible
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    appBg.withValues(alpha: 0.0),
                    appBg.withValues(alpha: 0.85),
                    appBg,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: appGold.withValues(alpha: 0.35)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_rounded, color: appGold, size: 32),
                  const SizedBox(height: 10),
                  const Text(
                    'Full rankings are Premium only',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upgrade to see all ${rest.length + 3} players ranked by rating',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _UpgradeButton(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPodium(List<_LeaderboardEntry> top3, String? myUserId) {
    // order: 2nd (left), 1st (center), 3rd (right)
    final order = [
      top3.length > 1 ? top3[1] : null,
      top3[0],
      top3.length > 2 ? top3[2] : null,
    ];
    final heights = [100.0, 130.0, 80.0];
    final colors = [appSilver, appGold, appBronze];
    final medals = ['2', '1', '3'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          final entry = order[i];
          if (entry == null) {
            return Expanded(child: SizedBox(height: heights[i]));
          }
          final isMe = entry.userId == myUserId;
          return Expanded(
            child: _PodiumBlock(
              entry: entry,
              height: heights[i],
              color: colors[i],
              medal: medals[i],
              isMe: isMe,
              delay: Duration(milliseconds: 80 + i * 80),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRow(
      _LeaderboardEntry entry, String? myUserId, Duration delay) {
    final isMe = entry.userId == myUserId;
    final initial =
        entry.username.isNotEmpty ? entry.username[0].toUpperCase() : '?';
    const avatarColors = [
      Color(0xFF0F3460),
      Color(0xFF533483),
      Color(0xFF2D6A4F),
      Color(0xFF7B2D8B),
      Color(0xFF1A4A80),
    ];
    final avatarColor =
        avatarColors[entry.username.codeUnitAt(0) % avatarColors.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? appCoral.withValues(alpha: 0.1) : appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? appCoral.withValues(alpha: 0.35) : Colors.white10,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${entry.rank}',
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 34,
            height: 34,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: avatarColor),
            alignment: Alignment.center,
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isMe ? '${entry.username} (You)' : entry.username,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isMe ? appCoral : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: appGold, size: 14),
              const SizedBox(width: 4),
              Text(
                '${entry.rating}',
                style: TextStyle(
                  color: isMe ? appCoral : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 300.ms)
        .slideX(begin: 0.06, end: 0, delay: delay);
  }
}

// ─────────────────────────────────────────
// PODIUM BLOCK
// ─────────────────────────────────────────

class _PodiumBlock extends StatelessWidget {
  final _LeaderboardEntry entry;
  final double height;
  final Color color;
  final String medal;
  final bool isMe;
  final Duration delay;

  const _PodiumBlock({
    required this.entry,
    required this.height,
    required this.color,
    required this.medal,
    required this.isMe,
    required this.delay,
  });

  Color get _avatarBg {
    const colors = [
      Color(0xFF0F3460),
      Color(0xFF533483),
      Color(0xFF2D6A4F),
      Color(0xFF7B2D8B),
      Color(0xFF1A4A80),
    ];
    return colors[entry.username.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final initial =
        entry.username.isNotEmpty ? entry.username[0].toUpperCase() : '?';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _avatarBg,
                border: Border.all(
                  color: isMe ? appCoral : color.withValues(alpha: 0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(initial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ),
            Positioned(
              bottom: -6,
              right: -2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: appBg, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(medal,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          isMe ? 'You' : entry.username,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: isMe ? appCoral : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: appGold, size: 12),
            const SizedBox(width: 2),
            Text('${entry.rating}',
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: delay, duration: 400.ms)
        .slideY(begin: 0.25, end: 0, delay: delay, curve: Curves.easeOutBack);
  }
}

// ─────────────────────────────────────────
// BLUR FILTER & UPGRADE BUTTON
// ─────────────────────────────────────────

final _blurFilter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);

class _UpgradeButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.pushNamed('premium'),
        icon: const Icon(Icons.bolt_rounded, size: 18),
        label: const Text('Upgrade to Premium'),
        style: ElevatedButton.styleFrom(
          backgroundColor: appGold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
