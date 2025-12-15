import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/backend_models.dart';

// Estado del PhotoSweep
class PhotoSweepState {
  final List<PhotoSweepPhotoResponse> pendingPhotos;
  final List<PhotoSweepPhotoResponse> recentDeleted;
  final PhotoSweepStatsResponse? stats;
  final bool isLoading;
  final String? error;
  final String? currentUserId;

  PhotoSweepState({
    this.pendingPhotos = const [],
    this.recentDeleted = const [],
    this.stats,
    this.isLoading = false,
    this.error,
    this.currentUserId,
  });

  PhotoSweepState copyWith({
    List<PhotoSweepPhotoResponse>? pendingPhotos,
    List<PhotoSweepPhotoResponse>? recentDeleted,
    PhotoSweepStatsResponse? stats,
    bool? isLoading,
    String? error,
    String? currentUserId,
  }) {
    return PhotoSweepState(
      pendingPhotos: pendingPhotos ?? this.pendingPhotos,
      recentDeleted: recentDeleted ?? this.recentDeleted,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }

  PhotoSweepState clearError() {
    return copyWith(error: '');
  }
}

// Notifier para PhotoSweep
class PhotoSweepNotifier extends StateNotifier<PhotoSweepState> {
  final ApiService _apiService;

  PhotoSweepNotifier(this._apiService) : super(PhotoSweepState());

  // Establecer usuario actual
  void setCurrentUser(String userId) {
    state = state.copyWith(currentUserId: userId);
    loadPendingPhotos();
    loadStats();
  }

  // Registrar foto
  Future<void> registerPhoto({
    required String uri,
    DateTime? dateTaken,
  }) async {
    if (state.currentUserId == null) return;

    state = state.copyWith(isLoading: true, error: '');
    try {
      await _apiService.registerPhoto(
        userId: state.currentUserId!,
        uri: uri,
        dateTaken: dateTaken,
      );

      state = state.copyWith(isLoading: false);
      
      // Recargar fotos pendientes
      await loadPendingPhotos();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Marcar foto como mantener
  Future<void> keepPhoto(String photoId) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      await _apiService.keepPhoto(photoId);

      // Remover de la lista de pendientes
      final updated = state.pendingPhotos
          .where((p) => p.id != photoId)
          .toList();

      state = state.copyWith(
        pendingPhotos: updated,
        isLoading: false,
      );

      // Actualizar estadísticas
      await loadStats();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Marcar foto como eliminar
  Future<void> deletePhoto(String photoId) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      await _apiService.deletePhoto(photoId);

      // Remover de la lista de pendientes
      final updated = state.pendingPhotos
          .where((p) => p.id != photoId)
          .toList();

      state = state.copyWith(
        pendingPhotos: updated,
        isLoading: false,
      );

      // Actualizar estadísticas y fotos eliminadas
      await loadStats();
      await loadRecentDeleted();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cargar fotos pendientes
  Future<void> loadPendingPhotos() async {
    if (state.currentUserId == null) return;

    try {
      final response = await _apiService.getPendingPhotos(state.currentUserId!);
      final photos = response
          .map((json) => PhotoSweepPhotoResponse.fromJson(json))
          .toList();

      state = state.copyWith(pendingPhotos: photos);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Recuperar foto eliminada
  Future<void> recoverPhoto(String photoId) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      await _apiService.recoverPhoto(photoId);

      // Remover de la lista de eliminadas
      final updated = state.recentDeleted
          .where((p) => p.id != photoId)
          .toList();

      state = state.copyWith(
        recentDeleted: updated,
        isLoading: false,
      );

      // Actualizar estadísticas
      await loadStats();
      await loadPendingPhotos();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cargar estadísticas
  Future<void> loadStats() async {
    if (state.currentUserId == null) return;

    try {
      final response = await _apiService.getStats(state.currentUserId!);
      final stats = PhotoSweepStatsResponse.fromJson(response);

      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Cargar fotos eliminadas recientemente
  Future<void> loadRecentDeleted() async {
    if (state.currentUserId == null) return;

    try {
      final response = await _apiService.getRecentDeletedPhotos(state.currentUserId!);
      final photos = response
          .map((json) => PhotoSweepPhotoResponse.fromJson(json))
          .toList();

      state = state.copyWith(recentDeleted: photos);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Eliminar foto permanentemente
  Future<void> permanentDeletePhoto(String photoId) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      await _apiService.permanentDeletePhoto(photoId);

      // Remover de la lista de eliminadas
      final updated = state.recentDeleted
          .where((p) => p.id != photoId)
          .toList();

      state = state.copyWith(
        recentDeleted: updated,
        isLoading: false,
      );

      // Actualizar estadísticas
      await loadStats();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Limpiar error
  void clearError() {
    state = state.clearError();
  }

  // Resetear estado
  void reset() {
    state = PhotoSweepState();
  }
}

// Provider del notifier
final photoSweepProvider = StateNotifierProvider<PhotoSweepNotifier, PhotoSweepState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PhotoSweepNotifier(apiService);
});

// Provider del servicio API (importado del otro archivo)
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
