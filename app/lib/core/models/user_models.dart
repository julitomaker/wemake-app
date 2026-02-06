import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_models.freezed.dart';
part 'user_models.g.dart';

/// Bio Profile model
@freezed
class BioProfile with _$BioProfile {
  const factory BioProfile({
    required String id,
    required String userId,

    // Basic Info
    double? weightKg,
    int? heightCm,
    int? age,
    String? sex,

    // Body & Fitness
    String? bodyType,
    @Default([]) List<Injury> injuries,
    String? equipmentAccess,
    String? activityLevel,

    // Cognitive Profile
    int? focusScore,
    String? attentionType,

    // Goals
    String? goalPrimary,
    String? goalUrgency,

    // Calculated Targets
    int? tdeeCalculated,
    MacroTargets? macroTargets,
    @Default(3500) int waterTargetMl,
    @Default(700) int bottleSizeMl,
    @Default(8.0) double sleepTargetHrs,

    // Onboarding
    String? commitmentSignature,
    DateTime? onboardingCompletedAt,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BioProfile;

  factory BioProfile.fromJson(Map<String, dynamic> json) =>
      _$BioProfileFromJson(json);
}

/// Macro targets
@freezed
class MacroTargets with _$MacroTargets {
  const factory MacroTargets({
    required int proteinG,
    required int carbsG,
    required int fatG,
    required int kcal,
  }) = _MacroTargets;

  factory MacroTargets.fromJson(Map<String, dynamic> json) =>
      _$MacroTargetsFromJson(json);
}

/// Injury record
@freezed
class Injury with _$Injury {
  const factory Injury({
    required String area,
    required String severity,
    String? notes,
  }) = _Injury;

  factory Injury.fromJson(Map<String, dynamic> json) => _$InjuryFromJson(json);
}

/// Currency (XP + Coins)
@freezed
class Currency with _$Currency {
  const factory Currency({
    String? id,
    String? userId,
    @Default(0) int xpTotal,
    @Default(0) int xpWeekly,
    @Default(0) int coinsBalance,
    DateTime? updatedAt,
  }) = _Currency;

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);
}

/// Streak Type enum
enum StreakType {
  streakLight,
  streakPerfect,
}

/// Streak
@freezed
class Streak with _$Streak {
  const factory Streak({
    String? id,
    String? userId,
    required StreakType streakType,
    @Default(0) int currentCount,
    @Default(0) int longestCount,
    DateTime? lastExtendedAt,
    @Default(0) int freezeAvailable,
    @Default(false) bool frozenToday,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Streak;

  factory Streak.fromJson(Map<String, dynamic> json) => _$StreakFromJson(json);
}

/// Daily Score (for correlation engine and daily tracking)
@freezed
class DailyScore with _$DailyScore {
  const factory DailyScore({
    String? id,
    String? userId,
    required DateTime scoreDate,

    // XP earned today
    @Default(0) int totalXp,

    // Percentages per domain
    @Default(0.0) double habitsPct,
    @Default(0.0) double nutritionPct,
    @Default(0.0) double trainingPct,
    @Default(0.0) double productivityPct,
    @Default(0.0) double hydrationPct,
    @Default(0.0) double overallPct,

    // Streak tracking
    @Default(false) bool streakLightMet,
    @Default(false) bool streakPerfectMet,

    // Sleep
    double? sleepHours,
    int? sleepQuality,
    double? sleepDebtHrs,

    // Nutrition details
    int? kcalConsumed,
    int? kcalBurned,
    int? proteinG,
    int? carbsG,
    int? fatG,
    int? waterMl,
    int? macroAdherence,

    // Activity
    int? steps,
    int? activeMinutes,
    @Default(false) bool workoutDone,
    double? workoutTonnage,
    double? workoutAvgRpe,

    // Focus
    int? focusMinutes,
    int? tasksCompleted,
    int? interruptions,

    // Habits
    int? habitsTotal,
    int? habitsCompleted,
    int? completionPct,

    // Self-reported
    int? energyReported,
    int? moodReported,

    // Composite
    int? dailyScoreValue,

    DateTime? calculatedAt,
  }) = _DailyScore;

  factory DailyScore.fromJson(Map<String, dynamic> json) =>
      _$DailyScoreFromJson(json);
}

/// Insight (AI-generated correlation)
@freezed
class Insight with _$Insight {
  const factory Insight({
    required String id,
    required String userId,
    required String insightType,
    required String title,
    required String description,
    required List<InsightVariable> variables,
    double? confidence,
    int? sampleSize,
    @Default(false) bool dismissed,
    @Default(false) bool actedUpon,
    DateTime? generatedAt,
  }) = _Insight;

  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);
}

@freezed
class InsightVariable with _$InsightVariable {
  const factory InsightVariable({
    required String name,
    required double correlationCoef,
  }) = _InsightVariable;

  factory InsightVariable.fromJson(Map<String, dynamic> json) =>
      _$InsightVariableFromJson(json);
}
