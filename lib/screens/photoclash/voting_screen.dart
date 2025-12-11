import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/photoclash_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../core/models/game_room.dart';
import 'round_results_screen.dart';

class VotingScreen extends ConsumerStatefulWidget {
  final String playerId;

  const VotingScreen({super.key, required this.playerId});

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  String? _selectedPlayerId;
  bool _hasVoted = false;

  Future<void> _castVote(GameRoom room) async {
    if (_selectedPlayerId == null || _hasVoted) return;

    await HapticService.medium();

    try {
      await ref.read(currentRoomProvider.notifier).castVote(
        voterId: widget.playerId,
        votedPlayerId: _selectedPlayerId!,
        roundNumber: room.currentRound,
      );

      setState(() => _hasVoted = true);
      await HapticService.success();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al votar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      await HapticService.error();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(currentRoomProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votación'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: roomAsync.when(
        data: (room) {
          if (room == null) {
            return const Center(child: Text('Error: Sala no encontrada'));
          }

          final roundData = room.roundsData[room.currentRound];
          
          if (roundData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if all players voted and move to results
          if (roundData.votes.length == room.players.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await Future.delayed(const Duration(seconds: 1));
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoundResultsScreen(playerId: widget.playerId),
                  ),
                );
              }
            });
          }

          // Get submissions excluding current player's photo
          final otherSubmissions = roundData.submissions.entries
              .where((entry) => entry.key != widget.playerId)
              .toList();

          final voteProgress = roundData.votes.length / room.players.length;

          return Column(
            children: [
              // Progress Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.secondaryContainer,
                child: Column(
                  children: [
                    Text(
                      'Ronda ${room.currentRound}/${room.rounds}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: voteProgress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${roundData.votes.length}/${room.players.length} votos',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Instructions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.how_to_vote_rounded,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _hasVoted
                                ? 'Voto enviado. Esperando a los demás...'
                                : '¿Cuál es la mejor foto?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn().slideY(begin: -0.1),

              // Photos Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: otherSubmissions.length,
                    itemBuilder: (context, index) {
                      final submission = otherSubmissions[index];
                      final playerId = submission.key;
                      final photoUrl = submission.value.photoUrl;
                      final player = room.players[playerId];
                      final isSelected = _selectedPlayerId == playerId;

                      return GestureDetector(
                        onTap: _hasVoted
                            ? null
                            : () async {
                                await HapticService.light();
                                setState(() => _selectedPlayerId = playerId);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 4,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: photoUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                                if (isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          theme.colorScheme.primary.withValues(alpha: 0.7),
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 64,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.7),
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      player?.name ?? 'Jugador ${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate(delay: (index * 100).ms).fadeIn().scale();
                    },
                  ),
                ),
              ),

              // Vote Button
              if (!_hasVoted)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedPlayerId == null ? null : () => _castVote(room),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Votar',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.2),
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
