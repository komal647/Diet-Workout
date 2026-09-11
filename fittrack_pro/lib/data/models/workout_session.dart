class CompletedExerciseRecord {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final int setsCompleted;
  final int repsCompleted;
  final double weightUsedKg;
  final int durationSeconds;
  final double caloriesBurned;
  final DateTime completedAt;

  const CompletedExerciseRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.setsCompleted,
    required this.repsCompleted,
    this.weightUsedKg = 0.0,
    required this.durationSeconds,
    required this.caloriesBurned,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'category': category,
      'setsCompleted': setsCompleted,
      'repsCompleted': repsCompleted,
      'weightUsedKg': weightUsedKg,
      'durationSeconds': durationSeconds,
      'caloriesBurned': caloriesBurned,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory CompletedExerciseRecord.fromMap(Map<String, dynamic> map) {
    return CompletedExerciseRecord(
      exerciseId: map['exerciseId'] as String? ?? '',
      exerciseName: map['exerciseName'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      setsCompleted: (map['setsCompleted'] as num?)?.toInt() ?? 0,
      repsCompleted: (map['repsCompleted'] as num?)?.toInt() ?? 0,
      weightUsedKg: (map['weightUsedKg'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toDouble() ?? 0.0,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class WorkoutSession {
  final String id;
  final String userId;
  final String? routineId;
  final String workoutTitle;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalDurationSeconds;
  final double totalCaloriesBurned;
  final List<CompletedExerciseRecord> completedExercises;
  final bool isCompleted;
  final int perceivedEffort; // 1 - 10
  final String? notes;

  const WorkoutSession({
    required this.id,
    required this.userId,
    this.routineId,
    required this.workoutTitle,
    required this.startTime,
    this.endTime,
    this.totalDurationSeconds = 0,
    this.totalCaloriesBurned = 0.0,
    this.completedExercises = const [],
    this.isCompleted = false,
    this.perceivedEffort = 5,
    this.notes,
  });

  WorkoutSession copyWith({
    String? id,
    String? userId,
    String? routineId,
    String? workoutTitle,
    DateTime? startTime,
    DateTime? endTime,
    int? totalDurationSeconds,
    double? totalCaloriesBurned,
    List<CompletedExerciseRecord>? completedExercises,
    bool? isCompleted,
    int? perceivedEffort,
    String? notes,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      routineId: routineId ?? this.routineId,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      totalCaloriesBurned: totalCaloriesBurned ?? this.totalCaloriesBurned,
      completedExercises: completedExercises ?? this.completedExercises,
      isCompleted: isCompleted ?? this.isCompleted,
      perceivedEffort: perceivedEffort ?? this.perceivedEffort,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'routineId': routineId,
      'workoutTitle': workoutTitle,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalDurationSeconds': totalDurationSeconds,
      'totalCaloriesBurned': totalCaloriesBurned,
      'completedExercises': completedExercises.map((e) => e.toMap()).toList(),
      'isCompleted': isCompleted,
      'perceivedEffort': perceivedEffort,
      'notes': notes,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      routineId: map['routineId'] as String?,
      workoutTitle: map['workoutTitle'] as String? ?? 'Workout Session',
      startTime: map['startTime'] != null
          ? DateTime.tryParse(map['startTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      endTime: map['endTime'] != null
          ? DateTime.tryParse(map['endTime'] as String)
          : null,
      totalDurationSeconds:
          (map['totalDurationSeconds'] as num?)?.toInt() ?? 0,
      totalCaloriesBurned:
          (map['totalCaloriesBurned'] as num?)?.toDouble() ?? 0.0,
      completedExercises: (map['completedExercises'] as List<dynamic>?)
              ?.map((e) =>
                  CompletedExerciseRecord.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCompleted: map['isCompleted'] as bool? ?? false,
      perceivedEffort: (map['perceivedEffort'] as num?)?.toInt() ?? 5,
      notes: map['notes'] as String?,
    );
  }
}

class DailyFitnessSummary {
  final DateTime date;
  final double caloriesBurned;
  final int minutesExercised;
  final int workoutsCompleted;
  final double? weightKg;

  const DailyFitnessSummary({
    required this.date,
    required this.caloriesBurned,
    required this.minutesExercised,
    required this.workoutsCompleted,
    this.weightKg,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'caloriesBurned': caloriesBurned,
      'minutesExercised': minutesExercised,
      'workoutsCompleted': workoutsCompleted,
      'weightKg': weightKg,
    };
  }
}
