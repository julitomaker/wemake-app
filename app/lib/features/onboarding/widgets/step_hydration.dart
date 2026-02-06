import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_provider.dart';

class StepHydration extends ConsumerStatefulWidget {
  const StepHydration({super.key});

  @override
  ConsumerState<StepHydration> createState() => _StepHydrationState();
}

class _StepHydrationState extends ConsumerState<StepHydration> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);

    // Calculate bottles
    final bottleCount = (state.waterTargetMl / state.bottleSizeMl).ceil();

    // Bottle size options
    final bottleSizes = [
      (500, '500ml', 'Botella pequena'),
      (700, '700ml', 'Botella mediana'),
      (1000, '1L', 'Botella grande'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          Text(
            'Configuremos tu hidratacion',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'En WEMAKE medimos el agua en botellas, no en litros.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 32),

          // Visual bottle representation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Bottles row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    bottleCount > 7 ? 7 : bottleCount,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.local_drink,
                        size: 32,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                if (bottleCount > 7)
                  Text(
                    '...',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  '$bottleCount botellas/dia',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(state.waterTargetMl / 1000).toStringAsFixed(1)}L total',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Water target slider
          Text(
            'Meta diaria de agua',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '2L',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              Expanded(
                child: Slider(
                  value: state.waterTargetMl.toDouble(),
                  min: 2000,
                  max: 5000,
                  divisions: 12,
                  label: '${(state.waterTargetMl / 1000).toStringAsFixed(1)}L',
                  onChanged: (value) {
                    ref.read(onboardingProvider.notifier).setHydrationPreferences(
                          waterTargetMl: value.round(),
                        );
                  },
                ),
              ),
              Text(
                '5L',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bottle size selection
          Text(
            'Tamano de tu botella',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: bottleSizes.map((size) {
              final isSelected = state.bottleSizeMl == size.$1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: size.$1 != 1000 ? 8 : 0,
                  ),
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(onboardingProvider.notifier)
                          .setHydrationPreferences(bottleSizeMl: size.$1);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withOpacity(0.15)
                            : theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue
                              : theme.colorScheme.outline.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_drink,
                            size: size.$1 == 500
                                ? 24
                                : size.$1 == 700
                                    ? 28
                                    : 32,
                            color: isSelected
                                ? Colors.blue
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            size.$2,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.blue
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Es mas facil recordar "toma 5 botellas hoy" que "toma 3.5 litros". La app te recordara cuando tomar tu siguiente botella.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
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
