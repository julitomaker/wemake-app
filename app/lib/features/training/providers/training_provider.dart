import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/training_models.dart';
import '../../../core/services/demo_mode.dart';
import '../../../core/data/julio_profile_data.dart';

part 'training_provider.freezed.dart';

/// Training state
@freezed
class TrainingState with _$TrainingState {
  const factory TrainingState({
    @Default([]) List<WorkoutRoutine> routines,
    @Default([]) List<Exercise> exercises,
    @Default([]) List<MuscleFatigue> muscleFatigue,
    @Default([]) List<WorkoutSession> recentSessions,
    WorkoutSession? activeSession,
    @Default(false) bool isLoading,
    String? error,
  }) = _TrainingState;
}

/// Training notifier
class TrainingNotifier extends StateNotifier<TrainingState> {
  TrainingNotifier() : super(const TrainingState());

  /// Load initial training data
  Future<void> loadTrainingData() async {
    state = state.copyWith(isLoading: true, error: null);

    // --- Demo Mode: usar datos reales de Julio ---
    if (demoMode.isActive) {
      await Future.delayed(const Duration(milliseconds: 400));

      final demoExercises = _getMockExercises();

      // Rutinas Upper/Lower Power de Julio
      final demoRoutines = [
        const WorkoutRoutine(
          id: 'upper_a',
          userId: 'julio',
          name: 'Upper A - Fuerza',
          routineType: 'upper_lower',
          dayOfWeek: 1, // Lunes
          estimatedMins: 70,
          muscleGroups: ['chest', 'back', 'shoulders', 'biceps', 'triceps'],
          isActive: true,
        ),
        const WorkoutRoutine(
          id: 'lower_a',
          userId: 'julio',
          name: 'Lower A - Fuerza',
          routineType: 'upper_lower',
          dayOfWeek: 2, // Martes
          estimatedMins: 65,
          muscleGroups: ['quads', 'hamstrings', 'glutes', 'calves', 'core'],
          isActive: true,
        ),
        const WorkoutRoutine(
          id: 'upper_b',
          userId: 'julio',
          name: 'Upper B - Hipertrofia',
          routineType: 'upper_lower',
          dayOfWeek: 4, // Jueves
          estimatedMins: 75,
          muscleGroups: ['chest', 'back', 'shoulders', 'biceps', 'triceps'],
          isActive: true,
        ),
        const WorkoutRoutine(
          id: 'lower_b',
          userId: 'julio',
          name: 'Lower B - Hipertrofia',
          routineType: 'upper_lower',
          dayOfWeek: 5, // Viernes
          estimatedMins: 70,
          muscleGroups: ['quads', 'hamstrings', 'glutes', 'calves', 'core'],
          isActive: true,
        ),
      ];

      // Fatiga muscular basada en ultimos entrenos de Julio
      final demoFatigue = [
        MuscleFatigue(
          id: 'mf_chest',
          userId: 'julio',
          muscleGroup: 'chest',
          fatigueScore: 35,
          recoveryEtaHours: 12,
          lastTrainedAt: DateTime.now().subtract(const Duration(days: 1)), // Jueves Upper B
          calculatedAt: DateTime.now(),
        ),
        MuscleFatigue(
          id: 'mf_back',
          userId: 'julio',
          muscleGroup: 'back',
          fatigueScore: 40,
          recoveryEtaHours: 16,
          lastTrainedAt: DateTime.now().subtract(const Duration(days: 1)),
          calculatedAt: DateTime.now(),
        ),
        MuscleFatigue(
          id: 'mf_shoulders',
          userId: 'julio',
          muscleGroup: 'shoulders',
          fatigueScore: 45,
          recoveryEtaHours: 18,
          lastTrainedAt: DateTime.now().subtract(const Duration(days: 1)),
          calculatedAt: DateTime.now(),
        ),
        MuscleFatigue(
          id: 'mf_legs',
          userId: 'julio',
          muscleGroup: 'legs',
          fatigueScore: 20,
          recoveryEtaHours: 0,
          lastTrainedAt: DateTime.now().subtract(const Duration(days: 3)), // Martes Lower A
          calculatedAt: DateTime.now(),
        ),
      ];

      // Sesiones recientes de Julio (sus entrenos reales)
      final demoRecentSessions = [
        WorkoutSession(
          id: 'session_upper_b',
          userId: 'julio',
          routineId: 'upper_b',
          startedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          completedAt: DateTime.now().subtract(const Duration(days: 1, hours: 0, minutes: 20)),
          status: 'completed',
          totalTonnageKg: 7250,
          avgRpe: 8.0,
          totalDurationMins: 100,
          notes: 'Upper B completado. Press inclinado falle en ultima serie.',
          routine: demoRoutines[2],
          sets: [],
        ),
        WorkoutSession(
          id: 'session_lower_a',
          userId: 'julio',
          routineId: 'lower_a',
          startedAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
          completedAt: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
          status: 'completed',
          totalTonnageKg: 9800,
          avgRpe: 8.0,
          totalDurationMins: 60,
          notes: 'Lower A completado. Prensa 100kg x12 bien.',
          routine: demoRoutines[1],
          sets: [],
        ),
        WorkoutSession(
          id: 'session_upper_a',
          userId: 'julio',
          routineId: 'upper_a',
          startedAt: DateTime.now().subtract(const Duration(days: 4, hours: 2)),
          completedAt: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
          status: 'completed',
          totalTonnageKg: 6500,
          avgRpe: 8.0,
          totalDurationMins: 55,
          notes: 'Upper A completado. Press banca 65kg x5 solido.',
          routine: demoRoutines[0],
          sets: [],
        ),
      ];

      state = state.copyWith(
        exercises: demoExercises,
        routines: demoRoutines,
        muscleFatigue: demoFatigue,
        recentSessions: demoRecentSessions,
        isLoading: false,
      );
      return;
    }
    // --- Fin Demo Mode ---

    try {
      // Simulated data - in production this would come from Supabase
      await Future.delayed(const Duration(milliseconds: 500));

      final exercises = _getMockExercises();
      final routines = _getMockRoutines();
      final fatigue = _getMockMuscleFatigue();

      state = state.copyWith(
        exercises: exercises,
        routines: routines,
        muscleFatigue: fatigue,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Start a new workout session
  Future<WorkoutSession?> startWorkout(String routineId) async {
    try {
      final routine = state.routines.firstWhere((r) => r.id == routineId);

      final session = WorkoutSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // In production, get from auth
        routineId: routineId,
        startedAt: DateTime.now(),
        status: 'in_progress',
        routine: routine,
        sets: [],
      );

      state = state.copyWith(activeSession: session);
      return session;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Log a set in the active workout
  Future<bool> logSet({
    required String exerciseId,
    required int setNumber,
    double? weightKg,
    int? reps,
    int? durationSecs,
    int? rpe,
    bool isWarmup = false,
  }) async {
    if (state.activeSession == null) return false;

    try {
      final newSet = ExerciseSet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: state.activeSession!.id,
        exerciseId: exerciseId,
        setNumber: setNumber,
        weightKg: weightKg,
        repsCompleted: reps,
        durationSecs: durationSecs,
        rpe: rpe,
        isWarmup: isWarmup,
        completedAt: DateTime.now(),
      );

      final updatedSets = [...state.activeSession!.sets, newSet];

      state = state.copyWith(
        activeSession: state.activeSession!.copyWith(sets: updatedSets),
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Complete the active workout
  Future<WorkoutSession?> completeWorkout({String? notes}) async {
    if (state.activeSession == null) return null;

    try {
      // Calculate stats
      final sets = state.activeSession!.sets.where((s) => !s.isWarmup).toList();
      double totalTonnage = 0;
      double totalRpe = 0;
      int rpeCount = 0;

      for (final set in sets) {
        if (set.weightKg != null && set.repsCompleted != null) {
          totalTonnage += set.weightKg! * set.repsCompleted!;
        }
        if (set.rpe != null) {
          totalRpe += set.rpe!;
          rpeCount++;
        }
      }

      final completedSession = state.activeSession!.copyWith(
        completedAt: DateTime.now(),
        status: 'completed',
        totalTonnageKg: totalTonnage,
        avgRpe: rpeCount > 0 ? totalRpe / rpeCount : null,
        totalDurationMins: DateTime.now()
            .difference(state.activeSession!.startedAt)
            .inMinutes,
        notes: notes,
      );

      state = state.copyWith(
        activeSession: null,
        recentSessions: [completedSession, ...state.recentSessions],
      );

      // TODO: Save to Supabase
      // TODO: Award XP and Coins

      return completedSession;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Cancel the active workout
  void cancelWorkout() {
    state = state.copyWith(activeSession: null);
  }

  /// Get weight suggestion for an exercise
  WeightSuggestion getWeightSuggestion(String exerciseId) {
    // Find last session with this exercise
    for (final session in state.recentSessions) {
      final lastSet = session.sets
          .where((s) => s.exerciseId == exerciseId && !s.isWarmup)
          .lastOrNull;

      if (lastSet != null && lastSet.weightKg != null) {
        // If completed all reps with RPE < 8, suggest progression
        if (lastSet.rpe != null && lastSet.rpe! < 8) {
          return WeightSuggestion(
            suggestedKg: lastSet.weightKg! + 2.5,
            lastUsedKg: lastSet.weightKg,
            reason: 'Progressive overload +2.5kg',
          );
        }

        return WeightSuggestion(
          suggestedKg: lastSet.weightKg!,
          lastUsedKg: lastSet.weightKg,
          reason: 'Same as last session',
        );
      }
    }

    // No previous data
    return const WeightSuggestion(
      suggestedKg: 0,
      lastUsedKg: null,
      reason: 'First time - start light',
    );
  }

  /// Get exercise by ID
  Exercise? getExercise(String exerciseId) {
    return state.exercises.where((e) => e.id == exerciseId).firstOrNull;
  }

  /// Get routine by ID
  WorkoutRoutine? getRoutine(String routineId) {
    return state.routines.where((r) => r.id == routineId).firstOrNull;
  }

  // Mock data generators
  List<Exercise> _getMockExercises() {
    return [
      const Exercise(
        id: 'ex_1',
        name: 'Bench Press',
        nameEs: 'Press de Banca',
        musclePrimary: 'chest',
        muscleSecondary: ['triceps', 'shoulders'],
        equipment: 'barbell',
        exerciseType: 'strength',
        isCompound: true,
        cues: ['Keep shoulder blades retracted', 'Touch chest', 'Drive feet into floor'],
      ),
      const Exercise(
        id: 'ex_2',
        name: 'Squat',
        nameEs: 'Sentadilla',
        musclePrimary: 'quads',
        muscleSecondary: ['glutes', 'hamstrings', 'core'],
        equipment: 'barbell',
        exerciseType: 'strength',
        isCompound: true,
        cues: ['Brace core', 'Knees track over toes', 'Break parallel'],
      ),
      const Exercise(
        id: 'ex_3',
        name: 'Deadlift',
        nameEs: 'Peso Muerto',
        musclePrimary: 'back',
        muscleSecondary: ['hamstrings', 'glutes', 'core', 'forearms'],
        equipment: 'barbell',
        exerciseType: 'strength',
        isCompound: true,
        cues: ['Neutral spine', 'Push through floor', 'Lock out hips'],
      ),
      const Exercise(
        id: 'ex_4',
        name: 'Overhead Press',
        nameEs: 'Press Militar',
        musclePrimary: 'shoulders',
        muscleSecondary: ['triceps', 'core'],
        equipment: 'barbell',
        exerciseType: 'strength',
        isCompound: true,
        cues: ['Squeeze glutes', 'Press straight up', 'Finish with ears visible'],
      ),
      const Exercise(
        id: 'ex_5',
        name: 'Barbell Row',
        nameEs: 'Remo con Barra',
        musclePrimary: 'back',
        muscleSecondary: ['biceps', 'rear_delts'],
        equipment: 'barbell',
        exerciseType: 'strength',
        isCompound: true,
        cues: ['Hinge at hips', 'Pull to lower chest', 'Squeeze shoulder blades'],
      ),
      const Exercise(
        id: 'ex_6',
        name: 'Pull Up',
        nameEs: 'Dominada',
        musclePrimary: 'back',
        muscleSecondary: ['biceps', 'core'],
        equipment: 'bodyweight',
        exerciseType: 'strength',
        isCompound: true,
        cues: ['Depress shoulders', 'Lead with chest', 'Full extension at bottom'],
      ),
      const Exercise(
        id: 'ex_7',
        name: 'Dumbbell Curl',
        nameEs: 'Curl con Mancuernas',
        musclePrimary: 'biceps',
        muscleSecondary: ['forearms'],
        equipment: 'dumbbell',
        exerciseType: 'strength',
        isCompound: false,
        cues: ['Keep elbows stationary', 'Full range of motion', 'Control the negative'],
      ),
      const Exercise(
        id: 'ex_8',
        name: 'Tricep Pushdown',
        nameEs: 'Extension de Triceps',
        musclePrimary: 'triceps',
        muscleSecondary: [],
        equipment: 'cable',
        exerciseType: 'strength',
        isCompound: false,
        cues: ['Elbows at sides', 'Full lockout', 'Squeeze at bottom'],
      ),
      const Exercise(
        id: 'ex_9',
        name: 'Leg Press',
        nameEs: 'Prensa de Piernas',
        musclePrimary: 'quads',
        muscleSecondary: ['glutes', 'hamstrings'],
        equipment: 'machine',
        exerciseType: 'strength',
        isCompound: true,
        cues: ['Feet shoulder width', 'Lower back on pad', 'Dont lock knees'],
      ),
      const Exercise(
        id: 'ex_10',
        name: 'Plank',
        nameEs: 'Plancha',
        musclePrimary: 'core',
        muscleSecondary: ['shoulders'],
        equipment: 'bodyweight',
        exerciseType: 'isometric',
        isCompound: false,
        cues: ['Straight line from head to heels', 'Engage core', 'Breathe steadily'],
      ),
    ];
  }

  List<WorkoutRoutine> _getMockRoutines() {
    return [
      const WorkoutRoutine(
        id: 'routine_1',
        userId: 'current_user',
        name: 'Push Day',
        routineType: 'ppl',
        dayOfWeek: 1,
        estimatedMins: 60,
        muscleGroups: ['chest', 'shoulders', 'triceps'],
        isActive: true,
      ),
      const WorkoutRoutine(
        id: 'routine_2',
        userId: 'current_user',
        name: 'Pull Day',
        routineType: 'ppl',
        dayOfWeek: 2,
        estimatedMins: 60,
        muscleGroups: ['back', 'biceps', 'rear_delts'],
        isActive: true,
      ),
      const WorkoutRoutine(
        id: 'routine_3',
        userId: 'current_user',
        name: 'Leg Day',
        routineType: 'ppl',
        dayOfWeek: 3,
        estimatedMins: 75,
        muscleGroups: ['quads', 'hamstrings', 'glutes', 'calves'],
        isActive: true,
      ),
      const WorkoutRoutine(
        id: 'routine_4',
        userId: 'current_user',
        name: 'Full Body',
        routineType: 'full_body',
        dayOfWeek: 0,
        estimatedMins: 90,
        muscleGroups: ['chest', 'back', 'shoulders', 'legs', 'arms'],
        isActive: true,
      ),
    ];
  }

  List<MuscleFatigue> _getMockMuscleFatigue() {
    return [
      MuscleFatigue(
        id: 'mf_1',
        userId: 'current_user',
        muscleGroup: 'chest',
        fatigueScore: 45,
        recoveryEtaHours: 24,
        lastTrainedAt: DateTime.now().subtract(const Duration(hours: 24)),
        calculatedAt: DateTime.now(),
      ),
      MuscleFatigue(
        id: 'mf_2',
        userId: 'current_user',
        muscleGroup: 'back',
        fatigueScore: 20,
        recoveryEtaHours: 0,
        lastTrainedAt: DateTime.now().subtract(const Duration(hours: 48)),
        calculatedAt: DateTime.now(),
      ),
      MuscleFatigue(
        id: 'mf_3',
        userId: 'current_user',
        muscleGroup: 'legs',
        fatigueScore: 80,
        recoveryEtaHours: 36,
        lastTrainedAt: DateTime.now().subtract(const Duration(hours: 12)),
        calculatedAt: DateTime.now(),
      ),
    ];
  }
}

/// Training provider
final trainingProvider = StateNotifierProvider<TrainingNotifier, TrainingState>((ref) {
  return TrainingNotifier();
});

/// Active session provider
final activeSessionProvider = Provider<WorkoutSession?>((ref) {
  return ref.watch(trainingProvider).activeSession;
});

/// Routines list provider
final routinesProvider = Provider<List<WorkoutRoutine>>((ref) {
  return ref.watch(trainingProvider).routines;
});

/// Exercises list provider
final exercisesProvider = Provider<List<Exercise>>((ref) {
  return ref.watch(trainingProvider).exercises;
});

/// Muscle fatigue provider
final muscleFatigueProvider = Provider<List<MuscleFatigue>>((ref) {
  return ref.watch(trainingProvider).muscleFatigue;
});
