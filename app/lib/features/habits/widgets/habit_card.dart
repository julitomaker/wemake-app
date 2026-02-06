import 'package:flutter/material.dart';

import '../../../core/models/habit_models.dart';

class HabitCard extends StatelessWidget {
  final HabitWithLog habit;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = habit.todayLog?.status == 'done';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            // Completion checkbox
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.habit.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted
                          ? theme.colorScheme.onSurface.withOpacity(0.5)
                          : null,
                    ),
                  ),
                  if (habit.habit.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      habit.habit.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Time if set
                      if (habit.habit.timeOfDay != null) ...[
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          habit.habit.timeOfDay!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // Rewards
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '+${habit.habit.xpValue}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              size: 12,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '+${habit.habit.coinsValue}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Type indicator
            _buildTypeIndicator(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIndicator(ThemeData theme) {
    IconData icon;
    Color color;

    switch (habit.habit.habitType) {
      case 'quantitative':
        icon = Icons.tag;
        color = Colors.blue;
        break;
      case 'evidence':
        icon = Icons.camera_alt;
        color = Colors.purple;
        break;
      case 'integrated':
        icon = Icons.sync;
        color = Colors.green;
        break;
      default:
        icon = Icons.check;
        color = theme.colorScheme.primary;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 18,
        color: color,
      ),
    );
  }
}
