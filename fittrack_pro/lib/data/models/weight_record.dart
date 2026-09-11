class WeightRecord {
  final String id;
  final String userId;
  final double weightKg;
  final DateTime recordedAt;
  final String? note;
  final double? bmi;

  const WeightRecord({
    required this.id,
    required this.userId,
    required this.weightKg,
    required this.recordedAt,
    this.note,
    this.bmi,
  });

  WeightRecord copyWith({
    String? id,
    String? userId,
    double? weightKg,
    DateTime? recordedAt,
    String? note,
    double? bmi,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weightKg: weightKg ?? this.weightKg,
      recordedAt: recordedAt ?? this.recordedAt,
      note: note ?? this.note,
      bmi: bmi ?? this.bmi,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'weightKg': weightKg,
      'recordedAt': recordedAt.toIso8601String(),
      'note': note,
      'bmi': bmi,
    };
  }

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      recordedAt: map['recordedAt'] != null
          ? DateTime.tryParse(map['recordedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      note: map['note'] as String?,
      bmi: (map['bmi'] as num?)?.toDouble(),
    );
  }
}
