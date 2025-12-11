import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/game_room.dart';
import '../services/firebase_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final playerIdProvider = Provider((ref) => const Uuid().v4());

final currentRoomProvider = AsyncNotifierProvider<CurrentRoomNotifier, GameRoom?>(() {
  return CurrentRoomNotifier();
});

class CurrentRoomNotifier extends AsyncNotifier<GameRoom?> {
  FirebaseService get _firebaseService => ref.read(firebaseServiceProvider);
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
      final room = await _firebaseService.createRoom(
        hostId: hostId,
        hostName: hostName,
        rounds: rounds,
        timePerRound: timePerRound,
        phraseMode: phraseMode,
        language: language,
        maxPlayers: maxPlayers,
      );
      
      _roomId = room.id;
      _listenToRoom(room.id);
      
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
      final room = await _firebaseService.joinRoom(
        code: code,
        playerId: playerId,
        playerName: playerName,
      );
      
      if (room == null) {
        throw Exception('Room not found or already started');
      }
      
      _roomId = room.id;
      _listenToRoom(room.id);
      
      state = AsyncValue.data(room);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> startGame(bool nsfwEnabled) async {
    if (_roomId == null) return;
    
    try {
      await _firebaseService.startGame(_roomId!, nsfwEnabled);
    } catch (e) {
      // Error handled by stream
    }
  }

  Future<String> uploadPhoto({
    required String playerId,
    required File photoFile,
    required int roundNumber,
  }) async {
    if (_roomId == null) throw Exception('No active room');
    
    return await _firebaseService.uploadPhoto(
      roomId: _roomId!,
      playerId: playerId,
      photoFile: photoFile,
      roundNumber: roundNumber,
    );
  }

  Future<void> castVote({
    required String voterId,
    required String votedPlayerId,
    required int roundNumber,
  }) async {
    if (_roomId == null) return;
    
    await _firebaseService.castVote(
      roomId: _roomId!,
      voterId: voterId,
      votedPlayerId: votedPlayerId,
      roundNumber: roundNumber,
    );
  }

  Future<Map<String, int>> calculateRoundResults(int roundNumber) async {
    if (_roomId == null) return {};
    
    return await _firebaseService.calculateRoundResults(
      roomId: _roomId!,
      roundNumber: roundNumber,
    );
  }

  Future<void> nextRound(bool nsfwEnabled) async {
    if (_roomId == null) return;
    
    await _firebaseService.nextRound(_roomId!, nsfwEnabled);
  }

  Future<void> leaveRoom(String playerId) async {
    if (_roomId == null) return;
    
    await _firebaseService.leaveRoom(_roomId!, playerId);
    _roomId = null;
    state = const AsyncValue.data(null);
  }

  Future<void> endGame() async {
    if (_roomId == null) return;
    
    await _firebaseService.endGame(_roomId!);
  }

  void _listenToRoom(String roomId) {
    _firebaseService.listenToRoom(roomId).listen(
      (room) {
        state = AsyncValue.data(room);
      },
      onError: (error, stack) {
        state = AsyncValue.error(error, stack);
      },
    );
  }

  String? get roomId => _roomId;
}
