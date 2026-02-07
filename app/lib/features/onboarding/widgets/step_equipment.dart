import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_provider.dart';

class StepEquipment extends ConsumerWidget {
  const StepEquipment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);

    final equipmentOptions = [
      (
        'full_gym',
        'Gimnasio completo',
        'Acceso a maquinas, pesas libres, cables',
        Icons.fitness_center,
      ),
      (
        'home_basic',
        'Casa - Basico',
        'Mancuernas, bandas elasticas',
        Icons.home,
      ),
      (
        'home_full',
        'Casa - Equipado',
        'Rack, barra, banco, mancuernas',
        Icons.house,
      ),
      (
        'bodyweight',
        'Solo peso corporal',
        'Sin equipo, ejercicios calistenicos',
        Icons.self_improvement,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          Text(
            'Que equipo tienes disponible?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crearemos rutinas adaptadas a tu equipamiento.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 32),

          // Equipment options
          ...equipmentOptions.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EquipmentCard(
                  value: option.$1,
                  title: option.$2,
                  description: option.$3,
                  icon: option.$4,
                  isSelected: state.equipmentAccess == option.$1,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(onboardingProvider.notifier)
                        .setEquipmentAccess(option.$1);
                  },
                ),
              )),
        ],
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final String value;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _EquipmentCard({
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 16),
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
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
