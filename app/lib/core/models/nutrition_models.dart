import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_models.freezed.dart';
part 'nutrition_models.g.dart';

/// Food item from database
@freezed
class Food with _$Food {
  const factory Food({
    required String id,
    required String name,
    String? nameEs,
    String? brand,

    // Per 100g
    required double kcalPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    @Default(0) double fiberPer100g,
    @Default(0) double sugarPer100g,
    @Default(0) double sodiumPer100g,

    @Default('custom') String source, // usda, custom, ai
    String? barcode,
    String? imageUrl,

    String? createdBy,
    @Default(false) bool isVerified,
    DateTime? createdAt,
  }) = _Food;

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);
}

/// Meal Log
@freezed
class MealLog with _$MealLog {
  const factory MealLog({
    required String id,
    required String userId,
    required DateTime loggedAt,
    required String mealType, // breakfast, lunch, dinner, snacks

    // Photo & AI
    String? photoUrl,
    double? aiConfidence,
    @Default(false) bool userVerified,

    // Calculated Totals
    required int totalKcal,
    required double totalProtein,
    required double totalCarbs,
    required double totalFat,
    @Default(0) double totalFiber,

    // Context
    String? timingContext, // pre_workout, post_workout, normal
    int? adherenceScore,
    String? notes,

    DateTime? createdAt,
  }) = _MealLog;

  factory MealLog.fromJson(Map<String, dynamic> json) =>
      _$MealLogFromJson(json);
}

/// Meal Log Item (individual food in a meal)
@freezed
class MealLogItem with _$MealLogItem {
  const factory MealLogItem({
    required String id,
    required String mealLogId,
    required String foodId,
    required double quantityG,
    @Default(false) bool aiDetected,
    @Default(false) bool userAdjusted,
    DateTime? createdAt,

    // Joined food data (for display)
    Food? food,
  }) = _MealLogItem;

  factory MealLogItem.fromJson(Map<String, dynamic> json) =>
      _$MealLogItemFromJson(json);
}

/// Meal Feedback (post-meal check-in)
@freezed
class MealFeedback with _$MealFeedback {
  const factory MealFeedback({
    required String id,
    required String mealLogId,
    int? energyLevel, // 1-10
    int? satietyLevel, // 1-10
    @Default(false) bool bloating,
    @Default(false) bool brainFog,
    @Default(false) bool cravings,
    String? notes,
    DateTime? loggedAt,
  }) = _MealFeedback;

  factory MealFeedback.fromJson(Map<String, dynamic> json) =>
      _$MealFeedbackFromJson(json);
}

/// Daily Nutrition Summary
@freezed
class DailyNutrition with _$DailyNutrition {
  const factory DailyNutrition({
    required String id,
    required String userId,
    required DateTime date,
    int? hungerAvg,
    int? energyAvg,
    int? digestionScore,
    @Default(false) bool cravingsHad,
    String? adherenceSelf, // high, medium, low
    Map<String, dynamic>? aiAdjustment,
    DateTime? createdAt,
  }) = _DailyNutrition;

  factory DailyNutrition.fromJson(Map<String, dynamic> json) =>
      _$DailyNutritionFromJson(json);
}

/// AI Meal Analysis Result
@freezed
class MealAnalysisResult with _$MealAnalysisResult {
  const factory MealAnalysisResult({
    required List<DetectedFoodItem> items,
    @Default(false) bool needsClarification,
    String? clarificationQuestion,
    MealTotals? totals,
  }) = _MealAnalysisResult;

  factory MealAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$MealAnalysisResultFromJson(json);
}

@freezed
class DetectedFoodItem with _$DetectedFoodItem {
  const factory DetectedFoodItem({
    required String name,
    required double estimatedGrams,
    required double confidence,
    String? foodId, // If matched to existing food in DB
  }) = _DetectedFoodItem;

  factory DetectedFoodItem.fromJson(Map<String, dynamic> json) =>
      _$DetectedFoodItemFromJson(json);
}

@freezed
class MealTotals with _$MealTotals {
  const factory MealTotals({
    required int kcal,
    required double protein,
    required double carbs,
    required double fat,
  }) = _MealTotals;

  factory MealTotals.fromJson(Map<String, dynamic> json) =>
      _$MealTotalsFromJson(json);
}

/// Water tracking
@freezed
class WaterLog with _$WaterLog {
  const factory WaterLog({
    required int totalMl,
    required int targetMl,
    required int bottleSizeMl,
    required int bottlesCompleted,
    required int bottlesTarget,
  }) = _WaterLog;

  factory WaterLog.fromJson(Map<String, dynamic> json) =>
      _$WaterLogFromJson(json);
}
