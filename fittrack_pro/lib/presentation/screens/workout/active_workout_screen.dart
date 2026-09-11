import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/workout.dart';
import '../../providers/fitness_providers.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutRoutine routine;

  const ActiveWorkoutScreen({super.key, required this.routine});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  int _repsCompleted = 12;
  int _setsCompleted = 3;
  double _weightUsedKg = 0.0;
  int _rpe = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeWorkoutProvider.notifier).startWorkout(widget.routine);
      _syncExerciseInputs();
    });
  }

  void _syncExerciseInputs() {
    final current = ref.read(activeWorkoutProvider).currentExercise;
    if (current != null) {
      setState(() {
        _repsCompleted = current.reps;
        _setsCompleted = current.sets;
        _weightUsedKg = current.weightKg;
      });
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onCompleteExercise() {
    final activeState = ref.read(activeWorkoutProvider);
    if (activeState.isLastExercise) {
      _showFinishDialog();
    } else {
      ref.read(activeWorkoutProvider.notifier).completeCurrentExercise(
            customReps: _repsCompleted,
            customSets: _setsCompleted,
            customWeight: _weightUsedKg,
          );
    }
  }

  void _showFinishDialog() {
    final activeState = ref.read(activeWorkoutProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: const [
                Icon(Icons.emoji_events_rounded,
                    color: AppTheme.amber, size: 28),
                SizedBox(width: 10),
                Text('Workout Complete!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Great job crushing ${widget.routine.title}!',
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Duration',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(activeState.totalElapsedSeconds),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.electricBlue),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Calories',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            '${activeState.liveCaloriesBurned.round()} kcal',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.emerald),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'How intense was this workout? (RPE)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: _rpe.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: AppTheme.amber,
                  label: '$_rpe / 10',
                  onChanged: (v) {
                    setDialogState(() => _rpe = v.round());
                    setState(() => _rpe = v.round());
                  },
                ),
                Center(
                  child: Text(
                    'Effort: $_rpe / 10',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.amber),
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(activeWorkoutProvider.notifier)
                        .finishWorkout(perceivedEffort: _rpe);
                    if (mounted) {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emerald,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Workout to History',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeWorkoutProvider);
    final currentEx = activeState.currentExercise;

    // Listen to rest completion to sync next exercise defaults
    ref.listen<ActiveWorkoutState>(activeWorkoutProvider, (prev, next) {
      if (prev?.currentExerciseIndex != next.currentExerciseIndex) {
        _syncExerciseInputs();
      }
    });

    if (currentEx == null && !activeState.isRunning) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.routine.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Quit Workout?'),
            content: const Text(
                'Are you sure you want to end this workout session early? Your active progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(activeWorkoutProvider.notifier).cancelWorkout();
                  Navigator.of(ctx).pop(true);
                },
                child: const Text('Quit',
                    style: TextStyle(color: AppTheme.crimson)),
              ),
            ],
          ),
        );
        return shouldLeave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.routine.title),
          actions: [
            IconButton(
              icon: Icon(
                activeState.isPaused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                color: AppTheme.amber,
              ),
              onPressed: () {
                if (activeState.isPaused) {
                  ref.read(activeWorkoutProvider.notifier).resumeWorkout();
                } else {
                  ref.read(activeWorkoutProvider.notifier).pauseWorkout();
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Top Live Stats Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 18, color: AppTheme.electricBlue),
                      const SizedBox(width: 6),
                      Text(
                        _formatDuration(activeState.totalElapsedSeconds),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.electricBlue,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          size: 18, color: AppTheme.emerald),
                      const SizedBox(width: 6),
                      Text(
                        '${activeState.liveCaloriesBurned.round()} kcal',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.emerald,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Ex ${activeState.currentExerciseIndex + 1} / ${widget.routine.exercises.length}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Main Body: If resting show rest timer, else show exercise active view
            Expanded(
              child: activeState.isResting
                  ? _buildRestTimerView(activeState)
                  : _buildExerciseView(currentEx),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: activeState.isResting
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('+15s Rest'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppTheme.amber),
                            ),
                            onPressed: () {
                              ref
                                  .read(activeWorkoutProvider.notifier)
                                  .addRestTime(15);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.skip_next_rounded,
                                color: Colors.white),
                            label: const Text('Skip Rest',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.electricBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              ref
                                  .read(activeWorkoutProvider.notifier)
                                  .skipRest();
                            },
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _onCompleteExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeState.isLastExercise
                              ? AppTheme.amber
                              : AppTheme.emerald,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          activeState.isLastExercise
                              ? 'Finish Workout'
                              : 'Complete Exercise & Rest',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestTimerView(ActiveWorkoutState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'REST INTERVAL',
              style: TextStyle(
                color: AppTheme.amber,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: (state.restSecondsRemaining / 60).clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amber),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${state.restSecondsRemaining}',
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.amber,
                    ),
                  ),
                  const Text(
                    'seconds left',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 36),
          Text(
            'Catch your breath & hydrate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseView(WorkoutExercise? currentEx) {
    if (currentEx == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.emerald.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currentEx.category.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.emerald,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currentEx.exerciseName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),

          // Target configuration card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Sets Target',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                      '${currentEx.sets}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: Colors.white10),
                Column(
                  children: [
                    const Text('Reps Target',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                      '${currentEx.reps}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: Colors.white10),
                Column(
                  children: [
                    const Text('Rest After',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                      '${currentEx.restSeconds}s',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Text(
            'Actual Performance Log',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          // Log adjustments
          Row(
            children: [
              Expanded(
                child: _buildCounterField(
                  label: 'Completed Sets',
                  value: _setsCompleted,
                  onMinus: () {
                    if (_setsCompleted > 1) {
                      setState(() => _setsCompleted--);
                    }
                  },
                  onPlus: () => setState(() => _setsCompleted++),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildCounterField(
                  label: 'Reps per Set',
                  value: _repsCompleted,
                  onMinus: () {
                    if (_repsCompleted > 1) {
                      setState(() => _repsCompleted--);
                    }
                  },
                  onPlus: () => setState(() => _repsCompleted++),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildWeightField(),
        ],
      ),
    );
  }

  Widget _buildCounterField({
    required String label,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 24),
                onPressed: onMinus,
              ),
              Text(
                '$value',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 24),
                onPressed: onPlus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Weight Loaded (kg)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                onPressed: () {
                  if (_weightUsedKg >= 2.5) {
                    setState(() => _weightUsedKg -= 2.5);
                  }
                },
              ),
              Text(
                '${_weightUsedKg.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.emerald,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () {
                  setState(() => _weightUsedKg += 2.5);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
