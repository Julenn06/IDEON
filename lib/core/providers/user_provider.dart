import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';
import '../models/backend_models.dart';

// Estado del usuario
class UserState {
  final UserResponse? user;
  final AppSettingsResponse? settings;
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  UserState({
    this.user,
    this.settings,
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  UserState copyWith({
    UserResponse? user,
    AppSettingsResponse? settings,
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
  }) {
    return UserState(
      user: user ?? this.user,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  UserState clearError() {
    return copyWith(error: '');
  }
}

// Notifier para el usuario
class UserNotifier extends StateNotifier<UserState> {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  UserNotifier(this._apiService, this._prefs) : super(UserState()) {
    _loadSavedUser();
  }

  // Cargar usuario guardado
  Future<void> _loadSavedUser() async {
    final userId = _prefs.getString('userId');
    if (userId != null && userId.isNotEmpty) {
      await loadUser(userId);
    }
  }

  // Registrar nuevo usuario
  Future<void> registerUser(String username) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _apiService.registerUser(username: username);
      final user = UserResponse.fromJson(response);

      // Guardar ID del usuario
      await _prefs.setString('userId', user.id);

      state = state.copyWith(
        user: user,
        isLoading: false,
        isLoggedIn: true,
      );

      // Cargar configuración
      await loadSettings();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cargar usuario existente
  Future<void> loadUser(String userId) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _apiService.getUser(userId);
      final user = UserResponse.fromJson(response);

      state = state.copyWith(
        user: user,
        isLoading: false,
        isLoggedIn: true,
      );

      // Cargar configuración
      await loadSettings();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Actualizar avatar
  Future<void> updateAvatar(String avatarUrl) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _apiService.updateUserAvatar(
        userId: state.user!.id,
        avatarUrl: avatarUrl,
      );
      final user = UserResponse.fromJson(response);

      state = state.copyWith(
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cargar configuración
  Future<void> loadSettings() async {
    if (state.user == null) return;

    try {
      final response = await _apiService.getUserSettings(state.user!.id);
      final settings = AppSettingsResponse.fromJson(response);

      state = state.copyWith(settings: settings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Actualizar configuración
  Future<void> updateSettings({
    required bool darkMode,
    required bool notifications,
    required String language,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _apiService.updateUserSettings(
        userId: state.user!.id,
        darkMode: darkMode,
        notifications: notifications,
        language: language,
      );
      final settings = AppSettingsResponse.fromJson(response);

      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _prefs.remove('userId');
    state = UserState();
  }

  // Limpiar error
  void clearError() {
    state = state.clearError();
  }

  // Generar username aleatorio
  String generateRandomUsername() {
    final uuid = const Uuid();
    final shortId = uuid.v4().substring(0, 8);
    return 'User_$shortId';
  }
}

// Provider de SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider del notifier de usuario
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  
  return prefs.when(
    data: (sharedPrefs) => UserNotifier(apiService, sharedPrefs),
    loading: () => UserNotifier(apiService, ref.read(sharedPreferencesProvider).value!),
    error: (_, __) => UserNotifier(apiService, ref.read(sharedPreferencesProvider).value!),
  );
});

// Provider del servicio API
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
