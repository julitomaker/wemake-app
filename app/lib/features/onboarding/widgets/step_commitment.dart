import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_provider.dart';

class StepCommitment extends ConsumerStatefulWidget {
  const StepCommitment({super.key});

  @override
  ConsumerState<StepCommitment> createState() => _StepCommitmentState();
}

class _StepCommitmentState extends ConsumerState<StepCommitment> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _controller = TextEditingController(text: state.commitmentSignature ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

          // Commitment header
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_note,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Tu compromiso',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 32),

          // Contract
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yo, ${state.name ?? "___________"},',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Me comprometo a construir la vida que quiero, no la que me toca.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Entiendo que los resultados requieren consistencia, no perfeccion.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Voy a presentarme cada dia, aunque no tenga ganas.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Se que un 60% de cumplimiento es mejor que 0%.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Make Today Count.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Signature field
          Text(
            'Firma tu compromiso',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe tu nombre completo para confirmar',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _controller,
            onChanged: (value) {
              ref
                  .read(onboardingProvider.notifier)
                  .setCommitmentSignature(value);
            },
            style: TextStyle(
              fontFamily: 'Caveat',
              fontSize: 24,
              fontStyle: FontStyle.italic,
            ),
            decoration: InputDecoration(
              hintText: 'Tu nombre aqui...',
              hintStyle: TextStyle(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),

          const SizedBox(height: 24),

          // Summary of what they get
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu plan personalizado incluye:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _SummaryItem(
                  icon: Icons.restaurant_menu,
                  text:
                      'Meta: ${state.kcalTarget ?? "---"} kcal, ${state.proteinTarget ?? "--"}g proteina',
                ),
                _SummaryItem(
                  icon: Icons.fitness_center,
                  text: 'Rutinas adaptadas a tu equipo y lesiones',
                ),
                _SummaryItem(
                  icon: Icons.local_drink,
                  text:
                      '${(state.waterTargetMl / state.bottleSizeMl).ceil()} botellas de agua/dia',
                ),
                _SummaryItem(
                  icon: Icons.psychology,
                  text: 'Recordatorios segun tu perfil cognitivo',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
