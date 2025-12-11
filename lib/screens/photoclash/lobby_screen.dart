import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/photoclash_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../core/models/game_room.dart';
import 'game_screen.dart';

class LobbyScreen extends ConsumerWidget {
  final String playerId;
  final bool isHost;

  const LobbyScreen({
    super.key,
    required this.playerId,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(currentRoomProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala de Espera'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Salir de la sala'),
                content: const Text('¿Estás seguro de que quieres salir?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Salir'),
                  ),
                ],
              ),
            );

            if (confirmed == true && context.mounted) {
              await ref.read(currentRoomProvider.notifier).leaveRoom(playerId);
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: roomAsync.when(
        data: (room) {
          if (room == null) {
            return const Center(child: Text('Error: Sala no encontrada'));
          }

          // Check if game started
          if (room.status == GameStatus.playing) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(playerId: playerId),
                ),
              );
            });
          }

          return Column(
            children: [
              // Room Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.secondary.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Código de Sala',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: room.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código copiado'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              room.code,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.copy, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${room.players.length}/${room.maxPlayers} jugadores',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),

              // Game Settings
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuración',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(icon: Icons.repeat, label: 'Rondas', value: '${room.rounds}'),
                        _InfoRow(icon: Icons.timer, label: 'Tiempo', value: '${room.timePerRound}s'),
                        _InfoRow(
                          icon: Icons.mood,
                          label: 'Modo',
                          value: room.phraseMode == 'normal'
                              ? 'Normal'
                              : room.phraseMode == 'crazy'
                                  ? 'Locas'
                                  : 'NSFW',
                        ),
                        _InfoRow(
                          icon: Icons.language,
                          label: 'Idioma',
                          value: room.language == 'es' ? 'Español' : 'English',
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1),

              // Players List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jugadores',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: room.players.length,
                          itemBuilder: (context, index) {
                            final player = room.players.values.toList()[index];
                            final isCurrentPlayer = player.id == playerId;
                            final isRoomHost = player.id == room.hostId;

                            return Card(
                              color: isCurrentPlayer
                                  ? theme.colorScheme.primaryContainer
                                  : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.secondary,
                                  child: Text(
                                    player.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  player.name,
                                  style: TextStyle(
                                    fontWeight: isCurrentPlayer
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: isRoomHost ? const Text('Host') : null,
                                trailing: isRoomHost
                                    ? Icon(
                                        Icons.star,
                                        color: Colors.amber.shade700,
                                      )
                                    : null,
                              ),
                            ).animate(delay: (300 + index * 100).ms).fadeIn().slideX(begin: -0.2);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Start Button (Host only)
              if (isHost)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: room.players.length >= 2
                          ? () async {
                              await HapticService.medium();
                              final settings = ref.read(settingsProvider);
                              await ref.read(currentRoomProvider.notifier).startGame(settings.nsfwMode);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Iniciar Partida',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn().scale()
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Esperando a que el host inicie...',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate(delay: 500.ms).fadeIn(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}
