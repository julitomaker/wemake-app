import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/pressable_scale.dart';

class OnboardingWelcomeStep extends StatelessWidget {
  final VoidCallback onStart;

  const OnboardingWelcomeStep({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'Bienvenido a PowerNax',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tu sistema operativo para cuerpo, mente y disciplina. Vamos a personalizarlo en segundos.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _GlowChip(label: 'Fitness', color: const Color(0xFFB8FF00)),
              const SizedBox(width: 8),
              _GlowChip(label: 'Nutricion', color: const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _GlowChip(label: 'Habitos', color: const Color(0xFFF97316)),
            ],
          ),
          const Spacer(),
          Animate(
            onPlay: (controller) => controller.repeat(reverse: true),
            effects: const [
              ScaleEffect(
                begin: Offset(1, 1),
                end: Offset(1.04, 1.04),
                duration: Duration(milliseconds: 1400),
                curve: Curves.easeInOut,
              ),
            ],
            child: PressableScale(
              onTap: onStart,
              child: Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGlow,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Empezar',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _GlowChip extends StatelessWidget {
  final String label;
  final Color color;

  const _GlowChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
