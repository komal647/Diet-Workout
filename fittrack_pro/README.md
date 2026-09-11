# FitTrack Pro – Smart Fitness Tracking & Workout Assistant 🏋️‍♂️🔥

A production-quality, data-driven Flutter application built with **Riverpod state management**, **Material 3 athletic design**, **fl_chart data visualization**, and **dual-mode Cloud Firestore / offline persistence**.

---

## 🌟 Key Capabilities & Features

### 1. Dynamic User Profile & Biometrics
- **Instant Weight Updates**: Tap anywhere to log a new weight. Updates BMI, BMR, TDEE, and progress charts immediately without needing to reload or restart the app.
- **Dynamic BMI Intelligence**: Computes Body Mass Index in real time, displays categorized badges (*Underweight, Normal, Overweight, Obese*), and shows the healthy weight boundary for the user's specific height.
- **Caloric Targets**: Calculates Basal Metabolic Rate (BMR) and Total Daily Energy Expenditure (TDEE), setting personalized caloric deficits for weight loss or surpluses for muscle building.

### 2. Workout Recommendation Engine
- Generates structured, customized weekly splits by cross-referencing:
  - **Goals**: Weight Loss, Muscle Building, Maintenance, Lean & Tone
  - **Fitness Levels**: Beginner, Intermediate, Advanced
  - **Locations**: Home (bodyweight/resistance), Gym (barbells/cables/machines), Both
  - **Frequency**: 2 to 6 training days per week
- Recommends today's designated workout session automatically based on day of week and user streak.

### 3. 50+ Comprehensive Seed Exercise Database
- Richly detailed across **12 Categories**:
  - *Chest, Back, Shoulders, Arms, Legs, Abs & Core, Cardio, HIIT, Full Body, Stretching, Yoga, Warm-up*
- Every single exercise contains:
  - Muscle group targeted & equipment needed
  - Step-by-step numbered movement instructions
  - Expert coaching & form safety tips
  - Accurate MET (Metabolic Equivalent of Task) value for calorie burn calculations
  - Default sets, reps, and recommended rest intervals

### 4. Interactive Workout Execution Player
- **Live Workout Session**: Full-screen exercise flow with real-time elapsed timer.
- **Dynamic Calorie Burn**: MET formula continuously accumulates live calories burned using the user's active weight and workout intensity.
- **Rest Interval Countdown**: Visual countdown timer between sets with quick **+15s** extension and **Skip Rest** controls.
- **Performance Logging**: Adjust and log actual sets, reps, and kilograms lifted per movement.
- **Completion Dialog**: Rate perceived exertion (RPE 1-10) and save session to persistent history.

### 5. Progress Analytics & Visualizations
- **Interactive Weight Trend Line Chart**: Powered by `fl_chart`, visualizing historical weigh-ins with a dotted target weight reference line.
- **Consistency & Streak Tracker**: Tracks current consecutive workout days, longest streak, and displays active streak indicators.
- **Workout Activity Log**: Detailed history cards showing date, duration, and calories burned for every session completed.

### 6. Dual-Mode Cloud & Offline Resilience
- **Cloud Firestore Ready**: Includes security rules (`firestore.rules`) and subcollection architecture (`users/{userId}/weights`, `users/{userId}/sessions`).
- **Offline First**: Automatically falls back to SharedPreferences and in-memory caches if Firebase credentials are not yet linked, allowing immediate testing and zero crashes.

### 7. Android Health Connect Integration Architecture
- Pluggable `HealthConnectService` abstraction ready to synchronize steps, active calories, and weight with the Google Health Connect Android ecosystem.

---

## 📁 Codebase Architecture

```
fittrack_pro/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart             # Categories, levels, goals, boundaries
│   │   ├── services/
│   │   │   ├── bmi_service.dart               # BMI & BMR caloric target algorithms
│   │   │   ├── calorie_calculation_service.dart # MET calorie calculation & set estimations
│   │   │   ├── health_connect_service.dart    # Android Health Connect adapter
│   │   │   ├── streak_service.dart            # Consecutive workout streak logic
│   │   │   └── workout_recommendation_service.dart # Dynamic workout split generator
│   │   └── theme/
│   │       └── app_theme.dart                 # Material 3 Dark & Light athletic palettes
│   ├── data/
│   │   ├── datasources/
│   │   │   └── exercise_seed_data.dart        # 50+ exercise library dataset
│   │   ├── models/
│   │   │   ├── exercise.dart                  # Exercise domain model
│   │   │   ├── user_profile.dart              # User profile & biometrics model
│   │   │   ├── weight_record.dart             # Weight log entry model
│   │   │   ├── workout.dart                   # WorkoutRoutine & WorkoutPlan models
│   │   │   └── workout_session.dart           # Session & completed exercise models
│   │   └── repositories/
│   │       └── fitness_repository.dart        # Dual Firestore / Local storage repository
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── fitness_providers.dart         # Riverpod StateNotifiers & computed providers
│   │   └── screens/
│   │       ├── auth/login_screen.dart         # Login & guest demo mode
│   │       ├── dashboard/dashboard_screen.dart # Hub with dynamic BMI, calories & today's routine
│   │       ├── exercise/
│   │       │   ├── exercise_library_screen.dart # Searchable 50+ exercise catalog
│   │       │   └── exercise_detail_screen.dart  # Form guides & coaching instructions
│   │       ├── main_navigation_screen.dart    # 4-tab bottom navigation
│   │       ├── onboarding/onboarding_screen.dart # Multi-step goal & biometrics setup
│   │       ├── profile/profile_screen.dart    # Biometric updates & calorie target specs
│   │       ├── progress/progress_screen.dart  # fl_chart weight trends & activity history
│   │       ├── settings/settings_screen.dart  # Dark/Light theme & Health Connect toggle
│   │       ├── splash_screen.dart             # Brand launch screen
│   │       └── workout/
│   │           ├── active_workout_screen.dart # Live workout player with rest countdown
│   │           ├── custom_workout_creator_screen.dart # Custom routine builder
│   │           └── workout_screen.dart        # Personalized program view
│   └── main.dart                              # Application bootstrap with ProviderScope
├── test/
│   └── fittrack_unit_tests.dart               # Automated tests for BMI, MET, and Streaks
├── firestore.rules                            # Production Firestore security rules
└── pubspec.yaml                               # Flutter dependencies configuration
```

---

## 🚀 Getting Started & Running the App

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.16.0 or higher)
- Android Studio / Xcode / Chrome for testing

### 1. Install Dependencies
```bash
cd fittrack_pro
flutter pub get
```

### 2. Run Automated Unit Tests
```bash
flutter test test/fittrack_unit_tests.dart
```

### 3. Run the Application
Run on your connected mobile device, emulator, or Chrome web browser:
```bash
# Run on default connected device (e.g. Android Phone or Emulator)
flutter run

# Or run in Chrome browser
flutter run -d chrome
```

---

## ⚙️ Optional: Connecting Firebase Cloud Firestore
1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Add an Android app with package name `com.fittrack.pro` and download `google-services.json` into `android/app/`.
3. Deploy the included Firestore rules:
   ```bash
   firebase deploy --only firestore:rules
   ```
*Note: If you run without Firebase, FitTrack Pro automatically activates local storage mode so you can test all features offline without any setup.*
