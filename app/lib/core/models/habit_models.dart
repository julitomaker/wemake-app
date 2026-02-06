import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_models.freezed.dart';
part 'habit_models.g.dart';

/// Habit model
@freezed
class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String userId,
    required String name,
    String? description,
    required String habitType, // check_simple, quantitative, evidence, integrated

    // For quantitative habits
    double? targetValue,
    String? unit,

    // Scheduling
    @Default('daily') String frequency,
    String? timeOfDay,
    @Default([0, 1, 2, 3, 4, 5, 6]) List<int> daysOfWeek,

    // Integration
    String? sourceApi,
    String? verificationType,

    // Rewards
    @Default(10) int xpValue,
    @Default(5) int coinsValue,

    @Default(true) bool isActive,
    @Default(0) int orderIndex,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
}

/// Habit Log (daily record)
@freezed
class HabitLog with _$HabitLog {
  const factory HabitLog({
    required String id,
    required String habitId,
    required DateTime date,
    @Default('pending') String status, // pending, done, skipped

    // For quantitative habits
    double? value,

    // For evidence-based habits
    String? evidenceUrl,
    bool? evidenceValid,

    // Rewards earned
    @Default(0) int xpEarned,
    @Default(0) int coinsEarned,

    DateTime? loggedAt,
    DateTime? createdAt,
  }) = _HabitLog;

  factory HabitLog.fromJson(Map<String, dynamic> json) =>
      _$HabitLogFromJson(json);
}

/// Habit with today's log (for UI display)
@freezed
class HabitWithLog with _$HabitWithLog {
  const factory HabitWithLog({
    required Habit habit,
    HabitLog? todayLog,
  }) = _HabitWithLog;

  factory HabitWithLog.fromJson(Map<String, dynamic> json) =>
      _$HabitWithLogFromJson(json);
}

/// Habit Evidence (screenshot verification)
@freezed
class HabitEvidence with _$HabitEvidence {
  const factory HabitEvidence({
    required String id,
    required String habitLogId,
    required String imageUrl,
    Map<String, dynamic>? ocrResult,
    String? aiValidation, // valid, invalid, uncertain
    String? extractedValue,
    DateTime? processedAt,
    DateTime? createdAt,
  }) = _HabitEvidence;

  factory HabitEvidence.fromJson(Map<String, dynamic> json) =>
      _$HabitEvidenceFromJson(json);
}

/// Daily Flow Item Type
enum DailyFlowItemType {
  habit,
  meal,
  workout,
  task,
  water,
}

/// Habit Type
enum HabitType {
  boolean,
  counter,
  timer,
}

/// Daily Flow Item (for timeline display)
@freezed
class DailyFlowItem with _$DailyFlowItem {
  const factory DailyFlowItem({
    required String id,
    required DailyFlowItemType type,
    required String title,
    String? subtitle,
    DateTime? scheduledTime,
    @Default(false) bool isCompleted,
    @Default(10) int xpReward,
    HabitType? habitType,
    double? currentValue,
    double? targetValue,
    Map<String, dynamic>? metadata,
  }) = _DailyFlowItem;

  factory DailyFlowItem.fromJson(Map<String, dynamic> json) =>
      _$DailyFlowItemFromJson(json);
}
