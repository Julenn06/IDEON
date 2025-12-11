import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../services/haptic_service.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'app_settings';

  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      state = AppSettings.fromJson(json);
      // Inicializar HapticService con el valor guardado
      HapticService.setEnabled(state.vibrationsEnabled);
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_key, jsonString);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _saveSettings();
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
    _saveSettings();
  }

  void toggleVibrations() {
    state = state.copyWith(vibrationsEnabled: !state.vibrationsEnabled);
    HapticService.setEnabled(state.vibrationsEnabled);
    _saveSettings();
  }

  void toggleNsfwMode() {
    state = state.copyWith(nsfwMode: !state.nsfwMode);
    _saveSettings();
  }

  void toggleConfirmBeforeDelete() {
    state = state.copyWith(confirmBeforeDelete: !state.confirmBeforeDelete);
    _saveSettings();
  }

  void setPrimaryColor(int index) {
    state = state.copyWith(primaryColorIndex: index);
    _saveSettings();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});
