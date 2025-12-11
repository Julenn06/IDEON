import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/haptic_service.dart';
import '../../core/providers/photoclash_provider.dart';
import 'lobby_screen.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu nombre'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el código de la sala'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await HapticService.medium();

    final playerId = ref.read(playerIdProvider);

    try {
      await ref.read(currentRoomProvider.notifier).joinRoom(
        code: _codeController.text.trim().toUpperCase(),
        playerId: playerId,
        playerName: _nameController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LobbyScreen(
              playerId: playerId,
              isHost: false,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
        title: const Text('Unirse a Sala'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              Icons.login_rounded,
              size: 80,
              color: theme.colorScheme.secondary,
            ).animate().fadeIn().scale(),

            const SizedBox(height: 40),

            // Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tu nombre',
                hintText: 'Ingresa tu nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person_rounded),
              ),
            ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1),

            const SizedBox(height: 24),

            // Code Input
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Código de la sala',
                hintText: 'XXXXXX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.vpn_key_rounded),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
            ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.1),

            const SizedBox(height: 40),

            // Join Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Unirse',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ).animate(delay: 600.ms).fadeIn().scale(),

            const SizedBox(height: 24),

            Text(
              'Pídele al host el código de 6 caracteres',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 800.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
