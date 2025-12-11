import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/haptic_service.dart';
import '../../core/providers/photoclash_provider.dart';
import 'lobby_screen.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _nameController = TextEditingController();
  int _rounds = 10;
  int _timePerRound = 60;
  String _phraseMode = 'normal';
  String _language = 'es';
  int _maxPlayers = 6;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu nombre'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await HapticService.medium();

    final playerId = ref.read(playerIdProvider);
    
    try {
      await ref.read(currentRoomProvider.notifier).createRoom(
        hostId: playerId,
        hostName: _nameController.text.trim(),
        rounds: _rounds,
        timePerRound: _timePerRound,
        phraseMode: _phraseMode,
        language: _language,
        maxPlayers: _maxPlayers,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LobbyScreen(
              playerId: playerId,
              isHost: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear sala: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Sala'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Player Name
          Text(
            'Tu nombre',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Ingresa tu nombre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_rounded),
            ),
          ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 32),

          // Game Settings
          Text(
            'Configuración de la partida',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 24),

          // Rounds
          _SettingCard(
            title: 'Número de rondas',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _rounds > 5
                      ? () {
                          setState(() => _rounds -= 5);
                          HapticService.light();
                        }
                      : null,
                ),
                Text(
                  '$_rounds',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _rounds < 30
                      ? () {
                          setState(() => _rounds += 5);
                          HapticService.light();
                        }
                      : null,
                ),
              ],
            ),
          ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 16),

          // Time per round
          _SettingCard(
            title: 'Tiempo por ronda',
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 30, label: Text('30s')),
                ButtonSegment(value: 60, label: Text('60s')),
                ButtonSegment(value: 90, label: Text('90s')),
              ],
              selected: {_timePerRound},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() => _timePerRound = newSelection.first);
                HapticService.light();
              },
            ),
          ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 16),

          // Max Players
          _SettingCard(
            title: 'Máximo de jugadores',
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 4, label: Text('4')),
                ButtonSegment(value: 6, label: Text('6')),
              ],
              selected: {_maxPlayers},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() => _maxPlayers = newSelection.first);
                HapticService.light();
              },
            ),
          ).animate(delay: 500.ms).fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 16),

          // Phrase Mode
          _SettingCard(
            title: 'Modo de frases',
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'normal', label: Text('Normal')),
                ButtonSegment(value: 'crazy', label: Text('Locas')),
                ButtonSegment(value: 'nsfw', label: Text('NSFW')),
              ],
              selected: {_phraseMode},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _phraseMode = newSelection.first);
                HapticService.light();
              },
            ),
          ).animate(delay: 600.ms).fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 16),

          // Language
          _SettingCard(
            title: 'Idioma de las frases',
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'es', label: Text('Español')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {_language},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _language = newSelection.first);
                HapticService.light();
              },
            ),
          ).animate(delay: 700.ms).fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 40),

          // Create Button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _createRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Crear Sala',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ).animate(delay: 800.ms).fadeIn().scale(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
