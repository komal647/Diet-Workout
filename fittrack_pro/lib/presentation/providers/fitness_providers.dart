import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/calorie_calculation_service.dart';
import '../../core/services/streak_service.dart';
import '../../core/services/workout_recommendation_service.dart';
import '../../data/models/exercise.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/weight_record.dart';
import '../../data/models/workout.dart';
import '../../data/models/workout_session.dart';
import '../../data/repositories/fitness_repository.dart';

// ---------------- REPOSITORY PROVIDER ----------------
final fitnessRepositoryProvider = Provider<FitnessRepository>((ref) {
  return FitnessRepository();
});

// ---------------- THEME MODE PROVIDER ----------------
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// ---------------- USER PROFILE PROVIDER ----------------
class UserProfileNotifier extends StateNotifier<UserProfile> {
  final FitnessRepository _repository;
  final Ref _ref;

  UserProfileNotifier(this._repository, this._ref)
      : super(UserProfile.defaultProfile()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _repository.getUserProfile('user_demo_01');
    state = profile;
  }

  Future<void> updateWeight(double newWeightKg, {String? note}) async {
    final updated = state.copyWith(
      weightKg: newWeightKg,
      updatedAt: DateTime.now(),
    );
    state = updated;
    await _repository.saveUserProfile(updated);

    // Automatically create a weight record in weight history
    final record = WeightRecord(
      id: const Uuid().v4(),
      userId: updated.id,
      weightKg: newWeightKg,
      recordedAt: DateTime.now(),
      note: note ?? 'Weight updated via profile',
      bmi: updated.bmi,
    );
    await _ref.read(weightHistoryProvider.notifier).addRecord(record);
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    state = newProfile.copyWith(updatedAt: DateTime.now());
    await _repository.saveUserProfile(state);
  }

  Future<void> updateGoal(String goal) async {
    final updated = state.copyWith(
      fitnessGoal: goal,
      updatedAt: DateTime.now(),
    );
    state = updated;
    await _repository.saveUserProfile(updated);
  }

  Future<void> updateFitnessLevel(String level) async {
    final updated = state.copyWith(
      fitnessLevel: level,
      updatedAt: DateTime.now(),
    );
    state = updated;
    await _repository.saveUserProfile(updated);
  }

  Future<void> updateLocation(String location) async {
    final updated = state.copyWith(
      preferredLocation: location,
      updatedAt: DateTime.now(),
    );
    state = updated;
    await _repository.saveUserProfile(updated);
  }

  Future<void> updateDaysPerWeek(int days) async {
    final updated = state.copyWith(
      workoutDaysPerWeek: days,
      updatedAt: DateTime.now(),
    );
    state = updated;
    await _repository.saveUserProfile(updated);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  final repo = ref.watch(fitnessRepositoryProvider);
  return UserProfileNotifier(repo, ref);
});

// ---------------- WEIGHT HISTORY PROVIDER ----------------
class WeightHistoryNotifier extends StateNotifier<List<WeightRecord>> {
  final FitnessRepository _repository;
  final String _userId;

  WeightHistoryNotifier(this._repository, this._userId) : super([]) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    final history = await _repository.getWeightHistory(_userId);
    state = history;
  }

  Future<void> addRecord(WeightRecord record) async {
    await _repository.addWeightRecord(record);
    state = [record, ...state.where((r) => r.id != record.id)];
  }
}

final weightHistoryProvider =
    StateNotifierProvider<WeightHistoryNotifier, List<WeightRecord>>((ref) {
  final repo = ref.watch(fitnessRepositoryProvider);
  final user = ref.watch(userProfileProvider);
  return WeightHistoryNotifier(repo, user.id);
});

// ---------------- EXERCISE SEARCH & FILTER PROVIDERS ----------------
final exerciseCategoryFilterProvider = StateProvider<String>((ref) => 'All');
final exerciseLevelFilterProvider = StateProvider<String>((ref) => 'All');
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

final allExercisesProvider = Provider<List<Exercise>>((ref) {
  final repo = ref.watch(fitnessRepositoryProvider);
  return repo.getExercises();
});

final filteredExercisesProvider = Provider<List<Exercise>>((ref) {
  final repo = ref.watch(fitnessRepositoryProvider);
  final category = ref.watch(exerciseCategoryFilterProvider);
  final level = ref.watch(exerciseLevelFilterProvider);
  final query = ref.watch(exerciseSearchQueryProvider);

  return repo.getExercises(
    category: category,
    level: level,
    query: query,
  );
});

// ---------------- WORKOUT RECOMMENDATION PROVIDERS ----------------
final recommendedWorkoutPlanProvider = Provider<WorkoutPlan>((ref) {
  final profile = ref.watch(userProfileProvider);
  return WorkoutRecommendationService.generatePersonalizedPlan(profile);
});

final todayRecommendedWorkoutProvider = Provider<WorkoutRoutine>((ref) {
  final profile = ref.watch(userProfileProvider);
  return WorkoutRecommendationService.getTodayRecommendedWorkout(profile);
});

// ---------------- WORKOUT SESSIONS & HISTORY ----------------
class WorkoutSessionsNotifier extends StateNotifier<List<WorkoutSession>> {
  final FitnessRepository _repository;
  final String _userId;

  WorkoutSessionsNotifier(this._repository, this._userId) : super([]) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    final sessions = await _repository.getWorkoutSessions(_userId);
    state = sessions;
  }

  Future<void> recordCompletedSession(WorkoutSession session) async {
    await _repository.saveWorkoutSession(session);
    state = [session, ...state.where((s) => s.id != session.id)];
  }
}

final workoutSessionsProvider =
    StateNotifierProvider<WorkoutSessionsNotifier, List<WorkoutSession>>((ref) {
  final repo = ref.watch(fitnessRepositoryProvider);
  final user = ref.watch(userProfileProvider);
  return WorkoutSessionsNotifier(repo, user.id);
});

// ---------------- STREAK & STATS COMPUTED PROVIDERS ----------------
final streakStatsProvider = Provider<StreakInfo>((ref) {
  final sessions = ref.watch(workoutSessionsProvider);
  final dates = sessions
      .where((s) => s.isCompleted)
      .map((s) => s.startTime)
      .toList();
  return StreakService.calculateStreak(dates);
});

final todayCaloriesBurnedProvider = Provider<double>((ref) {
  final sessions = ref.watch(workoutSessionsProvider);
  final now = DateTime.now();
  final todaySessions = sessions.where((s) =>
      s.isCompleted &&
      s.startTime.year == now.year &&
      s.startTime.month == now.month &&
      s.startTime.day == now.day);

  return todaySessions.fold<double>(
      0.0, (acc, s) => acc + s.totalCaloriesBurned);
});

final todayWorkoutMinutesProvider = Provider<int>((ref) {
  final sessions = ref.watch(workoutSessionsProvider);
  final now = DateTime.now();
  final todaySessions = sessions.where((s) =>
      s.isCompleted &&
      s.startTime.year == now.year &&
      s.startTime.month == now.month &&
      s.startTime.day == now.day);

  return todaySessions.fold<int>(
      0, (acc, s) => acc + (s.totalDurationSeconds ~/ 60));
});

// ---------------- ACTIVE WORKOUT SESSION STATE ----------------
class ActiveWorkoutState {
  final WorkoutRoutine? routine;
  final int currentExerciseIndex;
  final int totalElapsedSeconds;
  final bool isRunning;
  final bool isPaused;
  final bool isResting;
  final int restSecondsRemaining;
  final List<CompletedExerciseRecord> completedExercises;
  final double liveCaloriesBurned;

  const ActiveWorkoutState({
    this.routine,
    this.currentExerciseIndex = 0,
    this.totalElapsedSeconds = 0,
    this.isRunning = false,
    this.isPaused = false,
    this.isResting = false,
    this.restSecondsRemaining = 0,
    this.completedExercises = const [],
    this.liveCaloriesBurned = 0.0,
  });

  WorkoutExercise? get currentExercise {
    if (routine == null || routine!.exercises.isEmpty) return null;
    if (currentExerciseIndex < 0 ||
        currentExerciseIndex >= routine!.exercises.length) {
      return null;
    }
    return routine!.exercises[currentExerciseIndex];
  }

  bool get isLastExercise {
    if (routine == null) return true;
    return currentExerciseIndex >= routine!.exercises.length - 1;
  }

  ActiveWorkoutState copyWith({
    WorkoutRoutine? routine,
    int? currentExerciseIndex,
    int? totalElapsedSeconds,
    bool? isRunning,
    bool? isPaused,
    bool? isResting,
    int? restSecondsRemaining,
    List<CompletedExerciseRecord>? completedExercises,
    double? liveCaloriesBurned,
  }) {
    return ActiveWorkoutState(
      routine: routine ?? this.routine,
      currentExerciseIndex:
          currentExerciseIndex ?? this.currentExerciseIndex,
      totalElapsedSeconds: totalElapsedSeconds ?? this.totalElapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      isResting: isResting ?? this.isResting,
      restSecondsRemaining:
          restSecondsRemaining ?? this.restSecondsRemaining,
      completedExercises: completedExercises ?? this.completedExercises,
      liveCaloriesBurned: liveCaloriesBurned ?? this.liveCaloriesBurned,
    );
  }
}

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  final Ref _ref;
  Timer? _ticker;

  ActiveWorkoutNotifier(this._ref) : super(const ActiveWorkoutState());

  void startWorkout(WorkoutRoutine routine) {
    _ticker?.cancel();
    state = ActiveWorkoutState(
      routine: routine,
      currentExerciseIndex: 0,
      totalElapsedSeconds: 0,
      isRunning: true,
      isPaused: false,
      isResting: false,
      restSecondsRemaining: 0,
      completedExercises: const [],
      liveCaloriesBurned: 0.0,
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer timer) {
    if (!state.isRunning || state.isPaused) return;

    final newElapsed = state.totalElapsedSeconds + 1;
    final profile = _ref.read(userProfileProvider);

    // Calculate dynamic calories
    final currentEx = state.currentExercise;
    final met = currentEx?.metValue ?? 5.0;
    final cals = CalorieCalculationService.calculateCalorieBurn(
      metValue: met,
      weightKg: profile.weightKg,
      durationMinutes: newElapsed / 60.0,
      intensity: profile.fitnessLevel,
    );

    if (state.isResting) {
      if (state.restSecondsRemaining > 1) {
        state = state.copyWith(
          totalElapsedSeconds: newElapsed,
          liveCaloriesBurned: cals,
          restSecondsRemaining: state.restSecondsRemaining - 1,
        );
      } else {
        // Rest complete, proceed to next exercise
        state = state.copyWith(
          totalElapsedSeconds: newElapsed,
          liveCaloriesBurned: cals,
          isResting: false,
          restSecondsRemaining: 0,
          currentExerciseIndex: state.currentExerciseIndex + 1,
        );
      }
    } else {
      state = state.copyWith(
        totalElapsedSeconds: newElapsed,
        liveCaloriesBurned: cals,
      );
    }
  }

  void pauseWorkout() {
    state = state.copyWith(isPaused: true);
  }

  void resumeWorkout() {
    state = state.copyWith(isPaused: false);
  }

  void completeCurrentExercise({
    int? customReps,
    int? customSets,
    double? customWeight,
  }) {
    final currentEx = state.currentExercise;
    if (currentEx == null) return;

    final profile = _ref.read(userProfileProvider);
    final completedRecord = CompletedExerciseRecord(
      exerciseId: currentEx.exerciseId,
      exerciseName: currentEx.exerciseName,
      category: currentEx.category,
      setsCompleted: customSets ?? currentEx.sets,
      repsCompleted: customReps ?? currentEx.reps,
      weightUsedKg: customWeight ?? currentEx.weightKg,
      durationSeconds: 60,
      caloriesBurned: CalorieCalculationService.estimateExerciseBurn(
        exercise: null,
        sets: customSets ?? currentEx.sets,
        reps: customReps ?? currentEx.reps,
        weightKg: profile.weightKg,
        fallbackMet: currentEx.metValue,
      ),
      completedAt: DateTime.now(),
    );

    final updatedRecords = [...state.completedExercises, completedRecord];

    if (state.isLastExercise) {
      // Finished all exercises
      state = state.copyWith(
        completedExercises: updatedRecords,
      );
    } else {
      // Enter rest period
      state = state.copyWith(
        completedExercises: updatedRecords,
        isResting: true,
        restSecondsRemaining: currentEx.restSeconds > 0 ? currentEx.restSeconds : 45,
      );
    }
  }

  void addRestTime(int seconds) {
    if (state.isResting) {
      state = state.copyWith(
        restSecondsRemaining: state.restSecondsRemaining + seconds,
      );
    }
  }

  void skipRest() {
    if (state.isResting) {
      state = state.copyWith(
        isResting: false,
        restSecondsRemaining: 0,
        currentExerciseIndex: state.currentExerciseIndex + 1,
      );
    }
  }

  Future<WorkoutSession?> finishWorkout({int perceivedEffort = 7, String? notes}) async {
    _ticker?.cancel();
    if (state.routine == null) return null;

    final profile = _ref.read(userProfileProvider);
    final session = WorkoutSession(
      id: const Uuid().v4(),
      userId: profile.id,
      routineId: state.routine?.id,
      workoutTitle: state.routine?.title ?? 'Completed Workout',
      startTime: DateTime.now().subtract(
        Duration(seconds: state.totalElapsedSeconds),
      ),
      endTime: DateTime.now(),
      totalDurationSeconds: state.totalElapsedSeconds,
      totalCaloriesBurned: state.liveCaloriesBurned > 0
          ? state.liveCaloriesBurned
          : (state.routine?.estimatedCalories.toDouble() ?? 150.0),
      completedExercises: state.completedExercises,
      isCompleted: true,
      perceivedEffort: perceivedEffort,
      notes: notes,
    );

    // Save to history & repository
    await _ref
        .read(workoutSessionsProvider.notifier)
        .recordCompletedSession(session);

    state = const ActiveWorkoutState();
    return session;
  }

  void cancelWorkout() {
    _ticker?.cancel();
    state = const ActiveWorkoutState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>((ref) {
  return ActiveWorkoutNotifier(ref);
});
