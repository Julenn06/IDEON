import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/game_room.dart';
import '../constants/phrases.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Generate unique room code
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[(DateTime.now().microsecondsSinceEpoch + index) % chars.length]).join();
  }

  // Create a new room
  Future<GameRoom> createRoom({
    required String hostId,
    required String hostName,
    required int rounds,
    required int timePerRound,
    required String phraseMode,
    required String language,
    required int maxPlayers,
  }) async {
    final roomId = _uuid.v4();
    final code = _generateRoomCode();

    final room = GameRoom(
      id: roomId,
      code: code,
      hostId: hostId,
      rounds: rounds,
      timePerRound: timePerRound,
      phraseMode: phraseMode,
      language: language,
      maxPlayers: maxPlayers,
      status: GameStatus.waiting,
      players: {
        hostId: Player(id: hostId, name: hostName),
      },
    );

    await _firestore.collection('rooms').doc(roomId).set(room.toJson());

    return room;
  }

  // Join an existing room
  Future<GameRoom?> joinRoom({
    required String code,
    required String playerId,
    required String playerName,
  }) async {
    final querySnapshot = await _firestore
        .collection('rooms')
        .where('code', isEqualTo: code)
        .where('status', isEqualTo: GameStatus.waiting.index)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final doc = querySnapshot.docs.first;
    final room = GameRoom.fromJson(doc.data());

    if (room.players.length >= room.maxPlayers) {
      throw Exception('Room is full');
    }

    final updatedPlayers = Map<String, Player>.from(room.players);
    updatedPlayers[playerId] = Player(id: playerId, name: playerName);

    await _firestore.collection('rooms').doc(room.id).update({
      'players': updatedPlayers.map((key, value) => MapEntry(key, value.toJson())),
    });

    return room.copyWith(players: updatedPlayers);
  }

  // Start the game
  Future<void> startGame(String roomId, bool nsfwEnabled) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    final room = GameRoom.fromJson(doc.data()!);

    final firstPhrase = PhotoClashPhrases.getRandomPhrase(
      room.language,
      room.phraseMode,
      nsfwEnabled,
    );

    final roundData = RoundData(phrase: firstPhrase);

    await _firestore.collection('rooms').doc(roomId).update({
      'status': GameStatus.playing.index,
      'currentRound': 1,
      'roundsData.1': roundData.toJson(),
    });
  }

  // Upload photo for current round
  Future<String> uploadPhoto({
    required String roomId,
    required String playerId,
    required File photoFile,
    required int roundNumber,
  }) async {
    final fileName = '${roomId}_${playerId}_$roundNumber.jpg';
    final ref = _storage.ref().child('photoclash/$roomId/$fileName');

    await ref.putFile(photoFile);
    final photoUrl = await ref.getDownloadURL();

    final submission = PhotoSubmission(
      playerId: playerId,
      photoUrl: photoUrl,
      timestamp: DateTime.now(),
    );

    await _firestore.collection('rooms').doc(roomId).update({
      'roundsData.$roundNumber.submissions.$playerId': submission.toJson(),
    });

    return photoUrl;
  }

  // Cast a vote
  Future<void> castVote({
    required String roomId,
    required String voterId,
    required String votedPlayerId,
    required int roundNumber,
  }) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'roundsData.$roundNumber.votes.$voterId': votedPlayerId,
    });
  }

  // Calculate round results and update scores
  Future<Map<String, int>> calculateRoundResults({
    required String roomId,
    required int roundNumber,
  }) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    final room = GameRoom.fromJson(doc.data()!);
    final roundData = room.roundsData[roundNumber];

    if (roundData == null) return {};

    // Count votes
    final voteCounts = <String, int>{};
    for (final votedPlayerId in roundData.votes.values) {
      voteCounts[votedPlayerId] = (voteCounts[votedPlayerId] ?? 0) + 1;
    }

    // Assign points
    final roundPoints = <String, int>{};
    if (voteCounts.isNotEmpty) {
      final maxVotes = voteCounts.values.reduce((a, b) => a > b ? a : b);
      final winners = voteCounts.entries.where((e) => e.value == maxVotes).map((e) => e.key).toList();

      if (winners.length == 1) {
        roundPoints[winners.first] = 3;
        
        // Second place
        final secondPlace = voteCounts.entries
            .where((e) => e.value < maxVotes && e.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        if (secondPlace.isNotEmpty) {
          roundPoints[secondPlace.first.key] = 1;
        }
      } else {
        // Tie - split points
        for (final winner in winners) {
          roundPoints[winner] = 3 ~/ winners.length;
        }
      }
    }

    // Update player scores
    final updatedPlayers = Map<String, Player>.from(room.players);
    for (final entry in roundPoints.entries) {
      final player = updatedPlayers[entry.key];
      if (player != null) {
        updatedPlayers[entry.key] = player.copyWith(
          score: player.score + entry.value,
        );
      }
    }

    await _firestore.collection('rooms').doc(roomId).update({
      'players': updatedPlayers.map((key, value) => MapEntry(key, value.toJson())),
    });

    return roundPoints;
  }

  // Move to next round
  Future<void> nextRound(String roomId, bool nsfwEnabled) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    final room = GameRoom.fromJson(doc.data()!);

    final nextRoundNumber = room.currentRound + 1;

    if (nextRoundNumber > room.rounds) {
      // Game finished
      await _firestore.collection('rooms').doc(roomId).update({
        'status': GameStatus.finished.index,
      });
      return;
    }

    final nextPhrase = PhotoClashPhrases.getRandomPhrase(
      room.language,
      room.phraseMode,
      nsfwEnabled,
    );

    final roundData = RoundData(phrase: nextPhrase);

    await _firestore.collection('rooms').doc(roomId).update({
      'status': GameStatus.playing.index,
      'currentRound': nextRoundNumber,
      'roundsData.$nextRoundNumber': roundData.toJson(),
    });
  }

  // Check if all players have submitted photos
  Future<bool> allPlayersSubmitted(String roomId, int roundNumber) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    final room = GameRoom.fromJson(doc.data()!);
    final roundData = room.roundsData[roundNumber];

    if (roundData == null) return false;

    return roundData.submissions.length == room.players.length;
  }

  // Check if all players have voted
  Future<bool> allPlayersVoted(String roomId, int roundNumber) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    final room = GameRoom.fromJson(doc.data()!);
    final roundData = room.roundsData[roundNumber];

    if (roundData == null) return false;

    return roundData.votes.length == room.players.length;
  }

  // Listen to room updates
  Stream<GameRoom> listenToRoom(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((snapshot) => GameRoom.fromJson(snapshot.data()!));
  }

  // Delete room photos from storage
  Future<void> deleteRoomPhotos(String roomId) async {
    try {
      final listResult = await _storage.ref().child('photoclash/$roomId').listAll();
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      // Ignore errors - photos might not exist
    }
  }

  // Leave room
  Future<void> leaveRoom(String roomId, String playerId) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    if (!doc.exists) return;

    final room = GameRoom.fromJson(doc.data()!);
    final updatedPlayers = Map<String, Player>.from(room.players);
    updatedPlayers.remove(playerId);

    if (updatedPlayers.isEmpty) {
      // Delete room if no players left
      await _firestore.collection('rooms').doc(roomId).delete();
      await deleteRoomPhotos(roomId);
    } else {
      await _firestore.collection('rooms').doc(roomId).update({
        'players': updatedPlayers.map((key, value) => MapEntry(key, value.toJson())),
      });
    }
  }

  // End game and clean up
  Future<void> endGame(String roomId) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'status': GameStatus.finished.index,
    });

    // Schedule deletion of room and photos after 1 hour
    Future.delayed(const Duration(hours: 1), () async {
      await _firestore.collection('rooms').doc(roomId).delete();
      await deleteRoomPhotos(roomId);
    });
  }
}
