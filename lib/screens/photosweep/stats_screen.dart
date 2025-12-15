import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/services/stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await StatsService.getStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Nunca';
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Hoy a las ${DateFormat('HH:mm').format(date)}';
      } else if (difference.inDays == 1) {
        return 'Ayer a las ${DateFormat('HH:mm').format(date)}';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  Future<void> _resetStats() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetear estadísticas'),
        content: const Text(
          '¿Estás seguro de que quieres borrar todas las estadísticas? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StatsService.resetStats();
      await _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estadísticas reseteadas')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Estadísticas')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalDeleted = _stats!['totalDeleted'] as int;
    final totalBytes = _stats!['totalBytes'] as int;
    final sessions = _stats!['sessions'] as int;
    final lastSession = _stats!['lastSession'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetStats,
            tooltip: 'Resetear estadísticas',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header Icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: 50,
                color: theme.colorScheme.primary,
              ),
            )
                .animate()
                .scale(delay: 100.ms, duration: 400.ms)
                .shimmer(delay: 500.ms, duration: 1500.ms),
          ),

          const SizedBox(height: 32),

          // Total Photos Deleted
          _StatCard(
            icon: Icons.delete_sweep_rounded,
            title: 'Fotos eliminadas',
            value: totalDeleted.toString(),
            color: Colors.red,
            subtitle: totalDeleted == 0
                ? '¡Empieza tu primera limpieza!'
                : totalDeleted < 50
                    ? '¡Buen trabajo!'
                    : totalDeleted < 100
                        ? '¡Increíble progreso!'
                        : '¡Eres un maestro!',
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

          const SizedBox(height: 16),

          // Total Space Freed
          _StatCard(
            icon: Icons.storage_rounded,
            title: 'Espacio liberado',
            value: _formatBytes(totalBytes),
            color: Colors.green,
            subtitle: totalBytes == 0
                ? 'Aún no has liberado espacio'
                : totalBytes < 10 * 1024 * 1024
                    ? 'Sigue así'
                    : totalBytes < 100 * 1024 * 1024
                        ? 'Excelente ahorro de espacio'
                        : '¡Impresionante!',
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),

          const SizedBox(height: 16),

          // Sessions Count
          _StatCard(
            icon: Icons.event_available_rounded,
            title: 'Sesiones de limpieza',
            value: sessions.toString(),
            color: Colors.blue,
            subtitle: sessions == 0
                ? 'Aún no has completado ninguna'
                : sessions == 1
                    ? '¡Primera sesión completada!'
                    : '¡Eres constante!',
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

          const SizedBox(height: 16),

          // Last Session
          _StatCard(
            icon: Icons.schedule_rounded,
            title: 'Última limpieza',
            value: _formatDate(lastSession),
            color: Colors.orange,
            subtitle: lastSession == null
                ? 'Nunca'
                : DateTime.now().difference(DateTime.parse(lastSession)).inDays > 7
                    ? '¡Hace tiempo que no limpias!'
                    : 'Reciente',
          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),

          const SizedBox(height: 32),

          // Achievement Messages
          if (totalDeleted > 0) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getAchievementMessage(totalDeleted),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms),
          ],
        ],
      ),
    );
  }

  String _getAchievementMessage(int deleted) {
    if (deleted >= 500) return '¡Leyenda de la Limpieza! 🏆';
    if (deleted >= 250) return '¡Maestro del Orden! 🌟';
    if (deleted >= 100) return '¡Experto en Limpieza! ⭐';
    if (deleted >= 50) return '¡Limpiador Avanzado! 💪';
    if (deleted >= 25) return '¡Buen Progreso! 👍';
    return '¡Primer Paso Completado! 🎯';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
