import 'package:flutter/material.dart';

/// Categorías de insignias siguiendo el diseño de referencia
enum BadgeCategory {
  entrenamientos,
  milestones,
  rachas,
  calendario,
  volumen,
  app,
}

/// Nivel de rareza de la insignia
enum BadgeRarity {
  comun,
  raro,
  epico,
  legendario,
}

/// Modelo de insignia
class AppBadge {
  final String id;
  final String name;
  final String description;
  final BadgeCategory category;
  final BadgeRarity rarity;
  final IconData icon;
  final Color color;
  final int requiredValue;
  final String? unlockedAt;
  final bool isUnlocked;

  const AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.rarity,
    required this.icon,
    required this.color,
    required this.requiredValue,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  AppBadge copyWith({bool? isUnlocked, String? unlockedAt}) {
    return AppBadge(
      id: id,
      name: name,
      description: description,
      category: category,
      rarity: rarity,
      icon: icon,
      color: color,
      requiredValue: requiredValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

/// Colección de todas las insignias disponibles
class BadgeCollection {
  static const Color _gold = Color(0xFFFFD700);
  static const Color _silver = Color(0xFFC0C0C0);
  static const Color _bronze = Color(0xFFCD7F32);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _green = Color(0xFF10B981);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _red = Color(0xFFEF4444);
  static const Color _cyan = Color(0xFF06B6D4);

  static List<AppBadge> getAllBadges() {
    return [
      // === ENTRENAMIENTOS ===
      const AppBadge(
        id: 'workout_10',
        name: '10 Entrenamientos',
        description: 'Completa 10 entrenamientos',
        category: BadgeCategory.entrenamientos,
        rarity: BadgeRarity.comun,
        icon: Icons.fitness_center,
        color: _bronze,
        requiredValue: 10,
      ),
      const AppBadge(
        id: 'workout_50',
        name: '50 Entrenamientos',
        description: 'Completa 50 entrenamientos',
        category: BadgeCategory.entrenamientos,
        rarity: BadgeRarity.raro,
        icon: Icons.fitness_center,
        color: _silver,
        requiredValue: 50,
      ),
      const AppBadge(
        id: 'workout_100',
        name: '100 Entrenamientos',
        description: 'Completa 100 entrenamientos',
        category: BadgeCategory.entrenamientos,
        rarity: BadgeRarity.epico,
        icon: Icons.fitness_center,
        color: _gold,
        requiredValue: 100,
      ),
      const AppBadge(
        id: 'workout_200',
        name: '200 Entrenamientos',
        description: 'Completa 200 entrenamientos',
        category: BadgeCategory.entrenamientos,
        rarity: BadgeRarity.legendario,
        icon: Icons.emoji_events,
        color: _purple,
        requiredValue: 200,
      ),

      // === MILESTONES ===
      const AppBadge(
        id: 'first_workout',
        name: 'Primera Sesion',
        description: 'Completa tu primera sesion',
        category: BadgeCategory.milestones,
        rarity: BadgeRarity.comun,
        icon: Icons.star,
        color: _green,
        requiredValue: 1,
      ),
      const AppBadge(
        id: 'first_dropset',
        name: 'Primer Dropset',
        description: 'Completa tu primer dropset',
        category: BadgeCategory.milestones,
        rarity: BadgeRarity.raro,
        icon: Icons.trending_down,
        color: _blue,
        requiredValue: 1,
      ),
      const AppBadge(
        id: 'pr_breaker',
        name: 'Rompe Records',
        description: 'Rompe tu primer PR',
        category: BadgeCategory.milestones,
        rarity: BadgeRarity.raro,
        icon: Icons.military_tech,
        color: _gold,
        requiredValue: 1,
      ),
      const AppBadge(
        id: 'century_club',
        name: 'Club del Centenario',
        description: 'Levanta 100kg en cualquier ejercicio',
        category: BadgeCategory.milestones,
        rarity: BadgeRarity.epico,
        icon: Icons.workspace_premium,
        color: _red,
        requiredValue: 100,
      ),

      // === RACHAS ===
      const AppBadge(
        id: 'streak_7',
        name: '1 Semana',
        description: 'Manten una racha de 7 dias',
        category: BadgeCategory.rachas,
        rarity: BadgeRarity.comun,
        icon: Icons.local_fire_department,
        color: Color(0xFFFF6B35),
        requiredValue: 7,
      ),
      const AppBadge(
        id: 'streak_30',
        name: '1 Mes',
        description: 'Manten una racha de 30 dias',
        category: BadgeCategory.rachas,
        rarity: BadgeRarity.raro,
        icon: Icons.local_fire_department,
        color: Color(0xFFFF4500),
        requiredValue: 30,
      ),
      const AppBadge(
        id: 'streak_90',
        name: '3 Meses',
        description: 'Manten una racha de 90 dias',
        category: BadgeCategory.rachas,
        rarity: BadgeRarity.epico,
        icon: Icons.local_fire_department,
        color: Color(0xFFDC143C),
        requiredValue: 90,
      ),
      const AppBadge(
        id: 'streak_365',
        name: '1 Ano',
        description: 'Manten una racha de 365 dias',
        category: BadgeCategory.rachas,
        rarity: BadgeRarity.legendario,
        icon: Icons.whatshot,
        color: _purple,
        requiredValue: 365,
      ),

      // === CALENDARIO ===
      const AppBadge(
        id: 'calendar_week',
        name: 'Semana Perfecta',
        description: 'Entrena todos los dias de la semana',
        category: BadgeCategory.calendario,
        rarity: BadgeRarity.raro,
        icon: Icons.calendar_today,
        color: _green,
        requiredValue: 7,
      ),
      const AppBadge(
        id: 'calendar_month',
        name: 'Mes Perfecto',
        description: '100 entrenamientos en un ano',
        category: BadgeCategory.calendario,
        rarity: BadgeRarity.epico,
        icon: Icons.calendar_month,
        color: _cyan,
        requiredValue: 100,
      ),

      // === VOLUMEN ===
      const AppBadge(
        id: 'volume_1ton',
        name: '1 Tonelada',
        description: 'Mueve 1,000kg en una sesion',
        category: BadgeCategory.volumen,
        rarity: BadgeRarity.comun,
        icon: Icons.scale,
        color: _bronze,
        requiredValue: 1000,
      ),
      const AppBadge(
        id: 'volume_5ton',
        name: '5 Toneladas',
        description: 'Mueve 5,000kg en una sesion',
        category: BadgeCategory.volumen,
        rarity: BadgeRarity.raro,
        icon: Icons.scale,
        color: _silver,
        requiredValue: 5000,
      ),
      const AppBadge(
        id: 'volume_10ton',
        name: '10 Toneladas',
        description: 'Mueve 10,000kg en una sesion',
        category: BadgeCategory.volumen,
        rarity: BadgeRarity.epico,
        icon: Icons.scale,
        color: _gold,
        requiredValue: 10000,
      ),

      // === APP ===
      const AppBadge(
        id: 'app_early',
        name: 'Early Adopter',
        description: 'Te uniste en los primeros 1000 usuarios',
        category: BadgeCategory.app,
        rarity: BadgeRarity.legendario,
        icon: Icons.rocket_launch,
        color: _purple,
        requiredValue: 1,
      ),
      const AppBadge(
        id: 'app_share',
        name: 'Embajador',
        description: 'Comparte la app con 5 amigos',
        category: BadgeCategory.app,
        rarity: BadgeRarity.raro,
        icon: Icons.share,
        color: _blue,
        requiredValue: 5,
      ),
    ];
  }

  static List<AppBadge> getBadgesByCategory(BadgeCategory category) {
    return getAllBadges().where((b) => b.category == category).toList();
  }

  static String getCategoryName(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.entrenamientos:
        return 'Entrenamientos';
      case BadgeCategory.milestones:
        return 'Milestones';
      case BadgeCategory.rachas:
        return 'Rachas';
      case BadgeCategory.calendario:
        return 'Calendario';
      case BadgeCategory.volumen:
        return 'Volumen';
      case BadgeCategory.app:
        return 'App';
    }
  }

  static Color getRarityColor(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.comun:
        return const Color(0xFF9CA3AF);
      case BadgeRarity.raro:
        return const Color(0xFF3B82F6);
      case BadgeRarity.epico:
        return const Color(0xFF8B5CF6);
      case BadgeRarity.legendario:
        return const Color(0xFFFFD700);
    }
  }
}
