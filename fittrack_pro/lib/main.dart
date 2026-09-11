import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/fitness_providers.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try optional Firebase initialization without crashing if not configured yet
  try {
    // Note: Firebase.initializeApp() can be invoked here once google-services.json is added
  } catch (_) {
    // Graceful offline fallback
  }

  runApp(
    const ProviderScope(
      child: FitTrackProApp(),
    ),
  );
}

class FitTrackProApp extends ConsumerWidget {
  const FitTrackProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'FitTrack Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
