import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/daily_flow_provider.dart';

class QuickActionsBar extends ConsumerWidget {
  const QuickActionsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(dailyFlowProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Water tracker
            _WaterQuickAction(
              consumed: state.waterBottlesConsumed,
              target: state.waterBottlesTarget,
              onAdd: () {
                ref.read(dailyFlowProvider.notifier).addWaterBottle();
              },
            ),

            // Quick add meal
            _QuickActionButton(
              icon: Icons.restaurant,
              label: 'Comida',
              color: Colors.green,
              onTap: () => context.push('/nutrition/add'),
            ),

            // Quick add workout
            _QuickActionButton(
              icon: Icons.fitness_center,
              label: 'Entreno',
              color: Colors.blue,
              onTap: () => context.push('/training/start'),
            ),

            // Quick add habit
            _QuickActionButton(
              icon: Icons.add_circle_outline,
              label: 'Habito',
              color: Colors.purple,
              onTap: () => context.push('/habits/add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterQuickAction extends StatelessWidget {
  final int consumed;
  final int target;
  final VoidCallback onAdd;

  const _WaterQuickAction({
    required this.consumed,
    required this.target,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final isComplete = consumed >= target;

    return GestureDetector(
      onTap: isComplete ? null : onAdd,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: Colors.cyan.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.cyan : Colors.cyan.shade400,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isComplete ? Icons.check : Icons.local_drink,
                  color: Colors.cyan,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$consumed/$target',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.cyan,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
