import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers/photoclash_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../core/models/game_room.dart';
import 'voting_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String playerId;

  const GameScreen({super.key, required this.playerId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int _remainingTime = 0;
  Timer? _timer;
  File? _selectedPhoto;
  bool _isUploading = false;
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _remainingTime = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        // Time's up - auto submit or skip
        if (!_hasSubmitted && _selectedPhoto != null) {
          _uploadPhoto();
        }
      }
    });
  }

  Future<void> _pickPhoto() async {
    await HapticService.light();
    
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedPhoto = File(pickedFile.path);
      });
      await HapticService.success();
    }
  }

  Future<void> _uploadPhoto() async {
    if (_selectedPhoto == null || _hasSubmitted) return;

    setState(() => _isUploading = true);
    await HapticService.medium();

    final roomAsync = ref.read(currentRoomProvider);
    final room = roomAsync.value;
    
    if (room == null) return;

    try {
      await ref.read(currentRoomProvider.notifier).uploadPhoto(
        playerId: widget.playerId,
        photoFile: _selectedPhoto!,
        roundNumber: room.currentRound,
      );

      setState(() {
        _hasSubmitted = true;
        _isUploading = false;
      });

      await HapticService.success();
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir foto: $e'),
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
        title: const Text('PhotoClash'),
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

          // Check if all players submitted and move to voting
          if (room.status == GameStatus.playing && roundData.submissions.length == room.players.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              // Wait a moment before transitioning
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VotingScreen(playerId: widget.playerId),
                  ),
                );
              }
            });
          }

          // Start timer if not started
          if (_remainingTime == 0 && !_hasSubmitted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startTimer(room.timePerRound);
            });
          }

          final progress = roundData.submissions.length / room.players.length;

          return Column(
            children: [
              // Round Progress
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.secondaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ronda ${room.currentRound}/${room.rounds}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${roundData.submissions.length}/${room.players.length} fotos',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),

              // Timer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      'Tiempo restante',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _remainingTime.toString(),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _remainingTime <= 10
                            ? Colors.red
                            : theme.colorScheme.primary,
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(duration: 500.ms)
                        .then(delay: 500.ms)
                        .fadeOut(duration: 500.ms),
                  ],
                ),
              ),

              // Phrase Challenge
              Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 4,
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_camera_rounded,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          roundData.phrase,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: 16),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jugadores que subieron fotos',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Selected Photo Preview
              if (_selectedPhoto != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.primary, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _selectedPhoto!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (!_hasSubmitted)
                        TextButton(
                          onPressed: _pickPhoto,
                          child: const Text('Cambiar foto'),
                        ),
                    ],
                  ),
                ).animate().fadeIn().scale(),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: _hasSubmitted
                    ? Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 64,
                            color: Colors.green,
                          ).animate().scale(),
                          const SizedBox(height: 16),
                          Text(
                            'Foto enviada',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Esperando a los demás jugadores...',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : _selectedPhoto == null
                        ? SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _pickPhoto,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.photo_library),
                              label: const Text(
                                'Seleccionar Foto',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _isUploading ? null : _uploadPhoto,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: Colors.white,
                              ),
                              icon: _isUploading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.upload),
                              label: Text(
                                _isUploading ? 'Subiendo...' : 'Enviar Foto',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
              ),
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
