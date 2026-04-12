import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_battle/providers/game_provider.dart';
import 'package:quiz_battle/services/auth_service.dart';

void main() {
  // ─── GameState unit tests ─────────────────────────────────────

  group('GameState', () {
    test('initializes with default values', () {
      const state = GameState();
      expect(state.phase, MatchPhase.idle);
      expect(state.currentAnswerStreak, 0);
      expect(state.maxAnswerStreak, 0);
      expect(state.currentWinStreak, 0);
      expect(state.maxWinStreak, 0);
      expect(state.totalRounds, 5);
      expect(state.hasAnswered, false);
    });

    test('copyWith preserves unchanged fields', () {
      const state = GameState();
      final updated = state.copyWith(currentAnswerStreak: 3, currentWinStreak: 2);
      expect(updated.currentAnswerStreak, 3);
      expect(updated.maxAnswerStreak, 0); // unchanged
      expect(updated.currentWinStreak, 2);
      expect(updated.phase, MatchPhase.idle); // unchanged
    });

    test('clearAnswer flag clears selectedAnswerIndex', () {
      const state = GameState(selectedAnswerIndex: 2);
      final cleared = state.copyWith(clearAnswer: true);
      expect(cleared.selectedAnswerIndex, null);
      expect(cleared.hasAnswered, false);
    });
  });

  // ─── Win streak logic (pure state tests) ─────────────────────

  group('Win streak logic', () {
    int _calcWinStreak({
      required int? selectedAnswer,
      required int correctIndex,
      required String fastestUserId,
      required String myUserId,
      required int currentWinStreak,
    }) {
      final wasCorrect = selectedAnswer == correctIndex;
      final wasWinner = wasCorrect && fastestUserId == myUserId;
      return wasWinner ? currentWinStreak + 1 : 0;
    }

    test('increments when correct AND fastest', () {
      final streak = _calcWinStreak(
        selectedAnswer: 0,
        correctIndex: 0,
        fastestUserId: 'me',
        myUserId: 'me',
        currentWinStreak: 0,
      );
      expect(streak, 1);
    });

    test('does not increment when correct but NOT fastest', () {
      final streak = _calcWinStreak(
        selectedAnswer: 0,
        correctIndex: 0,
        fastestUserId: 'other',
        myUserId: 'me',
        currentWinStreak: 2,
      );
      expect(streak, 0);
    });

    test('resets on wrong answer even if fastest', () {
      final streak = _calcWinStreak(
        selectedAnswer: 1,
        correctIndex: 0,
        fastestUserId: 'me',
        myUserId: 'me',
        currentWinStreak: 3,
      );
      expect(streak, 0);
    });

    test('maxWinStreak preserved after reset', () {
      final currentWinStreak = 0;
      const maxWinStreak = 3;
      final newMax = currentWinStreak > maxWinStreak ? currentWinStreak : maxWinStreak;
      expect(newMax, 3);
    });

    test('maxWinStreak updates when current exceeds it', () {
      const currentWinStreak = 5;
      const maxWinStreak = 3;
      final newMax = currentWinStreak > maxWinStreak ? currentWinStreak : maxWinStreak;
      expect(newMax, 5);
    });
  });

  // ─── AuthState quota logic ────────────────────────────────────

  group('AuthState — daily quota (free user)', () {
    test('free user remaining decrements correctly', () {
      const auth = AuthState(isPremium: false, dailyQuizUsed: 2);
      expect(auth.dailyQuizRemaining, 3);
      expect(auth.isQuotaExhausted, false);
    });

    test('free user quota exhausted at limit', () {
      const auth = AuthState(isPremium: false, dailyQuizUsed: 5);
      expect(auth.dailyQuizRemaining, 0);
      expect(auth.isQuotaExhausted, true);
    });

    test('free user clamps remaining to 0 if over limit', () {
      const auth = AuthState(isPremium: false, dailyQuizUsed: 7);
      expect(auth.dailyQuizRemaining, 0);
      expect(auth.isQuotaExhausted, true);
    });

    test('premium user quota is never exhausted', () {
      const auth = AuthState(isPremium: true, dailyQuizUsed: 999);
      expect(auth.isQuotaExhausted, false);
    });

    test('bonus games add to remaining', () {
      const auth = AuthState(
          isPremium: false, dailyQuizUsed: 5, bonusGamesRemaining: 3);
      expect(auth.dailyQuizRemaining, 3);
      expect(auth.isQuotaExhausted, false);
    });

    test('quota exhausted only when free AND bonus both zero', () {
      const auth = AuthState(
          isPremium: false, dailyQuizUsed: 5, bonusGamesRemaining: 0);
      expect(auth.isQuotaExhausted, true);
    });
  });

  // ─── isEffectivelyPremium ─────────────────────────────────────

  group('AuthState — isEffectivelyPremium', () {
    test('isPremium=true → effectively premium', () {
      const auth = AuthState(isPremium: true);
      expect(auth.isEffectivelyPremium, true);
    });

    test('no trial → not effectively premium', () {
      const auth = AuthState(isPremium: false);
      expect(auth.isEffectivelyPremium, false);
    });

    test('active trial → effectively premium', () {
      final expiry = DateTime.now()
          .add(const Duration(days: 3))
          .toIso8601String();
      final auth = AuthState(isPremium: false, premiumTrialExpiresAt: expiry);
      expect(auth.isEffectivelyPremium, true);
      expect(auth.isQuotaExhausted, false);
    });

    test('expired trial → not effectively premium', () {
      final expiry = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String();
      final auth = AuthState(
          isPremium: false,
          dailyQuizUsed: 5,
          premiumTrialExpiresAt: expiry);
      expect(auth.isEffectivelyPremium, false);
      expect(auth.isQuotaExhausted, true);
    });

    test('malformed trial date → not effectively premium', () {
      const auth = AuthState(
          isPremium: false, premiumTrialExpiresAt: 'not-a-date');
      expect(auth.isEffectivelyPremium, false);
    });
  });

  // ─── rewardForDay ─────────────────────────────────────────────

  group('rewardForDay', () {
    test('day 1 gives 50 coins, no bonus games', () {
      final r = rewardForDay(1);
      expect(r.coins, 50);
      expect(r.bonusGames, 0);
      expect(r.badgeId, isNull);
      expect(r.premiumTrialDays, 0);
    });

    test('day 7 gives 250 coins + 3 bonus games + week_warrior badge', () {
      final r = rewardForDay(7);
      expect(r.coins, 250);
      expect(r.bonusGames, 3);
      expect(r.badgeId, 'week_warrior');
      expect(r.premiumTrialDays, 0);
    });

    test('day 14 (milestone) gives 500 coins + 5 bonus + fortnight_fighter', () {
      final r = rewardForDay(14);
      expect(r.coins, 500);
      expect(r.bonusGames, 5);
      expect(r.badgeId, 'fortnight_fighter');
      expect(r.premiumTrialDays, 0);
    });

    test('day 30 (milestone) gives 1000 coins + 7-day trial + monthly_master', () {
      final r = rewardForDay(30);
      expect(r.coins, 1000);
      expect(r.bonusGames, 7);
      expect(r.badgeId, 'monthly_master');
      expect(r.premiumTrialDays, 7);
    });

    test('day 8 cycles back to day-1 reward (50 coins)', () {
      final r = rewardForDay(8);
      expect(r.coins, 50);
      expect(r.bonusGames, 0);
    });

    test('day 35 cycles to day-7 reward (250 coins)', () {
      // (35-1) % 7 + 1 = 0 + 1... wait: (34 % 7) = 6, +1 = 7
      final r = rewardForDay(35);
      expect(r.coins, 250);
      expect(r.bonusGames, 3);
      expect(r.badgeId, 'week_warrior');
    });
  });

  // ─── AuthState.pendingReward ──────────────────────────────────

  group('AuthState — pendingReward', () {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    test('returns reward when logged in and streak > 0 and not claimed', () {
      final auth = AuthState(
          isLoggedIn: true, currentStreak: 3, dailyRewardClaimedDate: yesterday);
      expect(auth.pendingReward, isNotNull);
      expect(auth.pendingReward!.coins, 100); // day 3 = 100 coins
    });

    test('returns null when already claimed today', () {
      final auth = AuthState(
          isLoggedIn: true, currentStreak: 3, dailyRewardClaimedDate: today);
      expect(auth.pendingReward, isNull);
    });

    test('returns null when streak is 0', () {
      const auth = AuthState(isLoggedIn: true, currentStreak: 0);
      expect(auth.pendingReward, isNull);
    });

    test('returns null when not logged in', () {
      const auth = AuthState(isLoggedIn: false, currentStreak: 5);
      expect(auth.pendingReward, isNull);
    });
  });

  // ─── AuthState copyWith sentinel (premiumTrialExpiresAt) ──────

  group('AuthState.copyWith sentinel', () {
    test('omitting premiumTrialExpiresAt preserves existing value', () {
      const auth = AuthState(premiumTrialExpiresAt: '2099-01-01T00:00:00');
      final updated = auth.copyWith(coins: 100);
      expect(updated.premiumTrialExpiresAt, '2099-01-01T00:00:00');
    });

    test('explicitly passing null clears premiumTrialExpiresAt', () {
      const auth = AuthState(premiumTrialExpiresAt: '2099-01-01T00:00:00');
      final updated = auth.copyWith(premiumTrialExpiresAt: null);
      expect(updated.premiumTrialExpiresAt, isNull);
    });
  });
}
