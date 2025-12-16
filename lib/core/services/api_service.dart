import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/backend_config.dart';

class ApiService {
  // Configuración del backend
  static String get baseUrl => BackendConfig.apiUrl;
  
  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  
  // Headers comunes
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // ============================================================
  // USERS
  // ============================================================
  
  Future<Map<String, dynamic>> createUser({
    required String username,
    String? avatarUrl,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Users'),
      headers: _headers,
      body: jsonEncode({
        'Username': username,
        'AvatarUrl': avatarUrl,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear usuario: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> getUser(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Users/$userId'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener usuario: ${response.body}');
    }
  }
  
  Future<void> updateLastLogin(String userId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Users/$userId/login'),
      headers: _headers,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar login: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> getUserSettings(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Users/$userId/settings'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener configuración: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> updateUserSettings({
    required String userId,
    required bool darkMode,
    required bool notifications,
    required String language,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Users/settings'),
      headers: _headers,
      body: jsonEncode({
        'UserId': userId,
        'DarkMode': darkMode,
        'Notifications': notifications,
        'Language': language,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar configuración: ${response.body}');
    }
  }
  
  // ============================================================
  // PHOTOCLASH (PvP)
  // ============================================================
  
  Future<Map<String, dynamic>> createRoom({
    required String hostUserId,
    required int roundsTotal,
    required int secondsPerRound,
    bool nsfwAllowed = false,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoClash/rooms'),
      headers: _headers,
      body: jsonEncode({
        'HostUserId': hostUserId,
        'RoundsTotal': roundsTotal,
        'SecondsPerRound': secondsPerRound,
        'NsfwAllowed': nsfwAllowed,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear sala: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> joinRoom({
    required String code,
    required String userId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoClash/rooms/join'),
      headers: _headers,
      body: jsonEncode({
        'Code': code,
        'UserId': userId,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al unirse a la sala: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> getRoom(String roomId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PhotoClash/rooms/$roomId'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener sala: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> startGame({
    required String roomId,
    String language = 'es',
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoClash/rooms/start'),
      headers: _headers,
      body: jsonEncode({
        'RoomId': roomId,
        'Language': language,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al iniciar juego: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> getCurrentRound(String roomId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PhotoClash/rooms/$roomId/current-round'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener ronda actual: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> uploadPhoto({
    required String roundId,
    required String playerId,
    required String photoUrl,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoClash/photos'),
      headers: _headers,
      body: jsonEncode({
        'RoundId': roundId,
        'PlayerId': playerId,
        'PhotoUrl': photoUrl,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al subir foto: ${response.body}');
    }
  }
  
  Future<List<dynamic>> getRoundPhotos(String roundId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PhotoClash/rounds/$roundId/photos'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener fotos: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> vote({
    required String roundId,
    required String voterPlayerId,
    required String votedPlayerId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoClash/votes'),
      headers: _headers,
      body: jsonEncode({
        'RoundId': roundId,
        'VoterPlayerId': voterPlayerId,
        'VotedPlayerId': votedPlayerId,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al votar: ${response.body}');
    }
  }
  
  Future<List<dynamic>> getRoundVotes(String roundId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PhotoClash/rounds/$roundId/votes'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener votos: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> finishRound(String roundId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoClash/rounds/$roundId/finish'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al finalizar ronda: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>?> startNextRound(String roomId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoClash/rooms/$roomId/next-round'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final body = response.body;
      if (body.isEmpty || body == 'null') return null;
      return jsonDecode(body);
    } else {
      throw Exception('Error al iniciar siguiente ronda: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> finishGame(String roomId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoClash/rooms/$roomId/finish'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al finalizar juego: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> getGameResult(String roomId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PhotoClash/rooms/$roomId/result'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener resultado: ${response.body}');
    }
  }
  
  // ============================================================
  // PHOTOSWEEP (Limpieza de fotos)
  // ============================================================
  
  Future<Map<String, dynamic>> registerPhoto({
    required String userId,
    required String uri,
    DateTime? dateTaken,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoSweep/photos'),
      headers: _headers,
      body: jsonEncode({
        'UserId': userId,
        'Uri': uri,
        'DateTaken': dateTaken?.toIso8601String(),
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar foto: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> keepPhoto(String photoId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoSweep/photos/$photoId/keep'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al marcar foto como mantener: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> deletePhoto(String photoId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoSweep/photos/$photoId/delete'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al marcar foto como eliminar: ${response.body}');
    }
  }
  
  Future<List<dynamic>> getUnreviewedPhotos(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PhotoSweep/users/$userId/unreviewed'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener fotos pendientes: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> recoverPhoto(String photoId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoSweep/photos/$photoId/recover'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al recuperar foto: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> getStats(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PhotoSweep/users/$userId/stats'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener estadísticas: ${response.body}');
    }
  }
  
  Future<List<dynamic>> getDeletedPhotos(String userId, {int limit = 5}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PhotoSweep/users/$userId/deleted?limit=$limit'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener fotos eliminadas: ${response.body}');
    }
  }
  
  
  // ============================================================
  // HEALTH CHECK
  // ============================================================
  
  Future<bool> isBackendAvailable() async {
    try {
      final response = await _client.get(
        Uri.parse(BackendConfig.baseUrl),
        headers: _headers,
      ).timeout(BackendConfig.connectionTimeout);
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  void dispose() {
    _client.close();
  }
}
