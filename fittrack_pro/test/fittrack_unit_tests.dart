import 'package:flutter_test/flutter_test.dart';
import '../lib/core/constants/app_constants.dart';
import '../lib/core/services/bmi_service.dart';
import '../lib/core/services/calorie_calculation_service.dart';
import '../lib/core/services/streak_service.dart';
import '../lib/core/services/workout_recommendation_service.dart';
import '../lib/data/models/user_profile.dart';

void main() {
  group('BmiService Tests', () {
    test('calculateBmi returns correct value for standard height and weight', () {
      // 70 kg, 175 cm -> 70 / (1.75 * 1.75) = 22.86
      final bmi = BmiService.calculateBmi(weightKg: 70.0, heightCm: 175.0);
      expect(bmi, closeTo(22.86, 0.05));
    });

    test('getBmiCategory returns correct classification', () {
      expect(BmiService.getBmiCategory(17.5), AppConstants.bmiUnderweight);
      expect(BmiService.getBmiCategory(22.0), AppConstants.bmiNormal);
      expect(BmiService.getBmiCategory(27.5), AppConstants.bmiOverweight);
      expect(BmiService.getBmiCategory(32.0), AppConstants.bmiObese);
    });

    test('getHealthyWeightRange computes proper bounds for height', () {
      final range = BmiService.getHealthyWeightRange(180.0);
      // 18.5 * 1.8^2 = 59.94, 24.9 * 1.8^2 = 80.67
      expect(range.minWeightKg, closeTo(59.9, 0.2));
      expect(range.maxWeightKg, closeTo(80.7, 0.2));
    });

    test('calculateCalorieTarget returns appropriate deficit for weight loss', () {
      final profile = UserProfile(
        id: 'test_user',
        name: 'Alex',
        email: 'alex@test.com',
        gender: AppConstants.genderMale,
        age: 25,
        heightCm: 175.0,
        weightKg: 80.0,
        targetWeightKg: 72.0,
        fitnessGoal: AppConstants.goalWeightLoss,
        fitnessLevel: AppConstants.levelIntermediate,
        preferredLocation: AppConstants.locationGym,
        workoutDaysPerWeek: 4,
      );

      final targets = BmiService.calculateCalorieTarget(profile);
      expect(targets.bmr, greaterThan(1500));
      expect(targets.targetCalories, lessThan(targets.maintenanceCalories));
      expect(targets.targetCalories, closeTo(targets.maintenanceCalories - 450, 20));
    });
  });

  group('CalorieCalculationService Tests', () {
    test('calculateCalorieBurn uses MET formula with intensity multiplier', () {
      // MET = 6.0, weight = 70 kg, duration = 30 mins (0.5 hrs), intensity = 'Intermediate' (mult = 1.0)
      // Calories = 6.0 * 70 * 0.5 * 1.0 = 210 kcal
      final burned = CalorieCalculationService.calculateCalorieBurn(
        metValue: 6.0,
        weightKg: 70.0,
        durationMinutes: 30.0,
        intensity: 'Intermediate',
      );
      expect(burned, closeTo(210.0, 1.0));
    });

    test('calculateCalorieBurn applies higher multiplier for Advanced level', () {
      final normalBurn = CalorieCalculationService.calculateCalorieBurn(
        metValue: 8.0,
        weightKg: 75.0,
        durationMinutes: 45.0,
        intensity: 'Intermediate',
      );

      final advancedBurn = CalorieCalculationService.calculateCalorieBurn(
        metValue: 8.0,
        weightKg: 75.0,
        durationMinutes: 45.0,
        intensity: 'Advanced',
      );

      expect(advancedBurn, greaterThan(normalBurn));
    });
  });

  group('StreakService Tests', () {
    test('calculateStreak returns 0 for empty history', () {
      final streak = StreakService.calculateStreak([]);
      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.isStreakActive, isFalse);
    });

    test('calculateStreak counts sequential consecutive days', () {
      final today = DateTime.now();
      final dates = [
        today,
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 2)),
      ];

      final streak = StreakService.calculateStreak(dates);
      expect(streak.currentStreak, 3);
      expect(streak.longestStreak, 3);
      expect(streak.isStreakActive, isTrue);
    });

    test('calculateStreak detects broken streak', () {
      final today = DateTime.now();
      final dates = [
        today.subtract(const Duration(days: 3)),
        today.subtract(const Duration(days: 4)),
      ];

      final streak = StreakService.calculateStreak(dates);
      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 2);
      expect(streak.isStreakActive, isFalse);
    });
  });

  group('WorkoutRecommendationService Tests', () {
    test('generatePersonalizedPlan matches user goal and creates valid routines', () {
      final profile = UserProfile(
        id: 'rec_user',
        name: 'Jordan',
        email: 'jordan@test.com',
        gender: AppConstants.genderFemale,
        age: 28,
        heightCm: 165.0,
        weightKg: 65.0,
        targetWeightKg: 60.0,
        fitnessGoal: AppConstants.goalWeightLoss,
        fitnessLevel: AppConstants.levelBeginner,
        preferredLocation: AppConstants.locationHome,
        workoutDaysPerWeek: 3,
      );

      final plan = WorkoutRecommendationService.generatePersonalizedPlan(profile);
      expect(plan.routines, isNotEmpty);
      expect(plan.goal, AppConstants.goalWeightLoss);
      expect(plan.routines.first.exercises, isNotEmpty);
      expect(plan.routines.first.location, AppConstants.locationHome);
    });

    test('getTodayRecommendedWorkout returns a workout routine', () {
      final profile = UserProfile.defaultProfile();
      final routine = WorkoutRecommendationService.getTodayRecommendedWorkout(profile);
      expect(routine.title, isNotEmpty);
      expect(routine.exercises, isNotEmpty);
    });
  });
}
