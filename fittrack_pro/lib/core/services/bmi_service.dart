import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BMICategory {
  underweight,
  normal,
  overweight,
  obese,
}

class BMIResult {
  final double bmiValue;
  final BMICategory category;
  final String categoryName;
  final Color categoryColor;
  final double minHealthyWeightKg;
  final double maxHealthyWeightKg;

  const BMIResult({
    required this.bmiValue,
    required this.category,
    required this.categoryName,
    required this.categoryColor,
    required this.minHealthyWeightKg,
    required this.maxHealthyWeightKg,
  });
}

class BMIService {
  static BMIResult calculateBMI({
    required double weightKg,
    required double heightCm,
  }) {
    if (heightCm <= 0 || weightKg <= 0) {
      return const BMIResult(
        bmiValue: 0.0,
        category: BMICategory.normal,
        categoryName: 'Unknown',
        categoryColor: Colors.grey,
        minHealthyWeightKg: 0,
        maxHealthyWeightKg: 0,
      );
    }

    final heightM = heightCm / 100.0;
    final bmi = weightKg / (heightM * heightM);
    final roundedBmi = double.parse(bmi.toStringAsFixed(1));

    final minHealthy = double.parse((18.5 * heightM * heightM).toStringAsFixed(1));
    final maxHealthy = double.parse((24.9 * heightM * heightM).toStringAsFixed(1));

    BMICategory category;
    String categoryName;
    Color categoryColor;

    if (roundedBmi < 18.5) {
      category = BMICategory.underweight;
      categoryName = 'Underweight';
      categoryColor = AppColors.secondary;
    } else if (roundedBmi < 25.0) {
      category = BMICategory.normal;
      categoryName = 'Normal';
      categoryColor = AppColors.primary;
    } else if (roundedBmi < 30.0) {
      category = BMICategory.overweight;
      categoryName = 'Overweight';
      categoryColor = AppColors.warning;
    } else {
      category = BMICategory.obese;
      categoryName = 'Obese';
      categoryColor = AppColors.accent;
    }

    return BMIResult(
      bmiValue: roundedBmi,
      category: category,
      categoryName: categoryName,
      categoryColor: categoryColor,
      minHealthyWeightKg: minHealthy,
      maxHealthyWeightKg: maxHealthy,
    );
  }

  /// Calculates Daily Calorie Target based on Mifflin-St Jeor BMR equation & Activity Level / Goal
  static int calculateDailyCalorieTarget({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String goal,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) return 2200;

    // Base BMR (Mifflin-St Jeor)
    double bmr;
    if (gender.toLowerCase() == 'female') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    } else {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    }

    // Moderate activity multiplier ~1.4
    double tdee = bmr * 1.4;

    // Adjust based on fitness goal
    switch (goal.toLowerCase()) {
      case 'weight loss':
        tdee -= 450; // Caloric deficit
        break;
      case 'muscle gain':
        tdee += 350; // Caloric surplus
        break;
      case 'lean body':
        tdee -= 150; // Slight deficit / recomp
        break;
      case 'maintain weight':
      default:
        break;
    }

    return tdee.round().clamp(1200, 4500);
  }
}
