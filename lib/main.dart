import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/settings_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/models/app_settings.dart' as models;
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp(
      title: 'IDEON - Clean & Clash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(settings.primaryColorIndex),
      darkTheme: AppTheme.darkTheme(settings.primaryColorIndex),
      themeMode: _getThemeMode(settings.themeMode),
      home: const HomeScreen(),
    );
  }

  ThemeMode _getThemeMode(models.ThemeMode mode) {
    switch (mode) {
      case models.ThemeMode.light:
        return ThemeMode.light;
      case models.ThemeMode.dark:
        return ThemeMode.dark;
      case models.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}
