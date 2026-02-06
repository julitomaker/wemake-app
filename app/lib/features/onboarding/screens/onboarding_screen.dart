import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/onboarding_provider.dart';
import '../widgets/step_name.dart';
import '../widgets/step_basic_data.dart';
import '../widgets/step_body_type.dart';
import '../widgets/step_injuries.dart';
import '../widgets/step_equipment.dart';
import '../widgets/step_activity_level.dart';
import '../widgets/step_goals.dart';
import '../widgets/step_cognitive.dart';
import '../widgets/step_hydration.dart';
import '../widgets/step_commitment.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    final state = ref.read(onboardingProvider);
    if (state.currentStep < state.totalSteps - 1) {
      ref.read(onboardingProvider.notifier).nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onBack() {
    final state = ref.read(onboardingProvider);
    if (state.currentStep > 0) {
      ref.read(onboardingProvider.notifier).previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _onComplete() async {
    final success =
        await ref.read(onboardingProvider.notifier).submitOnboarding();
    if (success && mounted) {
      context.go('/home');
    }
  }

  bool _canProceed(int step) {
    final state = ref.read(onboardingProvider);
    switch (step) {
      case 0:
        return state.name != null && state.name!.isNotEmpty;
      case 1:
        return state.age != null &&
            state.sex != null &&
            state.weightKg != null &&
            state.heightCm != null;
      case 2:
        return state.bodyType != null;
      case 3:
        return true; // Injuries are optional
      case 4:
        return state.equipmentAccess != null;
      case 5:
        return state.activityLevel != null;
      case 6:
        return state.goalPrimary != null && state.goalUrgency != null;
      case 7:
        return state.focusScore != null && state.attentionType != null;
      case 8:
        return true; // Hydration has defaults
      case 9:
        return state.commitmentSignature != null &&
            state.commitmentSignature!.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            _buildHeader(theme, state),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  StepName(),
                  StepBasicData(),
                  StepBodyType(),
                  StepInjuries(),
                  StepEquipment(),
                  StepActivityLevel(),
                  StepGoals(),
                  StepCognitive(),
                  StepHydration(),
                  StepCommitment(),
                ],
              ),
            ),

            // Navigation buttons
            _buildNavigation(theme, state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, dynamic state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Back button and step indicator
          Row(
            children: [
              if (state.currentStep > 0)
                IconButton(
                  onPressed: _onBack,
                  icon: const Icon(Icons.arrow_back),
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Text(
                  'Paso ${state.currentStep + 1} de ${state.totalSteps}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (state.currentStep + 1) / state.totalSteps,
              minHeight: 4,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(ThemeData theme, dynamic state) {
    final isLastStep = state.currentStep == state.totalSteps - 1;
    final canProceed = _canProceed(state.currentStep);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Error message
          if (state.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Main button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : (canProceed
                      ? (isLastStep ? _onComplete : _onNext)
                      : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor:
                    theme.colorScheme.outline.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isSubmitting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      isLastStep ? 'Comenzar mi transformacion' : 'Continuar',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
