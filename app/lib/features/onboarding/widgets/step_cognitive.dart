import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/onboarding_state.dart';
import '../providers/onboarding_provider.dart';

class StepCognitive extends ConsumerStatefulWidget {
  const StepCognitive({super.key});

  @override
  ConsumerState<StepCognitive> createState() => _StepCognitiveState();
}

class _StepCognitiveState extends ConsumerState<StepCognitive> {
  int _currentQuestion = 0;
  final Map<String, int> _starterScores = {};
  final Map<String, int> _maintainerScores = {};
  bool _showBrain = false;

  void _selectAnswer(CognitiveAnswer answer) {
    final question = cognitiveQuestions[_currentQuestion];

    _starterScores[question.id] = answer.starterScore;
    _maintainerScores[question.id] = answer.maintainerScore;
    HapticFeedback.selectionClick();

    setState(() {
      _showBrain = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showBrain = false;
        });
      }
    });

    if (_currentQuestion < cognitiveQuestions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      // Calculate results
      _calculateResults();
    }
  }

  void _calculateResults() {
    final totalStarter = _starterScores.values.fold(0, (a, b) => a + b);
    final totalMaintainer = _maintainerScores.values.fold(0, (a, b) => a + b);
    final maxPossible = cognitiveQuestions.length * 3;

    // Focus score: 100 = perfect focus, 0 = severe issues
    // Higher scores in either category = lower focus
    final totalIssues = totalStarter + totalMaintainer;
    final focusScore = ((1 - (totalIssues / (maxPossible * 2))) * 100).round();

    // Determine attention type
    String attentionType;
    if (totalStarter > totalMaintainer + 2) {
      attentionType = 'starter_issue';
    } else if (totalMaintainer > totalStarter + 2) {
      attentionType = 'maintainer_issue';
    } else {
      attentionType = 'both';
    }

    ref.read(onboardingProvider.notifier).setCognitiveProfile(
          focusScore: focusScore,
          attentionType: attentionType,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);

    // If already completed, show results
    if (state.focusScore != null) {
      return _buildResults(theme, state);
    }

    final question = cognitiveQuestions[_currentQuestion];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Neuro-Onboarding',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AnimatedScale(
                scale: _showBrain ? 1.2 : 0.8,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: _showBrain ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Text('🧠', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_currentQuestion + 1}/${cognitiveQuestions.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentQuestion + 1) / cognitiveQuestions.length,
              minHeight: 4,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Question
          Text(
            question.question,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 32),

          // Answers
          ...question.answers.map((answer) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AnswerCard(
                  text: answer.text,
                  onTap: () => _selectAnswer(answer),
                ),
              )),

          const SizedBox(height: 24),

          // Info
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
                  Icons.info_outline,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Estas preguntas nos ayudan a personalizar recordatorios y la estructura de la app para tu estilo cognitivo.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildResults(ThemeData theme, dynamic state) {
    String profileTitle;
    String profileDescription;
    IconData profileIcon;
    Color profileColor;

    switch (state.attentionType) {
      case 'starter_issue':
        profileTitle = 'El Procrastinador';
        profileDescription =
            'Tu reto principal es comenzar las tareas. Una vez que arrancas, mantienes el enfoque bien.';
        profileIcon = Icons.play_circle_outline;
        profileColor = Colors.orange;
        break;
      case 'maintainer_issue':
        profileTitle = 'El Saltarin';
        profileDescription =
            'Empiezas sin problema pero te cuesta mantener el foco. Las distracciones te atrapan facilmente.';
        profileIcon = Icons.swap_horiz;
        profileColor = Colors.purple;
        break;
      default:
        profileTitle = 'El Equilibrista';
        profileDescription =
            'Tienes retos tanto para comenzar como para mantener el enfoque. Trabajaremos en ambos.';
        profileIcon = Icons.balance;
        profileColor = Colors.blue;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),

          // Result icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: profileColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              profileIcon,
              size: 40,
              color: profileColor,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            profileTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: profileColor,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            profileDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Focus score
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Puntaje de enfoque',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.focusScore}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.focusScore / 100,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // How we'll help
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Como te ayudaremos:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                _HelpItem(
                  icon: Icons.notifications_active,
                  text: 'Recordatorios adaptativos segun tu perfil',
                ),
                _HelpItem(
                  icon: Icons.timer,
                  text: 'Sesiones de trabajo estructuradas',
                ),
                _HelpItem(
                  icon: Icons.psychology,
                  text: 'El "Supervisor" te ayudara a mantenerte en track',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _AnswerCard({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpItem({
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
