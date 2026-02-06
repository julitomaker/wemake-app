import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/onboarding_state.dart';
import '../providers/onboarding_provider.dart';

class StepInjuries extends ConsumerStatefulWidget {
  const StepInjuries({super.key});

  @override
  ConsumerState<StepInjuries> createState() => _StepInjuriesState();
}

class _StepInjuriesState extends ConsumerState<StepInjuries> {
  void _showAddInjuryDialog() {
    String? selectedArea;
    String? selectedSeverity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agregar lesion',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Area selection
                  Text(
                    'Area afectada',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: injuryAreas
                        .map((area) => ChoiceChip(
                              label: Text(area),
                              selected: selectedArea == area,
                              onSelected: (selected) {
                                setModalState(() {
                                  selectedArea = selected ? area : null;
                                });
                              },
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Severity selection
                  Text(
                    'Severidad',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...injurySeverities.map((severity) => RadioListTile<String>(
                        value: severity.$1,
                        groupValue: selectedSeverity,
                        onChanged: (value) {
                          setModalState(() {
                            selectedSeverity = value;
                          });
                        },
                        title: Text(severity.$2),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      )),

                  const SizedBox(height: 24),

                  // Add button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedArea != null && selectedSeverity != null
                          ? () {
                              ref.read(onboardingProvider.notifier).addInjury(
                                    OnboardingInjury(
                                      area: selectedArea!,
                                      severity: selectedSeverity!,
                                    ),
                                  );
                              Navigator.pop(context);
                            }
                          : null,
                      child: const Text('Agregar'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          Text(
            'Tienes alguna lesion?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adaptaremos los ejercicios para protegerte.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 32),

          // Current injuries list
          if (state.injuries.isNotEmpty) ...[
            ...state.injuries.asMap().entries.map((entry) {
              final index = entry.key;
              final injury = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _InjuryChip(
                  injury: injury,
                  onRemove: () {
                    ref.read(onboardingProvider.notifier).removeInjury(index);
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Add injury button
          OutlinedButton.icon(
            onPressed: _showAddInjuryDialog,
            icon: const Icon(Icons.add),
            label: const Text('Agregar lesion'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // No injuries option
          if (state.injuries.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Si no tienes lesiones, simplemente continua al siguiente paso.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.green.shade700,
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

class _InjuryChip extends StatelessWidget {
  final OnboardingInjury injury;
  final VoidCallback onRemove;

  const _InjuryChip({
    required this.injury,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color severityColor;
    switch (injury.severity) {
      case 'mild':
        severityColor = Colors.yellow.shade700;
        break;
      case 'moderate':
        severityColor = Colors.orange;
        break;
      case 'severe':
        severityColor = Colors.red;
        break;
      default:
        severityColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: severityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              injury.area,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 20),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
