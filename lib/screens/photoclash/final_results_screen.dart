import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../core/providers/photoclash_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../core/models/game_room.dart';
import 'photoclash_menu_screen.dart';

class FinalResultsScreen extends ConsumerStatefulWidget {
  final String playerId;

  const FinalResultsScreen({super.key, required this.playerId});

  @override
  ConsumerState<FinalResultsScreen> createState() => _FinalResultsScreenState();
}

class _FinalResultsScreenState extends ConsumerState<FinalResultsScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    Future.delayed(const Duration(milliseconds: 500), () {
      _confettiController.play();
      HapticService.success();
    });
  }

  Future<void> _exitGame() async {
    await HapticService.medium();
    
    final room = ref.read(currentRoomProvider).value;
    if (room != null) {
      await ref.read(currentRoomProvider.notifier).leaveRoom(widget.playerId);
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PhotoClashMenuScreen()),
        (route) => false,
      );
    }
  }

  Color _getPodiumColor(int position) {
    switch (position) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey[400]!; // Silver
      case 2:
        return Colors.orange[700]!; // Bronze
      default:
        return Colors.grey;
    }
  }

  IconData _getPodiumIcon(int position) {
    switch (position) {
      case 0:
        return Icons.emoji_events;
      case 1:
        return Icons.military_tech;
      case 2:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  double _getPodiumHeight(int position) {
    switch (position) {
      case 0:
        return 200;
      case 1:
        return 150;
      case 2:
        return 120;
      default:
        return 100;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(currentRoomProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados Finales'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          roomAsync.when(
            data: (room) {
              if (room == null) {
                return const Center(child: Text('Error al cargar resultados'));
              }

              // Sort players by score
              final rankedPlayers = room.players.entries
                  .map((e) => MapEntry(e.key, e.value))
                  .toList()
                ..sort((a, b) => b.value.score.compareTo(a.value.score));

              final top3 = rankedPlayers.take(3).toList();

              final currentPlayer = room.players[widget.playerId];
              final currentPlayerPosition = rankedPlayers.indexWhere((e) => e.key == widget.playerId) + 1;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Game Over Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.celebration,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '¡Juego Terminado!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (currentPlayer != null)
                            Text(
                              'Tu posición: #$currentPlayerPosition',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.2),

                    const SizedBox(height: 32),

                    // Podium
                    if (top3.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              'Podium',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // 2nd Place
                                if (top3.length > 1)
                                  Expanded(
                                    child: _buildPodiumPosition(
                                      top3[1].value,
                                      1,
                                      theme,
                                    ).animate(delay: 400.ms).scale().fadeIn(),
                                  ),
                                // 1st Place
                                Expanded(
                                  child: _buildPodiumPosition(
                                    top3[0].value,
                                    0,
                                    theme,
                                  ).animate(delay: 200.ms).scale(duration: 600.ms, curve: Curves.elasticOut).fadeIn(),
                                ),
                                // 3rd Place
                                if (top3.length > 2)
                                  Expanded(
                                    child: _buildPodiumPosition(
                                      top3[2].value,
                                      2,
                                      theme,
                                    ).animate(delay: 600.ms).scale().fadeIn(),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Full Leaderboard
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clasificación Completa',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...rankedPlayers
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final position = entry.key + 1;
                                    final player = entry.value.value;
                                    final isCurrentPlayer = entry.value.key == widget.playerId;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: isCurrentPlayer
                                            ? theme.colorScheme.primaryContainer
                                            : null,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: position <= 3
                                              ? _getPodiumColor(position - 1)
                                              : theme.colorScheme.secondaryContainer,
                                          child: Text(
                                            '$position',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: position <= 3
                                                  ? Colors.white
                                                  : theme.colorScheme.onSecondaryContainer,
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
                                        trailing: Text(
                                          '${player.score} pts',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList()
                                  .animate(interval: 100.ms)
                                  .fadeIn(delay: 800.ms)
                                  .slideX(begin: 0.2),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _exitGame,
                              icon: const Icon(Icons.exit_to_app),
                              label: const Text(
                                'Salir',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 1000.ms).fadeIn().slideY(begin: 0.2),
                  ],
                ),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _exitGame,
                    child: const Text('Volver al Menú'),
                  ),
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.03,
              numberOfParticles: 50,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Colors.amber,
                Colors.orange,
                Colors.red,
                Colors.purple,
                Colors.blue,
                Colors.green,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(Player player, int position, ThemeData theme) {
    final color = _getPodiumColor(position);
    final icon = _getPodiumIcon(position);
    final height = _getPodiumHeight(position);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: color)
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(delay: 1000.ms, duration: 2000.ms),
        const SizedBox(height: 8),
        Text(
          player.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${player.score} pts',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color,
                color.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '${position + 1}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
