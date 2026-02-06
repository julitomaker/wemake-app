import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_provider.dart';

class StepActivityLevel extends ConsumerWidget {
  const StepActivityLevel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);

    final activityLevels = [
      (
        'sedentary',
        'Sedentario',
        'Trabajo de escritorio, poco o nada de ejercicio',
        '1.2x',
      ),
      (
        'light',
        'Ligeramente activo',
        'Ejercicio ligero 1-3 dias/semana',
        '1.375x',
      ),
      (
        'moderate',
        'Moderadamente activo',
        'Ejercicio moderado 3-5 dias/semana',
        '1.55x',
      ),
      (
        'active',
        'Muy activo',
        'Ejercicio intenso 6-7 dias/semana',
        '1.725x',
      ),
      (
        'very_active',
        'Extra activo',
        'Ejercicio muy intenso + trabajo fisico',
        '1.9x',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          Text(
            'Cual es tu nivel de actividad?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Considera tu actividad diaria promedio, no solo el ejercicio.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 32),

          // Activity levels
          ...activityLevels.map((level) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActivityLevelCard(
                  value: level.$1,
                  title: level.$2,
                  description: level.$3,
                  multiplier: level.$4,
                  isSelected: state.activityLevel == level.$1,
                  onTap: () {
                    ref
                        .read(onboardingProvider.notifier)
                        .setActivityLevel(level.$1);
                  },
                ),
              )),

          const SizedBox(height: 16),

          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.calculate_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Esto afecta tu TDEE (gasto calorico diario) y por lo tanto tus metas de nutricion.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityLevelCard extends StatelessWidget {
  final String value;
  final String title;
  final String description;
  final String multiplier;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityLevelCard({
    required this.value,
    required this.title,
    required this.description,
    required this.multiplier,
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
        padding: const EdgeInsets.all(16),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                multiplier,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
