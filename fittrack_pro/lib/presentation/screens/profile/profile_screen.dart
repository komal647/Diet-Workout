import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/bmi_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/fitness_providers.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showWeightUpdateModal() {
    final profile = ref.read(userProfileProvider);
    final controller = TextEditingController(text: profile.weightKg.toString());
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Current Weight',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Instant recalculation: Your BMI, maintenance calories, and workout plan will update automatically.',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'e.g. Morning fasted weigh-in',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final newWeight = double.tryParse(controller.text.trim());
                    if (newWeight != null && newWeight > 20 && newWeight < 300) {
                      ref.read(userProfileProvider.notifier).updateWeight(
                            newWeight,
                            note: noteController.text.trim().isNotEmpty
                                ? noteController.text.trim()
                                : null,
                          );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Weight updated to $newWeight kg! New BMI calculated.'),
                          backgroundColor: AppTheme.emerald,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emerald,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Save & Update',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final bmi = profile.bmi;
    final bmiCategory = BmiService.getBmiCategory(bmi);
    final healthyRange = BmiService.getHealthyWeightRange(profile.heightCm);
    final calorieTarget = BmiService.calculateCalorieTarget(profile);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Goals',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User Card with Weight Tap
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.emerald.withOpacity(0.2),
                  child: const Icon(Icons.person,
                      size: 36, color: AppTheme.emerald),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.fitnessGoal} • ${profile.fitnessLevel}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: _showWeightUpdateModal,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.emerald),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Edit Weight',
                      style: TextStyle(
                          color: AppTheme.emerald,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dynamic BMI Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  BmiService.getBmiColor(bmi).withOpacity(0.15),
                  AppTheme.surfaceDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: BmiService.getBmiColor(bmi).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dynamic Body Mass Index (BMI)',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BmiService.getBmiColor(bmi),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        bmiCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      bmi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: BmiService.getBmiColor(bmi),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('kg/m²',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Healthy weight for your ${profile.heightCm.toInt()} cm height: ${healthyRange.minWeightKg.toStringAsFixed(1)} - ${healthyRange.maxWeightKg.toStringAsFixed(1)} kg',
                  style: TextStyle(color: Colors.grey[300], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dynamic Calorie Targets Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Caloric Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCalorieStat(
                      'Basal Metabolic (BMR)',
                      '${calorieTarget.bmr.round()} kcal',
                      AppTheme.electricBlue,
                    ),
                    Container(width: 1, height: 40, color: Colors.white10),
                    _buildCalorieStat(
                      'Maintenance (TDEE)',
                      '${calorieTarget.maintenanceCalories.round()} kcal',
                      Colors.grey[300]!,
                    ),
                    Container(width: 1, height: 40, color: Colors.white10),
                    _buildCalorieStat(
                      'Goal Target',
                      '${calorieTarget.targetCalories.round()} kcal',
                      AppTheme.emerald,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Biometrics Settings List
          const Text('Profile Attributes',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          _buildConfigTile(
            title: 'Goal',
            value: profile.fitnessGoal,
            icon: Icons.flag_rounded,
            onTap: () => _pickOption(
              'Select Fitness Goal',
              AppConstants.fitnessGoals,
              profile.fitnessGoal,
              (val) => ref.read(userProfileProvider.notifier).updateGoal(val),
            ),
          ),
          _buildConfigTile(
            title: 'Fitness Level',
            value: profile.fitnessLevel,
            icon: Icons.speed_rounded,
            onTap: () => _pickOption(
              'Select Fitness Level',
              AppConstants.fitnessLevels,
              profile.fitnessLevel,
              (val) =>
                  ref.read(userProfileProvider.notifier).updateFitnessLevel(val),
            ),
          ),
          _buildConfigTile(
            title: 'Training Location',
            value: profile.preferredLocation,
            icon: Icons.place_rounded,
            onTap: () => _pickOption(
              'Select Training Location',
              AppConstants.workoutLocations,
              profile.preferredLocation,
              (val) =>
                  ref.read(userProfileProvider.notifier).updateLocation(val),
            ),
          ),
          _buildConfigTile(
            title: 'Height',
            value: '${profile.heightCm.toInt()} cm',
            icon: Icons.height_rounded,
            onTap: () => _editNumber(
              'Update Height (cm)',
              profile.heightCm,
              100,
              230,
              (val) => ref.read(userProfileProvider.notifier).updateProfile(
                    profile.copyWith(heightCm: val),
                  ),
            ),
          ),
          _buildConfigTile(
            title: 'Age',
            value: '${profile.age} years',
            icon: Icons.calendar_today_rounded,
            onTap: () => _editNumber(
              'Update Age',
              profile.age.toDouble(),
              14,
              100,
              (val) => ref.read(userProfileProvider.notifier).updateProfile(
                    profile.copyWith(age: val.toInt()),
                  ),
            ),
          ),
          _buildConfigTile(
            title: 'Workout Days / Week',
            value: '${profile.workoutDaysPerWeek} Days',
            icon: Icons.date_range_rounded,
            onTap: () => _editNumber(
              'Workout Days per Week',
              profile.workoutDaysPerWeek.toDouble(),
              2,
              7,
              (val) => ref.read(userProfileProvider.notifier).updateDaysPerWeek(val.toInt()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildConfigTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.emerald),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _pickOption(
    String title,
    List<String> options,
    String current,
    ValueChanged<String> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...options.map((opt) {
                final isSelected = opt == current;
                return ListTile(
                  title: Text(opt,
                      style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppTheme.emerald)
                      : null,
                  onTap: () {
                    onSelected(opt);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _editNumber(
    String title,
    double initial,
    double min,
    double max,
    ValueChanged<double> onSaved,
  ) {
    final controller = TextEditingController(
        text: initial == initial.roundToDouble()
            ? initial.toInt().toString()
            : initial.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emerald),
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val >= min && val <= max) {
                onSaved(val);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
