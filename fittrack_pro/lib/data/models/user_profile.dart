class UserProfile {
  final String id;
  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final String goal;
  final String fitnessLevel;
  final String workoutLocation;
  final int workoutDaysPerWeek;
  final int dailyCalorieTarget;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.goal,
    required this.fitnessLevel,
    required this.workoutLocation,
    required this.workoutDaysPerWeek,
    required this.dailyCalorieTarget,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? goal,
    String? fitnessLevel,
    String? workoutLocation,
    int? workoutDaysPerWeek,
    int? dailyCalorieTarget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      goal: goal ?? this.goal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      workoutLocation: workoutLocation ?? this.workoutLocation,
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'currentWeightKg': currentWeightKg,
      'targetWeightKg': targetWeightKg,
      'goal': goal,
      'fitnessLevel': fitnessLevel,
      'workoutLocation': workoutLocation,
      'workoutDaysPerWeek': workoutDaysPerWeek,
      'dailyCalorieTarget': dailyCalorieTarget,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? 'User',
      age: (map['age'] as num?)?.toInt() ?? 25,
      gender: map['gender'] ?? 'Other',
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 175.0,
      currentWeightKg: (map['currentWeightKg'] as num?)?.toDouble() ?? 62.0,
      targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble() ?? 58.0,
      goal: map['goal'] ?? 'Maintain Weight',
      fitnessLevel: map['fitnessLevel'] ?? 'Intermediate',
      workoutLocation: map['workoutLocation'] ?? 'Home',
      workoutDaysPerWeek: (map['workoutDaysPerWeek'] as num?)?.toInt() ?? 5,
      dailyCalorieTarget: (map['dailyCalorieTarget'] as num?)?.toInt() ?? 2200,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static UserProfile defaultProfile() {
    return UserProfile(
      id: 'default_user',
      name: 'Athlete',
      age: 24,
      gender: 'Male',
      heightCm: 175.0,
      currentWeightKg: 62.0,
      targetWeightKg: 58.0,
      goal: 'Muscle Gain',
      fitnessLevel: 'Intermediate',
      workoutLocation: 'Home',
      workoutDaysPerWeek: 5,
      dailyCalorieTarget: 2300,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
