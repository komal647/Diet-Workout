import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/exercise_seed_data.dart';
import '../models/exercise.dart';
import '../models/user_profile.dart';
import '../models/weight_record.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';

/// FitnessRepository handles both Cloud Firestore persistence and
/// an immediate local/in-memory fallback so the app works seamlessly offline or without Firebase.
class FitnessRepository {
  final FirebaseFirestore? _firestore;
  SharedPreferences? _prefs;

  // Local in-memory caches
  UserProfile? _cachedProfile;
  final List<WeightRecord> _localWeightRecords = [];
  final List<WorkoutSession> _localWorkoutSessions = [];
  final List<WorkoutRoutine> _localCustomRoutines = [];
  final List<Exercise> _allExercises = [];

  FitnessRepository({FirebaseFirestore? firestore}) : _firestore = firestore {
    _initLocalExercises();
  }

  void _initLocalExercises() {
    _allExercises.addAll(ExerciseSeedData.getAllExercises());
  }

  Future<void> initLocal() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadFromPrefs();
    } catch (_) {
      // Preferences fallback
    }
  }

  void _loadFromPrefs() {
    if (_prefs == null) return;
    final profileJson = _prefs!.getString('user_profile');
    if (profileJson != null) {
      try {
        final map = jsonDecode(profileJson) as Map<String, dynamic>;
        _cachedProfile = UserProfile.fromMap(map);
      } catch (_) {}
    }

    final weightListJson = _prefs!.getStringList('weight_history');
    if (weightListJson != null) {
      _localWeightRecords.clear();
      for (final item in weightListJson) {
        try {
          _localWeightRecords.add(WeightRecord.fromMap(jsonDecode(item)));
        } catch (_) {}
      }
    }

    final sessionListJson = _prefs!.getStringList('workout_sessions');
    if (sessionListJson != null) {
      _localWorkoutSessions.clear();
      for (final item in sessionListJson) {
        try {
          _localWorkoutSessions.add(WorkoutSession.fromMap(jsonDecode(item)));
        } catch (_) {}
      }
    }
  }

  Future<void> _saveProfileToPrefs(UserProfile profile) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString('user_profile', jsonEncode(profile.toMap()));
  }

  Future<void> _saveWeightsToPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    final list = _localWeightRecords.map((r) => jsonEncode(r.toMap())).toList();
    await _prefs?.setStringList('weight_history', list);
  }

  Future<void> _saveSessionsToPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    final list = _localWorkoutSessions.map((s) => jsonEncode(s.toMap())).toList();
    await _prefs?.setStringList('workout_sessions', list);
  }

  // ---------------- USER PROFILE ----------------
  Future<UserProfile> getUserProfile(String userId) async {
    if (_firestore != null) {
      try {
        final doc = await _firestore!.collection('users').doc(userId).get();
        if (doc.exists && doc.data() != null) {
          final profile = UserProfile.fromMap(doc.data()!);
          _cachedProfile = profile;
          await _saveProfileToPrefs(profile);
          return profile;
        }
      } catch (_) {
        // Fallback to local
      }
    }
    return _cachedProfile ?? UserProfile.defaultProfile(userId: userId);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    _cachedProfile = profile;
    await _saveProfileToPrefs(profile);

    if (_firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(profile.id)
            .set(profile.toMap(), SetOptions(merge: true));
      } catch (_) {
        // Ignored in offline mode
      }
    }
  }

  // ---------------- WEIGHT RECORDS ----------------
  Future<List<WeightRecord>> getWeightHistory(String userId) async {
    if (_firestore != null) {
      try {
        final query = await _firestore!
            .collection('users')
            .doc(userId)
            .collection('weights')
            .orderBy('recordedAt', descending: true)
            .get();

        if (query.docs.isNotEmpty) {
          final records = query.docs
              .map((d) => WeightRecord.fromMap(d.data()))
              .toList();
          _localWeightRecords.clear();
          _localWeightRecords.addAll(records);
          await _saveWeightsToPrefs();
          return records;
        }
      } catch (_) {
        // Fallback to local
      }
    }

    if (_localWeightRecords.isEmpty) {
      // Seed an initial record based on profile
      final initialRecord = WeightRecord(
        id: 'init_weight',
        userId: userId,
        weightKg: _cachedProfile?.weightKg ?? 70.0,
        recordedAt: DateTime.now().subtract(const Duration(days: 7)),
        note: 'Baseline Weight',
      );
      _localWeightRecords.add(initialRecord);
    }
    _localWeightRecords.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return List.unmodifiable(_localWeightRecords);
  }

  Future<void> addWeightRecord(WeightRecord record) async {
    _localWeightRecords.removeWhere((r) => r.id == record.id);
    _localWeightRecords.insert(0, record);
    _localWeightRecords.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    await _saveWeightsToPrefs();

    if (_firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(record.userId)
            .collection('weights')
            .doc(record.id)
            .set(record.toMap());
      } catch (_) {
        // Fallback
      }
    }
  }

  // ---------------- EXERCISES ----------------
  List<Exercise> getExercises({
    String? category,
    String? level,
    String? location,
    String? query,
  }) {
    return _allExercises.where((ex) {
      if (category != null && category != 'All' && ex.category != category) {
        return false;
      }
      if (level != null && level != 'All' && ex.level != level) {
        return false;
      }
      if (location != null &&
          location != 'All' &&
          ex.location != 'Both' &&
          ex.location != location) {
        return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchName = ex.name.toLowerCase().contains(q);
        final matchCat = ex.category.toLowerCase().contains(q);
        final matchMuscle = ex.muscleGroup.toLowerCase().contains(q);
        if (!matchName && !matchCat && !matchMuscle) return false;
      }
      return true;
    }).toList();
  }

  Exercise? getExerciseById(String id) {
    try {
      return _allExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------------- WORKOUT SESSIONS ----------------
  Future<List<WorkoutSession>> getWorkoutSessions(String userId) async {
    if (_firestore != null) {
      try {
        final query = await _firestore!
            .collection('users')
            .doc(userId)
            .collection('sessions')
            .orderBy('startTime', descending: true)
            .get();

        if (query.docs.isNotEmpty) {
          final sessions = query.docs
              .map((d) => WorkoutSession.fromMap(d.data()))
              .toList();
          _localWorkoutSessions.clear();
          _localWorkoutSessions.addAll(sessions);
          await _saveSessionsToPrefs();
          return sessions;
        }
      } catch (_) {
        // Fallback
      }
    }
    _localWorkoutSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return List.unmodifiable(_localWorkoutSessions);
  }

  Future<void> saveWorkoutSession(WorkoutSession session) async {
    _localWorkoutSessions.removeWhere((s) => s.id == session.id);
    _localWorkoutSessions.insert(0, session);
    _localWorkoutSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    await _saveSessionsToPrefs();

    if (_firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(session.userId)
            .collection('sessions')
            .doc(session.id)
            .set(session.toMap());
      } catch (_) {
        // Ignored in offline
      }
    }
  }

  // ---------------- CUSTOM ROUTINES ----------------
  Future<List<WorkoutRoutine>> getCustomRoutines(String userId) async {
    return List.unmodifiable(_localCustomRoutines);
  }

  Future<void> saveCustomRoutine(WorkoutRoutine routine) async {
    _localCustomRoutines.removeWhere((r) => r.id == routine.id);
    _localCustomRoutines.add(routine);
  }
}
