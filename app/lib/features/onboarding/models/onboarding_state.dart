import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';
part 'onboarding_state.g.dart';

/// Onboarding state that tracks progress through the 11-step process
@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentStep,
    @Default(11) int totalSteps,

    // Step 1: Nombre
    String? name,

    // Step 2: Datos basicos
    int? age,
    String? sex,
    double? weightKg,
    int? heightCm,

    // Step 3: Tipo de cuerpo
    String? bodyType,

    // Step 4: Lesiones
    @Default([]) List<OnboardingInjury> injuries,

    // Step 5: Equipo disponible
    String? equipmentAccess,

    // Step 6: Nivel de actividad
    String? activityLevel,

    // Step 7: Meta principal
    String? goalPrimary,
    String? goalUrgency,

    // Step 8: Perfil cognitivo (Neuro-Onboarding)
    int? focusScore, // 0-100
    String? attentionType, // starter_issue, maintainer_issue, both

    // Step 9: Preferencias de hidratacion
    @Default(3500) int waterTargetMl,
    @Default(700) int bottleSizeMl,

    // Step 10: Compromiso
    String? commitmentSignature,

    // Calculated values (set at the end)
    int? tdeeCalculated,
    int? proteinTarget,
    int? carbsTarget,
    int? fatTarget,
    int? kcalTarget,

    // UI state
    @Default(false) bool isSubmitting,
    String? error,
  }) = _OnboardingState;

  factory OnboardingState.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStateFromJson(json);
}

@freezed
class OnboardingInjury with _$OnboardingInjury {
  const factory OnboardingInjury({
    required String area,
    required String severity, // mild, moderate, severe
    String? notes,
  }) = _OnboardingInjury;

  factory OnboardingInjury.fromJson(Map<String, dynamic> json) =>
      _$OnboardingInjuryFromJson(json);
}

/// Questions for cognitive profile assessment
class CognitiveQuestion {
  final String id;
  final String question;
  final List<CognitiveAnswer> answers;

  const CognitiveQuestion({
    required this.id,
    required this.question,
    required this.answers,
  });
}

class CognitiveAnswer {
  final String text;
  final int starterScore; // Points towards starter_issue
  final int maintainerScore; // Points towards maintainer_issue

  const CognitiveAnswer({
    required this.text,
    required this.starterScore,
    required this.maintainerScore,
  });
}

/// Predefined cognitive assessment questions
const cognitiveQuestions = [
  CognitiveQuestion(
    id: 'q1',
    question: 'Cuando tienes una tarea importante, que te cuesta mas?',
    answers: [
      CognitiveAnswer(
        text: 'Empezar - siempre encuentro algo mas que hacer antes',
        starterScore: 3,
        maintainerScore: 0,
      ),
      CognitiveAnswer(
        text: 'Mantenerme enfocado una vez que empiezo',
        starterScore: 0,
        maintainerScore: 3,
      ),
      CognitiveAnswer(
        text: 'Ambas por igual',
        starterScore: 1,
        maintainerScore: 1,
      ),
    ],
  ),
  CognitiveQuestion(
    id: 'q2',
    question: 'Con que frecuencia revisas el celular mientras trabajas?',
    answers: [
      CognitiveAnswer(
        text: 'Casi nunca, pero me cuesta sentarme a trabajar',
        starterScore: 2,
        maintainerScore: 0,
      ),
      CognitiveAnswer(
        text: 'Constantemente, aunque no quiera',
        starterScore: 0,
        maintainerScore: 3,
      ),
      CognitiveAnswer(
        text: 'Depende del dia',
        starterScore: 1,
        maintainerScore: 1,
      ),
    ],
  ),
  CognitiveQuestion(
    id: 'q3',
    question: 'Como describes tu energia durante el dia?',
    answers: [
      CognitiveAnswer(
        text: 'Tengo energia pero me cuesta canalizarla',
        starterScore: 2,
        maintainerScore: 0,
      ),
      CognitiveAnswer(
        text: 'Empiezo bien pero me agoto rapido',
        starterScore: 0,
        maintainerScore: 2,
      ),
      CognitiveAnswer(
        text: 'Irregular, a veces mucha, a veces poca',
        starterScore: 1,
        maintainerScore: 1,
      ),
    ],
  ),
  CognitiveQuestion(
    id: 'q4',
    question: 'Cuando tienes un proyecto largo...',
    answers: [
      CognitiveAnswer(
        text: 'Lo pospongo hasta el ultimo momento',
        starterScore: 3,
        maintainerScore: 0,
      ),
      CognitiveAnswer(
        text: 'Empiezo con entusiasmo pero lo abandono a medio camino',
        starterScore: 0,
        maintainerScore: 3,
      ),
      CognitiveAnswer(
        text: 'Un poco de ambos',
        starterScore: 1,
        maintainerScore: 1,
      ),
    ],
  ),
  CognitiveQuestion(
    id: 'q5',
    question: 'En el gimnasio o haciendo ejercicio...',
    answers: [
      CognitiveAnswer(
        text: 'Lo mas dificil es ir, una vez alli me concentro',
        starterScore: 3,
        maintainerScore: 0,
      ),
      CognitiveAnswer(
        text: 'Voy sin problema pero me distraigo entre series',
        starterScore: 0,
        maintainerScore: 3,
      ),
      CognitiveAnswer(
        text: 'Ambas cosas me cuestan',
        starterScore: 2,
        maintainerScore: 2,
      ),
    ],
  ),
];

/// Body areas for injury selection
const injuryAreas = [
  'Hombro',
  'Codo',
  'Muneca',
  'Espalda baja',
  'Espalda alta',
  'Cadera',
  'Rodilla',
  'Tobillo',
  'Cuello',
  'Otro',
];

/// Severity levels
const injurySeverities = [
  ('mild', 'Leve - Molestia menor'),
  ('moderate', 'Moderada - Limita algunos ejercicios'),
  ('severe', 'Severa - Requiere cuidado especial'),
];
