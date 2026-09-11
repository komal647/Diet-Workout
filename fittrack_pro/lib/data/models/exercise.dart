class Exercise {
  final String id;
  final String name;
  final String category;
  final String muscleGroup;
  final String level; // Beginner, Intermediate, Advanced
  final String location; // Home, Gym, Both
  final String equipment;
  final String description;
  final List<String> instructions;
  final List<String> tips;
  final double metValue;
  final int defaultSets;
  final int defaultReps;
  final int defaultRestSeconds;
  final int estimatedDurationSeconds;
  final String? imageUrl;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroup,
    required this.level,
    required this.location,
    required this.equipment,
    required this.description,
    required this.instructions,
    this.tips = const [],
    required this.metValue,
    this.defaultSets = 3,
    this.defaultReps = 12,
    this.defaultRestSeconds = 60,
    this.estimatedDurationSeconds = 45,
    this.imageUrl,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? category,
    String? muscleGroup,
    String? level,
    String? location,
    String? equipment,
    String? description,
    List<String>? instructions,
    List<String>? tips,
    double? metValue,
    int? defaultSets,
    int? defaultReps,
    int? defaultRestSeconds,
    int? estimatedDurationSeconds,
    String? imageUrl,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      level: level ?? this.level,
      location: location ?? this.location,
      equipment: equipment ?? this.equipment,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      metValue: metValue ?? this.metValue,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      estimatedDurationSeconds:
          estimatedDurationSeconds ?? this.estimatedDurationSeconds,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'muscleGroup': muscleGroup,
      'level': level,
      'location': location,
      'equipment': equipment,
      'description': description,
      'instructions': instructions,
      'tips': tips,
      'metValue': metValue,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'defaultRestSeconds': defaultRestSeconds,
      'estimatedDurationSeconds': estimatedDurationSeconds,
      'imageUrl': imageUrl,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      muscleGroup: map['muscleGroup'] as String? ?? 'Full Body',
      level: map['level'] as String? ?? 'Beginner',
      location: map['location'] as String? ?? 'Both',
      equipment: map['equipment'] as String? ?? 'None',
      description: map['description'] as String? ?? '',
      instructions: (map['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      tips: (map['tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      metValue: (map['metValue'] as num?)?.toDouble() ?? 5.0,
      defaultSets: (map['defaultSets'] as num?)?.toInt() ?? 3,
      defaultReps: (map['defaultReps'] as num?)?.toInt() ?? 12,
      defaultRestSeconds: (map['defaultRestSeconds'] as num?)?.toInt() ?? 60,
      estimatedDurationSeconds:
          (map['estimatedDurationSeconds'] as num?)?.toInt() ?? 45,
      imageUrl: map['imageUrl'] as String?,
    );
  }
}
