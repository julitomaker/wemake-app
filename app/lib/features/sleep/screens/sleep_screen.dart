import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../../core/data/julio_profile_data.dart';

class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({super.key});

  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends ConsumerState<SleepScreen> {
  String _selectedPeriod = 'semana';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _SleepHeader(),
            ),

            // Card de sueño de anoche
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _LastNightCard(),
              ),
            ),

            // Gráfico de sueño
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SleepChart(
                  selectedPeriod: _selectedPeriod,
                  onPeriodChanged: (period) {
                    setState(() => _selectedPeriod = period);
                  },
                ),
              ),
            ),

            // Stats de sueño
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _SleepStatsGrid(),
              ),
            ),

            // Insights y recomendaciones
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SleepInsights(),
              ),
            ),

            // Configuración de sueño
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _SleepSettings(),
              ),
            ),

            // Espacio final
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogSleepDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
    );
  }

  void _showLogSleepDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _LogSleepSheet(),
    );
  }
}

// ========== HEADER ==========

class _SleepHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sueno',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tu recuperacion es clave',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              // Sleep score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.indigo],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bedtime, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '85',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      ' /100',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ========== LAST NIGHT CARD ==========

class _LastNightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Datos de demo
    final sleepData = _SleepData(
      bedTime: const TimeOfDay(hour: 23, minute: 15),
      wakeTime: const TimeOfDay(hour: 6, minute: 45),
      totalHours: 7.5,
      deepSleepHours: 2.3,
      remSleepHours: 1.8,
      lightSleepHours: 3.4,
      awakenings: 2,
      quality: 85,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade700,
            Colors.purple.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Anoche',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      sleepData.quality >= 80 ? Icons.thumb_up : Icons.thumb_down,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sleepData.quality >= 80 ? 'Bueno' : 'Mejorable',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tiempo total
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${sleepData.totalHours.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'horas',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              // Horarios
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _TimeRow(
                    icon: Icons.bedtime,
                    time: '${sleepData.bedTime.hour}:${sleepData.bedTime.minute.toString().padLeft(2, '0')}',
                    label: 'Dormi',
                  ),
                  const SizedBox(height: 4),
                  _TimeRow(
                    icon: Icons.wb_sunny,
                    time: '${sleepData.wakeTime.hour}:${sleepData.wakeTime.minute.toString().padLeft(2, '0')}',
                    label: 'Desperte',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Sleep stages bar
          _SleepStagesBar(
            deepHours: sleepData.deepSleepHours,
            remHours: sleepData.remSleepHours,
            lightHours: sleepData.lightSleepHours,
            totalHours: sleepData.totalHours,
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StageLegend(
                color: Colors.indigo.shade300,
                label: 'Profundo',
                hours: sleepData.deepSleepHours,
              ),
              _StageLegend(
                color: Colors.purple.shade300,
                label: 'REM',
                hours: sleepData.remSleepHours,
              ),
              _StageLegend(
                color: Colors.blue.shade200,
                label: 'Ligero',
                hours: sleepData.lightSleepHours,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final IconData icon;
  final String time;
  final String label;

  const _TimeRow({
    required this.icon,
    required this.time,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 14),
        const SizedBox(width: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _SleepStagesBar extends StatelessWidget {
  final double deepHours;
  final double remHours;
  final double lightHours;
  final double totalHours;

  const _SleepStagesBar({
    required this.deepHours,
    required this.remHours,
    required this.lightHours,
    required this.totalHours,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            Expanded(
              flex: (deepHours / totalHours * 100).round(),
              child: Container(color: Colors.indigo.shade300),
            ),
            Expanded(
              flex: (remHours / totalHours * 100).round(),
              child: Container(color: Colors.purple.shade300),
            ),
            Expanded(
              flex: (lightHours / totalHours * 100).round(),
              child: Container(color: Colors.blue.shade200),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageLegend extends StatelessWidget {
  final Color color;
  final String label;
  final double hours;

  const _StageLegend({
    required this.color,
    required this.label,
    required this.hours,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
            Text(
              '${hours.toStringAsFixed(1)}h',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SleepData {
  final TimeOfDay bedTime;
  final TimeOfDay wakeTime;
  final double totalHours;
  final double deepSleepHours;
  final double remSleepHours;
  final double lightSleepHours;
  final int awakenings;
  final int quality;

  _SleepData({
    required this.bedTime,
    required this.wakeTime,
    required this.totalHours,
    required this.deepSleepHours,
    required this.remSleepHours,
    required this.lightSleepHours,
    required this.awakenings,
    required this.quality,
  });
}

// ========== SLEEP CHART ==========

class _SleepChart extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const _SleepChart({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Datos de demo para la semana
    final weekData = [
      _DaySleep('L', 7.2, 80),
      _DaySleep('M', 6.5, 65),
      _DaySleep('X', 7.8, 88),
      _DaySleep('J', 7.0, 75),
      _DaySleep('V', 6.0, 55),
      _DaySleep('S', 8.5, 92),
      _DaySleep('D', 7.5, 85),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historial',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Period selector
              Row(
                children: [
                  _PeriodButton(
                    label: '7D',
                    isSelected: selectedPeriod == 'semana',
                    onTap: () => onPeriodChanged('semana'),
                  ),
                  const SizedBox(width: 6),
                  _PeriodButton(
                    label: '30D',
                    isSelected: selectedPeriod == 'mes',
                    onTap: () => onPeriodChanged('mes'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekData.map((day) {
                final heightPct = (day.hours / 10).clamp(0.0, 1.0);
                final color = day.quality >= 80
                    ? Colors.green
                    : day.quality >= 60
                        ? Colors.orange
                        : Colors.red;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${day.hours.toStringAsFixed(1)}h',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 100 * heightPct,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          day.day,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Target line info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 2,
                color: Colors.purple,
              ),
              const SizedBox(width: 6),
              Text(
                'Objetivo: 7-8 horas',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DaySleep {
  final String day;
  final double hours;
  final int quality;

  _DaySleep(this.day, this.hours, this.quality);
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ========== SLEEP STATS GRID ==========

class _SleepStatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Promedio semanal',
                value: '7.2h',
                icon: Icons.access_time,
                color: Colors.purple,
                trend: '+0.3h',
                trendPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Consistencia',
                value: '85%',
                icon: Icons.repeat,
                color: Colors.green,
                trend: '+5%',
                trendPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Hora promedio dormir',
                value: '23:15',
                icon: Icons.bedtime,
                color: Colors.indigo,
                trend: null,
                trendPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Hora promedio despertar',
                value: '06:45',
                icon: Icons.wb_sunny,
                color: Colors.orange,
                trend: null,
                trendPositive: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool trendPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendPositive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (trendPositive ? Colors.green : Colors.red)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trend!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: trendPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== SLEEP INSIGHTS ==========

class _SleepInsights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final insights = [
      _InsightData(
        icon: Icons.lightbulb,
        title: 'Sueno profundo bajo',
        description: 'Tu sueno profundo esta 15% debajo del objetivo. Intenta evitar cafeina despues de las 2pm.',
        color: Colors.orange,
      ),
      _InsightData(
        icon: Icons.trending_up,
        title: 'Mejora en consistencia',
        description: 'Llevas 5 dias durmiendo a la misma hora. Esto mejora tu ritmo circadiano!',
        color: Colors.green,
      ),
      _InsightData(
        icon: Icons.fitness_center,
        title: 'Correlacion con entreno',
        description: 'Los dias que entrenas duermes 30min mas en promedio.',
        color: Colors.blue,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Insights',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map((insight) => _InsightTile(insight: insight)),
        ],
      ),
    );
  }
}

class _InsightData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _InsightData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _InsightTile extends StatelessWidget {
  final _InsightData insight;

  const _InsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(insight.icon, color: insight.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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

// ========== SLEEP SETTINGS ==========

class _SleepSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Configuracion',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingRow(
            icon: Icons.access_time,
            title: 'Objetivo de sueno',
            value: '7-8 horas',
            onTap: () {},
          ),
          _SettingRow(
            icon: Icons.alarm,
            title: 'Recordatorio para dormir',
            value: '22:30',
            onTap: () {},
          ),
          _SettingRow(
            icon: Icons.watch,
            title: 'Sincronizar con Apple Watch',
            value: 'Conectado',
            onTap: () {},
            valueColor: Colors.green,
          ),
          _SettingRow(
            icon: Icons.notifications,
            title: 'Notificaciones',
            value: 'Activadas',
            onTap: () {},
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final Color? valueColor;
  final bool showDivider;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.valueColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: valueColor ?? theme.colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: valueColor != null ? FontWeight.w600 : null,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
      ],
    );
  }
}

// ========== LOG SLEEP SHEET ==========

class _LogSleepSheet extends StatefulWidget {
  @override
  State<_LogSleepSheet> createState() => _LogSleepSheetState();
}

class _LogSleepSheetState extends State<_LogSleepSheet> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _quality = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registrar sueno',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Bed time
          _TimeSelector(
            label: 'Me dormi a las',
            icon: Icons.bedtime,
            time: _bedTime,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _bedTime,
              );
              if (picked != null) {
                setState(() => _bedTime = picked);
              }
            },
          ),
          const SizedBox(height: 16),
          // Wake time
          _TimeSelector(
            label: 'Me desperte a las',
            icon: Icons.wb_sunny,
            time: _wakeTime,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _wakeTime,
              );
              if (picked != null) {
                setState(() => _wakeTime = picked);
              }
            },
          ),
          const SizedBox(height: 24),
          // Quality
          Text(
            'Como dormiste?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final selected = index + 1 == _quality;
              return InkWell(
                onTap: () => setState(() => _quality = index + 1),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getQualityEmoji(index + 1),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sueno registrado correctamente'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }

  String _getQualityEmoji(int quality) {
    switch (quality) {
      case 1:
        return '😫';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😴';
      default:
        return '😐';
    }
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeSelector({
    required this.label,
    required this.icon,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
