import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stats/screens/stats_screen.dart';

// Provider para los habitos
final habitsItemsProvider = StateNotifierProvider<HabitsItemsNotifier, List<HabitItem>>((ref) {
  return HabitsItemsNotifier();
});

// Provider para el día seleccionado del calendario
final selectedDayProvider = StateProvider<int>((ref) => DateTime.now().day);

class HabitItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String area;
  final String? progress;
  final bool hasToggl;
  final bool hasClickUp;
  bool done;

  HabitItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.area,
    this.progress,
    this.hasToggl = false,
    this.hasClickUp = false,
    this.done = false,
  });
}

class HabitsItemsNotifier extends StateNotifier<List<HabitItem>> {
  HabitsItemsNotifier() : super([
    // Salud
    HabitItem(id: '1', name: 'Dormir 7-8 horas', icon: Icons.bedtime, color: Colors.purple, area: 'salud', progress: '7.5/8 hrs', done: true),
    HabitItem(id: '2', name: 'Levantarse 6-7am', icon: Icons.alarm, color: Colors.orange, area: 'salud', progress: '6:45', done: true),
    HabitItem(id: '3', name: 'Ducha fria', icon: Icons.shower, color: Colors.cyan, area: 'salud'),
    HabitItem(id: '4', name: 'Cooper 10 min', icon: Icons.directions_run, color: Colors.green, area: 'salud', progress: '0/10 min'),
    // Productividad
    HabitItem(id: '5', name: 'Deep Work 4hrs', icon: Icons.psychology, color: Colors.blue, area: 'productividad', progress: '2.5/4 hrs', hasToggl: true),
    HabitItem(id: '6', name: 'Revisar ClickUp', icon: Icons.task_alt, color: Colors.pink, area: 'productividad', hasClickUp: true, done: true),
    HabitItem(id: '7', name: 'No redes antes 12pm', icon: Icons.phone_android, color: Colors.red, area: 'productividad'),
    // Bienestar
    HabitItem(id: '8', name: 'Leer 30 min', icon: Icons.menu_book, color: Colors.amber, area: 'bienestar', progress: '35/30 min', done: true),
    HabitItem(id: '9', name: 'Meditar 10 min', icon: Icons.self_improvement, color: Colors.indigo, area: 'bienestar', progress: '0/10 min'),
    HabitItem(id: '10', name: 'Caminar 30 min', icon: Icons.directions_walk, color: Colors.teal, area: 'bienestar', progress: '15/30 min'),
  ]);

  void toggle(String id) {
    state = [
      for (final item in state)
        if (item.id == id)
          HabitItem(
            id: item.id,
            name: item.name,
            icon: item.icon,
            color: item.color,
            area: item.area,
            progress: item.progress,
            hasToggl: item.hasToggl,
            hasClickUp: item.hasClickUp,
            done: !item.done,
          )
        else
          item
    ];
  }
}

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsItemsProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final completedCount = habits.where((h) => h.done).length;
    final totalCount = habits.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    final saludHabits = habits.where((h) => h.area == 'salud').toList();
    final productividadHabits = habits.where((h) => h.area == 'productividad').toList();
    final bienestarHabits = habits.where((h) => h.area == 'bienestar').toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con acceso a estadísticas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Habitos', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StatsScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.bar_chart, color: Color(0xFF6366F1), size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(Icons.local_fire_department, '15', Colors.orange),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Calendar Week Strip (Como IMG_5227/IMG_5228)
              _buildCalendarStrip(ref, selectedDay),

              const SizedBox(height: 16),

              // Streak + Stats Card (Como IMG_5228)
              _buildStreakStatsCard(completedCount, totalCount),

              const SizedBox(height: 16),

              // Progress Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFFB923C)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Progreso de hoy', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            progress >= 0.9 ? 'Casi lo logras!' : progress >= 0.5 ? 'Vas muy bien!' : 'Sigue asi!',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Completados', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                                  Text('$completedCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pendientes', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                                  Text('${totalCount - completedCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Habits List by Category
              _buildCategorySection('Salud', saludHabits, ref, const Color(0xFF10B981)),
              const SizedBox(height: 16),
              _buildCategorySection('Productividad', productividadHabits, ref, const Color(0xFF3B82F6)),
              const SizedBox(height: 16),
              _buildCategorySection('Bienestar', bienestarHabits, ref, const Color(0xFF8B5CF6)),

              const SizedBox(height: 20),

              // Integrations Section
              const Text('Integraciones', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildIntegrationCard('Toggl Track', Icons.timer, Colors.red, '2h 35m', '18h 20m')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildIntegrationCard('ClickUp', Icons.check_box, Colors.purple, '5 pend.', '12 done')),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agregar nuevo habito'), backgroundColor: Color(0xFF6366F1)),
          );
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarStrip(WidgetRef ref, int selectedDay) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final weekDays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    // Generar días de la semana actual
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final day = startOfWeek.add(Duration(days: index));
          final isToday = day.day == now.day && day.month == now.month;
          final isSelected = day.day == selectedDay;
          // Simular días completados (demo)
          final isCompleted = day.day < now.day && day.day > now.day - 5;
          final isMissed = day.day == now.day - 3;

          return GestureDetector(
            onTap: () => ref.read(selectedDayProvider.notifier).state = day.day,
            child: Column(
              children: [
                Text(
                  weekDays[index],
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : isCompleted
                            ? const Color(0xFF10B981).withOpacity(0.2)
                            : isMissed
                                ? Colors.red.withOpacity(0.2)
                                : Colors.transparent,
                    border: isToday && !isSelected
                        ? Border.all(color: const Color(0xFF6366F1), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: isCompleted && !isSelected
                        ? const Icon(Icons.check, color: Color(0xFF10B981), size: 18)
                        : isMissed && !isSelected
                            ? const Icon(Icons.close, color: Colors.red, size: 18)
                            : Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStreakStatsCard(int completed, int total) {
    return Row(
      children: [
        // Racha
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFF97316).withOpacity(0.2), const Color(0xFFF97316).withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF97316).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Color(0xFFF97316), size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('15', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Dias en fila', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Stats
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('21', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Este mes', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                Column(
                  children: [
                    const Text('87', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Total', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(String title, List<HabitItem> habits, WidgetRef ref, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(
              '${habits.where((h) => h.done).length}/${habits.length}',
              style: TextStyle(color: accentColor, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...habits.map((h) => _buildHabitTile(ref, h)),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHabitTile(WidgetRef ref, HabitItem habit) {
    return GestureDetector(
      onTap: () => ref.read(habitsItemsProvider.notifier).toggle(habit.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: habit.done ? habit.color.withOpacity(0.1) : const Color(0xFF1A1A1F),
          borderRadius: BorderRadius.circular(14),
          border: habit.done ? Border.all(color: habit.color.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: habit.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(habit.icon, color: habit.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          habit.name,
                          style: TextStyle(
                            color: habit.done ? Colors.white54 : Colors.white,
                            fontWeight: FontWeight.w500,
                            decoration: habit.done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (habit.hasToggl) _buildIntegrationBadge('Toggl', Colors.red),
                      if (habit.hasClickUp) _buildIntegrationBadge('ClickUp', Colors.purple),
                    ],
                  ),
                  if (habit.progress != null) ...[
                    const SizedBox(height: 4),
                    Text(habit.progress!, style: TextStyle(color: habit.color, fontWeight: FontWeight.w600, fontSize: 11)),
                  ],
                ],
              ),
            ),
            // Skip button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(ref.context).showSnackBar(
                  SnackBar(
                    content: Text('${habit.name} saltado por hoy'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.fast_forward,
                  size: 18,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: habit.done ? habit.color : Colors.transparent,
                border: Border.all(color: habit.done ? habit.color : habit.color.withOpacity(0.4), width: 2),
              ),
              child: habit.done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationBadge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildIntegrationCard(String title, IconData icon, Color color, String stat1, String stat2) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Hoy', style: TextStyle(color: Colors.white38, fontSize: 10)),
              Text(stat1, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Semana', style: TextStyle(color: Colors.white38, fontSize: 10)),
              Text(stat2, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
