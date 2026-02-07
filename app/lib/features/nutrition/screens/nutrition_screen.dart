import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';

// ============ PROVIDERS ============

final nutritionDataProvider = StateNotifierProvider<NutritionDataNotifier, NutritionData>((ref) {
  return NutritionDataNotifier();
});

// ============ MODELS ============

class NutritionData {
  final int caloriesConsumed;
  final int caloriesTarget;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbsConsumed;
  final int carbsTarget;
  final int fatConsumed;
  final int fatTarget;
  final int waterGlasses;
  final int waterTarget;
  final List<Meal> meals;

  NutritionData({
    this.caloriesConsumed = 1680,
    this.caloriesTarget = 3000,
    this.proteinConsumed = 125,
    this.proteinTarget = 190,
    this.carbsConsumed = 180,
    this.carbsTarget = 375,
    this.fatConsumed = 46,
    this.fatTarget = 83,
    this.waterGlasses = 6,
    this.waterTarget = 10,
    this.meals = const [],
  });

  NutritionData copyWith({
    int? caloriesConsumed,
    int? proteinConsumed,
    int? carbsConsumed,
    int? fatConsumed,
    int? waterGlasses,
    List<Meal>? meals,
  }) {
    return NutritionData(
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      caloriesTarget: caloriesTarget,
      proteinConsumed: proteinConsumed ?? this.proteinConsumed,
      proteinTarget: proteinTarget,
      carbsConsumed: carbsConsumed ?? this.carbsConsumed,
      carbsTarget: carbsTarget,
      fatConsumed: fatConsumed ?? this.fatConsumed,
      fatTarget: fatTarget,
      waterGlasses: waterGlasses ?? this.waterGlasses,
      waterTarget: waterTarget,
      meals: meals ?? this.meals,
    );
  }
}

class Meal {
  final String id;
  final String name;
  final String time;
  final IconData icon;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> foods;
  final bool isCompleted;

  const Meal({
    required this.id,
    required this.name,
    required this.time,
    required this.icon,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.foods = const [],
    this.isCompleted = false,
  });

  Meal copyWith({bool? isCompleted}) {
    return Meal(
      id: id,
      name: name,
      time: time,
      icon: icon,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      foods: foods,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class NutritionDataNotifier extends StateNotifier<NutritionData> {
  NutritionDataNotifier() : super(_initData());

  static NutritionData _initData() {
    return NutritionData(
      meals: [
        const Meal(
          id: '1',
          name: 'Desayuno',
          time: '7:00 AM',
          icon: Icons.wb_sunny,
          calories: 650,
          protein: 45,
          carbs: 70,
          fat: 18,
          foods: ['4 claras + 2 huevos', 'Avena 80g', 'Banana', 'Mani 15g'],
          isCompleted: true,
        ),
        const Meal(
          id: '2',
          name: 'Snack AM',
          time: '10:00 AM',
          icon: Icons.apple,
          calories: 280,
          protein: 30,
          carbs: 25,
          fat: 8,
          foods: ['Yogurt griego', 'Almendras 20g', 'Manzana'],
          isCompleted: true,
        ),
        const Meal(
          id: '3',
          name: 'Almuerzo',
          time: '1:00 PM',
          icon: Icons.restaurant,
          calories: 750,
          protein: 50,
          carbs: 85,
          fat: 20,
          foods: ['Pollo 200g', 'Arroz 150g', 'Vegetales', 'Aceite oliva'],
          isCompleted: true,
        ),
        const Meal(
          id: '4',
          name: 'Pre-Entreno',
          time: '4:00 PM',
          icon: Icons.flash_on,
          calories: 320,
          protein: 25,
          carbs: 45,
          fat: 5,
          foods: ['Batido proteina', 'Banana', 'Miel 10g'],
          isCompleted: false,
        ),
        const Meal(
          id: '5',
          name: 'Cena',
          time: '8:00 PM',
          icon: Icons.nightlight,
          calories: 600,
          protein: 45,
          carbs: 50,
          fat: 22,
          foods: ['Salmon 180g', 'Quinoa 100g', 'Brocoli', 'Aguacate'],
          isCompleted: false,
        ),
      ],
    );
  }

  void toggleMeal(String mealId) {
    state = state.copyWith(
      meals: state.meals.map((m) {
        if (m.id == mealId) return m.copyWith(isCompleted: !m.isCompleted);
        return m;
      }).toList(),
    );
    _recalculateConsumed();
  }

  void addWater() {
    if (state.waterGlasses < 15) {
      state = state.copyWith(waterGlasses: state.waterGlasses + 1);
    }
  }

  void removeWater() {
    if (state.waterGlasses > 0) {
      state = state.copyWith(waterGlasses: state.waterGlasses - 1);
    }
  }

  void _recalculateConsumed() {
    int cal = 0, prot = 0, carb = 0, fat = 0;
    for (var meal in state.meals) {
      if (meal.isCompleted) {
        cal += meal.calories;
        prot += meal.protein;
        carb += meal.carbs;
        fat += meal.fat;
      }
    }
    state = state.copyWith(
      caloriesConsumed: cal,
      proteinConsumed: prot,
      carbsConsumed: carb,
      fatConsumed: fat,
    );
  }
}

// ============ SCREEN ============

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  late final ConfettiController _confettiController;
  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerConfetti() {
    if (_celebrated) return;
    _celebrated = true;
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(nutritionDataProvider);
    final caloriesRemaining = data.caloriesTarget - data.caloriesConsumed;
    final mealsCompleted = data.meals.where((m) => m.isCompleted).length;
    final macrosComplete = data.proteinConsumed >= data.proteinTarget &&
        data.carbsConsumed >= data.carbsTarget &&
        data.fatConsumed >= data.fatTarget;

    if (macrosComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerConfetti());
    } else {
      _celebrated = false;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Comida', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showNutritionHistory(context),
                            child: GlassContainer(
                              radius: 12,
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.history, color: Color(0xFF6366F1), size: 20),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showAddFoodWithPhoto(context),
                            child: GlassContainer(
                              radius: 12,
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.camera_alt, color: Color(0xFF10B981), size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Main Calories Card
                  Hero(
                    tag: 'nutrition-hero',
                    child: _buildCaloriesCard(data, caloriesRemaining),
                  ),

                  const SizedBox(height: 16),

                  // Macros Row
                  _buildMacrosRow(data),

                  const SizedBox(height: 20),

                  // Water Tracking
                  _buildWaterCard(ref, data),

                  const SizedBox(height: 20),

                  // Meals Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Plan de Comidas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      GlassContainer(
                        radius: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          '$mealsCompleted/${data.meals.length}',
                          style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Meals List
                  ...data.meals.map((meal) => _buildMealCard(ref, meal)),

                  const SizedBox(height: 100),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.4,
                numberOfParticles: 18,
                colors: const [
                  Color(0xFF10B981),
                  Color(0xFF22D3EE),
                  Color(0xFF6366F1),
                  Color(0xFFB8FF00),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFoodWithPhoto(context),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text('Escanear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCaloriesCard(NutritionData data, int remaining) {
    final progress = data.caloriesConsumed / data.caloriesTarget;

    return GlassContainer(
      radius: 24,
      padding: const EdgeInsets.all(24),
      gradient: AppTheme.wellnessGlow,
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CustomPaint(
                    painter: CalorieRingPainter(
                      progress: progress.clamp(0.0, 1.0),
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: const Color(0xFF10B981),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$remaining',
                      style: AppTheme.numberDisplayMedium.copyWith(color: Colors.white),
                    ),
                    Text('kcal restantes', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Stats column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalorieStatRow('Objetivo', '${data.caloriesTarget}', Colors.white),
                const SizedBox(height: 10),
                _buildCalorieStatRow('Consumido', '${data.caloriesConsumed}', const Color(0xFF10B981)),
                const SizedBox(height: 10),
                _buildCalorieStatRow('Restante', '$remaining', const Color(0xFFF97316)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    progress >= 0.9 ? 'Casi completo!' : progress >= 0.6 ? 'Vas bien!' : 'Sigue comiendo',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMacrosRow(NutritionData data) {
    return Row(
      children: [
        Expanded(child: _buildMacroCard('Proteina', data.proteinConsumed, data.proteinTarget, 'g', const Color(0xFFEF4444))),
        const SizedBox(width: 10),
        Expanded(child: _buildMacroCard('Carbs', data.carbsConsumed, data.carbsTarget, 'g', const Color(0xFFF97316))),
        const SizedBox(width: 10),
        Expanded(child: _buildMacroCard('Grasa', data.fatConsumed, data.fatTarget, 'g', const Color(0xFF8B5CF6))),
      ],
    );
  }

  Widget _buildMacroCard(String label, int consumed, int target, String unit, Color color) {
    final progress = consumed / target;

    return GlassContainer(
      radius: 16,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 6),
          Text('$consumed$unit', style: AppTheme.numberDisplaySmall.copyWith(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 2),
          Text('/ $target$unit', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
          const SizedBox(height: 6),
          Container(
            height: 4,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(2)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterCard(WidgetRef ref, NutritionData data) {
    final waterMl = data.waterGlasses * 250;
    final targetMl = data.waterTarget * 250;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF06B6D4).withOpacity(0.15), const Color(0xFF06B6D4).withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: const Color(0xFF06B6D4).withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.water_drop, color: Color(0xFF06B6D4), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hidratacion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('${(waterMl / 1000).toStringAsFixed(1)}L / ${(targetMl / 1000).toStringAsFixed(1)}L', style: const TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(10, (index) {
                    final isFilled = index < data.waterGlasses;
                    return Expanded(
                      child: Container(
                        height: 18,
                        margin: const EdgeInsets.only(right: 3),
                        decoration: BoxDecoration(
                          color: isFilled ? const Color(0xFF06B6D4) : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              GestureDetector(
                onTap: () => ref.read(nutritionDataProvider.notifier).addWater(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: const Color(0xFF06B6D4), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => ref.read(nutritionDataProvider.notifier).removeWater(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.remove, color: Colors.white.withOpacity(0.5), size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(WidgetRef ref, Meal meal) {
    return GestureDetector(
      onTap: () => ref.read(nutritionDataProvider.notifier).toggleMeal(meal.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: meal.isCompleted ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF1A1A1F),
          borderRadius: BorderRadius.circular(16),
          border: meal.isCompleted ? Border.all(color: const Color(0xFF10B981).withOpacity(0.3)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: meal.isCompleted ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(meal.icon, color: const Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: TextStyle(
                          color: meal.isCompleted ? Colors.white54 : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          decoration: meal.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(meal.time, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${meal.calories} kcal',
                      style: TextStyle(color: meal.isCompleted ? const Color(0xFF10B981) : Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text('${meal.protein}p · ${meal.carbs}c · ${meal.fat}g', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: meal.isCompleted ? const Color(0xFF10B981) : Colors.transparent,
                    border: Border.all(color: meal.isCompleted ? const Color(0xFF10B981) : Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: meal.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                ),
              ],
            ),
            if (!meal.isCompleted && meal.foods.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: meal.foods.take(4).map((food) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
                    child: Text(food, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showNutritionHistory(BuildContext context) {
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
            _buildNutritionHistoryItem('Ayer', 2850, 3000, true),
            _buildNutritionHistoryItem('Hace 2 dias', 3100, 3000, true),
            _buildNutritionHistoryItem('Hace 3 dias', 2650, 3000, false),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionHistoryItem(String date, int consumed, int target, bool onTarget) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: onTarget ? const Color(0xFF10B981).withOpacity(0.15) : const Color(0xFFF97316).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(onTarget ? Icons.check_circle : Icons.warning, color: onTarget ? const Color(0xFF10B981) : const Color(0xFFF97316), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text('$consumed / $target kcal', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: onTarget ? const Color(0xFF10B981).withOpacity(0.15) : const Color(0xFFF97316).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(onTarget ? 'En meta' : 'Bajo', style: TextStyle(color: onTarget ? const Color(0xFF10B981) : const Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _showAddFoodWithPhoto(BuildContext context) {
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
            const Text('Agregar Comida', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abriendo camara...'), backgroundColor: Color(0xFF10B981)));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt, color: Color(0xFF10B981), size: 32),
                          SizedBox(height: 8),
                          Text('Tomar foto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          Text('AI detecta comida', style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                      child: const Column(
                        children: [
                          Icon(Icons.search, color: Colors.white54, size: 32),
                          SizedBox(height: 8),
                          Text('Buscar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          Text('Base de datos', style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Custom painter for calorie ring
class CalorieRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;

  CalorieRingPainter({required this.progress, required this.strokeWidth, required this.backgroundColor, required this.foregroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()..color = backgroundColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()..color = foregroundColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
