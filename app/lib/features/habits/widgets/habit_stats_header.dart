import 'package:flutter/material.dart';

class HabitStatsHeader extends StatelessWidget {
  final int totalHabits;
  final int completedToday;
  final int currentStreak;
  final double weeklyCompletion;

  const HabitStatsHeader({
    super.key,
    required this.totalHabits,
    required this.completedToday,
    required this.currentStreak,
    required this.weeklyCompletion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalHabits > 0 ? completedToday / totalHabits : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress section
          Row(
            children: [
              // Circular progress
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$completedToday/$totalHabits',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'hoy',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMotivationalMessage(progress),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progress >= 1.0
                          ? 'Has completado todos tus habitos!'
                          : 'Te faltan ${totalHabits - completedToday} habitos por completar',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bottom stats row
          Row(
            children: [
              _StatItem(
                icon: Icons.local_fire_department,
                value: '$currentStreak',
                label: 'Racha',
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withOpacity(0.2),
              ),
              _StatItem(
                icon: Icons.calendar_today,
                value: '${(weeklyCompletion * 100).round()}%',
                label: 'Semana',
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withOpacity(0.2),
              ),
              _StatItem(
                icon: Icons.emoji_events,
                value: '$totalHabits',
                label: 'Total',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(double progress) {
    if (progress >= 1.0) return 'Dia perfecto!';
    if (progress >= 0.9) return 'Casi perfecto!';
    if (progress >= 0.6) return 'Buen progreso!';
    if (progress >= 0.3) return 'Sigue asi!';
    return 'A por ello!';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
