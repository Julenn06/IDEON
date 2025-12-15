import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/models/app_settings.dart' as models;
import '../../core/theme/app_theme.dart';
import '../../core/services/haptic_service.dart';
import '../photosweep/stats_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    // ignore: unused_local_variable
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          _SectionHeader(title: 'Apariencia', icon: Icons.palette_rounded),
          _SettingsCard(
            child: Column(
              children: [
                _SettingsTile(
                  title: 'Tema',
                  subtitle: _getThemeLabel(settings.themeMode),
                  icon: Icons.brightness_6_rounded,
                  onTap: () => _showThemeDialog(context, ref, settings),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  title: 'Color principal',
                  subtitle: 'Personaliza el color de la app',
                  icon: Icons.color_lens_rounded,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      AppTheme.primaryColors.length,
                      (index) => GestureDetector(
                        onTap: () async {
                          await HapticService.light();
                          ref.read(settingsProvider.notifier).setPrimaryColor(index);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColors[index],
                            shape: BoxShape.circle,
                            border: settings.primaryColorIndex == index
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: settings.primaryColorIndex == index
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColors[index].withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: settings.primaryColorIndex == index
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 24),

          // Language Section
          _SectionHeader(title: 'Idioma', icon: Icons.language_rounded),
          _SettingsCard(
            child: _SettingsTile(
              title: 'Idioma de la aplicación',
              subtitle: settings.language == 'es' ? 'Español' : 'English',
              icon: Icons.translate_rounded,
              onTap: () => _showLanguageDialog(context, ref, settings),
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

          const SizedBox(height: 24),

          // PhotoSweep Section
          _SectionHeader(title: 'PhotoSweep', icon: Icons.cleaning_services_rounded),
          _SettingsCard(
            child: _SettingsTile(
              title: 'Estadísticas',
              subtitle: 'Ver tu progreso de limpieza',
              icon: Icons.analytics_rounded,
              onTap: () async {
                await HapticService.light();
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatsScreen(),
                    ),
                  );
                }
              },
            ),
          ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.1),

          const SizedBox(height: 24),

          // Interaction Section
          _SectionHeader(title: 'Interacción', icon: Icons.touch_app_rounded),
          _SettingsCard(
            child: Column(
              children: [
                _SettingsTile(
                  title: 'Vibraciones',
                  subtitle: 'Feedback háptico',
                  icon: Icons.vibration_rounded,
                  trailing: Switch(
                    value: settings.vibrationsEnabled,
                    onChanged: (value) async {
                      await HapticService.light();
                      ref.read(settingsProvider.notifier).toggleVibrations();
                      HapticService.setEnabled(value);
                    },
                  ),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  title: 'Confirmar eliminación',
                  subtitle: 'Pedir confirmación antes de borrar',
                  icon: Icons.warning_rounded,
                  trailing: Switch(
                    value: settings.confirmBeforeDelete,
                    onChanged: (_) async {
                      await HapticService.light();
                      ref.read(settingsProvider.notifier).toggleConfirmBeforeDelete();
                    },
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

          const SizedBox(height: 24),

          // PhotoClash Section
          _SectionHeader(title: 'PhotoClash', icon: Icons.people_rounded),
          _SettingsCard(
            child: _SettingsTile(
              title: 'Modo NSFW',
              subtitle: 'Activar frases para adultos',
              icon: Icons.warning_amber_rounded,
              trailing: Switch(
                value: settings.nsfwMode,
                onChanged: (_) async {
                  await HapticService.light();
                  ref.read(settingsProvider.notifier).toggleNsfwMode();
                },
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

          const SizedBox(height: 24),

          // About Section
          _SectionHeader(title: 'Acerca de', icon: Icons.info_rounded),
          _SettingsCard(
            child: Column(
              children: [
                _SettingsTile(
                  title: 'Versión',
                  subtitle: '1.0.0',
                  icon: Icons.app_settings_alt_rounded,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  title: 'IDEON - Clean & Clash',
                  subtitle: 'Desarrollado con ❤️',
                  icon: Icons.code_rounded,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeLabel(models.ThemeMode mode) {
    switch (mode) {
      case models.ThemeMode.light:
        return 'Claro';
      case models.ThemeMode.dark:
        return 'Oscuro';
      case models.ThemeMode.system:
        return 'Sistema';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, models.AppSettings settings) async {
    await HapticService.light();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              title: 'Claro',
              icon: Icons.light_mode_rounded,
              selected: settings.themeMode == models.ThemeMode.light,
              onTap: () async {
                await HapticService.light();
                ref.read(settingsProvider.notifier).setThemeMode(models.ThemeMode.light);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            _ThemeOption(
              title: 'Oscuro',
              icon: Icons.dark_mode_rounded,
              selected: settings.themeMode == models.ThemeMode.dark,
              onTap: () async {
                await HapticService.light();
                ref.read(settingsProvider.notifier).setThemeMode(models.ThemeMode.dark);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            _ThemeOption(
              title: 'Sistema',
              icon: Icons.brightness_auto_rounded,
              selected: settings.themeMode == models.ThemeMode.system,
              onTap: () async {
                await HapticService.light();
                ref.read(settingsProvider.notifier).setThemeMode(models.ThemeMode.system);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, models.AppSettings settings) async {
    await HapticService.light();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              title: 'Español',
              icon: Icons.flag_rounded,
              selected: settings.language == 'es',
              onTap: () async {
                await HapticService.light();
                ref.read(settingsProvider.notifier).setLanguage('es');
                if (context.mounted) Navigator.pop(context);
              },
            ),
            _ThemeOption(
              title: 'English',
              icon: Icons.flag_rounded,
              selected: settings.language == 'en',
              onTap: () async {
                await HapticService.light();
                ref.read(settingsProvider.notifier).setLanguage('en');
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded) : null),
      onTap: onTap,
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? theme.colorScheme.primary : null,
      ),
      title: Text(title),
      trailing: selected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
      onTap: onTap,
    );
  }
}
