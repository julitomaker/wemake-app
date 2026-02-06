import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/correlation_provider.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    // Load and analyze on init
    Future.microtask(() async {
      await ref.read(correlationProvider.notifier).loadDailyScores();
      await ref.read(correlationProvider.notifier).runAnalysis();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correlationState = ref.watch(correlationProvider);
    final insights = ref.watch(activeInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          if (!correlationState.isAnalyzing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await ref.read(correlationProvider.notifier).runAnalysis();
              },
              tooltip: 'Actualizar analisis',
            ),
        ],
      ),
      body: correlationState.isAnalyzing
          ? _buildLoadingState(theme)
          : !correlationState.hasEnoughData
              ? _buildNoDataState(theme)
              : insights.isEmpty
                  ? _buildNoInsightsState(theme)
                  : _buildInsightsList(theme, insights),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Analizando tus datos...',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Buscando patrones y correlaciones',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Aun no hay suficientes datos',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Necesitas al menos 14 dias de datos para que el motor de correlaciones pueda encontrar patrones utiles.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: ref.read(correlationProvider).dailyScores.length / 14,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            ),
            const SizedBox(height: 8),
            Text(
              '${ref.read(correlationProvider).dailyScores.length}/14 dias',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInsightsState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Todo en orden!',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'No se encontraron patrones preocupantes en tus datos. '
              'Sigue asi y regresa pronto para nuevos insights.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsList(ThemeData theme, List<GeneratedInsight> insights) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: insights.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader(theme);
        }
        return _InsightCard(
          insight: insights[index - 1],
          onDismiss: () {
            ref.read(correlationProvider.notifier).dismissInsight(insights[index - 1].id);
          },
          onActionTaken: () {
            ref.read(correlationProvider.notifier).markActionTaken(insights[index - 1].id);
          },
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final state = ref.watch(correlationProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Correlation Engine',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Basado en ${state.dailyScores.length} dias de datos',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          if (state.lastAnalyzedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Ultimo analisis: ${_formatTime(state.lastAnalyzedAt!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} horas';
    return 'Hace ${diff.inDays} dias';
  }
}

class _InsightCard extends StatelessWidget {
  final GeneratedInsight insight;
  final VoidCallback onDismiss;
  final VoidCallback onActionTaken;

  const _InsightCard({
    required this.insight,
    required this.onDismiss,
    required this.onActionTaken,
  });

  Color _getColorForType(InsightType type) {
    switch (type) {
      case InsightType.sleepWorkout:
        return Colors.indigo;
      case InsightType.nutritionFocus:
        return Colors.green;
      case InsightType.mealTiming:
        return Colors.orange;
      case InsightType.carbsPerformance:
        return Colors.amber;
      case InsightType.hydrationEnergy:
        return Colors.blue;
      case InsightType.habitStreak:
        return Colors.purple;
      case InsightType.workoutRecovery:
        return Colors.red;
      case InsightType.sleepQuality:
        return Colors.deepPurple;
    }
  }

  IconData _getIconForType(InsightType type) {
    switch (type) {
      case InsightType.sleepWorkout:
        return Icons.bedtime;
      case InsightType.nutritionFocus:
        return Icons.restaurant;
      case InsightType.mealTiming:
        return Icons.schedule;
      case InsightType.carbsPerformance:
        return Icons.fitness_center;
      case InsightType.hydrationEnergy:
        return Icons.water_drop;
      case InsightType.habitStreak:
        return Icons.repeat;
      case InsightType.workoutRecovery:
        return Icons.healing;
      case InsightType.sleepQuality:
        return Icons.nights_stay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColorForType(insight.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: color.withOpacity(0.1),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForType(insight.type),
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _ConfidenceBadge(confidence: insight.confidence),
                          const SizedBox(width: 8),
                          Text(
                            '${insight.sampleSize} dias',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  tooltip: 'Descartar',
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Correlation strength indicator
                Row(
                  children: [
                    Text(
                      'Correlacion:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CorrelationBar(
                        value: insight.correlationStrength,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      insight.correlationStrength > 0 ? 'Positiva' : 'Negativa',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Action suggestion
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.actionSuggestion,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Actions
                if (!insight.isActionTaken)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onActionTaken,
                      icon: const Icon(Icons.check),
                      label: const Text('Aplicare este insight'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Ya aplicaste este insight',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
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

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).round();
    Color color;
    if (confidence >= 0.8) {
      color = Colors.green;
    } else if (confidence >= 0.6) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$pct% confianza',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CorrelationBar extends StatelessWidget {
  final double value;
  final Color color;

  const _CorrelationBar({
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final absValue = value.abs();
    final isPositive = value > 0;

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final halfWidth = constraints.maxWidth / 2;
          final barWidth = halfWidth * absValue;

          return Stack(
            children: [
              // Center marker
              Positioned(
                left: halfWidth - 1,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: Colors.grey,
                ),
              ),
              // Correlation bar
              Positioned(
                left: isPositive ? halfWidth : halfWidth - barWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
