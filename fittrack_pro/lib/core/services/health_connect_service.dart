class HealthDataRecord {
  final int steps;
  final double activeCalories;
  final double latestWeightKg;
  final DateTime syncTime;

  const HealthDataRecord({
    required this.steps,
    required this.activeCalories,
    required this.latestWeightKg,
    required this.syncTime,
  });
}

abstract class HealthConnectService {
  Future<bool> isAvailable();
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();
  Future<HealthDataRecord?> fetchTodayHealthData();
}

class HealthConnectServiceImpl implements HealthConnectService {
  bool _mockPermissionGranted = false;

  @override
  Future<bool> isAvailable() async {
    // Android Health Connect check placeholder
    return true;
  }

  @override
  Future<bool> requestPermissions() async {
    // In production, invokes Health Connect SDK permission intent
    _mockPermissionGranted = true;
    return true;
  }

  @override
  Future<bool> hasPermissions() async {
    return _mockPermissionGranted;
  }

  @override
  Future<HealthDataRecord?> fetchTodayHealthData() async {
    if (!_mockPermissionGranted) return null;
    return HealthDataRecord(
      steps: 6420,
      activeCalories: 380.0,
      latestWeightKg: 62.0,
      syncTime: DateTime.now(),
    );
  }
}
