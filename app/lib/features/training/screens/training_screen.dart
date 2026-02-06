import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// ============ PROVIDERS ============

final restTimerProvider = StateNotifierProvider<RestTimerNotifier, RestTimerState>((ref) {
  return RestTimerNotifier();
});

// ============ MODELS ============

class RestTimerState {
  final int seconds;
  final int totalSeconds;
  final bool isRunning;

  RestTimerState({
    this.seconds = 0,
    this.totalSeconds = 90,
    this.isRunning = false,
  });

  RestTimerState copyWith({int? seconds, int? totalSeconds, bool? isRunning}) {
    return RestTimerState(
      seconds: seconds ?? this.seconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  RestTimerNotifier() : super(RestTimerState());
  Timer? _timer;

  void start(int seconds) {
    _timer?.cancel();
    state = RestTimerState(seconds: seconds, totalSeconds: seconds, isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.seconds > 0) {
        state = state.copyWith(seconds: state.seconds - 1);
      } else {
        timer.cancel();
        state = state.copyWith(isRunning: false);
      }
    });
  }

  void stop() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ============ SCREEN ============

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  // Demo data
  final List<Map<String, dynamic>> _todayWorkout = [
    {
      'name': 'Press Banca Inclinado',
      'muscle': 'Pecho',
      'icon': Icons.fitness_center,
      'pr': 80,
      'sets': [
        {'reps': 10, 'weight': 30.0, 'warmup': true},
        {'reps': 10, 'weight': 60.0, 'warmup': false},
        {'reps': 8, 'weight': 70.0, 'warmup': false},
        {'reps': 6, 'weight': 75.0, 'warmup': false},
      ],
    },
    {
      'name': 'Press Militar',
      'muscle': 'Hombros',
      'icon': Icons.accessibility_new,
      'pr': 50,
      'sets': [
        {'reps': 12, 'weight': 20.0, 'warmup': true},
        {'reps': 10, 'weight': 35.0, 'warmup': false},
        {'reps': 8, 'weight': 40.0, 'warmup': false},
        {'reps': 8, 'weight': 40.0, 'warmup': false},
      ],
    },
    {
      'name': 'Aperturas con Mancuernas',
      'muscle': 'Pecho',
      'icon': Icons.open_with,
      'pr': 20,
      'sets': [
        {'reps': 12, 'weight': 14.0, 'warmup': false},
        {'reps': 12, 'weight': 16.0, 'warmup': false},
        {'reps': 10, 'weight': 18.0, 'warmup': false},
      ],
    },
    {
      'name': 'Elevaciones Laterales',
      'muscle': 'Hombros',
      'icon': Icons.expand,
      'pr': 14,
      'sets': [
        {'reps': 15, 'weight': 8.0, 'warmup': false},
        {'reps': 12, 'weight': 10.0, 'warmup': false},
        {'reps': 12, 'weight': 12.0, 'warmup': false},
      ],
    },
  ];

  int _completedSets = 0;
  int _totalSets = 0;
  int _totalVolume = 0;
  bool _isWorkoutActive = false;
  int _currentExerciseIndex = 0;
  List<List<bool>> _setsCompleted = [];

  @override
  void initState() {
    super.initState();
    _initializeSets();
  }

  void _initializeSets() {
    _setsCompleted = [];
    _totalSets = 0;
    for (var exercise in _todayWorkout) {
      final sets = exercise['sets'] as List;
      _setsCompleted.add(List.filled(sets.length, false));
      _totalSets += sets.length;
    }
  }

  void _toggleSet(int exerciseIdx, int setIdx) {
    setState(() {
      _setsCompleted[exerciseIdx][setIdx] = !_setsCompleted[exerciseIdx][setIdx];

      _completedSets = 0;
      _totalVolume = 0;
      for (int i = 0; i < _setsCompleted.length; i++) {
        for (int j = 0; j < _setsCompleted[i].length; j++) {
          if (_setsCompleted[i][j]) {
            _completedSets++;
            final set = (_todayWorkout[i]['sets'] as List)[j];
            _totalVolume += ((set['reps'] as int) * (set['weight'] as double)).toInt();
          }
        }
      }

      if (_setsCompleted[exerciseIdx][setIdx]) {
        ref.read(restTimerProvider.notifier).start(90);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final restTimer = ref.watch(restTimerProvider);
    final progress = _totalSets > 0 ? _completedSets / _totalSets : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(progress),
            if (restTimer.isRunning) _buildRestTimer(restTimer),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _todayWorkout.length,
                itemBuilder: (context, index) => _buildExerciseCard(index),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !_isWorkoutActive
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _isWorkoutActive = true),
              backgroundColor: const Color(0xFFB8FF00),
              icon: const Icon(Icons.play_arrow, color: Colors.black),
              label: const Text('Comenzar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Entreno', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showWorkoutHistory(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.history, color: Color(0xFF6366F1), size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showWeekSchedule(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8FF00).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_today, color: Color(0xFFB8FF00), size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFB8FF00).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Upper A - Empuje', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Pecho • Hombros • Triceps', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 16),
                          SizedBox(width: 4),
                          Text('3 PRs', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progreso', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                        Text('$_completedSets/$_totalSets sets', style: const TextStyle(color: Color(0xFFB8FF00), fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFB8FF00), Color(0xFF10B981)]),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatItem(Icons.fitness_center, '${_todayWorkout.length}', 'Ejercicios'),
                    const SizedBox(width: 24),
                    _buildStatItem(Icons.scale, '${(_totalVolume / 1000).toStringAsFixed(1)}t', 'Volumen'),
                    const SizedBox(width: 24),
                    _buildStatItem(Icons.timer, _isWorkoutActive ? '32:15' : '--:--', 'Tiempo'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.5), size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildRestTimer(RestTimerState timer) {
    final minutes = timer.seconds ~/ 60;
    final seconds = timer.seconds % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF3B82F6).withOpacity(0.2), const Color(0xFF3B82F6).withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: timer.seconds / timer.totalSeconds,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              ),
              Text('$minutes:${seconds.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tiempo de descanso', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text('Siguiente: Press Militar', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(restTimerProvider.notifier).stop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(20)),
              child: const Text('Saltar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int exerciseIndex) {
    final exercise = _todayWorkout[exerciseIndex];
    final sets = exercise['sets'] as List;
    final completedInExercise = _setsCompleted[exerciseIndex].where((s) => s).length;
    final isExpanded = _currentExerciseIndex == exerciseIndex;

    return GestureDetector(
      onTap: () => setState(() => _currentExerciseIndex = exerciseIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpanded ? const Color(0xFF1A1A2E) : const Color(0xFF1A1A1F),
          borderRadius: BorderRadius.circular(20),
          border: isExpanded ? Border.all(color: const Color(0xFFB8FF00).withOpacity(0.5)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8FF00).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(exercise['icon'] as IconData, color: const Color(0xFFB8FF00), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(exercise['muscle'] as String, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('PR: ${exercise['pr']}kg', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: completedInExercise == sets.length ? const Color(0xFF10B981).withOpacity(0.15) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedInExercise/${sets.length}',
                    style: TextStyle(
                      color: completedInExercise == sets.length ? const Color(0xFF10B981) : Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text('SET', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w600))),
                    Expanded(child: Text('REPS', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w600))),
                    Expanded(child: Text('KG', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w600))),
                    const SizedBox(width: 60, child: Text('RPE', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600))),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(sets.length, (setIndex) {
                final set = sets[setIndex];
                return _buildSetRow(
                  setIndex + 1,
                  set['reps'] as int,
                  set['weight'] as double,
                  set['warmup'] as bool,
                  _setsCompleted[exerciseIndex][setIndex],
                  () => _toggleSet(exerciseIndex, setIndex),
                );
              }),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white.withOpacity(0.5), size: 18),
                      const SizedBox(width: 8),
                      Text('Añadir serie', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(int setNum, int reps, double weight, bool isWarmup, bool isCompleted, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFF10B981).withOpacity(0.1) : (isWarmup ? Colors.white.withOpacity(0.02) : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
          border: isCompleted ? Border.all(color: const Color(0xFF10B981).withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Row(
                children: [
                  Text('$setNum', style: TextStyle(color: isWarmup ? Colors.orange : Colors.white, fontWeight: FontWeight.bold)),
                  if (isWarmup) const Text(' W', style: TextStyle(color: Colors.orange, fontSize: 10)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Text('$reps', style: TextStyle(color: isCompleted ? const Color(0xFF10B981) : Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Text('${weight.toInt()}', style: TextStyle(color: isCompleted ? const Color(0xFF10B981) : Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFFEAB308), Color(0xFFEF4444)]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? const Color(0xFF10B981) : Colors.transparent,
                border: Border.all(color: isCompleted ? const Color(0xFF10B981) : Colors.white.withOpacity(0.3), width: 2),
              ),
              child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Historial', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildHistoryItem('Ayer', 'Upper A - Empuje', '45 min', '8.5t'),
            _buildHistoryItem('Hace 2 días', 'Lower A - Piernas', '55 min', '12.3t'),
            _buildHistoryItem('Hace 3 días', 'Upper B - Tirón', '48 min', '9.2t'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String date, String name, String time, String volume) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFB8FF00).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.fitness_center, color: Color(0xFFB8FF00), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(date, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
              Text(volume, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  void _showWeekSchedule(BuildContext context) {
    final schedule = [
      {'day': 'L', 'workout': 'Upper A', 'done': true},
      {'day': 'M', 'workout': 'Lower A', 'done': true},
      {'day': 'X', 'workout': 'Descanso', 'done': true},
      {'day': 'J', 'workout': 'Upper B', 'done': false},
      {'day': 'V', 'workout': 'Lower B', 'done': false},
      {'day': 'S', 'workout': 'Descanso', 'done': false},
      {'day': 'D', 'workout': 'Descanso', 'done': false},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Rutina Semanal', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: schedule.map((day) {
                final isDone = day['done'] as bool;
                final isRest = day['workout'] == 'Descanso';
                return Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? const Color(0xFF10B981) : (isRest ? Colors.white.withOpacity(0.05) : const Color(0xFFB8FF00).withOpacity(0.15)),
                        border: !isDone && !isRest ? Border.all(color: const Color(0xFFB8FF00).withOpacity(0.5)) : null,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : (isRest ? Icon(Icons.self_improvement, color: Colors.white.withOpacity(0.3), size: 18) : const Icon(Icons.fitness_center, color: Color(0xFFB8FF00), size: 18)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(day['day'] as String, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
