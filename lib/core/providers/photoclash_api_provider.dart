import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/backend_models.dart';

// Provider del servicio API
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Estado del PhotoClash
class PhotoClashState {
  final RoomResponse? currentRoom;
  final RoundResponse? currentRound;
  final List<RoundPhotoResponse> currentPhotos;
  final List<VoteResponse> currentVotes;
  final MatchResultResponse? gameResult;
  final bool isLoading;
  final String? error;
  final String? currentUserId;
  final String? currentPlayerId;

  PhotoClashState({
    this.currentRoom,
    this.currentRound,
    this.currentPhotos = const [],
    this.currentVotes = const [],
    this.gameResult,
    this.isLoading = false,
    this.error,
    this.currentUserId,
    this.currentPlayerId,
  });

  PhotoClashState copyWith({
    RoomResponse? currentRoom,
    RoundResponse? currentRound,
    List<RoundPhotoResponse>? currentPhotos,
    List<VoteResponse>? currentVotes,
    MatchResultResponse? gameResult,
    bool? isLoading,
    String? error,
    String? currentUserId,
    String? currentPlayerId,
  }) {
    return PhotoClashState(
      currentRoom: currentRoom ?? this.currentRoom,
      currentRound: currentRound ?? this.currentRound,
      currentPhotos: currentPhotos ?? this.currentPhotos,
      currentVotes: currentVotes ?? this.currentVotes,
      gameResult: gameResult ?? this.gameResult,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentUserId: currentUserId ?? this.currentUserId,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
    );
  }

  PhotoClashState clearError() {
    return copyWith(error: '');
  }
}

// Notifier para PhotoClash
class PhotoClashNotifier extends StateNotifier<PhotoClashState> {
  final ApiService _apiService;

  PhotoClashNotifier(this._apiService) : super(PhotoClashState());

  // Establecer usuario actual
  void setCurrentUser(String userId) {
    state = state.copyWith(currentUserId: userId);
  }

  // Crear sala
  Future<void> createRoom({
    required String hostUserId,
    required int roundsTotal,
    required int secondsPerRound,
    bool nsfwAllowed = false,
  }) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _apiService.createRoom(
        hostUserId: hostUserId,
        roundsTotal: roundsTotal,
        secondsPerRound: secondsPerRound,
        nsfwAllowed: nsfwAllowed,
      );

      final room = RoomResponse.fromJson(response);
      
      // Encontrar el player ID del usuario actual
      final currentPlayer = room.players.firstWhere(
        (p) => p.userId == hostUserId,
        orElse: () => room.players.first,
      );

      state = state.copyWith(
        currentRoom: room,
        currentUserId: hostUserId,
        currentPlayerId: currentPlayer.id,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Unirse a sala
  Future<void> joinRoom({
    required String code,
    required String userId,
  }) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _apiService.joinRoom(
        code: code,
        userId: userId,
      );

      final room = RoomResponse.fromJson(response);
      
      // Encontrar el player ID del usuario actual
      final currentPlayer = room.players.firstWhere(
        (p) => p.userId == userId,
        orElse: () => room.players.first,
      );

      state = state.copyWith(
        currentRoom: room,
        currentUserId: userId,
        currentPlayerId: currentPlayer.id,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Actualizar estado de la sala
  Future<void> refreshRoom() async {
    if (state.currentRoom == null) return;

    try {
      final response = await _apiService.getRoom(state.currentRoom!.id);
      final room = RoomResponse.fromJson(response);

      state = state.copyWith(currentRoom: room);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Iniciar juego
  Future<void> startGame({String language = 'es'}) async {
    if (state.currentRoom == null) return;

    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _apiService.startGame(
        roomId: state.currentRoom!.id,
        language: language,
      );

      final room = RoomResponse.fromJson(response);
      state = state.copyWith(
        currentRoom: room,
        isLoading: false,
      );

      // Cargar la ronda actual
      await loadCurrentRound();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cargar ronda actual
  Future<void> loadCurrentRound() async {
    if (state.currentRoom == null) return;

    try {
      final response = await _apiService.getCurrentRound(state.currentRoom!.id);
      final round = RoundResponse.fromJson(response);

      state = state.copyWith(currentRound: round);

      // Cargar fotos de la ronda
      await loadRoundPhotos();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Subir foto
  Future<void> uploadPhoto(String photoUrl) async {
    if (state.currentRound == null || state.currentPlayerId == null) return;

    state = state.copyWith(isLoading: true, error: '');
    try {
      await _apiService.uploadPhoto(
        roundId: state.currentRound!.id,
        playerId: state.currentPlayerId!,
        photoUrl: photoUrl,
      );

      state = state.copyWith(isLoading: false);

      // Recargar fotos
      await loadRoundPhotos();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cargar fotos de la ronda
  Future<void> loadRoundPhotos() async {
    if (state.currentRound == null) return;

    try {
      final response = await _apiService.getRoundPhotos(state.currentRound!.id);
      final photos = response
          .map((json) => RoundPhotoResponse.fromJson(json))
          .toList();

      state = state.copyWith(currentPhotos: photos);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Votar
  Future<void> vote(String votedPlayerId) async {
    if (state.currentRound == null || state.currentPlayerId == null) return;

    state = state.copyWith(isLoading: true, error: '');
    try {
      await _apiService.vote(
        roundId: state.currentRound!.id,
        voterPlayerId: state.currentPlayerId!,
        votedPlayerId: votedPlayerId,
      );

      state = state.copyWith(isLoading: false);

      // Recargar votos
      await loadRoundVotes();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cargar votos de la ronda
  Future<void> loadRoundVotes() async {
    if (state.currentRound == null) return;

    try {
      final response = await _apiService.getRoundVotes(state.currentRound!.id);
      final votes = response
          .map((json) => VoteResponse.fromJson(json))
          .toList();

      state = state.copyWith(currentVotes: votes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Finalizar ronda
  Future<void> finishRound() async {
    if (state.currentRound == null) return;

    state = state.copyWith(isLoading: true, error: '');
    try {
      await _apiService.finishRound(state.currentRound!.id);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Iniciar siguiente ronda
  Future<bool> startNextRound() async {
    if (state.currentRoom == null) return false;

    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _apiService.startNextRound(state.currentRoom!.id);
      
      if (response == null) {
        // No hay más rondas
        state = state.copyWith(isLoading: false);
        return false;
      }

      final round = RoundResponse.fromJson(response);
      state = state.copyWith(
        currentRound: round,
        currentPhotos: [],
        currentVotes: [],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Finalizar juego
  Future<void> finishGame() async {
    if (state.currentRoom == null) return;

    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _apiService.finishGame(state.currentRoom!.id);
      final result = MatchResultResponse.fromJson(response);

      state = state.copyWith(
        gameResult: result,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cargar resultado del juego
  Future<void> loadGameResult() async {
    if (state.currentRoom == null) return;

    try {
      final response = await _apiService.getGameResult(state.currentRoom!.id);
      final result = MatchResultResponse.fromJson(response);

      state = state.copyWith(gameResult: result);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Limpiar estado
  void reset() {
    state = PhotoClashState();
  }

  // Limpiar error
  void clearError() {
    state = state.clearError();
  }
}

// Provider del notifier
final photoClashProvider = StateNotifierProvider<PhotoClashNotifier, PhotoClashState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PhotoClashNotifier(apiService);
});
