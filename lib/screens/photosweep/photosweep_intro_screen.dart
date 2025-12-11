import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/haptic_service.dart';
import 'photosweep_screen.dart';

class PhotoSweepIntroScreen extends StatefulWidget {
  const PhotoSweepIntroScreen({super.key});

  @override
  State<PhotoSweepIntroScreen> createState() => _PhotoSweepIntroScreenState();
}

class _PhotoSweepIntroScreenState extends State<PhotoSweepIntroScreen> {
  bool _isLoading = false;
  bool _dontShowAgain = false;
  static const String _prefKey = 'photosweep_intro_shown';

  @override
  void initState() {
    super.initState();
    _checkIfShouldShow();
  }

  Future<void> _checkIfShouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final shouldSkip = prefs.getBool(_prefKey) ?? false;
    
    if (shouldSkip && mounted) {
      _requestPermissionAndStart(context, skipIntro: true);
    }
  }

  Future<void> _requestPermissionAndStart(BuildContext context, {bool skipIntro = false}) async {
    if (!skipIntro && _dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, true);
    }

    setState(() => _isLoading = true);
    await HapticService.medium();

    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    
    if (ps.isAuth || ps.hasAccess) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PhotoSweepScreen(),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Se necesitan permisos para acceder a las fotos'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Configuración',
              textColor: Colors.white,
              onPressed: () => PhotoManager.openSetting(),
            ),
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhotoSweep'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cleaning_services_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 2000.ms)
                          .then()
                          .shake(hz: 0.5, curve: Curves.easeInOut),

                      const SizedBox(height: 40),

                      // Title
                      Text(
                        'PhotoSweep',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Limpia tu galería de forma rápida e intuitiva',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: 40),

                      // Features
                      _FeatureItem(
                        icon: Icons.swipe_rounded,
                        title: 'Desliza para decidir',
                        description: 'Izquierda = Eliminar, Derecha = Conservar',
                      ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.2),

                      const SizedBox(height: 16),

                      _FeatureItem(
                        icon: Icons.storage_rounded,
                        title: 'Libera espacio',
                        description: 'Ve cuánto espacio has recuperado',
                      ).animate(delay: 600.ms).fadeIn().slideX(begin: -0.2),

                      const SizedBox(height: 16),

                      _FeatureItem(
                        icon: Icons.restore_rounded,
                        title: 'Recuperación temporal',
                        description: 'Recupera las últimas 5 fotos eliminadas',
                      ).animate(delay: 800.ms).fadeIn().slideX(begin: -0.2),

                      const Spacer(),

                      // Don't show again checkbox
                      CheckboxListTile(
                        value: _dontShowAgain,
                        onChanged: (value) {
                          setState(() => _dontShowAgain = value ?? false);
                          HapticService.light();
                        },
                        title: Text(
                          'No volver a mostrar esta pantalla',
                          style: theme.textTheme.bodyMedium,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ).animate(delay: 900.ms).fadeIn(),

                      const SizedBox(height: 16),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _requestPermissionAndStart(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Comenzar limpieza',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ).animate(delay: 1000.ms).fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
