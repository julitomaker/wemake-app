import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_provider.dart';

class StepGoals extends ConsumerWidget {
  const StepGoals({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);

    final primaryGoals = [
      (
        'muscle',
        'Ganar musculo',
        'Aumentar masa muscular y fuerza',
        Icons.trending_up,
        Colors.blue,
      ),
      (
        'fat_loss',
        'Perder grasa',
        'Reducir grasa corporal manteniendo musculo',
        Icons.local_fire_department,
        Colors.orange,
      ),
      (
        'maintenance',
        'Mantenerme',
        'Mantener mi fisico actual',
        Icons.balance,
        Colors.green,
      ),
      (
        'energy',
        'Mas energia',
        'Mejorar rendimiento y vitalidad diaria',
        Icons.bolt,
        Colors.yellow.shade700,
      ),
    ];

    final urgencyOptions = [
      ('relaxed', 'Tranquilo', 'Sin prisa, cambios sostenibles'),
      ('moderate', 'Moderado', 'Progreso constante en 3-6 meses'),
      ('aggressive', 'Agresivo', 'Resultados rapidos, mas esfuerzo'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          Text(
            'Cual es tu meta principal?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esto determina tu plan de nutricion y entrenamiento.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 24),

          // Primary goals - 2x2 grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: primaryGoals
                .map((goal) => _GoalCard(
                      value: goal.$1,
                      title: goal.$2,
                      description: goal.$3,
                      icon: goal.$4,
                      color: goal.$5,
                      isSelected: state.goalPrimary == goal.$1,
                      onTap: () {
                        ref.read(onboardingProvider.notifier).setGoals(
                              primary: goal.$1,
                            );
                      },
                    ))
                .toList(),
          ),

          const SizedBox(height: 32),

          // Urgency
          Text(
            'Con que urgencia?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          ...urgencyOptions.map((urgency) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _UrgencyOption(
                  value: urgency.$1,
                  title: urgency.$2,
                  description: urgency.$3,
                  isSelected: state.goalUrgency == urgency.$1,
                  onTap: () {
                    ref.read(onboardingProvider.notifier).setGoals(
                          urgency: urgency.$1,
                        );
                  },
                ),
              )),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String value;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected
                    ? color
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UrgencyOption extends StatelessWidget {
  final String value;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _UrgencyOption({
    required this.value,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: 2,
                ),
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
