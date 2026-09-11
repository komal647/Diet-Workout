import '../constants/app_constants.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/workout.dart';

class WorkoutRecommendationService {
  /// Generates a complete tailored workout plan matching user attributes
  static WorkoutPlan generatePersonalizedPlan(UserProfile profile) {
    final goal = profile.fitnessGoal;
    final level = profile.fitnessLevel;
    final location = profile.preferredLocation;
    final days = profile.workoutDaysPerWeek.clamp(2, 6);

    final routines = _buildRoutinesForCriteria(
      goal: goal,
      level: level,
      location: location,
      days: days,
    );

    return WorkoutPlan(
      id: 'plan_${goal.toLowerCase().replaceAll(' ', '_')}_${level.toLowerCase()}',
      name: '${profile.fitnessLevel} ${profile.fitnessGoal} Plan',
      description:
          'Personalized $days-day program designed for ${profile.fitnessGoal.toLowerCase()} at ${profile.preferredLocation.toLowerCase()}.',
      goal: goal,
      level: level,
      daysPerWeek: days,
      routines: routines,
    );
  }

  /// Selects the recommended workout for today given the user's plan and streak/day index
  static WorkoutRoutine getTodayRecommendedWorkout(
    UserProfile profile, {
    int dayOffset = 0,
  }) {
    final plan = generatePersonalizedPlan(profile);
    if (plan.routines.isEmpty) {
      return _defaultFullBodyRoutine(profile.fitnessLevel, profile.preferredLocation);
    }
    final todayIndex = (DateTime.now().weekday - 1 + dayOffset) % plan.routines.length;
    return plan.routines[todayIndex];
  }

  static List<WorkoutRoutine> _buildRoutinesForCriteria({
    required String goal,
    required String level,
    required String location,
    required int days,
  }) {
    final isHome = location == AppConstants.locationHome;
    final isGym = location == AppConstants.locationGym;

    if (goal == AppConstants.goalWeightLoss) {
      return _buildWeightLossRoutines(level, isHome);
    } else if (goal == AppConstants.goalMuscleBuilding) {
      return _buildMuscleBuildingRoutines(level, isHome);
    } else if (goal == AppConstants.goalLeanTone) {
      return _buildLeanToneRoutines(level, isHome);
    } else {
      return _buildMaintenanceRoutines(level, isHome);
    }
  }

  // ---- GOAL: WEIGHT LOSS (HIIT + Full Body + Core) ----
  static List<WorkoutRoutine> _buildWeightLossRoutines(String level, bool isHome) {
    final sets = level == AppConstants.levelAdvanced ? 4 : (level == AppConstants.levelIntermediate ? 3 : 2);
    final reps = 15;
    final rest = level == AppConstants.levelAdvanced ? 30 : 45;

    return [
      WorkoutRoutine(
        id: 'wl_day1',
        title: 'Full Body Fat Burner',
        description: 'High-energy circuit activating large muscle groups to maximize caloric expenditure.',
        targetGoal: AppConstants.goalWeightLoss,
        targetLevel: level,
        location: isHome ? AppConstants.locationHome : AppConstants.locationGym,
        durationMinutes: 35,
        estimatedCalories: 320,
        exercises: [
          WorkoutExercise(exerciseId: 'jumping_jacks', exerciseName: 'Jumping Jacks', category: 'Cardio', sets: sets, reps: 30, restSeconds: rest, metValue: 8.0),
          WorkoutExercise(exerciseId: isHome ? 'bodyweight_squats' : 'goblet_squat', exerciseName: isHome ? 'Bodyweight Squats' : 'Goblet Squats', category: 'Legs', sets: sets, reps: reps, restSeconds: rest, metValue: 6.0),
          WorkoutExercise(exerciseId: isHome ? 'push_ups' : 'dumbbell_bench_press', exerciseName: isHome ? 'Push-Ups' : 'Dumbbell Bench Press', category: 'Chest', sets: sets, reps: reps, restSeconds: rest, metValue: 5.5),
          WorkoutExercise(exerciseId: 'mountain_climbers', exerciseName: 'Mountain Climbers', category: 'HIIT', sets: sets, reps: 24, restSeconds: rest, metValue: 8.5),
          WorkoutExercise(exerciseId: 'plank', exerciseName: 'Forearm Plank', category: 'Abs & Core', sets: sets, reps: 45, restSeconds: rest, metValue: 4.5),
        ],
      ),
      WorkoutRoutine(
        id: 'wl_day2',
        title: 'HIIT Cardio & Core Blast',
        description: 'Explosive intervals combined with targeted core stability movements.',
        targetGoal: AppConstants.goalWeightLoss,
        targetLevel: level,
        location: isHome ? AppConstants.locationHome : AppConstants.locationGym,
        durationMinutes: 30,
        estimatedCalories: 290,
        exercises: [
          WorkoutExercise(exerciseId: 'high_knees', exerciseName: 'High Knees', category: 'Cardio', sets: sets, reps: 30, restSeconds: rest, metValue: 8.0),
          WorkoutExercise(exerciseId: 'burpees', exerciseName: 'Burpees', category: 'HIIT', sets: sets, reps: 10, restSeconds: rest, metValue: 9.0),
          WorkoutExercise(exerciseId: 'bicycle_crunches', exerciseName: 'Bicycle Crunches', category: 'Abs & Core', sets: sets, reps: 20, restSeconds: rest, metValue: 5.0),
          WorkoutExercise(exerciseId: 'lunges', exerciseName: 'Walking Lunges', category: 'Legs', sets: sets, reps: 16, restSeconds: rest, metValue: 6.0),
          WorkoutExercise(exerciseId: 'russian_twists', exerciseName: 'Russian Twists', category: 'Abs & Core', sets: sets, reps: 24, restSeconds: rest, metValue: 4.5),
        ],
      ),
      WorkoutRoutine(
        id: 'wl_day3',
        title: 'Metabolic Conditioning',
        description: 'Paced resistance work engineered for sustained afterburn (EPOC).',
        targetGoal: AppConstants.goalWeightLoss,
        targetLevel: level,
        location: isHome ? AppConstants.locationHome : AppConstants.locationGym,
        durationMinutes: 40,
        estimatedCalories: 360,
        exercises: [
          WorkoutExercise(exerciseId: 'jump_rope', exerciseName: 'Jump Rope / Mock Rope', category: 'Cardio', sets: sets, reps: 50, restSeconds: rest, metValue: 8.8),
          WorkoutExercise(exerciseId: isHome ? 'glute_bridges' : 'romanian_deadlift', exerciseName: isHome ? 'Glute Bridges' : 'Romanian Deadlift', category: 'Legs', sets: sets, reps: reps, restSeconds: rest, metValue: 5.5),
          WorkoutExercise(exerciseId: isHome ? 'chair_dips' : 'triceps_rope_pushdown', exerciseName: isHome ? 'Chair / Bench Dips' : 'Triceps Rope Pushdown', category: 'Arms', sets: sets, reps: reps, restSeconds: rest, metValue: 4.5),
          WorkoutExercise(exerciseId: 'shadow_boxing', exerciseName: 'Shadow Boxing Combos', category: 'Cardio', sets: sets, reps: 40, restSeconds: rest, metValue: 7.5),
          WorkoutExercise(exerciseId: 'dead_bug', exerciseName: 'Dead Bug Core Hold', category: 'Abs & Core', sets: sets, reps: 16, restSeconds: rest, metValue: 4.0),
        ],
      ),
    ];
  }

  // ---- GOAL: MUSCLE BUILDING (Hypertrophy Splits) ----
  static List<WorkoutRoutine> _buildMuscleBuildingRoutines(String level, bool isHome) {
    final sets = level == AppConstants.levelAdvanced ? 4 : 3;
    final reps = 10;
    final rest = 75;

    return [
      WorkoutRoutine(
        id: 'mb_day1',
        title: 'Upper Body Power & Hypertrophy',
        description: 'Focus on chest, back, shoulders, and arms with progressive overload stimulus.',
        targetGoal: AppConstants.goalMuscleBuilding,
        targetLevel: level,
        location: isHome ? AppConstants.locationHome : AppConstants.locationGym,
        durationMinutes: 45,
        estimatedCalories: 280,
        exercises: [
          WorkoutExercise(exerciseId: isHome ? 'push_ups' : 'barbell_bench_press', exerciseName: isHome ? 'Push-Ups (Tempo)' : 'Barbell Bench Press', category: 'Chest', sets: sets, reps: reps, restSeconds: rest, metValue: 5.5),
          WorkoutExercise(exerciseId: isHome ? 'inverted_rows' : 'lat_pulldown', exerciseName: isHome ? 'Doorway / Table Rows' : 'Lat Pulldown', category: 'Back', sets: sets, reps: reps, restSeconds: rest, metValue: 5.5),
          WorkoutExercise(exerciseId: isHome ? 'pike_push_ups' : 'overhead_shoulder_press', exerciseName: isHome ? 'Pike Push-Ups' : 'Overhead Dumbbell Press', category: 'Shoulders', sets: sets, reps: reps, restSeconds: rest, metValue: 5.0),
          WorkoutExercise(exerciseId: isHome ? 'diamond_pushups' : 'dumbbell_bicep_curls', exerciseName: isHome ? 'Diamond Push-Ups' : 'Dumbbell Bicep Curls', category: 'Arms', sets: sets, reps: 12, restSeconds: 60, metValue: 4.5),
        ],
      ),
      WorkoutRoutine(
        id: 'mb_day2',
        title: 'Lower Body & Core Builder',
        description: 'Compound strength targeting quadriceps, hamstrings, glutes, and calves.',
        targetGoal: AppConstants.goalMuscleBuilding,
        targetLevel: level,
        location: isHome ? AppConstants.locationHome : AppConstants.locationGym,
        durationMinutes: 45,
        estimatedCalories: 310,
        exercises: [
          WorkoutExercise(exerciseId: isHome ? 'bulgarian_split_squats' : 'barbell_back_squats', exerciseName: isHome ? 'Bulgarian Split Squats' : 'Barbell Back Squats', category: 'Legs', sets: sets, reps: reps, restSeconds: 90, metValue: 6.5),
          WorkoutExercise(exerciseId: isHome ? 'single_leg_deadlift' : 'romanian_deadlift', exerciseName: isHome ? 'Single-Leg Bodyweight Deadlift' : 'Barbell Romanian Deadlift', category: 'Legs', sets: sets, reps: reps, restSeconds: rest, metValue: 6.0),
          WorkoutExercise(exerciseId: 'calf_raises', exerciseName: 'Standing Calf Raises', category: 'Legs', sets: sets, reps: 15, restSeconds: 45, metValue: 4.0),
          WorkoutExercise(exerciseId: 'hanging_leg_raises', exerciseName: isHome ? 'Lying Leg Raises' : 'Hanging Leg Raises', category: 'Abs & Core', sets: sets, reps: 12, restSeconds: 60, metValue: 4.5),
        ],
      ),
      WorkoutRoutine(
        id: 'mb_day3',
        title: 'Push-Pull Antagonist Focus',
        description: 'Complete upper body density session to balance anterior and posterior chains.',
        targetGoal: AppConstants.goalMuscleBuilding,
        targetLevel: level,
        location: isHome ? AppConstants.locationHome : AppConstants.locationGym,
        durationMinutes: 45,
        estimatedCalories: 290,
        exercises: [
          WorkoutExercise(exerciseId: isHome ? 'incline_push_ups' : 'incline_dumbbell_press', exerciseName: isHome ? 'Incline Feet-Elevated Push-Ups' : 'Incline Dumbbell Press', category: 'Chest', sets: sets, reps: reps, restSeconds: rest, metValue: 5.5),
          WorkoutExercise(exerciseId: isHome ? 'superman' : 'seated_cable_row', exerciseName: isHome ? 'Superman Holds' : 'Seated Cable Row', category: 'Back', sets: sets, reps: 12, restSeconds: rest, metValue: 5.0),
          WorkoutExercise(exerciseId: isHome ? 'lateral_raises_bands' : 'dumbbell_lateral_raise', exerciseName: isHome ? 'Resistance Lateral Raises' : 'Dumbbell Lateral Raise', category: 'Shoulders', sets: sets, reps: 14, restSeconds: 60, metValue: 4.5),
          WorkoutExercise(exerciseId: 'plank', exerciseName: 'Weighted or Plank Hold', category: 'Abs & Core', sets: sets, reps: 45, restSeconds: 60, metValue: 4.5),
        ],
      ),
    ];
  }

  // ---- GOAL: LEAN & TONE (High Reps + Density) ----
  static List<WorkoutRoutine> _buildLeanToneRoutines(String level, bool isHome) {
    return [
      WorkoutRoutine(
        id: 'lt_day1',
        title: 'Sculpt & Tone Full Body',
        description: 'Moderate loads with higher rep density for definition and endurance.',
        targetGoal: AppConstants.goalLeanTone,
        targetLevel: level,
        location: isHome ? AppConstants.locationHome : AppConstants.locationGym,
        durationMinutes: 35,
        estimatedCalories: 260,
        exercises: [
          WorkoutExercise(exerciseId: 'bodyweight_squats', exerciseName: 'Bodyweight Squats', category: 'Legs', sets: 3, reps: 18, restSeconds: 45, metValue: 5.5),
          WorkoutExercise(exerciseId: 'push_ups', exerciseName: 'Tempo Push-Ups', category: 'Chest', sets: 3, reps: 12, restSeconds: 45, metValue: 5.0),
          WorkoutExercise(exerciseId: 'glute_bridges', exerciseName: 'Single-Leg Glute Bridges', category: 'Legs', sets: 3, reps: 14, restSeconds: 45, metValue: 5.0),
          WorkoutExercise(exerciseId: 'plank', exerciseName: 'Side Plank Holds', category: 'Abs & Core', sets: 3, reps: 30, restSeconds: 45, metValue: 4.5),
        ],
      ),
      WorkoutRoutine(
        id: 'lt_day2',
        title: 'Cardio-Core Definition',
        description: 'Agility and abdominal definition circuit to boost tone and stamina.',
        targetGoal: AppConstants.goalLeanTone,
        targetLevel: level,
        location: isHome ? AppConstants.locationHome : AppConstants.locationGym,
        durationMinutes: 30,
        estimatedCalories: 240,
        exercises: [
          WorkoutExercise(exerciseId: 'mountain_climbers', exerciseName: 'Mountain Climbers', category: 'HIIT', sets: 3, reps: 20, restSeconds: 40, metValue: 8.0),
          WorkoutExercise(exerciseId: 'lunges', exerciseName: 'Reverse Lunges', category: 'Legs', sets: 3, reps: 16, restSeconds: 40, metValue: 5.5),
          WorkoutExercise(exerciseId: 'bicycle_crunches', exerciseName: 'Bicycle Crunches', category: 'Abs & Core', sets: 3, reps: 20, restSeconds: 40, metValue: 5.0),
          WorkoutExercise(exerciseId: 'jumping_jacks', exerciseName: 'Jumping Jacks', category: 'Cardio', sets: 3, reps: 35, restSeconds: 30, metValue: 7.5),
        ],
      ),
    ];
  }

  // ---- GOAL: MAINTENANCE (Functional & Balanced) ----
  static List<WorkoutRoutine> _buildMaintenanceRoutines(String level, bool isHome) {
    return [
      WorkoutRoutine(
        id: 'mn_day1',
        title: 'Functional Total Body Balance',
        description: 'Balanced strength, mobility, and cardiovascular health maintenance.',
        targetGoal: AppConstants.goalMaintainWeight,
        targetLevel: level,
        location: isHome ? AppConstants.locationHome : AppConstants.locationGym,
        durationMinutes: 35,
        estimatedCalories: 250,
        exercises: [
          WorkoutExercise(exerciseId: 'bodyweight_squats', exerciseName: 'Air Squats', category: 'Legs', sets: 3, reps: 15, restSeconds: 60, metValue: 5.0),
          WorkoutExercise(exerciseId: 'push_ups', exerciseName: 'Push-Ups', category: 'Chest', sets: 3, reps: 12, restSeconds: 60, metValue: 5.0),
          WorkoutExercise(exerciseId: 'superman', exerciseName: 'Back Extensions / Superman', category: 'Back', sets: 3, reps: 12, restSeconds: 60, metValue: 4.0),
          WorkoutExercise(exerciseId: 'plank', exerciseName: 'Classic Plank', category: 'Abs & Core', sets: 3, reps: 45, restSeconds: 60, metValue: 4.5),
        ],
      ),
    ];
  }

  static WorkoutRoutine _defaultFullBodyRoutine(String level, String location) {
    return WorkoutRoutine(
      id: 'default_routine',
      title: 'Quick Daily Full Body',
      description: 'Quick functional full body workout designed for all fitness levels.',
      targetGoal: AppConstants.goalMaintainWeight,
      targetLevel: level,
      location: location,
      durationMinutes: 25,
      estimatedCalories: 200,
      exercises: const [
        WorkoutExercise(exerciseId: 'bodyweight_squats', exerciseName: 'Bodyweight Squats', category: 'Legs', sets: 3, reps: 15, restSeconds: 60, metValue: 5.0),
        WorkoutExercise(exerciseId: 'push_ups', exerciseName: 'Push-Ups', category: 'Chest', sets: 3, reps: 10, restSeconds: 60, metValue: 5.0),
        WorkoutExercise(exerciseId: 'plank', exerciseName: 'Plank', category: 'Abs & Core', sets: 3, reps: 45, restSeconds: 60, metValue: 4.5),
      ],
    );
  }
}
