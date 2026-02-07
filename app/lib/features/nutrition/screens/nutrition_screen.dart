import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';

final nutritionDataProvider = StateNotifierProvider<NutritionDataNotifier, NutritionData>((ref) {
  return NutritionDataNotifier();
});

enum UserGoal { loseFat, gainMuscle, maintain, recomposition }

enum MealStatus { pending, upcoming, completed, modified, skipped, different }

enum MealType { breakfast, snackAm, lunch, snackPm, dinner, snackNight, custom }

enum WaterUnit { bottle, glass, liters }

class NutritionData {
  final String dateLabel;
  final UserGoal goal;
  final double currentWeight;
  final double lastWeight;
  final double goalWeight;
  final List<PlannedMeal> meals;
  final WaterConfig waterConfig;
  final TrainingContext trainingContext;
  final MacroSummary macroSummary;

  const NutritionData({
    required this.dateLabel,
    required this.goal,
    required this.currentWeight,
    required this.lastWeight,
    required this.goalWeight,
    required this.meals,
    required this.waterConfig,
    required this.trainingContext,
    required this.macroSummary,
  });

  NutritionData copyWith({
    String? dateLabel,
    UserGoal? goal,
    double? currentWeight,
    double? lastWeight,
    double? goalWeight,
    List<PlannedMeal>? meals,
    WaterConfig? waterConfig,
    TrainingContext? trainingContext,
    MacroSummary? macroSummary,
  }) {
    return NutritionData(
      dateLabel: dateLabel ?? this.dateLabel,
      goal: goal ?? this.goal,
      currentWeight: currentWeight ?? this.currentWeight,
      lastWeight: lastWeight ?? this.lastWeight,
      goalWeight: goalWeight ?? this.goalWeight,
      meals: meals ?? this.meals,
      waterConfig: waterConfig ?? this.waterConfig,
      trainingContext: trainingContext ?? this.trainingContext,
      macroSummary: macroSummary ?? this.macroSummary,
    );
  }
}

class MacroSummary {
  final MacroTarget calories;
  final MacroTarget protein;
  final MacroTarget carbs;
  final MacroTarget fat;

  const MacroSummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  MacroSummary copyWith({
    MacroTarget? calories,
    MacroTarget? protein,
    MacroTarget? carbs,
    MacroTarget? fat,
  }) {
    return MacroSummary(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }
}

class MacroTarget {
  final int consumed;
  final int target;
  final int min;
  final int max;

  const MacroTarget({
    required this.consumed,
    required this.target,
    required this.min,
    required this.max,
  });

  MacroTarget copyWith({int? consumed, int? target, int? min, int? max}) {
    return MacroTarget(
      consumed: consumed ?? this.consumed,
      target: target ?? this.target,
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }
}

class WaterConfig {
  final WaterUnit unit;
  final int capacityMl;
  final int dailyTargetMl;
  final int consumedUnits;

  const WaterConfig({
    required this.unit,
    required this.capacityMl,
    required this.dailyTargetMl,
    required this.consumedUnits,
  });

  int get targetUnits => (dailyTargetMl / capacityMl).ceil();

  WaterConfig copyWith({
    WaterUnit? unit,
    int? capacityMl,
    int? dailyTargetMl,
    int? consumedUnits,
  }) {
    return WaterConfig(
      unit: unit ?? this.unit,
      capacityMl: capacityMl ?? this.capacityMl,
      dailyTargetMl: dailyTargetMl ?? this.dailyTargetMl,
      consumedUnits: consumedUnits ?? this.consumedUnits,
    );
  }
}

class TrainingContext {
  final String? label;
  final int kcalAdjustment;
  final int caloriesBurned;

  const TrainingContext({
    required this.label,
    required this.kcalAdjustment,
    required this.caloriesBurned,
  });
}

class PlannedMeal {
  final String id;
  final MealType type;
  final String name;
  final String time;
  final String? imageUrl;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final MealStatus status;
  final String? educationNote;

  const PlannedMeal({
    required this.id,
    required this.type,
    required this.name,
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.status,
    this.imageUrl,
    this.educationNote,
  });

  PlannedMeal copyWith({MealStatus? status}) {
    return PlannedMeal(
      id: id,
      type: type,
      name: name,
      time: time,
      imageUrl: imageUrl,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      status: status ?? this.status,
      educationNote: educationNote,
    );
  }
}

class NutritionDataNotifier extends StateNotifier<NutritionData> {
  NutritionDataNotifier() : super(_seed());

  static NutritionData _seed() {
    return NutritionData(
      dateLabel: 'Hoy · Mar 12',
      goal: UserGoal.loseFat,
      currentWeight: 78.5,
      lastWeight: 79.0,
      goalWeight: 74.0,
      waterConfig: const WaterConfig(
        unit: WaterUnit.bottle,
        capacityMl: 700,
        dailyTargetMl: 2800,
        consumedUnits: 3,
      ),
      trainingContext: const TrainingContext(
        label: 'Entrenas UPPER a las 6:00 PM',
        kcalAdjustment: 200,
        caloriesBurned: 350,
      ),
      macroSummary: const MacroSummary(
        calories: MacroTarget(consumed: 1450, target: 2200, min: 1900, max: 2400),
        protein: MacroTarget(consumed: 95, target: 150, min: 130, max: 170),
        carbs: MacroTarget(consumed: 180, target: 250, min: 210, max: 280),
        fat: MacroTarget(consumed: 45, target: 70, min: 55, max: 80),
      ),
      meals: const [
        PlannedMeal(
          id: 'breakfast',
          type: MealType.breakfast,
          name: 'Avena con frutas y huevo',
          time: '8:00 AM',
          calories: 450,
          protein: 28,
          carbs: 60,
          fat: 12,
          status: MealStatus.completed,
          educationNote: 'Proteína temprana para saciedad y energía estable.',
        ),
        PlannedMeal(
          id: 'snack-am',
          type: MealType.snackAm,
          name: 'Yogur griego con nueces',
          time: '11:00 AM',
          calories: 220,
          protein: 18,
          carbs: 16,
          fat: 9,
          status: MealStatus.completed,
          educationNote: 'Mantén la energía sin picos de azúcar.',
        ),
        PlannedMeal(
          id: 'lunch',
          type: MealType.lunch,
          name: 'Pollo grillado con quinoa y vegetales',
          time: '1:30 PM',
          calories: 520,
          protein: 42,
          carbs: 55,
          fat: 12,
          status: MealStatus.upcoming,
          educationNote: 'Carbos complejos antes del entreno para energía sostenida.',
        ),
        PlannedMeal(
          id: 'snack-pm',
          type: MealType.snackPm,
          name: 'Banana con crema de cacahuate',
          time: '4:30 PM',
          calories: 240,
          protein: 6,
          carbs: 28,
          fat: 9,
          status: MealStatus.pending,
          educationNote: 'Snack rápido para llegar fuerte al entrenamiento.',
        ),
        PlannedMeal(
          id: 'dinner',
          type: MealType.dinner,
          name: 'Salmón con arroz y ensalada',
          time: '8:30 PM',
          calories: 620,
          protein: 45,
          carbs: 48,
          fat: 24,
          status: MealStatus.pending,
          educationNote: 'Proteína alta para recuperación post-entreno.',
        ),
      ],
    );
  }

  void updateWeight(double newWeight) {
    state = state.copyWith(lastWeight: state.currentWeight, currentWeight: newWeight);
  }

  void addWaterUnit() {
    if (state.waterConfig.consumedUnits < state.waterConfig.targetUnits + 2) {
      state = state.copyWith(
        waterConfig: state.waterConfig.copyWith(consumedUnits: state.waterConfig.consumedUnits + 1),
      );
    }
  }

  void removeWaterUnit() {
    if (state.waterConfig.consumedUnits > 0) {
      state = state.copyWith(
        waterConfig: state.waterConfig.copyWith(consumedUnits: state.waterConfig.consumedUnits - 1),
      );
    }
  }

  void updateMealStatus(String mealId, MealStatus status) {
    final updatedMeals = state.meals.map((meal) {
      if (meal.id == mealId) {
        return meal.copyWith(status: status);
      }
      return meal;
    }).toList();
    state = state.copyWith(meals: updatedMeals, macroSummary: _recalculateMacros(updatedMeals));
  }

  MacroSummary _recalculateMacros(List<PlannedMeal> meals) {
    int calories = 0;
    int protein = 0;
    int carbs = 0;
    int fat = 0;

    for (final meal in meals) {
      if (meal.status == MealStatus.completed || meal.status == MealStatus.modified || meal.status == MealStatus.different) {
        calories += meal.calories;
        protein += meal.protein;
        carbs += meal.carbs;
        fat += meal.fat;
      }
    }

    return state.macroSummary.copyWith(
      calories: state.macroSummary.calories.copyWith(consumed: calories),
      protein: state.macroSummary.protein.copyWith(consumed: protein),
      carbs: state.macroSummary.carbs.copyWith(consumed: carbs),
      fat: state.macroSummary.fat.copyWith(consumed: fat),
    );
  }
}

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(nutritionDataProvider);
    final mealsCompleted = data.meals.where((meal) => meal.status == MealStatus.completed).length;
    final mealTargets = _mealTargets();
    final waterDisplay = _waterDisplay(data.waterConfig);
    final headerMessage = _headerMessage(data);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, data, headerMessage, mealsCompleted, mealTargets),
              const SizedBox(height: 18),
              _buildTrainingBanner(data.trainingContext),
              const SizedBox(height: 16),
              _buildMacroRings(data, waterDisplay, context),
              const SizedBox(height: 20),
              _buildPlanHeader(mealsCompleted, data.meals.length),
              const SizedBox(height: 12),
              ...data.meals.map((meal) => _buildMealCard(context, ref, meal)).toList(),
              const SizedBox(height: 16),
              _buildCheckInCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddMealSheet(context),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(PhosphorIconsFill.camera, color: Colors.white),
        label: const Text('Registrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    NutritionData data,
    String headerMessage,
    int mealsCompleted,
    List<MealTargetInfo> mealTargets,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                headerMessage,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            _WeightIndicator(data: data),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              data.dateLabel,
              style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
            ),
            const Spacer(),
            _MealCounter(mealsCompleted: mealsCompleted, totalMeals: data.meals.length, mealTargets: mealTargets),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _CalorieSilhouette(macroTarget: data.macroSummary.calories, goal: data.goal)),
            const SizedBox(width: 12),
            _buildQuickStats(data),
          ],
        ),
      ],
    );
  }

  Widget _buildTrainingBanner(TrainingContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFB8FF00).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(PhosphorIconsFill.barbell, color: Color(0xFFB8FF00), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.label ?? 'Hoy es día de descanso', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(
                  'Hoy +${context.kcalAdjustment} kcal sugeridas · ${context.caloriesBurned} kcal quemadas',
                  style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFB8FF00).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Pre-entreno', style: TextStyle(color: Color(0xFFB8FF00), fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRings(NutritionData data, String waterDisplay, BuildContext context) {
    final rings = [
      MacroRingData(
        label: 'Calorías',
        color: const Color(0xFF2563EB),
        target: data.macroSummary.calories,
        unit: 'kcal',
      ),
      MacroRingData(
        label: 'Proteína',
        color: const Color(0xFF10B981),
        target: data.macroSummary.protein,
        unit: 'g',
      ),
      MacroRingData(
        label: 'Carbohidratos',
        color: const Color(0xFFF59E0B),
        target: data.macroSummary.carbs,
        unit: 'g',
      ),
      MacroRingData(
        label: 'Grasas',
        color: const Color(0xFFEF4444),
        target: data.macroSummary.fat,
        unit: 'g',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(240, 240),
                  painter: MacroRingsPainter(rings: rings),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Agua', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                      waterDisplay,
                      style: AppTheme.numberDisplaySmall.copyWith(color: const Color(0xFF06B6D4), fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text('Toca para detalle', style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10)),
                  ],
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(120),
                      onTap: () => _openWaterDetail(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: rings.map((ring) {
              final progress = ring.target.consumed / ring.target.target;
              final isInRange = ring.target.consumed >= ring.target.min && ring.target.consumed <= ring.target.max;
              final status = ring.target.consumed < ring.target.min
                  ? 'Debajo del mínimo'
                  : ring.target.consumed > ring.target.max
                      ? 'Exceso'
                      : 'En zona ideal';
              return GestureDetector(
                onTap: () => _openMacroDetail(context, ring, status),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: ring.color, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${ring.label}: ${ring.target.consumed}/${ring.target.target} ${ring.unit}',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        status,
                        style: TextStyle(color: isInRange ? const Color(0xFF10B981) : Colors.white.withOpacity(0.5), fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        height: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0, 1),
                            backgroundColor: Colors.white.withOpacity(0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(ring.color),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHeader(int mealsCompleted, int totalMeals) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Mi plan de hoy', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        GlassContainer(
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            '$mealsCompleted/$totalMeals comidas',
            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, WidgetRef ref, PlannedMeal meal) {
    final statusData = _mealStatusStyle(meal.status);
    final icon = _mealTypeIcon(meal.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusData.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusData.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: statusData.iconBg, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: statusData.iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(meal.time, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11)),
                        const SizedBox(width: 8),
                        Text(
                          '${meal.calories} kcal • ${meal.protein}g prot',
                          style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _MealStatusChip(text: statusData.label, color: statusData.labelColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MealAction(
                label: 'Ver receta',
                icon: PhosphorIconsFill.bookOpen,
                onTap: () => _openRecipeInfo(context),
              ),
              const SizedBox(width: 8),
              _MealAction(
                label: meal.status == MealStatus.completed ? 'Ver registro' : 'Registrar',
                icon: PhosphorIconsFill.checkCircle,
                onTap: () => _openMealCheckIn(context, ref, meal),
                highlight: true,
              ),
              const SizedBox(width: 8),
              _MealAction(
                label: 'Editar',
                icon: PhosphorIconsFill.pencilSimple,
                onTap: () => _openMealEditSheet(context),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _openEducationInfo(context, meal),
                icon: const Icon(PhosphorIconsRegular.info, color: Color(0xFF6366F1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
            child: const Icon(PhosphorIconsFill.moonStars, color: Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Check-in nocturno', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text('Cierra tu día con 4 preguntas rápidas', style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(12)),
            child: const Text('Hacer check-in', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(NutritionData data) {
    final caloriesRemaining = data.macroSummary.calories.target - data.macroSummary.calories.consumed;
    final proteinRemaining = data.macroSummary.protein.target - data.macroSummary.protein.consumed;
    final balance = data.macroSummary.calories.consumed - data.trainingContext.caloriesBurned;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _QuickStat(label: 'Restante', value: '$caloriesRemaining kcal', highlight: const Color(0xFFF97316)),
        const SizedBox(height: 8),
        _QuickStat(label: 'Prot. restante', value: '${proteinRemaining}g', highlight: const Color(0xFF10B981)),
        const SizedBox(height: 8),
        _QuickStat(label: 'Balance neto', value: '$balance kcal', highlight: const Color(0xFF2563EB)),
      ],
    );
  }

  String _headerMessage(NutritionData data) {
    final now = DateTime.now();
    final hour = now.hour;
    final proteinLow = data.macroSummary.protein.consumed < data.macroSummary.protein.min;
    final caloriesExceeded = data.macroSummary.calories.consumed > data.macroSummary.calories.target;
    final breakfastLogged = data.meals.any((meal) => meal.type == MealType.breakfast && meal.status == MealStatus.completed);

    if (caloriesExceeded) {
      return 'Cuidado, ya alcanzaste tu límite calórico';
    }
    if (proteinLow) {
      return 'Vas un poco bajo en proteína hoy';
    }

    if (hour >= 6 && hour < 11) {
      return breakfastLogged ? 'Buen día, vas bien con tu proteína' : 'Buenos días, ¿ya desayunaste?';
    }
    if (hour >= 11 && hour < 14) {
      return 'Es hora del almuerzo, ¿qué vas a comer?';
    }
    if (hour >= 14 && hour < 18) {
      return '¿Cómo vas con tus macros de hoy?';
    }
    if (hour >= 18 && hour < 21) {
      final remaining = data.macroSummary.calories.target - data.macroSummary.calories.consumed;
      return 'Hora de la cena, te quedan ${remaining > 0 ? remaining : 0} calorías';
    }
    return 'Último check del día, ¿cómo te fue?';
  }

  List<MealTargetInfo> _mealTargets() {
    return const [
      MealTargetInfo(MealType.breakfast, PhosphorIconsFill.sun),
      MealTargetInfo(MealType.snackAm, PhosphorIconsFill.appleLogo),
      MealTargetInfo(MealType.lunch, PhosphorIconsFill.plate),
      MealTargetInfo(MealType.snackPm, PhosphorIconsFill.bowlFood),
      MealTargetInfo(MealType.dinner, PhosphorIconsFill.moonStars),
    ];
  }

  String _waterDisplay(WaterConfig config) {
    final unitLabel = switch (config.unit) {
      WaterUnit.bottle => 'botellas',
      WaterUnit.glass => 'vasos',
      WaterUnit.liters => 'L',
    };
    if (config.unit == WaterUnit.liters) {
      final consumed = (config.consumedUnits * config.capacityMl) / 1000;
      final target = (config.targetUnits * config.capacityMl) / 1000;
      return '${consumed.toStringAsFixed(1)}/${target.toStringAsFixed(1)} $unitLabel';
    }
    return '${config.consumedUnits}/${config.targetUnits} $unitLabel';
  }

  MealStatusStyle _mealStatusStyle(MealStatus status) {
    return switch (status) {
      MealStatus.pending => MealStatusStyle(
          label: 'Pendiente',
          labelColor: Colors.white.withOpacity(0.6),
          backgroundColor: const Color(0xFF1A1A1C),
          borderColor: Colors.white.withOpacity(0.06),
          iconColor: Colors.white.withOpacity(0.6),
          iconBg: Colors.white.withOpacity(0.08),
        ),
      MealStatus.upcoming => MealStatusStyle(
          label: 'Por hacer',
          labelColor: const Color(0xFFF97316),
          backgroundColor: const Color(0xFFF97316).withOpacity(0.08),
          borderColor: const Color(0xFFF97316).withOpacity(0.25),
          iconColor: const Color(0xFFF97316),
          iconBg: const Color(0xFFF97316).withOpacity(0.15),
        ),
      MealStatus.completed => MealStatusStyle(
          label: 'Completada',
          labelColor: const Color(0xFF10B981),
          backgroundColor: const Color(0xFF10B981).withOpacity(0.08),
          borderColor: const Color(0xFF10B981).withOpacity(0.25),
          iconColor: const Color(0xFF10B981),
          iconBg: const Color(0xFF10B981).withOpacity(0.15),
        ),
      MealStatus.modified => MealStatusStyle(
          label: 'Modificada',
          labelColor: const Color(0xFF2563EB),
          backgroundColor: const Color(0xFF2563EB).withOpacity(0.08),
          borderColor: const Color(0xFF2563EB).withOpacity(0.25),
          iconColor: const Color(0xFF2563EB),
          iconBg: const Color(0xFF2563EB).withOpacity(0.15),
        ),
      MealStatus.skipped => MealStatusStyle(
          label: 'Saltada',
          labelColor: const Color(0xFFEF4444),
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.08),
          borderColor: const Color(0xFFEF4444).withOpacity(0.25),
          iconColor: const Color(0xFFEF4444),
          iconBg: const Color(0xFFEF4444).withOpacity(0.15),
        ),
      MealStatus.different => MealStatusStyle(
          label: 'Diferente',
          labelColor: const Color(0xFF6366F1),
          backgroundColor: const Color(0xFF6366F1).withOpacity(0.08),
          borderColor: const Color(0xFF6366F1).withOpacity(0.25),
          iconColor: const Color(0xFF6366F1),
          iconBg: const Color(0xFF6366F1).withOpacity(0.15),
        ),
    };
  }

  IconData _mealTypeIcon(MealType type) {
    return switch (type) {
      MealType.breakfast => PhosphorIconsFill.sun,
      MealType.snackAm => PhosphorIconsFill.appleLogo,
      MealType.lunch => PhosphorIconsFill.plate,
      MealType.snackPm => PhosphorIconsFill.bowlFood,
      MealType.dinner => PhosphorIconsFill.moonStars,
      MealType.snackNight => PhosphorIconsFill.cookie,
      MealType.custom => PhosphorIconsFill.sparkle,
    };
  }

  void _openWaterDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Detalle de hidratación', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Necesitas tomar agua cada 2-3 horas para mantener tu energía.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Text('Meta diaria', style: TextStyle(color: Colors.white54, fontSize: 11)),
                        SizedBox(height: 6),
                        Text('2,800 ml', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Text('Siguiente toma', style: TextStyle(color: Colors.white54, fontSize: 11)),
                        SizedBox(height: 6),
                        Text('En 45 min', style: TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.bold)),
                      ],
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

  void _openMacroDetail(BuildContext context, MacroRingData ring, String status) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('${ring.label} hoy', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              '${ring.target.consumed}/${ring.target.target} ${ring.unit} · $status',
              style: TextStyle(color: ring.color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Sugerencia: agrega alimentos ricos en ${ring.label.toLowerCase()} para completar tu rango ideal.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openAddMealSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 18),
            const Text('Agregar comida', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _AddMealOption(
              title: 'Tomar foto',
              subtitle: 'IA detecta tu comida',
              icon: PhosphorIconsFill.camera,
              highlight: true,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _AddMealOption(
              title: 'Buscar alimento',
              subtitle: 'Base de datos',
              icon: PhosphorIconsFill.magnifyingGlass,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _AddMealOption(
              title: 'Escanear código',
              subtitle: 'Productos empaquetados',
              icon: PhosphorIconsFill.barcode,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _AddMealOption(
              title: 'Mis recetas',
              subtitle: 'Tus favoritas guardadas',
              icon: PhosphorIconsFill.heart,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openRecipeInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Receta completa', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Ingredientes principales: pollo, quinoa, espinaca.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            const Text('Tiempo estimado: 25 min · 4 pasos', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openMealEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Editar comida', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _EditOption(label: 'Cambiar por otra sugerencia', icon: PhosphorIconsFill.shuffle),
            const SizedBox(height: 10),
            _EditOption(label: 'Buscar receta específica', icon: PhosphorIconsFill.magnifyingGlass),
            const SizedBox(height: 10),
            _EditOption(label: 'Crear entrada personalizada', icon: PhosphorIconsFill.notePencil),
            const SizedBox(height: 10),
            _EditOption(label: 'Ajustar porciones', icon: PhosphorIconsFill.sliders),
            const SizedBox(height: 10),
            _EditOption(label: 'Cambiar horario', icon: PhosphorIconsFill.clock),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openMealCheckIn(BuildContext context, WidgetRef ref, PlannedMeal meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('¿Seguiste ${meal.name}?', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _CheckInOption(
              label: 'Sí, al pie de la letra',
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.pop(context);
                ref.read(nutritionDataProvider.notifier).updateMealStatus(meal.id, MealStatus.completed);
              },
            ),
            const SizedBox(height: 10),
            _CheckInOption(
              label: 'Con algunos cambios',
              color: const Color(0xFF2563EB),
              onTap: () {
                Navigator.pop(context);
                ref.read(nutritionDataProvider.notifier).updateMealStatus(meal.id, MealStatus.modified);
              },
            ),
            const SizedBox(height: 10),
            _CheckInOption(
              label: 'Comí otra cosa',
              color: const Color(0xFF6366F1),
              onTap: () {
                Navigator.pop(context);
                ref.read(nutritionDataProvider.notifier).updateMealStatus(meal.id, MealStatus.different);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openEducationInfo(BuildContext context, PlannedMeal meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('¿Por qué esta comida?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              meal.educationNote ?? 'Recomendación personalizada para tus objetivos.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            const Text('Beneficios: proteína alta, carbohidratos complejos y grasas saludables.', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 12),
            const Text('Contribuye con 25% de tu proteína diaria.', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(12)),
              child: const Text('Ver más detalles científicos', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _WeightIndicator extends ConsumerWidget {
  const _WeightIndicator({required this.data});

  final NutritionData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diff = data.currentWeight - data.lastWeight;
    final diffLabel = diff >= 0 ? '+${diff.toStringAsFixed(1)} kg esta semana' : '${diff.toStringAsFixed(1)} kg esta semana';
    final indicator = _weightIndicatorColor(data.goal, data.currentWeight, data.lastWeight, data.goalWeight);
    final icon = indicator.trendUp ? PhosphorIconsFill.arrowUpRight : PhosphorIconsFill.arrowDownRight;

    return GestureDetector(
      onTap: () => _openWeightModal(context, ref, data),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: indicator.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: indicator.color.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${data.currentWeight.toStringAsFixed(1)} kg', style: TextStyle(color: indicator.color, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Icon(icon, color: indicator.color, size: 16),
              ],
            ),
            Text(diffLabel, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  WeightIndicator _weightIndicatorColor(UserGoal goal, double current, double last, double target) {
    final delta = current - last;
    final isUp = delta > 0.2;
    final isDown = delta < -0.2;

    switch (goal) {
      case UserGoal.loseFat:
        if (isDown) return WeightIndicator(const Color(0xFF10B981), trendUp: false);
        if (isUp) return WeightIndicator(const Color(0xFFEF4444), trendUp: true);
        return WeightIndicator(const Color(0xFFF59E0B), trendUp: false);
      case UserGoal.gainMuscle:
        if (isUp) return WeightIndicator(const Color(0xFF10B981), trendUp: true);
        if (isDown) return WeightIndicator(const Color(0xFFEF4444), trendUp: false);
        return WeightIndicator(const Color(0xFFF59E0B), trendUp: false);
      case UserGoal.maintain:
        final diff = (current - target).abs();
        if (diff <= 1.0) return WeightIndicator(const Color(0xFF10B981), trendUp: delta > 0);
        if (diff <= 1.8) return WeightIndicator(const Color(0xFFF59E0B), trendUp: delta > 0);
        return WeightIndicator(const Color(0xFFEF4444), trendUp: delta > 0);
      case UserGoal.recomposition:
        if (isDown) return WeightIndicator(const Color(0xFF10B981), trendUp: false);
        return WeightIndicator(const Color(0xFFF59E0B), trendUp: delta > 0);
    }
  }

  void _openWeightModal(BuildContext context, WidgetRef ref, NutritionData data) {
    final controller = TextEditingController(text: data.currentWeight.toStringAsFixed(1));
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Actualizar peso', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Tip: pésate en ayunas para mayor precisión', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '78.2',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                    onPressed: () {
                      final newWeight = double.tryParse(controller.text);
                      if (newWeight != null) {
                        ref.read(nutritionDataProvider.notifier).updateWeight(newWeight);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _MealCounter extends StatelessWidget {
  const _MealCounter({required this.mealsCompleted, required this.totalMeals, required this.mealTargets});

  final int mealsCompleted;
  final int totalMeals;
  final List<MealTargetInfo> mealTargets;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$mealsCompleted/$totalMeals comidas', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        const SizedBox(width: 8),
        Row(
          children: mealTargets.map((target) {
            final isCompleted = mealTargets.indexOf(target) < mealsCompleted;
            return Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF10B981).withOpacity(0.2) : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(target.icon, color: isCompleted ? const Color(0xFF10B981) : Colors.white.withOpacity(0.4), size: 14),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CalorieSilhouette extends StatelessWidget {
  const _CalorieSilhouette({required this.macroTarget, required this.goal});

  final MacroTarget macroTarget;
  final UserGoal goal;

  @override
  Widget build(BuildContext context) {
    final progress = macroTarget.consumed / macroTarget.target;
    final color = _silhouetteColor(progress, goal);
    final fillHeight = (progress.clamp(0.0, 1.2)) * 120;

    return Container(
      height: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 120,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Icon(PhosphorIconsRegular.user, color: Colors.white.withOpacity(0.2), size: 120),
                ClipRect(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: fillHeight / 120,
                    child: Icon(PhosphorIconsFill.user, color: color, size: 120),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Progreso diario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('${(progress * 100).clamp(0, 120).toStringAsFixed(0)}% del objetivo', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  progress >= 1.1 ? 'Exceso calórico' : progress >= 1.0 ? 'En límite' : 'En ruta correcta',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _silhouetteColor(double progress, UserGoal goal) {
    if (progress >= 1.1) {
      return const Color(0xFFEF4444);
    }
    if (progress >= 1.0) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF10B981);
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({required this.label, required this.value, required this.highlight});

  final String label;
  final String value;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
          Text(value, style: TextStyle(color: highlight, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _MealAction extends StatelessWidget {
  const _MealAction({required this.label, required this.icon, required this.onTap, this.highlight = false});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final background = highlight ? const Color(0xFF10B981) : Colors.white.withOpacity(0.08);
    final color = highlight ? Colors.white : Colors.white.withOpacity(0.7);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _MealStatusChip extends StatelessWidget {
  const _MealStatusChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _AddMealOption extends StatelessWidget {
  const _AddMealOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.highlight = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFF10B981) : Colors.white.withOpacity(0.7);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFF10B981).withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: highlight ? const Color(0xFF10B981).withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditOption extends StatelessWidget {
  const _EditOption({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

class _CheckInOption extends StatelessWidget {
  const _CheckInOption({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class MacroRingData {
  final String label;
  final Color color;
  final MacroTarget target;
  final String unit;

  MacroRingData({
    required this.label,
    required this.color,
    required this.target,
    required this.unit,
  });
}

class MacroRingsPainter extends CustomPainter {
  MacroRingsPainter({required this.rings});

  final List<MacroRingData> rings;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    const strokeWidth = 12.0;
    const gap = 6.0;

    for (var i = 0; i < rings.length; i++) {
      final ring = rings[i];
      final radius = maxRadius - i * (strokeWidth + gap);
      final backgroundPaint = Paint()
        ..color = Colors.white.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, backgroundPaint);

      final progress = ring.target.consumed / ring.target.target;
      final sweep = (2 * math.pi) * progress.clamp(0.0, 1.1);

      final progressPaint = Paint()
        ..color = ring.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweep, false, progressPaint);

      final minAngle = (ring.target.min / ring.target.target) * 2 * math.pi - math.pi / 2;
      final maxAngle = (ring.target.max / ring.target.target) * 2 * math.pi - math.pi / 2;
      final tickPaint = Paint()
        ..color = ring.color.withOpacity(0.5)
        ..strokeWidth = 2;

      _drawTick(canvas, center, radius, minAngle, tickPaint);
      _drawTick(canvas, center, radius, maxAngle, tickPaint);

      final tolerancePaint = Paint()
        ..color = ring.color.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), minAngle, maxAngle - minAngle, false, tolerancePaint);
    }
  }

  void _drawTick(Canvas canvas, Offset center, double radius, double angle, Paint paint) {
    final start = Offset(
      center.dx + math.cos(angle) * (radius - 8),
      center.dy + math.sin(angle) * (radius - 8),
    );
    final end = Offset(
      center.dx + math.cos(angle) * (radius + 4),
      center.dy + math.sin(angle) * (radius + 4),
    );
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WeightIndicator {
  final Color color;
  final bool trendUp;

  WeightIndicator(this.color, {required this.trendUp});
}

class MealStatusStyle {
  final String label;
  final Color labelColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color iconBg;

  MealStatusStyle({
    required this.label,
    required this.labelColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.iconBg,
  });
}

class MealTargetInfo {
  final MealType type;
  final IconData icon;

  const MealTargetInfo(this.type, this.icon);
}
