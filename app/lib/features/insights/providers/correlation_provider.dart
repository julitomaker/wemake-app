import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/user_models.dart';
import '../../../core/services/demo_mode.dart';

part 'correlation_provider.freezed.dart';

/// Insight type enum
enum InsightType {
  sleepWorkout,      // Sleep affects workout performance
  nutritionFocus,    // Nutrition affects focus/productivity
  mealTiming,        // Meal timing affects diet adherence
  carbsPerformance,  // Carbs before workout affects performance
  hydrationEnergy,   // Hydration affects energy levels
  habitStreak,       // Habit completion patterns
  workoutRecovery,   // Workout recovery time patterns
  sleepQuality,      // Sleep quality factors
}

/// Generated insight with correlation data
@freezed
class GeneratedInsight with _$GeneratedInsight {
  const factory GeneratedInsight({
    required String id,
    required InsightType type,
    required String title,
    required String description,
    required String actionSuggestion,
    required double correlationStrength, // -1 to 1
    required double confidence, // 0 to 1
    required int sampleSize,
    @Default(false) bool isDismissed,
    @Default(false) bool isActionTaken,
    DateTime? generatedAt,
  }) = _GeneratedInsight;
}

/// Correlation analysis result
@freezed
class CorrelationResult with _$CorrelationResult {
  const factory CorrelationResult({
    required String variableA,
    required String variableB,
    required double coefficient,
    required double pValue,
    required int sampleSize,
    required bool isSignificant,
  }) = _CorrelationResult;
}

/// Correlation Engine state
@freezed
class CorrelationState with _$CorrelationState {
  const factory CorrelationState({
    @Default([]) List<DailyScore> dailyScores,
    @Default([]) List<GeneratedInsight> insights,
    @Default([]) List<CorrelationResult> correlations,
    DateTime? lastAnalyzedAt,
    @Default(false) bool isAnalyzing,
    @Default(false) bool hasEnoughData,
    String? error,
  }) = _CorrelationState;
}

/// Correlation Engine Notifier
class CorrelationNotifier extends StateNotifier<CorrelationState> {
  static const int minSampleSize = 14; // 2 weeks minimum
  static const double significanceThreshold = 0.05;
  static const double correlationThreshold = 0.3;

  CorrelationNotifier() : super(const CorrelationState());

  /// Load daily scores for analysis
  Future<void> loadDailyScores() async {
    // --- Demo Mode: cargar datos mock directamente ---
    if (demoMode.isActive) {
      await Future.delayed(const Duration(milliseconds: 200));
      final scores = _generateMockDailyScores(30);
      state = state.copyWith(
        dailyScores: scores,
        hasEnoughData: true,
      );
      return;
    }
    // --- Fin Demo Mode ---

    try {
      // In production, fetch from Supabase
      await Future.delayed(const Duration(milliseconds: 300));

      // Generate mock daily scores for the last 30 days
      final scores = _generateMockDailyScores(30);

      state = state.copyWith(
        dailyScores: scores,
        hasEnoughData: scores.length >= minSampleSize,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Run correlation analysis
  Future<void> runAnalysis() async {
    // --- Demo Mode: generar insights demo directamente ---
    if (demoMode.isActive) {
      state = state.copyWith(isAnalyzing: true, error: null);
      await Future.delayed(const Duration(milliseconds: 600));

      final now = DateTime.now();
      final demoInsights = [
        GeneratedInsight(
          id: 'demo_insight_1',
          type: InsightType.sleepWorkout,
          title: 'Sueno y Rendimiento',
          description: 'Cuando duermes menos de 6 horas, tu RPE promedio sube un 18%. '
              'Tus entrenamientos se sienten significativamente mas dificiles.',
          actionSuggestion: 'Prioriza dormir 7+ horas las noches antes de entrenar.',
          correlationStrength: -0.52,
          confidence: 0.87,
          sampleSize: 24,
          generatedAt: now,
        ),
        GeneratedInsight(
          id: 'demo_insight_2',
          type: InsightType.nutritionFocus,
          title: 'Proteina y Concentracion',
          description: 'Los dias con mas de 120g de proteina, tu tiempo de enfoque '
              'es 25 minutos mayor que los dias bajos en proteina.',
          actionSuggestion: 'Asegurate de consumir suficiente proteina en el desayuno y almuerzo.',
          correlationStrength: 0.44,
          confidence: 0.79,
          sampleSize: 28,
          generatedAt: now,
        ),
        GeneratedInsight(
          id: 'demo_insight_3',
          type: InsightType.mealTiming,
          title: 'Patron de Comidas',
          description: 'Tiendes a exceder tus calorias despues de las 8PM. '
              'Esto coincide con los dias de mayor deficit calorico matutino.',
          actionSuggestion: 'Considera un snack saludable a las 6PM para evitar el exceso nocturno.',
          correlationStrength: 0.48,
          confidence: 0.82,
          sampleSize: 30,
          generatedAt: now,
        ),
        GeneratedInsight(
          id: 'demo_insight_4',
          type: InsightType.carbsPerformance,
          title: 'Carbohidratos y Fuerza',
          description: 'Los dias con carbohidratos altos (+180g), tu volumen total '
              'de entrenamiento es 22% mayor.',
          actionSuggestion: 'Consume carbohidratos complejos 2-3 horas antes de entrenar.',
          correlationStrength: 0.58,
          confidence: 0.88,
          sampleSize: 18,
          generatedAt: now,
        ),
        GeneratedInsight(
          id: 'demo_insight_5',
          type: InsightType.hydrationEnergy,
          title: 'Hidratacion y Energia',
          description: 'Tu nivel de energia es 1.8 puntos mayor los dias que '
              'bebes mas de 2.5L de agua.',
          actionSuggestion: 'Lleva tu botella contigo y apunta a beber al menos 2.5L al dia.',
          correlationStrength: 0.41,
          confidence: 0.74,
          sampleSize: 26,
          generatedAt: now,
        ),
        GeneratedInsight(
          id: 'demo_insight_6',
          type: InsightType.habitStreak,
          title: 'Patron de Habitos Semanal',
          description: 'Completas tus habitos mejor entre semana (82%) que los fines '
              'de semana (61%). Los domingos son tu dia mas debil.',
          actionSuggestion: 'Crea una rutina especifica para fines de semana con habitos mas ligeros.',
          correlationStrength: 0.38,
          confidence: 0.71,
          sampleSize: 30,
          generatedAt: now,
        ),
      ];

      state = state.copyWith(
        insights: demoInsights,
        correlations: [],
        lastAnalyzedAt: now,
        isAnalyzing: false,
        hasEnoughData: true,
      );
      return;
    }
    // --- Fin Demo Mode ---

    if (state.dailyScores.length < minSampleSize) {
      state = state.copyWith(
        hasEnoughData: false,
        error: 'Necesitas al menos 14 dias de datos para generar insights',
      );
      return;
    }

    state = state.copyWith(isAnalyzing: true, error: null);

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate processing

      final insights = <GeneratedInsight>[];
      final correlations = <CorrelationResult>[];

      // 1. Check sleep-workout correlation
      final sleepWorkoutInsight = _analyzeSleepWorkout();
      if (sleepWorkoutInsight != null) {
        insights.add(sleepWorkoutInsight);
      }

      // 2. Check nutrition-focus correlation
      final nutritionFocusInsight = _analyzeNutritionFocus();
      if (nutritionFocusInsight != null) {
        insights.add(nutritionFocusInsight);
      }

      // 3. Check meal timing patterns
      final mealTimingInsight = _analyzeMealTiming();
      if (mealTimingInsight != null) {
        insights.add(mealTimingInsight);
      }

      // 4. Check carbs-performance correlation
      final carbsInsight = _analyzeCarbsPerformance();
      if (carbsInsight != null) {
        insights.add(carbsInsight);
      }

      // 5. Check hydration-energy correlation
      final hydrationInsight = _analyzeHydrationEnergy();
      if (hydrationInsight != null) {
        insights.add(hydrationInsight);
      }

      // 6. Check habit patterns
      final habitInsight = _analyzeHabitPatterns();
      if (habitInsight != null) {
        insights.add(habitInsight);
      }

      state = state.copyWith(
        insights: insights,
        correlations: correlations,
        lastAnalyzedAt: DateTime.now(),
        isAnalyzing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        error: e.toString(),
      );
    }
  }

  /// Dismiss an insight
  void dismissInsight(String insightId) {
    final updatedInsights = state.insights.map((i) {
      if (i.id == insightId) {
        return i.copyWith(isDismissed: true);
      }
      return i;
    }).toList();

    state = state.copyWith(insights: updatedInsights);
  }

  /// Mark insight action as taken
  void markActionTaken(String insightId) {
    final updatedInsights = state.insights.map((i) {
      if (i.id == insightId) {
        return i.copyWith(isActionTaken: true);
      }
      return i;
    }).toList();

    state = state.copyWith(insights: updatedInsights);
  }

  /// Get active insights (not dismissed)
  List<GeneratedInsight> getActiveInsights() {
    return state.insights.where((i) => !i.isDismissed).toList();
  }

  // Analysis methods

  GeneratedInsight? _analyzeSleepWorkout() {
    final workoutDays = state.dailyScores.where((d) => d.workoutDone).toList();
    if (workoutDays.length < 7) return null;

    // Simple analysis: compare performance on low vs good sleep days
    final lowSleepDays = workoutDays.where((d) =>
        d.sleepHours != null && d.sleepHours! < 6).toList();
    final goodSleepDays = workoutDays.where((d) =>
        d.sleepHours != null && d.sleepHours! >= 7).toList();

    if (lowSleepDays.isEmpty || goodSleepDays.isEmpty) return null;

    final avgRpeLowSleep = lowSleepDays
        .where((d) => d.workoutAvgRpe != null)
        .map((d) => d.workoutAvgRpe!)
        .fold(0.0, (a, b) => a + b) / lowSleepDays.length;

    final avgRpeGoodSleep = goodSleepDays
        .where((d) => d.workoutAvgRpe != null)
        .map((d) => d.workoutAvgRpe!)
        .fold(0.0, (a, b) => a + b) / goodSleepDays.length;

    if (avgRpeLowSleep > avgRpeGoodSleep + 0.5) {
      final pctIncrease = ((avgRpeLowSleep - avgRpeGoodSleep) / avgRpeGoodSleep * 100).round();

      return GeneratedInsight(
        id: 'insight_sleep_workout_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.sleepWorkout,
        title: 'Sueno y Rendimiento',
        description: 'Cuando duermes menos de 6 horas, tu RPE sube un $pctIncrease%. '
            'Esto significa que tus entrenamientos se sienten mas dificiles.',
        actionSuggestion: 'Prioriza dormir 7+ horas las noches antes de entrenar.',
        correlationStrength: -0.45,
        confidence: 0.82,
        sampleSize: workoutDays.length,
        generatedAt: DateTime.now(),
      );
    }

    return null;
  }

  GeneratedInsight? _analyzeNutritionFocus() {
    final focusDays = state.dailyScores.where((d) =>
        d.focusMinutes != null && d.focusMinutes! > 0).toList();
    if (focusDays.length < 10) return null;

    // Check protein intake correlation with focus
    final highProteinDays = focusDays.where((d) =>
        d.proteinG != null && d.proteinG! > 100).toList();
    final lowProteinDays = focusDays.where((d) =>
        d.proteinG != null && d.proteinG! < 80).toList();

    if (highProteinDays.isEmpty || lowProteinDays.isEmpty) return null;

    final avgFocusHighProtein = highProteinDays
        .map((d) => d.focusMinutes!)
        .fold(0, (a, b) => a + b) / highProteinDays.length;

    final avgFocusLowProtein = lowProteinDays
        .map((d) => d.focusMinutes!)
        .fold(0, (a, b) => a + b) / lowProteinDays.length;

    if (avgFocusHighProtein > avgFocusLowProtein + 15) {
      return GeneratedInsight(
        id: 'insight_nutrition_focus_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.nutritionFocus,
        title: 'Proteina y Concentracion',
        description: 'Los dias con mas de 100g de proteina, tu tiempo de enfoque es '
            '${(avgFocusHighProtein - avgFocusLowProtein).round()} minutos mayor.',
        actionSuggestion: 'Asegurate de consumir suficiente proteina temprano en el dia.',
        correlationStrength: 0.38,
        confidence: 0.75,
        sampleSize: focusDays.length,
        generatedAt: DateTime.now(),
      );
    }

    return null;
  }

  GeneratedInsight? _analyzeMealTiming() {
    // Check for late night eating patterns
    // In production, this would analyze actual meal timestamps

    return GeneratedInsight(
      id: 'insight_meal_timing_${DateTime.now().millisecondsSinceEpoch}',
      type: InsightType.mealTiming,
      title: 'Patron de Comidas',
      description: 'Tiendes a fallar tu dieta despues de las 7PM. '
          'Esto coincide con los dias de mayor deficit calorico.',
      actionSuggestion: 'Considera un snack saludable a las 6PM para evitar el exceso nocturno.',
      correlationStrength: 0.42,
      confidence: 0.78,
      sampleSize: state.dailyScores.length,
      generatedAt: DateTime.now(),
    );
  }

  GeneratedInsight? _analyzeCarbsPerformance() {
    final workoutDays = state.dailyScores.where((d) =>
        d.workoutDone && d.carbsG != null && d.workoutTonnage != null).toList();
    if (workoutDays.length < 7) return null;

    // Check carb intake effect on workout tonnage
    final highCarbDays = workoutDays.where((d) => d.carbsG! > 150).toList();
    final lowCarbDays = workoutDays.where((d) => d.carbsG! < 100).toList();

    if (highCarbDays.isEmpty || lowCarbDays.isEmpty) return null;

    final avgTonnageHighCarbs = highCarbDays
        .map((d) => d.workoutTonnage!)
        .fold(0.0, (a, b) => a + b) / highCarbDays.length;

    final avgTonnageLowCarbs = lowCarbDays
        .map((d) => d.workoutTonnage!)
        .fold(0.0, (a, b) => a + b) / lowCarbDays.length;

    if (avgTonnageHighCarbs > avgTonnageLowCarbs * 1.1) {
      final pctIncrease = ((avgTonnageHighCarbs - avgTonnageLowCarbs) / avgTonnageLowCarbs * 100).round();

      return GeneratedInsight(
        id: 'insight_carbs_performance_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.carbsPerformance,
        title: 'Carbohidratos y Fuerza',
        description: 'Los dias con carbohidratos altos, tu volumen de entrenamiento '
            'es $pctIncrease% mayor.',
        actionSuggestion: 'Consume carbohidratos 2-3 horas antes de entrenar para mejor rendimiento.',
        correlationStrength: 0.52,
        confidence: 0.85,
        sampleSize: workoutDays.length,
        generatedAt: DateTime.now(),
      );
    }

    return null;
  }

  GeneratedInsight? _analyzeHydrationEnergy() {
    final daysWithData = state.dailyScores.where((d) =>
        d.waterMl != null && d.energyReported != null).toList();
    if (daysWithData.length < 10) return null;

    final wellHydratedDays = daysWithData.where((d) => d.waterMl! >= 2500).toList();
    final dehydratedDays = daysWithData.where((d) => d.waterMl! < 1500).toList();

    if (wellHydratedDays.isEmpty || dehydratedDays.isEmpty) return null;

    final avgEnergyHydrated = wellHydratedDays
        .map((d) => d.energyReported!)
        .fold(0, (a, b) => a + b) / wellHydratedDays.length;

    final avgEnergyDehydrated = dehydratedDays
        .map((d) => d.energyReported!)
        .fold(0, (a, b) => a + b) / dehydratedDays.length;

    if (avgEnergyHydrated > avgEnergyDehydrated + 1) {
      return GeneratedInsight(
        id: 'insight_hydration_energy_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.hydrationEnergy,
        title: 'Hidratacion y Energia',
        description: 'Tu nivel de energia reportado es ${(avgEnergyHydrated - avgEnergyDehydrated).toStringAsFixed(1)} '
            'puntos mayor los dias que te hidratas bien.',
        actionSuggestion: 'Lleva tu botella contigo y bebe al menos 2.5L de agua al dia.',
        correlationStrength: 0.41,
        confidence: 0.72,
        sampleSize: daysWithData.length,
        generatedAt: DateTime.now(),
      );
    }

    return null;
  }

  GeneratedInsight? _analyzeHabitPatterns() {
    final daysWithHabits = state.dailyScores.where((d) =>
        d.habitsTotal != null && d.habitsTotal! > 0).toList();
    if (daysWithHabits.length < 14) return null;

    // Find best day of week for habit completion
    // Simplified: just check weekday vs weekend
    final weekdays = daysWithHabits.where((d) =>
        d.scoreDate.weekday <= 5).toList();
    final weekends = daysWithHabits.where((d) =>
        d.scoreDate.weekday > 5).toList();

    if (weekdays.isEmpty || weekends.isEmpty) return null;

    final avgCompletionWeekday = weekdays
        .where((d) => d.completionPct != null)
        .map((d) => d.completionPct!)
        .fold(0, (a, b) => a + b) / weekdays.length;

    final avgCompletionWeekend = weekends
        .where((d) => d.completionPct != null)
        .map((d) => d.completionPct!)
        .fold(0, (a, b) => a + b) / weekends.length;

    if ((avgCompletionWeekday - avgCompletionWeekend).abs() > 15) {
      final betterDays = avgCompletionWeekday > avgCompletionWeekend
          ? 'entre semana'
          : 'los fines de semana';
      final worseDays = avgCompletionWeekday > avgCompletionWeekend
          ? 'los fines de semana'
          : 'entre semana';

      return GeneratedInsight(
        id: 'insight_habit_patterns_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.habitStreak,
        title: 'Patron de Habitos',
        description: 'Completas tus habitos mejor $betterDays. '
            'Los $worseDays tu completion baja significativamente.',
        actionSuggestion: 'Crea rutinas especificas para $worseDays para mantener consistencia.',
        correlationStrength: 0.35,
        confidence: 0.68,
        sampleSize: daysWithHabits.length,
        generatedAt: DateTime.now(),
      );
    }

    return null;
  }

  // Generate mock data for testing
  List<DailyScore> _generateMockDailyScores(int days) {
    final scores = <DailyScore>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dayOfWeek = date.weekday;

      // Simulate realistic patterns
      final isWeekend = dayOfWeek > 5;
      final baseSleep = isWeekend ? 7.5 : 6.5;
      final sleepVariation = (i % 3) - 1;

      scores.add(DailyScore(
        id: 'ds_$i',
        userId: 'current_user',
        scoreDate: date,
        totalXp: 50 + (i % 30),
        habitsPct: isWeekend ? 0.65 : 0.80,
        nutritionPct: 0.70 + (i % 20) / 100,
        trainingPct: i % 3 == 0 ? 1.0 : 0.0,
        productivityPct: isWeekend ? 0.50 : 0.75,
        hydrationPct: 0.60 + (i % 40) / 100,
        overallPct: 0.70,
        streakLightMet: i % 10 != 0,
        streakPerfectMet: i % 15 == 0,
        sleepHours: baseSleep + sleepVariation * 0.5,
        sleepQuality: 6 + (i % 4),
        sleepDebtHrs: i % 7 == 0 ? 2.0 : 0.5,
        kcalConsumed: 2000 + (i % 500),
        kcalBurned: i % 3 == 0 ? 400 : 200,
        proteinG: 80 + (i % 60),
        carbsG: 150 + (i % 100),
        fatG: 60 + (i % 30),
        waterMl: 1500 + (i % 1500),
        macroAdherence: 70 + (i % 25),
        steps: 5000 + (i % 10000),
        activeMinutes: 30 + (i % 60),
        workoutDone: i % 3 == 0,
        workoutTonnage: i % 3 == 0 ? 5000 + (i % 3000).toDouble() : null,
        workoutAvgRpe: i % 3 == 0 ? 6.5 + (sleepVariation * 0.5) : null,
        focusMinutes: isWeekend ? 60 : 120 + (i % 60),
        tasksCompleted: isWeekend ? 2 : 5 + (i % 5),
        interruptions: isWeekend ? 5 : 10 + (i % 10),
        habitsTotal: 8,
        habitsCompleted: isWeekend ? 5 : 6 + (i % 2),
        completionPct: isWeekend ? 62 : 75 + (i % 15),
        energyReported: 5 + (i % 5),
        moodReported: 6 + (i % 4),
        dailyScoreValue: 65 + (i % 30),
        calculatedAt: date,
      ));
    }

    return scores;
  }
}

/// Correlation provider
final correlationProvider = StateNotifierProvider<CorrelationNotifier, CorrelationState>((ref) {
  return CorrelationNotifier();
});

/// Active insights provider (non-dismissed)
final activeInsightsProvider = Provider<List<GeneratedInsight>>((ref) {
  return ref.watch(correlationProvider.notifier).getActiveInsights();
});

/// Has enough data for analysis
final hasEnoughDataProvider = Provider<bool>((ref) {
  return ref.watch(correlationProvider).hasEnoughData;
});
