import 'package:signalr_netcore/signalr_client.dart';
import 'dart:async';
import '../constants/backend_config.dart';

class SignalRService {
  static String get hubUrl => BackendConfig.signalRUrl;
  
  HubConnection? _connection;
  final _eventController = StreamController<SignalREvent>.broadcast();
  
  Stream<SignalREvent> get events => _eventController.stream;
  
  bool get isConnected => _connection?.state == HubConnectionState.Connected;
  
  Future<void> connect(String roomId) async {
    if (isConnected) return;
    
    _connection = HubConnectionBuilder()
        .withUrl(hubUrl)
        .withAutomaticReconnect()
        .build();
    
    _registerHandlers();
    
    await _connection!.start();
    await joinRoom(roomId);
  }
  
  void _registerHandlers() {
    // Jugador unido
    _connection!.on('PlayerJoined', (arguments) {
      final username = arguments?[0] as String?;
      if (username != null) {
        _eventController.add(PlayerJoinedEvent(username));
      }
    });
    
    // Jugador salió
    _connection!.on('PlayerLeft', (arguments) {
      final username = arguments?[0] as String?;
      if (username != null) {
        _eventController.add(PlayerLeftEvent(username));
      }
    });
    
    // Ronda iniciada
    _connection!.on('RoundStarted', (arguments) {
      final roundNumber = arguments?[0] as int?;
      final phrase = arguments?[1] as String?;
      final seconds = arguments?[2] as int?;
      
      if (roundNumber != null && phrase != null && seconds != null) {
        _eventController.add(RoundStartedEvent(roundNumber, phrase, seconds));
      }
    });
    
    // Tick del temporizador
    _connection!.on('TimerTick', (arguments) {
      final secondsRemaining = arguments?[0] as int?;
      if (secondsRemaining != null) {
        _eventController.add(TimerTickEvent(secondsRemaining));
      }
    });
    
    // Temporizador expirado
    _connection!.on('TimerExpired', (arguments) {
      _eventController.add(TimerExpiredEvent());
    });
    
    // Foto subida
    _connection!.on('PhotoUploaded', (arguments) {
      final playerId = arguments?[0] as String?;
      final playerName = arguments?[1] as String?;
      
      if (playerId != null && playerName != null) {
        _eventController.add(PhotoUploadedEvent(playerId, playerName));
      }
    });
    
    // Todos subieron fotos
    _connection!.on('AllPhotosUploaded', (arguments) {
      _eventController.add(AllPhotosUploadedEvent());
    });
    
    // Fase de votación iniciada
    _connection!.on('VotingStarted', (arguments) {
      _eventController.add(VotingStartedEvent());
    });
    
    // Voto registrado
    _connection!.on('VoteRegistered', (arguments) {
      final voterName = arguments?[0] as String?;
      if (voterName != null) {
        _eventController.add(VoteRegisteredEvent(voterName));
      }
    });
    
    // Ronda finalizada
    _connection!.on('RoundFinished', (arguments) {
      final winnerName = arguments?[0] as String?;
      final points = arguments?[1] as int?;
      
      if (winnerName != null && points != null) {
        _eventController.add(RoundFinishedEvent(winnerName, points));
      }
    });
    
    // Juego terminado
    _connection!.on('GameFinished', (arguments) {
      final winnerName = arguments?[0] as String?;
      final totalPoints = arguments?[1] as int?;
      
      if (winnerName != null && totalPoints != null) {
        _eventController.add(GameFinishedEvent(winnerName, totalPoints));
      }
    });
  }
  
  // Métodos para invocar en el servidor
  Future<void> joinRoom(String roomId) async {
    await _connection?.invoke('JoinRoom', args: [roomId]);
  }
  
  Future<void> leaveRoom(String roomId) async {
    await _connection?.invoke('LeaveRoom', args: [roomId]);
  }
  
  Future<void> notifyPhotoUploaded(String roomId, String playerId, String playerName) async {
    await _connection?.invoke('NotifyPhotoUploaded', args: [roomId, playerId, playerName]);
  }
  
  Future<void> notifyVoteRegistered(String roomId, String voterName) async {
    await _connection?.invoke('NotifyVoteRegistered', args: [roomId, voterName]);
  }
  
  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }
  
  void dispose() {
    _eventController.close();
    disconnect();
  }
}

// Eventos de SignalR
abstract class SignalREvent {}

class PlayerJoinedEvent extends SignalREvent {
  final String username;
  PlayerJoinedEvent(this.username);
}

class PlayerLeftEvent extends SignalREvent {
  final String username;
  PlayerLeftEvent(this.username);
}

class RoundStartedEvent extends SignalREvent {
  final int roundNumber;
  final String phrase;
  final int seconds;
  RoundStartedEvent(this.roundNumber, this.phrase, this.seconds);
}

class TimerTickEvent extends SignalREvent {
  final int secondsRemaining;
  TimerTickEvent(this.secondsRemaining);
}

class TimerExpiredEvent extends SignalREvent {}

class PhotoUploadedEvent extends SignalREvent {
  final String playerId;
  final String playerName;
  PhotoUploadedEvent(this.playerId, this.playerName);
}

class AllPhotosUploadedEvent extends SignalREvent {}

class VotingStartedEvent extends SignalREvent {}

class VoteRegisteredEvent extends SignalREvent {
  final String voterName;
  VoteRegisteredEvent(this.voterName);
}

class RoundFinishedEvent extends SignalREvent {
  final String winnerName;
  final int points;
  RoundFinishedEvent(this.winnerName, this.points);
}

class GameFinishedEvent extends SignalREvent {
  final String winnerName;
  final int totalPoints;
  GameFinishedEvent(this.winnerName, this.totalPoints);
}
