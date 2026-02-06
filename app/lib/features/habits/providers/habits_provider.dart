import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/habit_models.dart';
import '../../../core/services/demo_mode.dart';
import '../../../core/data/julio_profile_data.dart';

/// State for habits management
class HabitsState {
  final bool isLoading;
  final String? error;
  final List<HabitWithLog> habits;
  final int completedToday;
  final int currentStreak;
  final double weeklyCompletion;

  const HabitsState({
    this.isLoading = false,
    this.error,
    this.habits = const [],
    this.completedToday = 0,
    this.currentStreak = 0,
    this.weeklyCompletion = 0,
  });

  HabitsState copyWith({
    bool? isLoading,
    String? error,
    List<HabitWithLog>? habits,
    int? completedToday,
    int? currentStreak,
    double? weeklyCompletion,
  }) {
    return HabitsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      habits: habits ?? this.habits,
      completedToday: completedToday ?? this.completedToday,
      currentStreak: currentStreak ?? this.currentStreak,
      weeklyCompletion: weeklyCompletion ?? this.weeklyCompletion,
    );
  }
}

/// Provider for habits state management
final habitsProvider =
    StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  return HabitsNotifier();
});

class HabitsNotifier extends StateNotifier<HabitsState> {
  HabitsNotifier() : super(const HabitsState());

  final _supabase = Supabase.instance.client;

  /// Load all habits with today's logs
  Future<void> loadHabits() async {
    state = state.copyWith(isLoading: true, error: null);

    // --- Demo Mode: usar datos reales de Julio ---
    if (demoMode.isActive) {
      await Future.delayed(const Duration(milliseconds: 300));
      final now = DateTime.now();

      // Convertir habitos de JulioHabitsData a HabitWithLog
      final mockHabits = <HabitWithLog>[];
      int index = 0;

      for (var habitData in JulioHabitsData.habitos) {
        final isCompleted = habitData['completadoHoy'] as bool;

        mockHabits.add(HabitWithLog(
          habit: Habit(
            id: habitData['id'] as String,
            userId: 'julio',
            name: habitData['nombre'] as String,
            description: habitData['descripcion'] as String?,
            habitType: 'check_simple',
            frequency: habitData['frecuencia'] as String? ?? 'daily',
            timeOfDay: habitData['horaRecordatorio'] as String?,
            xpValue: 15,
            coinsValue: 5,
            orderIndex: index,
          ),
          todayLog: isCompleted
              ? HabitLog(
                  id: 'log_${habitData['id']}',
                  habitId: habitData['id'] as String,
                  date: now,
                  status: 'done',
                  xpEarned: 15,
                  coinsEarned: 5,
                )
              : null,
        ));
        index++;
      }

      final completedToday = JulioHabitsData.habitosCompletadosHoy;

      state = state.copyWith(
        isLoading: false,
        habits: mockHabits,
        completedToday: completedToday,
        currentStreak: JulioHabitsData.rachaMaxima,
        weeklyCompletion: completedToday / JulioHabitsData.totalHabitos,
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

      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Fetch habits
      final habitsResponse = await _supabase
          .from('habit')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('order_index');

      // Fetch today's logs
      final logsResponse = await _supabase
          .from('habit_log')
          .select()
          .eq('user_id', userId)
          .eq('log_date', dateStr);

      final habits = (habitsResponse as List).map((h) {
        final logs =
            (logsResponse as List).where((l) => l['habit_id'] == h['id']);
        final log = logs.isNotEmpty ? logs.first : null;

        return HabitWithLog(
          habit: Habit(
            id: h['id'],
            userId: h['user_id'],
            name: h['name'],
            description: h['description'],
            habitType: h['habit_type'] ?? 'check_simple',
            targetValue: h['target_value']?.toDouble(),
            unit: h['unit'],
            frequency: h['frequency'] ?? 'daily',
            timeOfDay: h['preferred_time'],
            xpValue: h['xp_reward'] ?? 10,
            coinsValue: h['coins_reward'] ?? 5,
            isActive: h['is_active'] ?? true,
            orderIndex: h['order_index'] ?? 0,
          ),
          todayLog: log != null
              ? HabitLog(
                  id: log['id'],
                  habitId: log['habit_id'],
                  date: DateTime.parse(log['log_date']),
                  status: log['status'] ?? 'pending',
                  value: log['value']?.toDouble(),
                  xpEarned: log['xp_earned'] ?? 0,
                  coinsEarned: log['coins_earned'] ?? 0,
                )
              : null,
        );
      }).toList();

      // Calculate stats
      final completedToday =
          habits.where((h) => h.todayLog?.status == 'done').length;

      // Get streak from streak table
      final streakResponse = await _supabase
          .from('streak')
          .select('current_count')
          .eq('user_id', userId)
          .eq('streak_type', 'streak_light')
          .maybeSingle();

      final currentStreak = streakResponse?['current_count'] ?? 0;

      // Calculate weekly completion (simplified)
      final weeklyCompletion =
          habits.isEmpty ? 0.0 : completedToday / habits.length;

      state = state.copyWith(
        isLoading: false,
        habits: habits,
        completedToday: completedToday,
        currentStreak: currentStreak,
        weeklyCompletion: weeklyCompletion,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error: ${e.toString()}',
      );
    }
  }

  /// Toggle a habit's completion status
  Future<void> toggleHabit(String habitId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final habitIndex = state.habits.indexWhere((h) => h.habit.id == habitId);
    if (habitIndex == -1) return;

    final habit = state.habits[habitIndex];
    final isCurrentlyDone = habit.todayLog?.status == 'done';
    final newStatus = isCurrentlyDone ? 'pending' : 'done';

    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      // Upsert the log
      await _supabase.from('habit_log').upsert({
        'user_id': userId,
        'habit_id': habitId,
        'log_date': dateStr,
        'status': newStatus,
        'value': habit.habit.targetValue ?? 1,
        'xp_earned': isCurrentlyDone ? 0 : habit.habit.xpValue,
        'coins_earned': isCurrentlyDone ? 0 : habit.habit.coinsValue,
        'completed_at':
            isCurrentlyDone ? null : DateTime.now().toIso8601String(),
      });

      // Update local state
      final updatedHabits = List<HabitWithLog>.from(state.habits);
      updatedHabits[habitIndex] = HabitWithLog(
        habit: habit.habit,
        todayLog: HabitLog(
          id: habit.todayLog?.id ?? 'temp',
          habitId: habitId,
          date: today,
          status: newStatus,
          value: habit.habit.targetValue ?? 1,
          xpEarned: isCurrentlyDone ? 0 : habit.habit.xpValue,
          coinsEarned: isCurrentlyDone ? 0 : habit.habit.coinsValue,
        ),
      );

      final completedToday =
          updatedHabits.where((h) => h.todayLog?.status == 'done').length;

      state = state.copyWith(
        habits: updatedHabits,
        completedToday: completedToday,
      );

      // Update currency if completing (not uncompleting)
      if (!isCurrentlyDone) {
        await _supabase.rpc('add_currency', params: {
          'p_user_id': userId,
          'p_xp': habit.habit.xpValue,
          'p_coins': habit.habit.coinsValue,
        });
      }
    } catch (e) {
      // Reload on error
      loadHabits();
    }
  }

  /// Create a new habit
  Future<bool> createHabit({
    required String name,
    String? description,
    required String habitType,
    double? targetValue,
    String? unit,
    String? timeOfDay,
    int xpValue = 10,
    int coinsValue = 5,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _supabase.from('habit').insert({
        'user_id': userId,
        'name': name,
        'description': description,
        'habit_type': habitType,
        'target_value': targetValue,
        'unit': unit,
        'preferred_time': timeOfDay,
        'xp_reward': xpValue,
        'coins_reward': coinsValue,
        'is_active': true,
        'order_index': state.habits.length,
      });

      await loadHabits();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      await _supabase.from('habit').delete().eq('id', habitId);
      await loadHabits();
    } catch (e) {
      // Handle error
    }
  }

  /// Reorder habits
  Future<void> reorderHabits(int oldIndex, int newIndex) async {
    final habits = List<HabitWithLog>.from(state.habits);
    final item = habits.removeAt(oldIndex);
    habits.insert(newIndex, item);

    state = state.copyWith(habits: habits);

    // Update order in database
    for (var i = 0; i < habits.length; i++) {
      await _supabase
          .from('habit')
          .update({'order_index': i}).eq('id', habits[i].habit.id);
    }
  }
}
