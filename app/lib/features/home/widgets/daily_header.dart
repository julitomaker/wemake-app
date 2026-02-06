import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/daily_flow_provider.dart';

class DailyHeader extends ConsumerWidget {
  const DailyHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(dailyFlowProvider);

    final dateFormat = DateFormat('EEEE, d MMMM', 'es');
    final isToday = _isToday(state.selectedDate);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Date and Currency
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date selector
              GestureDetector(
                onTap: () => _showDatePicker(context, ref),
                child: Row(
                  children: [
                    Text(
                      isToday ? 'Hoy' : dateFormat.format(state.selectedDate),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ],
                ),
              ),

              // Currency display
              Row(
                children: [
                  // XP
                  _CurrencyChip(
                    icon: Icons.star,
                    value: state.currency?.xpTotal ?? 0,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  // Coins
                  _CurrencyChip(
                    icon: Icons.monetization_on,
                    value: state.currency?.coinsBalance ?? 0,
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress row: Score, Streaks, Macros
          Row(
            children: [
              // Daily score circle
              _ScoreCircle(
                percentage: state.completionPercentage,
                label: 'Dia',
              ),

              const SizedBox(width: 16),

              // Streaks
              Expanded(
                child: Row(
                  children: [
                    _StreakIndicator(
                      icon: Icons.local_fire_department,
                      count: state.streakLight?.currentCount ?? 0,
                      label: 'Light',
                      color: Colors.orange,
                      isActive: state.hasLightStreak,
                    ),
                    const SizedBox(width: 12),
                    _StreakIndicator(
                      icon: Icons.whatshot,
                      count: state.streakPerfect?.currentCount ?? 0,
                      label: 'Perfect',
                      color: Colors.deepOrange,
                      isActive: state.hasPerfectStreak,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Quick macros
              _MacroSummary(
                kcal: state.kcalConsumed,
                kcalTarget: state.kcalTarget,
                protein: state.proteinConsumed,
                proteinTarget: state.proteinTarget,
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showDatePicker(BuildContext context, WidgetRef ref) async {
    final state = ref.read(dailyFlowProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      ref.read(dailyFlowProvider.notifier).changeDate(picked);
    }
  }
}

class _CurrencyChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;

  const _CurrencyChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            _formatNumber(value),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }
}

class _ScoreCircle extends StatelessWidget {
  final double percentage;
  final String label;

  const _ScoreCircle({
    required this.percentage,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayPercentage = (percentage * 100).round();

    Color progressColor;
    if (percentage >= 0.9) {
      progressColor = Colors.green;
    } else if (percentage >= 0.6) {
      progressColor = Colors.orange;
    } else {
      progressColor = theme.colorScheme.primary;
    }

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage,
            strokeWidth: 4,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$displayPercentage%',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakIndicator extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;
  final bool isActive;

  const _StreakIndicator({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? color : theme.colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isActive ? color : theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class _MacroSummary extends StatelessWidget {
  final int kcal;
  final int kcalTarget;
  final int protein;
  final int proteinTarget;

  const _MacroSummary({
    required this.kcal,
    required this.kcalTarget,
    required this.protein,
    required this.proteinTarget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$kcal / $kcalTarget',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'kcal',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${protein}g / ${proteinTarget}g prot',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
