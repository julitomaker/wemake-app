import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_models.freezed.dart';
part 'training_models.g.dart';

/// Exercise from library
@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    String? nameEs,
    required String musclePrimary,
    @Default([]) List<String> muscleSecondary,
    String? equipment,
    required String exerciseType, // strength, isometric, cardio
    @Default([]) List<String> videoUrls,
    @Default([]) List<String> cues,
    String? description,
    @Default(false) bool isCompound,
    DateTime? createdAt,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

/// Workout Routine (template)
@freezed
class WorkoutRoutine with _$WorkoutRoutine {
  const factory WorkoutRoutine({
    required String id,
    required String userId,
    required String name,
    String? routineType, // upper_lower, ppl, full_body, custom
    int? dayOfWeek, // 0-6
    int? estimatedMins,
    @Default([]) List<String> muscleGroups,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WorkoutRoutine;

  factory WorkoutRoutine.fromJson(Map<String, dynamic> json) =>
      _$WorkoutRoutineFromJson(json);
}

/// Routine Exercise (exercise in a routine template)
@freezed
class RoutineExercise with _$RoutineExercise {
  const factory RoutineExercise({
    required String id,
    required String routineId,
    required String exerciseId,
    required int orderIndex,
    required int targetSets,
    String? targetReps, // "8-12" or "10"
    double? targetWeightKg,
    @Default(90) int restSeconds,
    String? notes,
    DateTime? createdAt,

    // Joined exercise data
    Exercise? exercise,
  }) = _RoutineExercise;

  factory RoutineExercise.fromJson(Map<String, dynamic> json) =>
      _$RoutineExerciseFromJson(json);
}

/// Workout Session (actual workout)
@freezed
class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    required String id,
    required String userId,
    String? routineId,
    required DateTime startedAt,
    DateTime? completedAt,
    @Default('pending') String status, // pending, in_progress, completed, cancelled

    // Location
    double? locationLat,
    double? locationLng,
    @Default(false) bool gymDetected,

    // Stats
    double? totalTonnageKg,
    double? avgRpe,
    int? totalDurationMins,

    String? notes,
    DateTime? createdAt,

    // Joined data
    WorkoutRoutine? routine,
    @Default([]) List<ExerciseSet> sets,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
}

/// Exercise Set (individual set in a workout)
@freezed
class ExerciseSet with _$ExerciseSet {
  const factory ExerciseSet({
    required String id,
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    double? weightKg, // NULL for bodyweight/isometric
    int? repsCompleted, // NULL for isometric
    int? durationSecs, // For isometric/cardio
    int? rpe, // 1-10
    @Default(false) bool isWarmup,
    @Default(false) bool isDropset,
    @Default(false) bool techniqueFail,
    double? assistanceKg, // For assisted pullups
    int? restActualSecs,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,

    // Joined data
    Exercise? exercise,
  }) = _ExerciseSet;

  factory ExerciseSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetFromJson(json);
}

/// Muscle Fatigue tracking
@freezed
class MuscleFatigue with _$MuscleFatigue {
  const factory MuscleFatigue({
    required String id,
    required String userId,
    required String muscleGroup,
    required int fatigueScore, // 0-100
    int? recoveryEtaHours,
    DateTime? lastTrainedAt,
    DateTime? calculatedAt,
  }) = _MuscleFatigue;

  factory MuscleFatigue.fromJson(Map<String, dynamic> json) =>
      _$MuscleFatigueFromJson(json);
}

/// Today's workout info (for home screen display)
@freezed
class TodayWorkout with _$TodayWorkout {
  const factory TodayWorkout({
    required WorkoutRoutine routine,
    required String status, // pending, in_progress, completed, rest_day
    WorkoutSession? session,
    String? timeUntil, // "In 2 hours"
    String? contextMessage, // "You're 10min from the gym"
  }) = _TodayWorkout;

  factory TodayWorkout.fromJson(Map<String, dynamic> json) =>
      _$TodayWorkoutFromJson(json);
}

/// Smart weight suggestion
@freezed
class WeightSuggestion with _$WeightSuggestion {
  const factory WeightSuggestion({
    required double suggestedKg,
    double? lastUsedKg,
    required String reason, // "Progressive overload +1.25kg", "Same as last week"
  }) = _WeightSuggestion;

  factory WeightSuggestion.fromJson(Map<String, dynamic> json) =>
      _$WeightSuggestionFromJson(json);
}
