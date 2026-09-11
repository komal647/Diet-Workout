enum ExerciseIntensity {
  low,
  medium,
  high,
}

extension ExerciseIntensityExtension on ExerciseIntensity {
  String get displayName {
    switch (this) {
      case ExerciseIntensity.low:
        return 'Low';
      case ExerciseIntensity.medium:
        return 'Medium';
      case ExerciseIntensity.high:
        return 'High';
    }
  }

  double get multiplier {
    switch (this) {
      case ExerciseIntensity.low:
        return 0.85;
      case ExerciseIntensity.medium:
        return 1.0;
      case ExerciseIntensity.high:
        return 1.25;
    }
  }
}

class CalorieCalculationService {
  /// Calculates estimated calories burned using standard MET formula:
  /// Calories = MET * Weight (kg) * (Duration in minutes / 60) * Intensity Multiplier
  static int calculateCaloriesBurned({
    required double met,
    required double weightKg,
    required int durationMinutes,
    ExerciseIntensity intensity = ExerciseIntensity.medium,
  }) {
    if (met <= 0 || weightKg <= 0 || durationMinutes <= 0) return 0;

    final durationHours = durationMinutes / 60.0;
    final baseCalories = met * weightKg * durationHours;
    final totalCalories = baseCalories * intensity.multiplier;

    return totalCalories.round();
  }

  /// Convenience method for calculating calories by sets & reps
  static int estimateSetCalories({
    required double met,
    required double weightKg,
    required int sets,
    required int reps,
    ExerciseIntensity intensity = ExerciseIntensity.medium,
  }) {
    // Average set duration estimation: ~4 seconds per rep + set setup ~ 45s
    final approxSeconds = sets * (reps * 4 + 15);
    final durationMinutes = (approxSeconds / 60.0).clamp(1.0, 60.0).round();
    return calculateCaloriesBurned(
      met: met,
      weightKg: weightKg,
      durationMinutes: durationMinutes,
      intensity: intensity,
    );
  }
}
