import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/fitness_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _healthConnectEnabled = true;
  bool _soundEffectsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Integrations',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // App Appearance
          const Text('Appearance & Display',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              secondary: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppTheme.amber,
              ),
              title: const Text('Dark Mode',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                isDarkMode ? 'Material 3 Dark Athletic' : 'Clean Light Mode',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              value: isDarkMode,
              activeColor: AppTheme.emerald,
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 24),

          // Integrations
          const Text('Health Integrations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.favorite_rounded,
                      color: AppTheme.crimson),
                  title: const Text('Android Health Connect',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Sync steps, active calories, and weight with Google Health ecosystem',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  value: _healthConnectEnabled,
                  activeColor: AppTheme.emerald,
                  onChanged: (val) {
                    setState(() => _healthConnectEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val
                            ? 'Health Connect synchronization enabled'
                            : 'Health Connect disconnected'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_rounded,
                      color: AppTheme.electricBlue),
                  title: const Text('Rest Timer Bells & Haptics',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Chime when rest intervals conclude during active workout player',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  value: _soundEffectsEnabled,
                  activeColor: AppTheme.emerald,
                  onChanged: (val) {
                    setState(() => _soundEffectsEnabled = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Persistence & Sync
          const Text('Cloud & Offline Storage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.emerald.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.cloud_done_rounded,
                      color: AppTheme.emerald),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dual-Mode Persistence',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cloud Firestore + Local Encrypted Storage. All your sessions and weights are backed up offline & synchronized when online.',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // App Info
          Center(
            child: Column(
              children: [
                const Text(
                  'FITTRACK PRO v1.0.0',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 12,
                      color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Production Flutter & Riverpod Architecture',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
