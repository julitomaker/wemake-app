import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/habit_models.dart';
import '../providers/daily_flow_provider.dart';

class DailyFlowTimeline extends ConsumerWidget {
  const DailyFlowTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(dailyFlowProvider);

    if (state.items.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        final isLast = index == state.items.length - 1;

        return _TimelineItem(
          item: item,
          isLast: isLast,
          onComplete: () {
            ref.read(dailyFlowProvider.notifier).completeItem(item.id);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu dia esta vacio',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega habitos, comidas y entrenamientos\npara empezar a construir tu rutina.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add habit/meal
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar actividad'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final DailyFlowItem item;
  final bool isLast;
  final VoidCallback onComplete;

  const _TimelineItem({
    required this.item,
    required this.isLast,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          _buildTimelineIndicator(theme),

          const SizedBox(width: 12),

          // Content card
          Expanded(
            child: _buildContentCard(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator(ThemeData theme) {
    final color = _getTypeColor(item.type);

    return SizedBox(
      width: 40,
      child: Column(
        children: [
          // Time
          if (item.scheduledTime != null)
            Text(
              '${item.scheduledTime!.hour.toString().padLeft(2, '0')}:${item.scheduledTime!.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            )
          else
            const SizedBox(height: 14),

          const SizedBox(height: 4),

          // Dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.isCompleted ? color : Colors.transparent,
              border: Border.all(
                color: item.isCompleted
                    ? color
                    : theme.colorScheme.outline.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: item.isCompleted
                ? const Icon(Icons.check, size: 8, color: Colors.white)
                : null,
          ),

          // Line
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: item.isCompleted
                    ? color.withOpacity(0.5)
                    : theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, ThemeData theme) {
    final color = _getTypeColor(item.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: item.isCompleted ? null : onComplete,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.isCompleted
                ? color.withOpacity(0.1)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.isCompleted
                  ? color.withOpacity(0.3)
                  : theme.colorScheme.outline.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              // Type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getTypeIcon(item.type),
                  color: color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.isCompleted
                                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                                  : null,
                            ),
                          ),
                        ),
                        // XP reward
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
                                '+${item.xpReward}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                    // Progress for counter/timer habits
                    if (item.habitType == HabitType.counter &&
                        item.targetValue != null) ...[
                      const SizedBox(height: 8),
                      _buildProgressIndicator(theme, color),
                    ],
                  ],
                ),
              ),

              // Completion checkbox
              if (!item.isCompleted) ...[
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: color.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme, Color color) {
    final progress = item.currentValue != null && item.targetValue != null
        ? (item.currentValue! / item.targetValue!).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${item.currentValue?.toInt() ?? 0} / ${item.targetValue?.toInt() ?? 0}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(DailyFlowItemType type) {
    switch (type) {
      case DailyFlowItemType.habit:
        return Colors.purple;
      case DailyFlowItemType.meal:
        return Colors.green;
      case DailyFlowItemType.workout:
        return Colors.blue;
      case DailyFlowItemType.task:
        return Colors.orange;
      case DailyFlowItemType.water:
        return Colors.cyan;
    }
  }

  IconData _getTypeIcon(DailyFlowItemType type) {
    switch (type) {
      case DailyFlowItemType.habit:
        return Icons.repeat;
      case DailyFlowItemType.meal:
        return Icons.restaurant;
      case DailyFlowItemType.workout:
        return Icons.fitness_center;
      case DailyFlowItemType.task:
        return Icons.task_alt;
      case DailyFlowItemType.water:
        return Icons.local_drink;
    }
  }
}
