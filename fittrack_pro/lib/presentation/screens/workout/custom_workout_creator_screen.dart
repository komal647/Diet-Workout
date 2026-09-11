import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/workout.dart';
import '../../providers/fitness_providers.dart';

class CustomWorkoutCreatorScreen extends ConsumerStatefulWidget {
  const CustomWorkoutCreatorScreen({super.key});

  @override
  ConsumerState<CustomWorkoutCreatorScreen> createState() =>
      _CustomWorkoutCreatorScreenState();
}

class _CustomWorkoutCreatorScreenState
    extends ConsumerState<CustomWorkoutCreatorScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedGoal = AppConstants.goalMuscleBuilding;
  String _selectedLevel = AppConstants.levelIntermediate;
  String _selectedLocation = AppConstants.locationBoth;
  final List<WorkoutExercise> _selectedExercises = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _openAddExerciseModal() {
    final allExercises = ref.read(allExercisesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Select Exercise to Add',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: allExercises.length,
                    itemBuilder: (_, idx) {
                      final ex = allExercises[idx];
                      return ListTile(
                        leading: const Icon(Icons.fitness_center,
                            color: AppTheme.emerald),
                        title: Text(ex.name),
                        subtitle: Text('${ex.category} • ${ex.muscleGroup}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: AppTheme.emerald),
                          onPressed: () {
                            setState(() {
                              _selectedExercises.add(
                                WorkoutExercise.fromExercise(ex),
                              );
                            });
                            Navigator.of(ctx).pop();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveWorkout() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a routine title')),
      );
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

    final duration = _selectedExercises.length * 6; // approx 6 mins per exercise
    final estimatedCals = _selectedExercises.length * 50;

    final routine = WorkoutRoutine(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : 'Custom created routine with ${_selectedExercises.length} exercises.',
      targetGoal: _selectedGoal,
      targetLevel: _selectedLevel,
      location: _selectedLocation,
      durationMinutes: duration,
      estimatedCalories: estimatedCals,
      exercises: _selectedExercises,
      isCustom: true,
      createdAt: DateTime.now(),
    );

    final repo = ref.read(fitnessRepositoryProvider);
    await repo.saveCustomRoutine(routine);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved "${routine.title}" successfully!'),
          backgroundColor: AppTheme.emerald,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Routine'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Routine Title',
                hintText: 'e.g. Morning Arms & Abs Blast',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Quick notes or focus points...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGoal,
                    decoration: InputDecoration(
                      labelText: 'Goal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: AppConstants.fitnessGoals
                        .map((g) =>
                            DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedGoal = v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    decoration: InputDecoration(
                      labelText: 'Level',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: AppConstants.fitnessLevels
                        .map((l) =>
                            DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedLevel = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Exercises header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercises (${_selectedExercises.length})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_rounded, color: AppTheme.emerald),
                  label: const Text('Add Exercise',
                      style: TextStyle(color: AppTheme.emerald)),
                  onPressed: _openAddExerciseModal,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_selectedExercises.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Icon(Icons.fitness_center_outlined,
                        size: 48, color: Colors.grey[600]),
                    const SizedBox(height: 12),
                    const Text('No exercises added yet',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Tap "Add Exercise" to pick from 50+ movements',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedExercises.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _selectedExercises.removeAt(oldIndex);
                    _selectedExercises.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, idx) {
                  final ex = _selectedExercises[idx];
                  return Container(
                    key: ValueKey(ex.exerciseId + idx.toString()),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: Text(
                        '#${idx + 1}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.emerald),
                      ),
                      title: Text(ex.exerciseName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${ex.sets} sets • ${ex.reps} reps'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppTheme.crimson, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedExercises.removeAt(idx);
                              });
                            },
                          ),
                          const Icon(Icons.drag_handle, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emerald,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Custom Routine',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
