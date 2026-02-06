import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_models.dart';

/// Provider para las insignias del usuario
final userBadgesProvider = StateNotifierProvider<UserBadgesNotifier, List<AppBadge>>((ref) {
  return UserBadgesNotifier();
});

class UserBadgesNotifier extends StateNotifier<List<AppBadge>> {
  UserBadgesNotifier() : super(_initBadges());

  static List<AppBadge> _initBadges() {
    final allBadges = BadgeCollection.getAllBadges();
    // Simular algunas insignias desbloqueadas para demo
    return allBadges.map((badge) {
      if (badge.id == 'workout_10' ||
          badge.id == 'workout_50' ||
          badge.id == 'first_workout' ||
          badge.id == 'first_dropset' ||
          badge.id == 'streak_7' ||
          badge.id == 'streak_30' ||
          badge.id == 'volume_1ton' ||
          badge.id == 'app_early') {
        return badge.copyWith(isUnlocked: true, unlockedAt: '2025-01-15');
      }
      return badge;
    }).toList();
  }

  void unlockBadge(String badgeId) {
    state = state.map((badge) {
      if (badge.id == badgeId && !badge.isUnlocked) {
        return badge.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now().toIso8601String().substring(0, 10),
        );
      }
      return badge;
    }).toList();
  }
}

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(userBadgesProvider);
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB8FF00)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Insignias',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFB8FF00).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFB8FF00), size: 16),
                const SizedBox(width: 4),
                Text(
                  '$unlockedCount/${badges.length}',
                  style: const TextStyle(
                    color: Color(0xFFB8FF00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress overview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFB8FF00).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: unlockedCount / badges.length,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB8FF00)),
                        ),
                      ),
                      Text(
                        '${((unlockedCount / badges.length) * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu Coleccion',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$unlockedCount insignias desbloqueadas',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${badges.length - unlockedCount} por desbloquear',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Badge categories grid
            ...BadgeCategory.values.map((category) {
              final categoryBadges = badges.where((b) => b.category == category).toList();
              final unlockedInCategory = categoryBadges.where((b) => b.isUnlocked).length;
              final latestBadge = categoryBadges.where((b) => b.isUnlocked).isNotEmpty
                  ? categoryBadges.where((b) => b.isUnlocked).first
                  : categoryBadges.first;

              return _buildCategoryCard(
                context,
                BadgeCollection.getCategoryName(category),
                categoryBadges,
                unlockedInCategory,
                latestBadge,
              );
            }),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String categoryName,
    List<AppBadge> badges,
    int unlockedCount,
    AppBadge featuredBadge,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: featuredBadge.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => _showAllBadges(context, categoryName, badges),
                child: Text(
                  'Show all',
                  style: TextStyle(
                    color: featuredBadge.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Featured badge
          Center(
            child: _buildFeaturedBadge(featuredBadge),
          ),

          const SizedBox(height: 12),

          // Badge name and date
          Center(
            child: Column(
              children: [
                Text(
                  featuredBadge.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (featuredBadge.isUnlocked && featuredBadge.unlockedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    featuredBadge.unlockedAt!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Mini badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...badges.take(3).map((badge) => _buildMiniBadge(badge)),
              if (badges.length > 3)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${badges.length - 3}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBadge(AppBadge badge) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: badge.isUnlocked
            ? LinearGradient(
                colors: [
                  badge.color.withOpacity(0.3),
                  badge.color.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: badge.isUnlocked ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badge.isUnlocked ? badge.color : Colors.white.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: badge.isUnlocked
            ? [
                BoxShadow(
                  color: badge.color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            badge.icon,
            size: 48,
            color: badge.isUnlocked ? badge.color : Colors.white.withOpacity(0.2),
          ),
          if (!badge.isUnlocked)
            Positioned(
              bottom: 8,
              child: Icon(
                Icons.lock,
                size: 16,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          if (badge.isUnlocked)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badge.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(AppBadge badge) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: badge.isUnlocked
            ? badge.color.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: badge.isUnlocked ? badge.color.withOpacity(0.5) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Icon(
        badge.icon,
        size: 18,
        color: badge.isUnlocked ? badge.color : Colors.white.withOpacity(0.2),
      ),
    );
  }

  void _showAllBadges(BuildContext context, String categoryName, List<AppBadge> badges) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              categoryName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: badges.map((badge) => _buildBadgeItem(badge)).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(AppBadge badge) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: badge.isUnlocked
                ? badge.color.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: badge.isUnlocked ? badge.color : Colors.white.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                badge.icon,
                size: 28,
                color: badge.isUnlocked ? badge.color : Colors.white.withOpacity(0.2),
              ),
              if (!badge.isUnlocked)
                const Positioned(
                  bottom: 4,
                  child: Icon(Icons.lock, size: 12, color: Colors.white30),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: badge.isUnlocked ? Colors.white : Colors.white54,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
