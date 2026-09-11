class AppConstants {
  static const String appName = 'FitTrack Pro';
  static const String appTagline = 'Smart Fitness Tracking & Workout Assistant';
  
  // Validation limits
  static const double minWeightKg = 20.0;
  static const double maxWeightKg = 300.0;
  static const double minHeightCm = 100.0;
  static const double maxHeightCm = 250.0;
  static const int minAge = 13;
  static const int maxAge = 100;

  // Goals
  static const String goalWeightLoss = 'Weight Loss';
  static const String goalMuscleGain = 'Muscle Gain';
  static const String goalMaintain = 'Maintain Weight';
  static const String goalLeanBody = 'Lean Body';
  static const String goalGeneralFitness = 'General Fitness';

  static const List<String> fitnessGoals = [
    goalWeightLoss,
    goalMuscleGain,
    goalMaintain,
    goalLeanBody,
    goalGeneralFitness,
  ];

  // Levels
  static const String levelBeginner = 'Beginner';
  static const String levelIntermediate = 'Intermediate';
  static const String levelAdvanced = 'Advanced';

  static const List<String> fitnessLevels = [
    levelBeginner,
    levelIntermediate,
    levelAdvanced,
  ];

  // Locations
  static const String locationHome = 'Home';
  static const String locationGym = 'Gym';
  static const String locationBoth = 'Both';

  static const List<String> workoutLocations = [
    locationHome,
    locationGym,
    locationBoth,
  ];

  // Workout Days per week options
  static const List<int> availableWorkoutDays = [3, 4, 5, 6, 7];

  // Exercise Categories
  static const List<String> exerciseCategories = [
    'All',
    'Chest',
    'Back',
    'Biceps',
    'Triceps',
    'Shoulders',
    'Legs',
    'Glutes',
    'Abs & Core',
    'Cardio & HIIT',
    'Full Body',
    'Stretching',
  ];

  // Equipment Types
  static const List<String> equipmentTypes = [
    'All',
    'No Equipment',
    'Dumbbells',
    'Resistance Band',
    'Barbell',
    'Machine',
    'Gym Equipment',
  ];
}
