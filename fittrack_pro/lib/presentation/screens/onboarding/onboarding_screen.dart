import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/fitness_providers.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _gender = AppConstants.genderMale;
  int _age = 26;
  double _heightCm = 175.0;
  double _weightKg = 75.0;
  double _targetWeightKg = 70.0;
  String _fitnessGoal = AppConstants.goalWeightLoss;
  String _fitnessLevel = AppConstants.levelBeginner;
  String _location = AppConstants.locationBoth;

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    final currentProfile = ref.read(userProfileProvider);
    final updated = currentProfile.copyWith(
      gender: _gender,
      age: _age,
      heightCm: _heightCm,
      weightKg: _weightKg,
      targetWeightKg: _targetWeightKg,
      fitnessGoal: _fitnessGoal,
      fitnessLevel: _fitnessLevel,
      preferredLocation: _location,
    );

    ref.read(userProfileProvider.notifier).updateProfile(updated);
    ref.read(userProfileProvider.notifier).updateWeight(_weightKg, note: 'Initial Onboarding Weight');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _previousPage,
              )
            : null,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text('Skip', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentPage + 1) / 4,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emerald),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildGoalStep(),
                  _buildBiometricsStep(),
                  _buildLevelStep(),
                  _buildLocationStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emerald,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == 3 ? 'Get Started' : 'Continue',
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

  Widget _buildGoalStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your primary goal?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'FitTrack Pro customizes workout volume, calorie deficits, and training splits based on your target.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView(
              children: AppConstants.fitnessGoals.map((goal) {
                final isSelected = _fitnessGoal == goal;
                return GestureDetector(
                  onTap: () => setState(() => _fitnessGoal = goal),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.emerald.withOpacity(0.18)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.emerald : Colors.white10,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: isSelected ? AppTheme.emerald : Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            goal,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Used for precise dynamic BMI and MET calorie calculation.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildChoiceCard(
                  title: 'Male',
                  isSelected: _gender == AppConstants.genderMale,
                  onTap: () =>
                      setState(() => _gender = AppConstants.genderMale),
                  icon: Icons.male_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildChoiceCard(
                  title: 'Female',
                  isSelected: _gender == AppConstants.genderFemale,
                  onTap: () =>
                      setState(() => _gender = AppConstants.genderFemale),
                  icon: Icons.female_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSliderField(
            label: 'Age',
            value: _age.toDouble(),
            min: 14,
            max: 85,
            unit: 'yrs',
            onChanged: (v) => setState(() => _age = v.round()),
          ),
          const SizedBox(height: 16),
          _buildSliderField(
            label: 'Height',
            value: _heightCm,
            min: 120,
            max: 220,
            unit: 'cm',
            onChanged: (v) => setState(() => _heightCm = v),
          ),
          const SizedBox(height: 16),
          _buildSliderField(
            label: 'Current Weight',
            value: _weightKg,
            min: 35,
            max: 180,
            unit: 'kg',
            onChanged: (v) => setState(() => _weightKg = v),
          ),
          const SizedBox(height: 16),
          _buildSliderField(
            label: 'Target Weight',
            value: _targetWeightKg,
            min: 35,
            max: 180,
            unit: 'kg',
            onChanged: (v) => setState(() => _targetWeightKg = v),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your fitness level?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'We tailor rep ranges, exercise selections, and rest periods to prevent injury.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView(
              children: AppConstants.fitnessLevels.map((level) {
                final isSelected = _fitnessLevel == level;
                return GestureDetector(
                  onTap: () => setState(() => _fitnessLevel = level),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.electricBlue.withOpacity(0.18)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected ? AppTheme.electricBlue : Colors.white10,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.bolt_rounded
                              : Icons.circle_outlined,
                          color: isSelected
                              ? AppTheme.electricBlue
                              : Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where do you plan to train?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'FitTrack Pro automatically recommends calisthenics & bodyweight workouts for Home, or barbell/cable machines for Gym.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView(
              children: AppConstants.workoutLocations.map((loc) {
                final isSelected = _location == loc;
                return GestureDetector(
                  onTap: () => setState(() => _location = loc),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.amber.withOpacity(0.18)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.amber : Colors.white10,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          loc == AppConstants.locationHome
                              ? Icons.home_rounded
                              : (loc == AppConstants.locationGym
                                  ? Icons.fitness_center_rounded
                                  : Icons.shuffle_rounded),
                          color: isSelected ? AppTheme.amber : Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            loc,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.emerald.withOpacity(0.18)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.emerald : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 32,
                color: isSelected ? AppTheme.emerald : Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} $unit',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.emerald,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: AppTheme.emerald,
            inactiveColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
