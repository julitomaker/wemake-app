import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/habit_models.dart';
import '../../../core/models/user_models.dart';
import '../../../core/services/demo_mode.dart';
import '../../../core/data/julio_profile_data.dart';

// Streak thresholds
const _streakLightThreshold = 0.6;
const _streakPerfectThreshold = 0.9;

/// State for the daily flow
class DailyFlowState {
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;
  final List<DailyFlowItem> items;
  final DailyScore? dailyScore;
  final Currency? currency;
  final Streak? streakLight;
  final Streak? streakPerfect;
  final int waterBottlesConsumed;
  final int waterBottlesTarget;
  final int kcalConsumed;
  final int kcalTarget;
  final int proteinConsumed;
  final int proteinTarget;

  const DailyFlowState({
    this.isLoading = false,
    this.error,
    required this.selectedDate,
    this.items = const [],
    this.dailyScore,
    this.currency,
    this.streakLight,
    this.streakPerfect,
    this.waterBottlesConsumed = 0,
    this.waterBottlesTarget = 5,
    this.kcalConsumed = 0,
    this.kcalTarget = 2000,
    this.proteinConsumed = 0,
    this.proteinTarget = 150,
  });

  DailyFlowState copyWith({
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    List<DailyFlowItem>? items,
    DailyScore? dailyScore,
    Currency? currency,
    Streak? streakLight,
    Streak? streakPerfect,
    int? waterBottlesConsumed,
    int? waterBottlesTarget,
    int? kcalConsumed,
    int? kcalTarget,
    int? proteinConsumed,
    int? proteinTarget,
  }) {
    return DailyFlowState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
      items: items ?? this.items,
      dailyScore: dailyScore ?? this.dailyScore,
      currency: currency ?? this.currency,
      streakLight: streakLight ?? this.streakLight,
      streakPerfect: streakPerfect ?? this.streakPerfect,
      waterBottlesConsumed: waterBottlesConsumed ?? this.waterBottlesConsumed,
      waterBottlesTarget: waterBottlesTarget ?? this.waterBottlesTarget,
      kcalConsumed: kcalConsumed ?? this.kcalConsumed,
      kcalTarget: kcalTarget ?? this.kcalTarget,
      proteinConsumed: proteinConsumed ?? this.proteinConsumed,
      proteinTarget: proteinTarget ?? this.proteinTarget,
    );
  }

  double get completionPercentage {
    if (items.isEmpty) return 0;
    final completed = items.where((i) => i.isCompleted).length;
    return completed / items.length;
  }

  bool get hasLightStreak => completionPercentage >= _streakLightThreshold;
  bool get hasPerfectStreak => completionPercentage >= _streakPerfectThreshold;
}

/// Provider for daily flow state management
final dailyFlowProvider =
    StateNotifierProvider<DailyFlowNotifier, DailyFlowState>((ref) {
  return DailyFlowNotifier();
});

class DailyFlowNotifier extends StateNotifier<DailyFlowState> {
  DailyFlowNotifier()
      : super(DailyFlowState(selectedDate: DateTime.now()));

  final _supabase = Supabase.instance.client;

  /// Load today's flow data
  Future<void> loadTodayFlow() async {
    state = state.copyWith(isLoading: true, error: null);

    // Demo mode: load mock data
    if (demoMode.isActive) {
      await _loadDemoData();
      return;
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false, error: 'No autenticado');
        return;
      }

      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Fetch multiple data sources in parallel
      final results = await Future.wait([
        _loadHabits(userId, dateStr),
        _loadDailyScore(userId, dateStr),
        _loadCurrency(userId),
        _loadStreaks(userId),
        _loadNutritionSummary(userId, dateStr),
        _loadBioProfile(userId),
      ]);

      final habits = results[0] as List<DailyFlowItem>;
      final dailyScore = results[1] as DailyScore?;
      final currency = results[2] as Currency?;
      final streaks = results[3] as List<Streak>;
      final nutritionData = results[4] as Map<String, dynamic>;
      final bioProfile = results[5] as Map<String, dynamic>?;

      // Build flow items (habits + scheduled meals + workouts)
      final flowItems = _buildFlowItems(habits);

      state = state.copyWith(
        isLoading: false,
        selectedDate: today,
        items: flowItems,
        dailyScore: dailyScore,
        currency: currency,
        streakLight: streaks.firstWhere(
          (s) => s.streakType == StreakType.streakLight,
          orElse: () => const Streak(streakType: StreakType.streakLight),
        ),
        streakPerfect: streaks.firstWhere(
          (s) => s.streakType == StreakType.streakPerfect,
          orElse: () => const Streak(streakType: StreakType.streakPerfect),
        ),
        waterBottlesConsumed: nutritionData['waterBottles'] ?? 0,
        waterBottlesTarget: (bioProfile?['water_target_ml'] ?? 3500) ~/
            (bioProfile?['bottle_size_ml'] ?? 700),
        kcalConsumed: nutritionData['kcal'] ?? 0,
        kcalTarget: bioProfile?['macro_targets']?['kcal'] ?? 2000,
        proteinConsumed: nutritionData['protein'] ?? 0,
        proteinTarget: bioProfile?['macro_targets']?['protein_g'] ?? 150,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error: ${e.toString()}',
      );
    }
  }

  Future<List<DailyFlowItem>> _loadHabits(String userId, String dateStr) async {
    try {
      // Get user's habits
      final habitsResponse = await _supabase
          .from('habit')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true);

      // Get today's logs
      final logsResponse = await _supabase
          .from('habit_log')
          .select()
          .eq('user_id', userId)
          .eq('log_date', dateStr);

      final habits = (habitsResponse as List).map((h) {
        final logs = (logsResponse as List).where((l) => l['habit_id'] == h['id']);
        final log = logs.isNotEmpty ? logs.first : null;

        return DailyFlowItem(
          id: h['id'],
          type: DailyFlowItemType.habit,
          title: h['name'],
          subtitle: h['description'],
          scheduledTime: h['preferred_time'] != null
              ? DateTime.tryParse('2024-01-01 ${h['preferred_time']}')
              : null,
          isCompleted: log != null && log['status'] == 'completed',
          xpReward: h['xp_reward'] ?? 10,
          habitType: _parseHabitType(h['habit_type']),
          currentValue: log?['value']?.toDouble(),
          targetValue: h['target_value']?.toDouble(),
        );
      }).toList();

      return habits;
    } catch (e) {
      return [];
    }
  }

  Future<DailyScore?> _loadDailyScore(String userId, String dateStr) async {
    try {
      final response = await _supabase
          .from('daily_score')
          .select()
          .eq('user_id', userId)
          .eq('score_date', dateStr)
          .maybeSingle();

      if (response == null) return null;

      return DailyScore(
        id: response['id'],
        scoreDate: DateTime.parse(response['score_date']),
        totalXp: response['total_xp'] ?? 0,
        habitsPct: (response['habits_pct'] ?? 0).toDouble(),
        nutritionPct: (response['nutrition_pct'] ?? 0).toDouble(),
        trainingPct: (response['training_pct'] ?? 0).toDouble(),
        productivityPct: (response['productivity_pct'] ?? 0).toDouble(),
        hydrationPct: (response['hydration_pct'] ?? 0).toDouble(),
        overallPct: (response['overall_pct'] ?? 0).toDouble(),
        streakLightMet: response['streak_light_met'] ?? false,
        streakPerfectMet: response['streak_perfect_met'] ?? false,
      );
    } catch (e) {
      return null;
    }
  }

  Future<Currency?> _loadCurrency(String userId) async {
    try {
      final response = await _supabase
          .from('currency')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return Currency(
        xpTotal: response['xp_total'] ?? 0,
        xpWeekly: response['xp_weekly'] ?? 0,
        coinsBalance: response['coins_balance'] ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Streak>> _loadStreaks(String userId) async {
    try {
      final response = await _supabase
          .from('streak')
          .select()
          .eq('user_id', userId);

      return (response as List).map((s) {
        return Streak(
          streakType: s['streak_type'] == 'streak_light'
              ? StreakType.streakLight
              : StreakType.streakPerfect,
          currentCount: s['current_count'] ?? 0,
          longestCount: s['longest_count'] ?? 0,
          freezeAvailable: s['freeze_available'] ?? 0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> _loadNutritionSummary(
      String userId, String dateStr) async {
    try {
      final response = await _supabase
          .from('daily_nutrition')
          .select()
          .eq('user_id', userId)
          .eq('nutrition_date', dateStr)
          .maybeSingle();

      if (response == null) {
        return {'waterBottles': 0, 'kcal': 0, 'protein': 0};
      }

      return {
        'waterBottles': response['water_bottles'] ?? 0,
        'kcal': response['kcal_consumed'] ?? 0,
        'protein': response['protein_consumed'] ?? 0,
      };
    } catch (e) {
      return {'waterBottles': 0, 'kcal': 0, 'protein': 0};
    }
  }

  Future<Map<String, dynamic>?> _loadBioProfile(String userId) async {
    try {
      final response = await _supabase
          .from('bio_profile')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  List<DailyFlowItem> _buildFlowItems(List<DailyFlowItem> habits) {
    // Add default meal items
    final mealItems = [
      DailyFlowItem(
        id: 'meal_breakfast',
        type: DailyFlowItemType.meal,
        title: 'Desayuno',
        scheduledTime: DateTime(2024, 1, 1, 8, 0),
        isCompleted: false,
        xpReward: 15,
      ),
      DailyFlowItem(
        id: 'meal_lunch',
        type: DailyFlowItemType.meal,
        title: 'Almuerzo',
        scheduledTime: DateTime(2024, 1, 1, 13, 0),
        isCompleted: false,
        xpReward: 15,
      ),
      DailyFlowItem(
        id: 'meal_dinner',
        type: DailyFlowItemType.meal,
        title: 'Cena',
        scheduledTime: DateTime(2024, 1, 1, 20, 0),
        isCompleted: false,
        xpReward: 15,
      ),
    ];

    // Combine and sort by scheduled time
    final allItems = [...habits, ...mealItems];
    allItems.sort((a, b) {
      if (a.scheduledTime == null && b.scheduledTime == null) return 0;
      if (a.scheduledTime == null) return 1;
      if (b.scheduledTime == null) return -1;
      return a.scheduledTime!.compareTo(b.scheduledTime!);
    });

    return allItems;
  }

  HabitType _parseHabitType(String? type) {
    switch (type) {
      case 'boolean':
        return HabitType.boolean;
      case 'counter':
        return HabitType.counter;
      case 'timer':
        return HabitType.timer;
      default:
        return HabitType.boolean;
    }
  }

  /// Mark a flow item as completed
  Future<void> completeItem(String itemId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final item = state.items.firstWhere((i) => i.id == itemId);

    if (item.type == DailyFlowItemType.habit) {
      final dateStr = '${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}';

      await _supabase.from('habit_log').upsert({
        'user_id': userId,
        'habit_id': itemId,
        'log_date': dateStr,
        'status': 'completed',
        'value': item.targetValue ?? 1,
        'completed_at': DateTime.now().toIso8601String(),
      });
    }

    // Update local state
    final updatedItems = state.items.map((i) {
      if (i.id == itemId) {
        return i.copyWith(isCompleted: true);
      }
      return i;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  /// Add water bottle
  Future<void> addWaterBottle() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final newCount = state.waterBottlesConsumed + 1;
    final dateStr = '${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}';

    await _supabase.from('daily_nutrition').upsert({
      'user_id': userId,
      'nutrition_date': dateStr,
      'water_bottles': newCount,
    });

    state = state.copyWith(waterBottlesConsumed: newCount);
  }

  /// Change selected date
  void changeDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    loadTodayFlow();
  }

  /// Load demo/mock data - Datos reales de Julio
  Future<void> _loadDemoData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final diaSemana = now.weekday;
    final esDiaEntreno = JulioTrainingData.esDiaDeEntreno(diaSemana);
    final rutinaHoy = JulioTrainingData.getNombreRutinaDelDia(diaSemana);

    // Construir items del flujo diario basados en datos reales de Julio
    final mockItems = <DailyFlowItem>[];

    // Habitos de Julio
    for (var habito in JulioHabitsData.habitos) {
      final hora = habito['horaRecordatorio'] as String?;
      int horaInt = 8;
      if (hora != null) {
        horaInt = int.tryParse(hora.split(':')[0]) ?? 8;
      }

      mockItems.add(DailyFlowItem(
        id: habito['id'] as String,
        type: DailyFlowItemType.habit,
        title: habito['nombre'] as String,
        subtitle: habito['descripcion'] as String?,
        scheduledTime: DateTime(now.year, now.month, now.day, horaInt, 0),
        isCompleted: habito['completadoHoy'] as bool,
        xpReward: 15,
        habitType: HabitType.boolean,
      ));
    }

    // Comidas de Julio
    for (var comida in JulioNutritionData.planComidas) {
      final hora = comida['hora'] as String;
      final horaInt = int.tryParse(hora.split(':')[0]) ?? 12;

      mockItems.add(DailyFlowItem(
        id: 'meal_${comida['nombre'].toString().toLowerCase().replaceAll(' ', '_').replaceAll('-', '')}',
        type: DailyFlowItemType.meal,
        title: comida['nombre'] as String,
        subtitle: '${comida['totalCalorias']} kcal | ${comida['totalProteina']}g prot',
        scheduledTime: DateTime(now.year, now.month, now.day, horaInt, 0),
        isCompleted: comida['completado'] as bool? ?? false,
        xpReward: 15,
      ));
    }

    // Entrenamiento de hoy si corresponde
    if (esDiaEntreno) {
      mockItems.add(DailyFlowItem(
        id: 'workout_today',
        type: DailyFlowItemType.workout,
        title: rutinaHoy,
        subtitle: 'Upper/Lower Power - ~70 min',
        scheduledTime: DateTime(now.year, now.month, now.day, 16, 0),
        isCompleted: false,
        xpReward: 150,
      ));
    }

    // Ordenar por hora
    mockItems.sort((a, b) {
      if (a.scheduledTime == null && b.scheduledTime == null) return 0;
      if (a.scheduledTime == null) return 1;
      if (b.scheduledTime == null) return -1;
      return a.scheduledTime!.compareTo(b.scheduledTime!);
    });

    // Calcular calorias y proteina consumidas de comidas completadas
    int kcalConsumidas = 0;
    int protConsumidas = 0;
    for (var comida in JulioNutritionData.planComidas) {
      if (comida['completado'] == true) {
        kcalConsumidas += comida['totalCalorias'] as int;
        protConsumidas += comida['totalProteina'] as int;
      }
    }

    state = state.copyWith(
      isLoading: false,
      selectedDate: now,
      items: mockItems,
      dailyScore: DailyScore(
        id: 'julio',
        scoreDate: now,
        totalXp: 235,
        habitsPct: JulioHabitsData.habitosCompletadosHoy / JulioHabitsData.totalHabitos,
        nutritionPct: kcalConsumidas / JulioNutritionData.caloriasObjetivo,
        trainingPct: 0.0,
        productivityPct: 0.7,
        hydrationPct: 0.6,
        overallPct: 0.45,
        streakLightMet: true,
        streakPerfectMet: false,
      ),
      currency: const Currency(
        xpTotal: 3850,
        xpWeekly: 485,
        coinsBalance: 215,
      ),
      streakLight: const Streak(
        streakType: StreakType.streakLight,
        currentCount: 15,
        longestCount: 28,
        freezeAvailable: 2,
      ),
      streakPerfect: const Streak(
        streakType: StreakType.streakPerfect,
        currentCount: 3,
        longestCount: 7,
        freezeAvailable: 1,
      ),
      waterBottlesConsumed: 3,
      waterBottlesTarget: 5,
      kcalConsumed: kcalConsumidas,
      kcalTarget: JulioNutritionData.caloriasObjetivo,
      proteinConsumed: protConsumidas,
      proteinTarget: JulioNutritionData.proteinaObjetivo,
    );
  }
}
