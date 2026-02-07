import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/data/julio_profile_data.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../gamification/screens/badges_screen.dart';
import '../../stats/screens/stats_screen.dart';

// Provider para los items del dia
final homeItemsProvider = StateNotifierProvider<HomeItemsNotifier, List<HomeItem>>((ref) {
  return HomeItemsNotifier();
});

class HomeItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final int xp;
  bool done;

  HomeItem({required this.id, required this.title, required this.icon, required this.color, this.xp = 15, this.done = false});
}

class HomeItemsNotifier extends StateNotifier<List<HomeItem>> {
  HomeItemsNotifier() : super([
    HomeItem(id: '1', title: 'Tomar creatina', icon: Icons.fitness_center, color: Colors.purple, done: true),
    HomeItem(id: '2', title: 'Tomar maca', icon: Icons.eco, color: Colors.green, done: true),
    HomeItem(id: '3', title: 'Caminata al gym', icon: Icons.directions_walk, color: Colors.orange),
    HomeItem(id: '4', title: 'Registrar comidas', icon: Icons.restaurant, color: Colors.pink),
    HomeItem(id: '5', title: 'Hidratacion 2.5L', icon: Icons.water_drop, color: Colors.cyan),
    HomeItem(id: '6', title: 'Dormir 7-8 horas', icon: Icons.bedtime, color: Colors.indigo),
  ]);

  void toggle(String id) {
    state = [
      for (final item in state)
        if (item.id == id)
          HomeItem(id: item.id, title: item.title, icon: item.icon, color: item.color, xp: item.xp, done: !item.done)
        else
          item
    ];
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hora = DateTime.now().hour;
    final saludo = hora < 12 ? 'Buenos dias' : hora < 18 ? 'Buenas tardes' : 'Buenas noches';
    final items = ref.watch(homeItemsProvider);
    final completedCount = items.where((i) => i.done).length;
    final totalCount = items.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    final sections = <Widget>[
      _buildHeader(context, saludo),
      _buildScoreCard(progress),
      _buildQuickStats(),
      _buildAreasSection(context, completedCount, totalCount),
      _buildBodyProgress(),
      _buildTasksSection(ref, items, completedCount, totalCount),
      const SizedBox(height: 100),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections
                .asMap()
                .entries
                .map((entry) => entry.value
                    .animate(delay: (entry.key * 80).ms)
                    .fadeIn(duration: 420.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOut))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String saludo) {
    return Row(
      children: [
        GlassContainer(
          radius: 16,
          padding: EdgeInsets.zero,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.brandGlow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('J', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$saludo, Julio', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Make Today Count', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BadgesScreen()));
              },
              child: GlassContainer(
                radius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('${JulioProfileData.xpTotal}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
              },
              child: GlassContainer(
                radius: 12,
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF6366F1), size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCard(double progress) {
    return GlassContainer(
      radius: 24,
      padding: const EdgeInsets.all(20),
      gradient: AppTheme.brandGlow,
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (rect) => AppTheme.scoreRingGradient.createShader(rect),
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}',
                  style: AppTheme.numberDisplaySmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Score del dia', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildProgressRow('Nutricion', 0.85),
                _buildProgressRow('Sueno', 0.94),
                _buildProgressRow('Actividad', 0.70),
                _buildProgressRow('Habitos', progress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.local_fire_department, '${JulioProfileData.rachaActual}', 'Racha', Colors.orange)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard(Icons.restaurant, '1850', 'kcal', Colors.green)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard(Icons.water_drop, '2.1L', 'Agua', Colors.cyan)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard(Icons.directions_walk, '6.5k', 'Pasos', Colors.purple)),
      ],
    );
  }

  Widget _buildAreasSection(BuildContext context, int completedCount, int totalCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Areas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Hero(
                tag: 'nutrition-hero',
                child: _buildAreaCard(context, Icons.restaurant, 'Nutricion', '1850', '/ 3000 kcal', Colors.green, '/nutrition'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildAreaCard(context, Icons.fitness_center, 'Entreno', 'Upper A', 'Fuerza', Colors.blue, '/training')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildAreaCard(context, Icons.bedtime, 'Sueno', '7.5h', 'Calidad: 85%', Colors.purple, '/habits')),
            const SizedBox(width: 12),
            Expanded(child: _buildAreaCard(context, Icons.check_circle, 'Habitos', '$completedCount/$totalCount', 'completados', Colors.orange, '/habits')),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyProgress() {
    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Progreso corporal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildBodyStat('Peso', '${JulioProfileData.pesoActual} kg', '+2.5 kg')),
              Expanded(child: _buildBodyStat('Grasa', '${JulioProfileData.grasaCorporal}%', 'Meta: 12%')),
              Expanded(child: _buildBodyStat('Musculo', '${JulioProfileData.masaMuscularEsqueletica.toStringAsFixed(1)} kg', '+1.2 kg')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(WidgetRef ref, List<HomeItem> items, int completedCount, int totalCount) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tu dia', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            GlassContainer(
              radius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text('$completedCount/$totalCount', style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildTaskItem(ref, item)),
      ],
    );
  }

  Widget _buildProgressRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11))),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(value * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return GlassContainer(
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: AppTheme.numberDisplaySmall.copyWith(color: Colors.white, fontSize: 15)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildAreaCard(BuildContext context, IconData icon, String title, String value, String subtitle, Color color, String route) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: GlassContainer(
        radius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 22),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 14),
              ],
            ),
            const SizedBox(height: 14),
            Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: AppTheme.numberDisplaySmall.copyWith(color: Colors.white)),
            Text(subtitle, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyStat(String label, String value, String change) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
        const SizedBox(height: 6),
        Text(value, style: AppTheme.numberDisplaySmall.copyWith(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 4),
        Text(change, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTaskItem(WidgetRef ref, HomeItem item) {
    return GestureDetector(
      onTap: () => ref.read(homeItemsProvider.notifier).toggle(item.id),
      child: GlassContainer(
        radius: 14,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        gradient: item.done
            ? LinearGradient(
                colors: [item.color.withOpacity(0.18), item.color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: item.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: item.done ? Colors.white54 : Colors.white,
                  fontWeight: FontWeight.w500,
                  decoration: item.done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text('+${item.xp}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.done ? item.color : Colors.transparent,
                border: Border.all(color: item.done ? item.color : item.color.withOpacity(0.4), width: 2),
              ),
              child: item.done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}
