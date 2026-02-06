/// App-wide constants for WEMAKE
class AppConstants {
  AppConstants._();

  // ===================
  // SUPABASE CONFIG
  // ===================
  // TODO: Replace with your actual Supabase credentials
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // ===================
  // APP INFO
  // ===================
  static const String appName = 'WEMAKE';
  static const String tagline = 'Make Today Count.';
  static const String taglineSecondary = 'For makers.';

  // ===================
  // ONBOARDING
  // ===================
  static const int onboardingTotalSteps = 10;
  static const int minFocusScore = 0;
  static const int maxFocusScore = 100;

  // ===================
  // NUTRITION DEFAULTS
  // ===================
  static const double defaultWaterTargetLiters = 3.5;
  static const int defaultBottleSizeMl = 700;
  static const double proteinPerKgMuscleGain = 2.0;
  static const double proteinPerKgMaintenance = 1.6;
  static const double proteinPerKgFatLoss = 2.2;

  // ===================
  // TRAINING
  // ===================
  static const int defaultRestSeconds = 90;
  static const int prepTimerSeconds = 10;
  static const double progressiveOverloadKg = 1.25;
  static const int minRpe = 1;
  static const int maxRpe = 10;

  // ===================
  // GAMIFICATION
  // ===================
  static const int xpPerHabitComplete = 10;
  static const int xpPerWorkoutComplete = 50;
  static const int xpPerMealLogged = 5;
  static const int xpPerPerfectDay = 100;

  static const int coinsPerHabit = 5;
  static const int coinsPerWorkout = 20;
  static const int coinsMinChest = 5;
  static const int coinsMaxChest = 15;

  static const double streakLightThreshold = 0.6; // 60%
  static const double streakPerfectThreshold = 0.9; // 90%
  static const int streakFreezeBaseCost = 50;

  // ===================
  // PRODUCTIVITY
  // ===================
  static const int defaultPomodoroMinutes = 25;
  static const int supervisorIdleMinutes = 15;

  // ===================
  // CORRELATION ENGINE
  // ===================
  static const int minSampleSizeDays = 14;
  static const double significanceThreshold = 0.05;
  static const double correlationThreshold = 0.3;

  // ===================
  // TIMING
  // ===================
  static const int mealFeedbackDelayMinutes = 60;
  static const int notificationCooldownMinutes = 30;

  // ===================
  // LIMITS
  // ===================
  static const int maxHabitsPerUser = 20;
  static const int maxGroupMembers = 10;
  static const int maxFriendsCount = 50;
}

/// Enum for goal types
enum GoalType {
  muscle('muscle', 'Ganar Musculo'),
  fatLoss('fat_loss', 'Perder Grasa'),
  maintenance('maintenance', 'Mantenimiento'),
  energy('energy', 'Mas Energia');

  const GoalType(this.value, this.label);
  final String value;
  final String label;
}

/// Enum for goal urgency
enum GoalUrgency {
  high('high', 'Alta - Lo necesito ya'),
  medium('medium', 'Media - En los proximos meses'),
  low('low', 'Baja - Sin prisa');

  const GoalUrgency(this.value, this.label);
  final String value;
  final String label;
}

/// Enum for attention types (from cognitive onboarding)
enum AttentionType {
  starterIssue('starter_issue', 'Me cuesta arrancar'),
  maintainerIssue('maintainer_issue', 'Me cuesta mantener'),
  both('both', 'Ambos problemas');

  const AttentionType(this.value, this.label);
  final String value;
  final String label;
}

/// Enum for body types
enum BodyType {
  ectomorph('ectomorph', 'Delgado, cuesta ganar peso'),
  mesomorph('mesomorph', 'Atletico, gana musculo facil'),
  endomorph('endomorph', 'Robusto, gana peso facil');

  const BodyType(this.value, this.label);
  final String value;
  final String label;
}

/// Enum for equipment access
enum EquipmentAccess {
  gym('gym', 'Gimnasio comercial'),
  home('home', 'Equipo en casa'),
  minimal('minimal', 'Minimo/Peso corporal');

  const EquipmentAccess(this.value, this.label);
  final String value;
  final String label;
}

/// Enum for activity levels
enum ActivityLevel {
  sedentary('sedentary', 'Sedentario', 1.2),
  light('light', 'Ligeramente activo', 1.375),
  moderate('moderate', 'Moderadamente activo', 1.55),
  active('active', 'Muy activo', 1.725),
  veryActive('very_active', 'Extremadamente activo', 1.9);

  const ActivityLevel(this.value, this.label, this.multiplier);
  final String value;
  final String label;
  final double multiplier;
}

/// Enum for habit types
enum HabitType {
  checkSimple('check_simple', 'Check Simple'),
  quantitative('quantitative', 'Cuantitativo'),
  evidence('evidence', 'Con Evidencia'),
  integrated('integrated', 'Integrado (API)');

  const HabitType(this.value, this.label);
  final String value;
  final String label;
}

/// Enum for habit status
enum HabitLogStatus {
  pending('pending'),
  done('done'),
  skipped('skipped');

  const HabitLogStatus(this.value);
  final String value;
}

/// Enum for streak types
enum StreakType {
  light('streak_light'),
  perfect('streak_perfect');

  const StreakType(this.value);
  final String value;
}

/// Enum for meal types
enum MealType {
  breakfast('breakfast', 'Desayuno'),
  morningSnack('morning_snack', 'Snack AM'),
  lunch('lunch', 'Almuerzo'),
  afternoonSnack('afternoon_snack', 'Snack PM'),
  dinner('dinner', 'Cena'),
  lateSnack('late_snack', 'Snack Nocturno');

  const MealType(this.value, this.label);
  final String value;
  final String label;
}

/// Enum for workout session status
enum WorkoutStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  const WorkoutStatus(this.value);
  final String value;
}

/// Enum for exercise types
enum ExerciseType {
  strength('strength', 'Fuerza'),
  isometric('isometric', 'Isometrico'),
  cardio('cardio', 'Cardio');

  const ExerciseType(this.value, this.label);
  final String value;
  final String label;
}
