import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/demo_mode.dart';

/// State for nutrition tracking
class NutritionState {
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;
  final int kcalConsumed;
  final int kcalTarget;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbsConsumed;
  final int carbsTarget;
  final int fatConsumed;
  final int fatTarget;
  final int waterBottles;
  final int waterTarget;
  final List<MealEntry> meals;

  const NutritionState({
    this.isLoading = false,
    this.error,
    required this.selectedDate,
    this.kcalConsumed = 0,
    this.kcalTarget = 2000,
    this.proteinConsumed = 0,
    this.proteinTarget = 150,
    this.carbsConsumed = 0,
    this.carbsTarget = 200,
    this.fatConsumed = 0,
    this.fatTarget = 65,
    this.waterBottles = 0,
    this.waterTarget = 5,
    this.meals = const [],
  });

  NutritionState copyWith({
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    int? kcalConsumed,
    int? kcalTarget,
    int? proteinConsumed,
    int? proteinTarget,
    int? carbsConsumed,
    int? carbsTarget,
    int? fatConsumed,
    int? fatTarget,
    int? waterBottles,
    int? waterTarget,
    List<MealEntry>? meals,
  }) {
    return NutritionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
      kcalConsumed: kcalConsumed ?? this.kcalConsumed,
      kcalTarget: kcalTarget ?? this.kcalTarget,
      proteinConsumed: proteinConsumed ?? this.proteinConsumed,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbsConsumed: carbsConsumed ?? this.carbsConsumed,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      fatConsumed: fatConsumed ?? this.fatConsumed,
      fatTarget: fatTarget ?? this.fatTarget,
      waterBottles: waterBottles ?? this.waterBottles,
      waterTarget: waterTarget ?? this.waterTarget,
      meals: meals ?? this.meals,
    );
  }

  double get kcalProgress => kcalTarget > 0 ? (kcalConsumed / kcalTarget).clamp(0.0, 1.5) : 0;
  double get proteinProgress => proteinTarget > 0 ? (proteinConsumed / proteinTarget).clamp(0.0, 1.5) : 0;
  double get carbsProgress => carbsTarget > 0 ? (carbsConsumed / carbsTarget).clamp(0.0, 1.5) : 0;
  double get fatProgress => fatTarget > 0 ? (fatConsumed / fatTarget).clamp(0.0, 1.5) : 0;
  double get waterProgress => waterTarget > 0 ? (waterBottles / waterTarget).clamp(0.0, 1.0) : 0;
}

class MealEntry {
  final String id;
  final String mealType;
  final String? description;
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
  final String? imageUrl;
  final DateTime loggedAt;

  const MealEntry({
    required this.id,
    required this.mealType,
    this.description,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageUrl,
    required this.loggedAt,
  });
}

/// Provider for nutrition state management
final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  return NutritionNotifier();
});

class NutritionNotifier extends StateNotifier<NutritionState> {
  NutritionNotifier() : super(NutritionState(selectedDate: DateTime.now()));

  final _supabase = Supabase.instance.client;

  /// Load nutrition data for a specific date
  Future<void> loadNutritionData([DateTime? date]) async {
    final targetDate = date ?? state.selectedDate;
    state = state.copyWith(isLoading: true, error: null, selectedDate: targetDate);

    // --- Demo Mode: devolver datos mock de nutricion ---
    if (demoMode.isActive) {
      await Future.delayed(const Duration(milliseconds: 300));

      final mockMeals = [
        MealEntry(
          id: 'demo_meal1',
          mealType: 'breakfast',
          description: 'Avena con banana, mantequilla de mani y whey protein',
          kcal: 520,
          protein: 38,
          carbs: 65,
          fat: 14,
          loggedAt: targetDate.copyWith(hour: 8, minute: 15),
        ),
        MealEntry(
          id: 'demo_meal2',
          mealType: 'snack',
          description: 'Yogur griego con frutos rojos y granola',
          kcal: 280,
          protein: 22,
          carbs: 30,
          fat: 8,
          loggedAt: targetDate.copyWith(hour: 10, minute: 30),
        ),
        MealEntry(
          id: 'demo_meal3',
          mealType: 'lunch',
          description: 'Pechuga de pollo a la plancha con arroz integral y ensalada',
          kcal: 650,
          protein: 48,
          carbs: 60,
          fat: 18,
          loggedAt: targetDate.copyWith(hour: 13, minute: 0),
        ),
        MealEntry(
          id: 'demo_meal4',
          mealType: 'snack',
          description: 'Batido de proteina con leche de almendras',
          kcal: 220,
          protein: 30,
          carbs: 12,
          fat: 5,
          loggedAt: targetDate.copyWith(hour: 16, minute: 30),
        ),
        MealEntry(
          id: 'demo_meal5',
          mealType: 'dinner',
          description: 'Salmon al horno con batata y brocoli',
          kcal: 580,
          protein: 42,
          carbs: 40,
          fat: 24,
          loggedAt: targetDate.copyWith(hour: 20, minute: 0),
        ),
      ];

      int kcal = 0, protein = 0, carbs = 0, fat = 0;
      for (final meal in mockMeals) {
        kcal += meal.kcal;
        protein += meal.protein;
        carbs += meal.carbs;
        fat += meal.fat;
      }

      state = state.copyWith(
        isLoading: false,
        meals: mockMeals,
        kcalConsumed: kcal,
        proteinConsumed: protein,
        carbsConsumed: carbs,
        fatConsumed: fat,
        kcalTarget: 2400,
        proteinTarget: 160,
        carbsTarget: 240,
        fatTarget: 75,
        waterBottles: 4,
        waterTarget: 5,
      );
      return;
    }
    // --- Fin Demo Mode ---

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false, error: 'No autenticado');
        return;
      }

      final dateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      // Load bio profile for targets
      final bioProfile = await _supabase
          .from('bio_profile')
          .select('macro_targets, water_target_ml, bottle_size_ml')
          .eq('user_id', userId)
          .maybeSingle();

      // Load meals for the date
      final mealsResponse = await _supabase
          .from('meal_log')
          .select()
          .eq('user_id', userId)
          .eq('log_date', dateStr)
          .order('created_at');

      // Load daily nutrition summary
      final dailyNutrition = await _supabase
          .from('daily_nutrition')
          .select()
          .eq('user_id', userId)
          .eq('nutrition_date', dateStr)
          .maybeSingle();

      // Parse meals
      final meals = (mealsResponse as List).map((m) => MealEntry(
            id: m['id'],
            mealType: m['meal_type'] ?? 'other',
            description: m['description'],
            kcal: m['kcal'] ?? 0,
            protein: m['protein_g'] ?? 0,
            carbs: m['carbs_g'] ?? 0,
            fat: m['fat_g'] ?? 0,
            imageUrl: m['image_url'],
            loggedAt: DateTime.parse(m['created_at']),
          )).toList();

      // Calculate totals
      int kcal = 0, protein = 0, carbs = 0, fat = 0;
      for (final meal in meals) {
        kcal += meal.kcal;
        protein += meal.protein;
        carbs += meal.carbs;
        fat += meal.fat;
      }

      // Get targets from bio profile
      final macroTargets = bioProfile?['macro_targets'] as Map<String, dynamic>?;
      final waterTargetMl = bioProfile?['water_target_ml'] ?? 3500;
      final bottleSizeMl = bioProfile?['bottle_size_ml'] ?? 700;

      state = state.copyWith(
        isLoading: false,
        meals: meals,
        kcalConsumed: kcal,
        proteinConsumed: protein,
        carbsConsumed: carbs,
        fatConsumed: fat,
        kcalTarget: macroTargets?['kcal'] ?? 2000,
        proteinTarget: macroTargets?['protein_g'] ?? 150,
        carbsTarget: macroTargets?['carbs_g'] ?? 200,
        fatTarget: macroTargets?['fat_g'] ?? 65,
        waterBottles: dailyNutrition?['water_bottles'] ?? 0,
        waterTarget: (waterTargetMl / bottleSizeMl).ceil(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error: ${e.toString()}',
      );
    }
  }

  /// Log a meal
  Future<bool> logMeal({
    required String mealType,
    String? description,
    required int kcal,
    required int protein,
    required int carbs,
    required int fat,
    Uint8List? imageBytes,
    dynamic imageFile, // Accept any type for cross-platform compatibility
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final dateStr = '${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}';

      String? imageUrl;

      // Upload image if provided (imageBytes for web, imageFile for native)
      if (imageBytes != null) {
        final fileName = '$userId/${dateStr}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _supabase.storage.from('meal-photos').uploadBinary(fileName, imageBytes);
        imageUrl = _supabase.storage.from('meal-photos').getPublicUrl(fileName);
      }

      // Insert meal log
      await _supabase.from('meal_log').insert({
        'user_id': userId,
        'log_date': dateStr,
        'meal_type': mealType,
        'description': description,
        'kcal': kcal,
        'protein_g': protein,
        'carbs_g': carbs,
        'fat_g': fat,
        'image_url': imageUrl,
      });

      // Update daily nutrition
      await _supabase.from('daily_nutrition').upsert({
        'user_id': userId,
        'nutrition_date': dateStr,
        'kcal_consumed': state.kcalConsumed + kcal,
        'protein_consumed': state.proteinConsumed + protein,
        'carbs_consumed': state.carbsConsumed + carbs,
        'fat_consumed': state.fatConsumed + fat,
      });

      // Award XP for logging meal
      await _supabase.rpc('add_currency', params: {
        'p_user_id': userId,
        'p_xp': 15,
        'p_coins': 5,
      });

      // Reload data
      await loadNutritionData();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Add a water bottle
  Future<void> addWaterBottle() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final newCount = state.waterBottles + 1;
    final dateStr = '${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}';

    try {
      await _supabase.from('daily_nutrition').upsert({
        'user_id': userId,
        'nutrition_date': dateStr,
        'water_bottles': newCount,
      });

      state = state.copyWith(waterBottles: newCount);

      // Award XP if target reached
      if (newCount == state.waterTarget) {
        await _supabase.rpc('add_currency', params: {
          'p_user_id': userId,
          'p_xp': 10,
          'p_coins': 3,
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  /// Remove a water bottle
  Future<void> removeWaterBottle() async {
    if (state.waterBottles <= 0) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final newCount = state.waterBottles - 1;
    final dateStr = '${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}';

    try {
      await _supabase.from('daily_nutrition').upsert({
        'user_id': userId,
        'nutrition_date': dateStr,
        'water_bottles': newCount,
      });

      state = state.copyWith(waterBottles: newCount);
    } catch (e) {
      // Handle error
    }
  }

  /// Delete a meal
  Future<void> deleteMeal(String mealId) async {
    try {
      await _supabase.from('meal_log').delete().eq('id', mealId);
      await loadNutritionData();
    } catch (e) {
      // Handle error
    }
  }

  /// Change selected date
  void changeDate(DateTime date) {
    loadNutritionData(date);
  }
}
