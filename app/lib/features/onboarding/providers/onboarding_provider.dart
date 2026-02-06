import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../models/onboarding_state.dart';

/// Provider for onboarding state management
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  final _supabase = Supabase.instance.client;

  // Navigation
  void nextStep() {
    if (state.currentStep < state.totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  // Step 1: Name
  void setName(String name) {
    state = state.copyWith(name: name);
  }

  // Step 2: Basic data
  void setBasicData({
    int? age,
    String? sex,
    double? weightKg,
    int? heightCm,
  }) {
    state = state.copyWith(
      age: age ?? state.age,
      sex: sex ?? state.sex,
      weightKg: weightKg ?? state.weightKg,
      heightCm: heightCm ?? state.heightCm,
    );
  }

  // Step 3: Body type
  void setBodyType(String bodyType) {
    state = state.copyWith(bodyType: bodyType);
  }

  // Step 4: Injuries
  void addInjury(OnboardingInjury injury) {
    state = state.copyWith(injuries: [...state.injuries, injury]);
  }

  void removeInjury(int index) {
    final injuries = List<OnboardingInjury>.from(state.injuries);
    injuries.removeAt(index);
    state = state.copyWith(injuries: injuries);
  }

  void clearInjuries() {
    state = state.copyWith(injuries: []);
  }

  // Step 5: Equipment
  void setEquipmentAccess(String equipment) {
    state = state.copyWith(equipmentAccess: equipment);
  }

  // Step 6: Activity level
  void setActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
  }

  // Step 7: Goals
  void setGoals({String? primary, String? urgency}) {
    state = state.copyWith(
      goalPrimary: primary ?? state.goalPrimary,
      goalUrgency: urgency ?? state.goalUrgency,
    );
  }

  // Step 8: Cognitive profile
  void setCognitiveProfile({
    required int focusScore,
    required String attentionType,
  }) {
    state = state.copyWith(
      focusScore: focusScore,
      attentionType: attentionType,
    );
  }

  // Step 9: Hydration preferences
  void setHydrationPreferences({
    int? waterTargetMl,
    int? bottleSizeMl,
  }) {
    state = state.copyWith(
      waterTargetMl: waterTargetMl ?? state.waterTargetMl,
      bottleSizeMl: bottleSizeMl ?? state.bottleSizeMl,
    );
  }

  // Step 10: Commitment
  void setCommitmentSignature(String signature) {
    state = state.copyWith(commitmentSignature: signature);
  }

  // Calculate TDEE and macros based on user data
  void _calculateTargets() {
    if (state.weightKg == null ||
        state.heightCm == null ||
        state.age == null ||
        state.sex == null ||
        state.activityLevel == null ||
        state.goalPrimary == null) {
      return;
    }

    // Harris-Benedict BMR
    double bmr;
    if (state.sex == 'male') {
      bmr = 88.362 +
          (13.397 * state.weightKg!) +
          (4.799 * state.heightCm!) -
          (5.677 * state.age!);
    } else {
      bmr = 447.593 +
          (9.247 * state.weightKg!) +
          (3.098 * state.heightCm!) -
          (4.330 * state.age!);
    }

    // Activity multiplier
    double multiplier;
    switch (state.activityLevel) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'light':
        multiplier = 1.375;
        break;
      case 'moderate':
        multiplier = 1.55;
        break;
      case 'active':
        multiplier = 1.725;
        break;
      case 'very_active':
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.55;
    }

    int tdee = (bmr * multiplier).round();

    // Adjust for goal
    int kcalTarget;
    double proteinPerKg;

    switch (state.goalPrimary) {
      case 'muscle':
        kcalTarget = tdee + 300; // Surplus
        proteinPerKg = AppConstants.proteinPerKgMuscleGain;
        break;
      case 'fat_loss':
        kcalTarget = tdee - 500; // Deficit
        proteinPerKg = AppConstants.proteinPerKgFatLoss;
        break;
      case 'maintenance':
      case 'energy':
      default:
        kcalTarget = tdee;
        proteinPerKg = AppConstants.proteinPerKgMaintenance;
    }

    // Calculate macros
    int proteinTarget = (state.weightKg! * proteinPerKg).round();
    int proteinKcal = proteinTarget * 4;

    // Fat: 25% of calories
    int fatKcal = (kcalTarget * 0.25).round();
    int fatTarget = (fatKcal / 9).round();

    // Carbs: remaining calories
    int carbsKcal = kcalTarget - proteinKcal - fatKcal;
    int carbsTarget = (carbsKcal / 4).round();

    state = state.copyWith(
      tdeeCalculated: tdee,
      kcalTarget: kcalTarget,
      proteinTarget: proteinTarget,
      carbsTarget: carbsTarget,
      fatTarget: fatTarget,
    );
  }

  // Submit onboarding data to Supabase
  Future<bool> submitOnboarding() async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isSubmitting: false,
          error: 'Usuario no autenticado',
        );
        return false;
      }

      // Calculate targets before submitting
      _calculateTargets();

      // Prepare injuries JSON
      final injuriesJson = state.injuries
          .map((i) => {
                'area': i.area,
                'severity': i.severity,
                'notes': i.notes,
              })
          .toList();

      // Prepare macro targets JSON
      final macroTargets = {
        'protein_g': state.proteinTarget,
        'carbs_g': state.carbsTarget,
        'fat_g': state.fatTarget,
        'kcal': state.kcalTarget,
      };

      // Insert bio_profile
      await _supabase.from('bio_profile').upsert({
        'user_id': userId,
        'weight_kg': state.weightKg,
        'height_cm': state.heightCm,
        'age': state.age,
        'sex': state.sex,
        'body_type': state.bodyType,
        'injuries': injuriesJson,
        'equipment_access': state.equipmentAccess,
        'activity_level': state.activityLevel,
        'focus_score': state.focusScore,
        'attention_type': state.attentionType,
        'goal_primary': state.goalPrimary,
        'goal_urgency': state.goalUrgency,
        'tdee_calculated': state.tdeeCalculated,
        'macro_targets': macroTargets,
        'water_target_ml': state.waterTargetMl,
        'bottle_size_ml': state.bottleSizeMl,
        'commitment_signature': state.commitmentSignature,
        'onboarding_completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Initialize currency for user
      await _supabase.from('currency').upsert({
        'user_id': userId,
        'xp_total': 0,
        'xp_weekly': 0,
        'coins_balance': 50, // Starting bonus
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Initialize streaks
      await _supabase.from('streak').upsert([
        {
          'user_id': userId,
          'streak_type': 'streak_light',
          'current_count': 0,
          'longest_count': 0,
          'freeze_available': 1, // Start with 1 free freeze
        },
        {
          'user_id': userId,
          'streak_type': 'streak_perfect',
          'current_count': 0,
          'longest_count': 0,
          'freeze_available': 0,
        },
      ]);

      // Update user metadata
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'display_name': state.name,
            'onboarding_completed': true,
          },
        ),
      );

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al guardar: ${e.toString()}',
      );
      return false;
    }
  }

  // Reset state
  void reset() {
    state = const OnboardingState();
  }
}
