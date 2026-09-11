import 'exercise.dart';

class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final int sets;
  final int reps;
  final int restSeconds;
  final double weightKg;
  final double metValue;
  final String? notes;

  const WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    this.sets = 3,
    this.reps = 12,
    this.restSeconds = 60,
    this.weightKg = 0.0,
    this.metValue = 5.0,
    this.notes,
  });

  factory WorkoutExercise.fromExercise(
    Exercise exercise, {
    int? sets,
    int? reps,
    int? restSeconds,
    double? weightKg,
    String? notes,
  }) {
    return WorkoutExercise(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      category: exercise.category,
      sets: sets ?? exercise.defaultSets,
      reps: reps ?? exercise.defaultReps,
      restSeconds: restSeconds ?? exercise.defaultRestSeconds,
      weightKg: weightKg ?? 0.0,
      metValue: exercise.metValue,
      notes: notes,
    );
  }

  WorkoutExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    String? category,
    int? sets,
    int? reps,
    int? restSeconds,
    double? weightKg,
    double? metValue,
    String? notes,
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      category: category ?? this.category,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      weightKg: weightKg ?? this.weightKg,
      metValue: metValue ?? this.metValue,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'category': category,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'weightKg': weightKg,
      'metValue': metValue,
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exerciseId: map['exerciseId'] as String? ?? '',
      exerciseName: map['exerciseName'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] as num?)?.toInt() ?? 12,
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 60,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      metValue: (map['metValue'] as num?)?.toDouble() ?? 5.0,
      notes: map['notes'] as String?,
    );
  }
}

class WorkoutRoutine {
  final String id;
  final String title;
  final String description;
  final String targetGoal;
  final String targetLevel;
  final String location;
  final int durationMinutes;
  final int estimatedCalories;
  final List<WorkoutExercise> exercises;
  final bool isCustom;
  final String? createdBy;
  final DateTime? createdAt;

  const WorkoutRoutine({
    required this.id,
    required this.title,
    required this.description,
    required this.targetGoal,
    required this.targetLevel,
    required this.location,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.exercises,
    this.isCustom = false,
    this.createdBy,
    this.createdAt,
  });

  WorkoutRoutine copyWith({
    String? id,
    String? title,
    String? description,
    String? targetGoal,
    String? targetLevel,
    String? location,
    int? durationMinutes,
    int? estimatedCalories,
    List<WorkoutExercise>? exercises,
    bool? isCustom,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return WorkoutRoutine(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetGoal: targetGoal ?? this.targetGoal,
      targetLevel: targetLevel ?? this.targetLevel,
      location: location ?? this.location,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      exercises: exercises ?? this.exercises,
      isCustom: isCustom ?? this.isCustom,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetGoal': targetGoal,
      'targetLevel': targetLevel,
      'location': location,
      'durationMinutes': durationMinutes,
      'estimatedCalories': estimatedCalories,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'isCustom': isCustom,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory WorkoutRoutine.fromMap(Map<String, dynamic> map) {
    return WorkoutRoutine(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      targetGoal: map['targetGoal'] as String? ?? '',
      targetLevel: map['targetLevel'] as String? ?? '',
      location: map['location'] as String? ?? '',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 30,
      estimatedCalories: (map['estimatedCalories'] as num?)?.toInt() ?? 200,
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCustom: map['isCustom'] as bool? ?? false,
      createdBy: map['createdBy'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }
}

class WorkoutPlan {
  final String id;
  final String name;
  final String description;
  final String goal;
  final String level;
  final int daysPerWeek;
  final List<WorkoutRoutine> routines;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    required this.routines,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'goal': goal,
      'level': level,
      'daysPerWeek': daysPerWeek,
      'routines': routines.map((r) => r.toMap()).toList(),
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutPlan(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      goal: map['goal'] as String? ?? '',
      level: map['level'] as String? ?? '',
      daysPerWeek: (map['daysPerWeek'] as num?)?.toInt() ?? 3,
      routines: (map['routines'] as List<dynamic>?)
              ?.map((r) => WorkoutRoutine.fromMap(r as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
