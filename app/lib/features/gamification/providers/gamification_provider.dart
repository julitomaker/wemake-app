import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/user_models.dart';
import '../../../core/services/demo_mode.dart';

part 'gamification_provider.freezed.dart';

/// Cosmetic item types
enum CosmeticType {
  avatar,
  frame,
  badge,
  title,
  theme,
}

/// Cosmetic item model
class CosmeticItem {
  final String id;
  final String name;
  final String description;
  final CosmeticType type;
  final int priceCoins;
  final String? imageUrl;
  final bool isLimited;
  final DateTime? expiresAt;

  const CosmeticItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.priceCoins,
    this.imageUrl,
    this.isLimited = false,
    this.expiresAt,
  });
}

/// User owned cosmetic
class OwnedCosmetic {
  final String id;
  final String cosmeticId;
  final DateTime purchasedAt;
  final bool isEquipped;

  const OwnedCosmetic({
    required this.id,
    required this.cosmeticId,
    required this.purchasedAt,
    this.isEquipped = false,
  });
}

/// Gamification state
@freezed
class GamificationState with _$GamificationState {
  const factory GamificationState({
    Currency? currency,
    @Default([]) List<Streak> streaks,
    @Default([]) List<CosmeticItem> storeItems,
    @Default([]) List<OwnedCosmetic> ownedCosmetics,
    @Default(false) bool isLoading,
    String? error,
  }) = _GamificationState;
}

/// Gamification notifier
class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(const GamificationState());

  /// Load gamification data
  Future<void> loadGamificationData() async {
    state = state.copyWith(isLoading: true, error: null);

    // --- Demo Mode: devolver datos mock de gamificacion ---
    if (demoMode.isActive) {
      await Future.delayed(const Duration(milliseconds: 250));

      final demoCurrency = Currency(
        id: 'demo_currency',
        userId: 'demo_user',
        xpTotal: 3850,
        xpWeekly: 520,
        coinsBalance: 215,
        updatedAt: DateTime.now(),
      );

      final demoStreaks = [
        Streak(
          id: 'demo_streak_1',
          userId: 'demo_user',
          streakType: StreakType.streakLight,
          currentCount: 18,
          longestCount: 42,
          lastExtendedAt: DateTime.now(),
          freezeAvailable: 2,
          frozenToday: false,
        ),
        Streak(
          id: 'demo_streak_2',
          userId: 'demo_user',
          streakType: StreakType.streakPerfect,
          currentCount: 7,
          longestCount: 21,
          lastExtendedAt: DateTime.now(),
          freezeAvailable: 1,
          frozenToday: false,
        ),
      ];

      final demoOwnedCosmetics = [
        OwnedCosmetic(
          id: 'demo_owned_1',
          cosmeticId: 'avatar_warrior',
          purchasedAt: DateTime.now().subtract(const Duration(days: 10)),
          isEquipped: true,
        ),
        OwnedCosmetic(
          id: 'demo_owned_2',
          cosmeticId: 'badge_early',
          purchasedAt: DateTime.now().subtract(const Duration(days: 30)),
          isEquipped: true,
        ),
        OwnedCosmetic(
          id: 'demo_owned_3',
          cosmeticId: 'badge_streak7',
          purchasedAt: DateTime.now().subtract(const Duration(days: 5)),
          isEquipped: true,
        ),
        OwnedCosmetic(
          id: 'demo_owned_4',
          cosmeticId: 'title_maker',
          purchasedAt: DateTime.now().subtract(const Duration(days: 15)),
          isEquipped: true,
        ),
      ];

      state = state.copyWith(
        currency: demoCurrency,
        streaks: demoStreaks,
        storeItems: _getMockStoreItems(),
        ownedCosmetics: demoOwnedCosmetics,
        isLoading: false,
      );
      return;
    }
    // --- Fin Demo Mode ---

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock data
      final currency = Currency(
        id: 'currency_1',
        userId: 'current_user',
        xpTotal: 2450,
        xpWeekly: 350,
        coinsBalance: 125,
        updatedAt: DateTime.now(),
      );

      final streaks = [
        Streak(
          id: 'streak_1',
          userId: 'current_user',
          streakType: StreakType.streakLight,
          currentCount: 12,
          longestCount: 28,
          lastExtendedAt: DateTime.now(),
          freezeAvailable: 2,
          frozenToday: false,
        ),
        Streak(
          id: 'streak_2',
          userId: 'current_user',
          streakType: StreakType.streakPerfect,
          currentCount: 5,
          longestCount: 14,
          lastExtendedAt: DateTime.now(),
          freezeAvailable: 1,
          frozenToday: false,
        ),
      ];

      final storeItems = _getMockStoreItems();

      state = state.copyWith(
        currency: currency,
        streaks: streaks,
        storeItems: storeItems,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Award XP to user
  Future<bool> awardXp(int amount, {String? reason}) async {
    if (state.currency == null) return false;

    try {
      final newXpTotal = state.currency!.xpTotal + amount;
      final newXpWeekly = state.currency!.xpWeekly + amount;

      state = state.copyWith(
        currency: state.currency!.copyWith(
          xpTotal: newXpTotal,
          xpWeekly: newXpWeekly,
          updatedAt: DateTime.now(),
        ),
      );

      // TODO: Save to Supabase
      // TODO: Check for level up

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Award coins to user
  Future<bool> awardCoins(int amount, {String? reason}) async {
    if (state.currency == null) return false;

    try {
      final newBalance = state.currency!.coinsBalance + amount;

      state = state.copyWith(
        currency: state.currency!.copyWith(
          coinsBalance: newBalance,
          updatedAt: DateTime.now(),
        ),
      );

      // TODO: Save to Supabase

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Purchase cosmetic item
  Future<bool> purchaseCosmetic(String cosmeticId) async {
    if (state.currency == null) return false;

    final item = state.storeItems.where((i) => i.id == cosmeticId).firstOrNull;
    if (item == null) return false;

    if (state.currency!.coinsBalance < item.priceCoins) {
      state = state.copyWith(error: 'Insufficient coins');
      return false;
    }

    // Check if already owned
    if (state.ownedCosmetics.any((c) => c.cosmeticId == cosmeticId)) {
      state = state.copyWith(error: 'Already owned');
      return false;
    }

    try {
      // Deduct coins
      final newBalance = state.currency!.coinsBalance - item.priceCoins;

      // Add to owned
      final newOwned = OwnedCosmetic(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cosmeticId: cosmeticId,
        purchasedAt: DateTime.now(),
      );

      state = state.copyWith(
        currency: state.currency!.copyWith(
          coinsBalance: newBalance,
          updatedAt: DateTime.now(),
        ),
        ownedCosmetics: [...state.ownedCosmetics, newOwned],
      );

      // TODO: Save to Supabase

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Equip cosmetic
  Future<bool> equipCosmetic(String cosmeticId) async {
    final ownedIndex = state.ownedCosmetics.indexWhere(
      (c) => c.cosmeticId == cosmeticId,
    );

    if (ownedIndex == -1) return false;

    final item = state.storeItems.where((i) => i.id == cosmeticId).firstOrNull;
    if (item == null) return false;

    try {
      // Unequip all of same type, equip this one
      final updatedOwned = state.ownedCosmetics.map((c) {
        final cItem = state.storeItems.where((i) => i.id == c.cosmeticId).firstOrNull;
        if (cItem?.type == item.type) {
          return OwnedCosmetic(
            id: c.id,
            cosmeticId: c.cosmeticId,
            purchasedAt: c.purchasedAt,
            isEquipped: c.cosmeticId == cosmeticId,
          );
        }
        return c;
      }).toList();

      state = state.copyWith(ownedCosmetics: updatedOwned);

      // TODO: Save to Supabase

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Extend streak (called when daily requirements met)
  Future<bool> extendStreak(StreakType type) async {
    final streakIndex = state.streaks.indexWhere((s) => s.streakType == type);
    if (streakIndex == -1) return false;

    try {
      final streak = state.streaks[streakIndex];
      final newCount = streak.currentCount + 1;
      final newLongest = newCount > streak.longestCount ? newCount : streak.longestCount;

      final updatedStreak = streak.copyWith(
        currentCount: newCount,
        longestCount: newLongest,
        lastExtendedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedStreaks = [...state.streaks];
      updatedStreaks[streakIndex] = updatedStreak;

      state = state.copyWith(streaks: updatedStreaks);

      // Award bonus XP for streak milestones
      if (newCount % 7 == 0) {
        await awardXp(50, reason: '7-day streak bonus');
        await awardCoins(10, reason: '7-day streak bonus');
      }

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Use streak freeze
  Future<bool> useStreakFreeze(StreakType type) async {
    final streakIndex = state.streaks.indexWhere((s) => s.streakType == type);
    if (streakIndex == -1) return false;

    final streak = state.streaks[streakIndex];
    if (streak.freezeAvailable <= 0) {
      state = state.copyWith(error: 'No freezes available');
      return false;
    }

    if (streak.frozenToday) {
      state = state.copyWith(error: 'Already frozen today');
      return false;
    }

    try {
      final updatedStreak = streak.copyWith(
        freezeAvailable: streak.freezeAvailable - 1,
        frozenToday: true,
        updatedAt: DateTime.now(),
      );

      final updatedStreaks = [...state.streaks];
      updatedStreaks[streakIndex] = updatedStreak;

      state = state.copyWith(streaks: updatedStreaks);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Open daily chest (random coins reward)
  Future<int> openDailyChest() async {
    try {
      // Random coins between 5-15
      final reward = 5 + (DateTime.now().millisecond % 11);
      await awardCoins(reward, reason: 'Daily chest');
      return reward;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return 0;
    }
  }

  /// Get user level based on XP
  int getUserLevel() {
    if (state.currency == null) return 1;

    final xp = state.currency!.xpTotal;
    // Simple level formula: level = sqrt(xp / 100) + 1
    return (xp / 100).floor() ~/ 10 + 1;
  }

  /// Get XP progress to next level
  double getXpProgress() {
    if (state.currency == null) return 0;

    final xp = state.currency!.xpTotal;
    final level = getUserLevel();
    final xpForCurrentLevel = (level - 1) * (level - 1) * 100;
    final xpForNextLevel = level * level * 100;
    final xpInLevel = xp - xpForCurrentLevel;
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;

    return xpInLevel / xpNeeded;
  }

  List<CosmeticItem> _getMockStoreItems() {
    return const [
      // Avatars
      CosmeticItem(
        id: 'avatar_warrior',
        name: 'Warrior',
        description: 'A fierce warrior avatar',
        type: CosmeticType.avatar,
        priceCoins: 100,
      ),
      CosmeticItem(
        id: 'avatar_ninja',
        name: 'Ninja',
        description: 'A stealthy ninja avatar',
        type: CosmeticType.avatar,
        priceCoins: 150,
      ),
      CosmeticItem(
        id: 'avatar_robot',
        name: 'Robot',
        description: 'A futuristic robot avatar',
        type: CosmeticType.avatar,
        priceCoins: 200,
      ),

      // Frames
      CosmeticItem(
        id: 'frame_gold',
        name: 'Golden Frame',
        description: 'A prestigious golden frame',
        type: CosmeticType.frame,
        priceCoins: 250,
      ),
      CosmeticItem(
        id: 'frame_fire',
        name: 'Fire Frame',
        description: 'A blazing fire frame',
        type: CosmeticType.frame,
        priceCoins: 300,
        isLimited: true,
      ),

      // Badges
      CosmeticItem(
        id: 'badge_early',
        name: 'Early Bird',
        description: 'For early adopters',
        type: CosmeticType.badge,
        priceCoins: 50,
      ),
      CosmeticItem(
        id: 'badge_streak7',
        name: '7-Day Warrior',
        description: 'Achieved 7-day streak',
        type: CosmeticType.badge,
        priceCoins: 75,
      ),
      CosmeticItem(
        id: 'badge_streak30',
        name: '30-Day Legend',
        description: 'Achieved 30-day streak',
        type: CosmeticType.badge,
        priceCoins: 200,
      ),

      // Titles
      CosmeticItem(
        id: 'title_maker',
        name: 'Maker',
        description: 'The Maker title',
        type: CosmeticType.title,
        priceCoins: 100,
      ),
      CosmeticItem(
        id: 'title_champion',
        name: 'Champion',
        description: 'The Champion title',
        type: CosmeticType.title,
        priceCoins: 175,
      ),

      // Themes
      CosmeticItem(
        id: 'theme_dark',
        name: 'Dark Mode Pro',
        description: 'Premium dark theme',
        type: CosmeticType.theme,
        priceCoins: 150,
      ),
      CosmeticItem(
        id: 'theme_neon',
        name: 'Neon Nights',
        description: 'Vibrant neon theme',
        type: CosmeticType.theme,
        priceCoins: 200,
      ),
    ];
  }
}

/// Gamification provider
final gamificationProvider = StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier();
});

/// Currency provider
final currencyProvider = Provider<Currency?>((ref) {
  return ref.watch(gamificationProvider).currency;
});

/// Streaks provider
final streaksProvider = Provider<List<Streak>>((ref) {
  return ref.watch(gamificationProvider).streaks;
});

/// Store items provider
final storeItemsProvider = Provider<List<CosmeticItem>>((ref) {
  return ref.watch(gamificationProvider).storeItems;
});

/// Owned cosmetics provider
final ownedCosmeticsProvider = Provider<List<OwnedCosmetic>>((ref) {
  return ref.watch(gamificationProvider).ownedCosmetics;
});

/// User level provider
final userLevelProvider = Provider<int>((ref) {
  return ref.watch(gamificationProvider.notifier).getUserLevel();
});
