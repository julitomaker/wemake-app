import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../gamification/screens/badges_screen.dart';

/// Provider para estadísticas del usuario
final userStatsProvider = StateProvider<UserStats>((ref) => UserStats.demo());

class UserStats {
  final int strengthScore;
  final String strengthLevel;
  final int currentStreak;
  final int longestStreak;
  final String bestMonth;
  final double completionRate;
  final int totalWorkouts;
  final List<double> weeklyPerformance;
  final List<StrengthHistory> strengthHistory;
  final Map<String, int> muscleStrength;

  UserStats({
    required this.strengthScore,
    required this.strengthLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.bestMonth,
    required this.completionRate,
    required this.totalWorkouts,
    required this.weeklyPerformance,
    required this.strengthHistory,
    required this.muscleStrength,
  });

  factory UserStats.demo() {
    return UserStats(
      strengthScore: 240,
      strengthLevel: 'Atleta',
      currentStreak: 15,
      longestStreak: 23,
      bestMonth: 'Enero',
      completionRate: 0.75,
      totalWorkouts: 87,
      weeklyPerformance: [10, 45, 60, 50, 60, 70, 75],
      strengthHistory: [
        StrengthHistory('Ene', 210),
        StrengthHistory('Feb', 215),
        StrengthHistory('Mar', 220),
        StrengthHistory('Abr', 225),
        StrengthHistory('May', 230),
        StrengthHistory('Jun', 235),
        StrengthHistory('Jul', 240),
      ],
      muscleStrength: {
        'Pectorales': 253,
        'Espalda': 217,
        'Hombros': 195,
        'Biceps': 142,
        'Triceps': 156,
        'Piernas': 289,
        'Core': 178,
      },
    );
  }
}

class StrengthHistory {
  final String month;
  final int score;
  StrengthHistory(this.month, this.score);
}

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estadisticas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BadgesScreen()),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8FF00).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Color(0xFFB8FF00),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Tab selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Resumen',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            'Habitos',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Strength Score Card (Como IMG_5237)
              _buildStrengthScoreCard(stats),

              const SizedBox(height: 20),

              // Highlighted Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildHighlightCard(
                      icon: Icons.local_fire_department,
                      value: '${stats.currentStreak}',
                      label: 'Racha actual',
                      color: const Color(0xFF3B82F6),
                      suffix: ' Dias',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHighlightCard(
                      icon: Icons.rocket_launch,
                      value: '${stats.longestStreak}',
                      label: 'Racha mas larga',
                      color: const Color(0xFFEC4899),
                      suffix: ' Dias',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildHighlightCard(
                      icon: Icons.star,
                      value: stats.bestMonth,
                      label: 'Mejor mes',
                      color: const Color(0xFF8B5CF6),
                      suffix: '',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHighlightCard(
                      icon: Icons.percent,
                      value: '${(stats.completionRate * 100).toInt()}%',
                      label: '% completado',
                      color: const Color(0xFFF97316),
                      suffix: '',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Weekly Performance Chart
              _buildWeeklyChart(stats.weeklyPerformance),

              const SizedBox(height: 20),

              // Streaks Section (Como IMG_5226)
              _buildStreaksSection(stats),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthScoreCard(UserStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Puntaje de Fuerza',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Circular score
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: StrengthCirclePainter(
                      progress: stats.strengthScore / 300,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${stats.strengthScore}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stats.strengthLevel,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (stats.strengthScore / 300 * 100).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - (stats.strengthScore / 300 * 100).toInt(),
                  child: const SizedBox(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('200', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              Text('250', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          ),

          const SizedBox(height: 20),

          // Strength History Chart
          const Text(
            'Historial de Fuerza',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // Time range selector
          Row(
            children: [
              _buildTimeChip('Mes', false),
              const SizedBox(width: 8),
              _buildTimeChip('6 meses', true),
              const SizedBox(width: 8),
              _buildTimeChip('Año', false),
              const SizedBox(width: 8),
              _buildTimeChip('Total', false),
            ],
          ),

          const SizedBox(height: 16),

          // Line chart
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: StrengthChartPainter(stats.strengthHistory),
            ),
          ),

          const SizedBox(height: 20),

          // Muscle strength breakdown
          const Text(
            'Fuerza por Musculo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          ...stats.muscleStrength.entries.take(4).map((e) => _buildMuscleRow(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2A2A30) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMuscleRow(String muscle, int score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white54, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              muscle,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.5)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$score',
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: suffix,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(List<double> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rendimiento Semanal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${data.last.toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 24,
                            height: (data[i] / 100) * 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6366F1),
                                  const Color(0xFF8B5CF6).withOpacity(0.5),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        days[i],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksSection(UserStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF97316).withOpacity(0.2),
            const Color(0xFFF97316).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF97316).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rachas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Mostrar mas >',
                style: TextStyle(
                  color: const Color(0xFFF97316),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFF97316).withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.local_fire_department,
                      size: 60,
                      color: Color(0xFFF97316),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.currentStreak} dias',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Racha actual',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for strength circle
class StrengthCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  StrengthCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for strength history chart
class StrengthChartPainter extends CustomPainter {
  final List<StrengthHistory> data;

  StrengthChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minScore = data.map((e) => e.score).reduce(math.min).toDouble() - 10;
    final maxScore = data.map((e) => e.score).reduce(math.max).toDouble() + 10;
    final range = maxScore - minScore;

    // Points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].score - minScore) / range) * size.height;
      points.add(Offset(x, y));
    }

    // Draw line
    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw trend line
    final trendPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height - ((data.first.score - minScore) / range) * size.height),
      Offset(size.width, size.height - ((data.last.score - minScore) / range) * size.height),
      trendPaint,
    );

    // Draw points
    final pointPaint = Paint()..color = Colors.white;
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
