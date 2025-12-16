import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/game_room.dart';
import '../services/api_service.dart';
import '../services/signalr_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());
final signalRServiceProvider = Provider((ref) => SignalRService());

final playerIdProvider = Provider((ref) => const Uuid().v4());

final currentRoomProvider = AsyncNotifierProvider<CurrentRoomNotifier, GameRoom?>(() {
  return CurrentRoomNotifier();
});

class CurrentRoomNotifier extends AsyncNotifier<GameRoom?> {
  ApiService get _apiService => ref.read(apiServiceProvider);
  SignalRService get _signalRService => ref.read(signalRServiceProvider);
  String? _roomId;

  @override
  Future<GameRoom?> build() async {
    return null;
  }

  Future<void> createRoom({
    required String hostId,
    required String hostName,
    required int rounds,
    required int timePerRound,
    required String phraseMode,
    required String language,
    required int maxPlayers,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // Crear sala en el backend C#
      final roomData = await _apiService.createRoom(
        hostUserId: hostId,
        roundsTotal: rounds,
        secondsPerRound: timePerRound,
        nsfwAllowed: phraseMode == 'nsfw',
      );
      
      _roomId = roomData['Id'];
      
      // Conectar SignalR
      await _signalRService.connect(_roomId!);
      _listenToSignalR();
      
      // Convertir a GameRoom (por compatibilidad con UI)
      final room = GameRoom(
        id: roomData['Id'],
        code: roomData['Code'],
        hostId: hostId,
        rounds: rounds,
        timePerRound: timePerRound,
        phraseMode: phraseMode,
        language: language,
        maxPlayers: maxPlayers,
        status: GameStatus.waiting,
        players: {hostId: Player(id: hostId, name: hostName)},
      );
      
      state = AsyncValue.data(room);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> joinRoom({
    required String code,
    required String playerId,
    required String playerName,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // Unirse a sala en backend C#
      final roomData = await _apiService.joinRoom(
        code: code,
        userId: playerId,
      );
      
      _roomId = roomData['Id'];
      
      // Conectar SignalR
      await _signalRService.connect(_roomId!);
      _listenToSignalR();
      
      // Obtener datos completos de la sala
      final fullRoomData = await _apiService.getRoom(_roomId!);
      
      // Convertir a GameRoom (simplificado)
      final room = GameRoom(
        id: fullRoomData['Id'],
        code: fullRoomData['Code'],
        hostId: fullRoomData['HostUserId'],
        rounds: fullRoomData['RoundsTotal'],
        timePerRound: fullRoomData['SecondsPerRound'],
        phraseMode: 'normal',
        language: 'es',
        maxPlayers: 6,
        status: GameStatus.waiting,
        players: {playerId: Player(id: playerId, name: playerName)},
      );
      
      state = AsyncValue.data(room);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> startGame(bool nsfwEnabled) async {
    if (_roomId == null) return;
    
    try {
      await _apiService.startGame(roomId: _roomId!, language: 'es');
    } catch (e) {
      // Error manejado por stream
    }
  }

  Future<String> uploadPhoto({
    required String playerId,
    required File photoFile,
    required int roundNumber,
  }) async {
    if (_roomId == null) throw Exception('No active room');
    
    // TODO: Subir foto a un storage (ej: servidor local, S3, etc.)
    // Por ahora retornamos una URL de ejemplo
    final photoUrl = 'https://picsum.photos/600/400?random=$roundNumber';
    
    final roundData = await _apiService.getCurrentRound(_roomId!);
    
    await _apiService.uploadPhoto(
      roundId: roundData['Id'],
      playerId: playerId,
      photoUrl: photoUrl,
    );
    
    return photoUrl;
  }

  Future<void> castVote({
    required String voterId,
    required String votedPlayerId,
    required int roundNumber,
  }) async {
    if (_roomId == null) return;
    
    final roundData = await _apiService.getCurrentRound(_roomId!);
    
    await _apiService.vote(
      roundId: roundData['Id'],
      voterPlayerId: voterId,
      votedPlayerId: votedPlayerId,
    );
  }

  Future<Map<String, int>> calculateRoundResults(int roundNumber) async {
    if (_roomId == null) return {};
    
    // Obtener votos de la ronda
    final roundData = await _apiService.getCurrentRound(_roomId!);
    final votes = await _apiService.getRoundVotes(roundData['Id']);
    
    // Contar votos por jugador
    final Map<String, int> results = {};
    for (var vote in votes) {
      final votedId = vote['VotedPlayerId'];
      results[votedId] = (results[votedId] ?? 0) + 1;
    }
    
    return results;
  }

  Future<void> nextRound(bool nsfwEnabled) async {
    if (_roomId == null) return;
    
    await _apiService.startNextRound(_roomId!);
  }

  Future<void> leaveRoom(String playerId) async {
    if (_roomId == null) return;
    
    await _signalRService.leaveRoom(_roomId!);
    await _signalRService.disconnect();
    
    _roomId = null;
    state = const AsyncValue.data(null);
  }

  Future<void> endGame() async {
    if (_roomId == null) return;
    
    await _apiService.finishGame(_roomId!);
  }

  void _listenToSignalR() {
    _signalRService.events.listen(
      (event) {
        // Actualizar estado según eventos de SignalR
        // Por ahora solo logueamos
        print('SignalR Event: ${event.runtimeType}');
      },
      onError: (error, stack) {
        state = AsyncValue.error(error, stack);
      },
    );
  }

  String? get roomId => _roomId;
}
