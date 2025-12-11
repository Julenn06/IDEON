import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/photoclash_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../core/models/game_room.dart';
import 'game_screen.dart';
import 'final_results_screen.dart';

class RoundResultsScreen extends ConsumerStatefulWidget {
  final String playerId;

  const RoundResultsScreen({super.key, required this.playerId});

  @override
  ConsumerState<RoundResultsScreen> createState() => _RoundResultsScreenState();
}

class _RoundResultsScreenState extends ConsumerState<RoundResultsScreen> {
  late final ConfettiController _confettiController;
  bool _resultsCalculated = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _calculateResults();
  }

  Future<void> _calculateResults() async {
    final room = ref.read(currentRoomProvider).value;
    if (room == null) return;

    try {
      await ref.read(currentRoomProvider.notifier).calculateRoundResults(room.currentRound);
      setState(() => _resultsCalculated = true);
      await HapticService.success();
      _confettiController.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al calcular resultados: $e')),
        );
      }
    }
  }

  Future<void> _nextRound(GameRoom room) async {
    await HapticService.medium();

    try {
      if (room.currentRound < room.rounds) {
        await ref.read(currentRoomProvider.notifier).nextRound(false);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(playerId: widget.playerId),
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FinalResultsScreen(playerId: widget.playerId),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      await HapticService.error();
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
        title: const Text('Resultados de Ronda'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          roomAsync.when(
            data: (room) {
              if (room == null || !_resultsCalculated) {
                return const Center(child: CircularProgressIndicator());
              }

              final roundData = room.roundsData[room.currentRound];
              if (roundData == null) {
                return const Center(child: Text('Error al cargar resultados'));
              }

              // Get winner and second place
              final voteCount = <String, int>{};
              for (final vote in roundData.votes.values) {
                voteCount[vote] = (voteCount[vote] ?? 0) + 1;
              }

              final sortedVotes = voteCount.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              final winnerId = sortedVotes.isNotEmpty ? sortedVotes[0].key : null;
              final secondId = sortedVotes.length > 1 ? sortedVotes[1].key : null;

              final winner = winnerId != null ? room.players[winnerId] : null;
              final second = secondId != null ? room.players[secondId] : null;

              final winnerPhotoUrl = winnerId != null ? roundData.submissions[winnerId]?.photoUrl : null;

              final isHost = room.hostId == widget.playerId;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Round indicator
                      Text(
                        'Ronda ${room.currentRound}/${room.rounds}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(),

                      const SizedBox(height: 24),

                      // Winner's Photo
                      if (winnerPhotoUrl != null)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CachedNetworkImage(
                                imageUrl: winnerPhotoUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
                            .fadeIn(),

                      const SizedBox(height: 24),

                      // Winner Card
                      if (winner != null)
                        Card(
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 64,
                                  color: Colors.amber,
                                ).animate(onPlay: (controller) => controller.repeat())
                                    .shimmer(delay: 500.ms, duration: 1500.ms),
                                const SizedBox(height: 16),
                                Text(
                                  '¡${winner.name} gana!',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${voteCount[winnerId]} votos',
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  '+3 puntos',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate(delay: 400.ms)
                            .fadeIn()
                            .slideY(begin: 0.2, duration: 600.ms),

                      // Second Place
                      if (second != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.military_tech,
                                    size: 32,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '2º lugar: ${second.name}',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Text(
                                          '${voteCount[secondId]} votos • +1 punto',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                            .animate(delay: 600.ms)
                            .fadeIn()
                            .slideX(begin: -0.2),

                      const SizedBox(height: 24),

                      // Current Scores
                      Card(
                        color: theme.colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Puntuación actual',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...room.players.entries
                                  .map((entry) {
                                    final player = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            player.name,
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          Text(
                                            '${player.score} pts',
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
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

                      const SizedBox(height: 24),

                      // Next Button (only host)
                      if (isHost)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => _nextRound(room),
                            icon: Icon(
                              room.currentRound < room.rounds
                                  ? Icons.arrow_forward
                                  : Icons.emoji_events,
                            ),
                            label: Text(
                              room.currentRound < room.rounds
                                  ? 'Siguiente Ronda'
                                  : 'Ver Resultados Finales',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        )
                            .animate(delay: 1000.ms)
                            .fadeIn()
                            .slideY(begin: 0.2)
                      else
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Esperando al host para continuar...',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(),
                    ],
                  ),
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
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Colors.amber,
                Colors.orange,
                Colors.red,
                Colors.purple,
                Colors.blue,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
