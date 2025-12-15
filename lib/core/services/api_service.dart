import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Configuración del backend
  static const String baseUrl = 'http://localhost:5000/api';
  
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
  
  Future<Map<String, dynamic>> registerUser({
    required String username,
    String? avatarUrl,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Users/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'avatarUrl': avatarUrl,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar usuario: ${response.body}');
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
  
  Future<Map<String, dynamic>> updateUserAvatar({
    required String userId,
    required String avatarUrl,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/Users/$userId/avatar'),
      headers: _headers,
      body: jsonEncode({'avatarUrl': avatarUrl}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar avatar: ${response.body}');
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
    final response = await _client.put(
      Uri.parse('$baseUrl/Users/$userId/settings'),
      headers: _headers,
      body: jsonEncode({
        'darkMode': darkMode,
        'notifications': notifications,
        'language': language,
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
        'hostUserId': hostUserId,
        'roundsTotal': roundsTotal,
        'secondsPerRound': secondsPerRound,
        'nsfwAllowed': nsfwAllowed,
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
        'code': code,
        'userId': userId,
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
        'roomId': roomId,
        'language': language,
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
        'roundId': roundId,
        'playerId': playerId,
        'photoUrl': photoUrl,
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
        'roundId': roundId,
        'voterPlayerId': voterPlayerId,
        'votedPlayerId': votedPlayerId,
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
      Uri.parse('$baseUrl/PhotoSweep/register'),
      headers: _headers,
      body: jsonEncode({
        'userId': userId,
        'uri': uri,
        'dateTaken': dateTaken?.toIso8601String(),
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
      Uri.parse('$baseUrl/PhotoSweep/keep'),
      headers: _headers,
      body: jsonEncode({'photoId': photoId}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al marcar foto como mantener: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> deletePhoto(String photoId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoSweep/delete'),
      headers: _headers,
      body: jsonEncode({'photoId': photoId}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al marcar foto como eliminar: ${response.body}');
    }
  }
  
  Future<List<dynamic>> getPendingPhotos(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PhotoSweep/pending/$userId'),
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
      Uri.parse('$baseUrl/PhotoSweep/recover'),
      headers: _headers,
      body: jsonEncode({'photoId': photoId}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al recuperar foto: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> getStats(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PhotoSweep/stats/$userId'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener estadísticas: ${response.body}');
    }
  }
  
  Future<List<dynamic>> getRecentDeletedPhotos(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PhotoSweep/recent-deleted/$userId'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener fotos eliminadas: ${response.body}');
    }
  }
  
  Future<void> permanentDeletePhoto(String photoId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PhotoSweep/permanent-delete'),
      headers: _headers,
      body: jsonEncode({'photoId': photoId}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar permanentemente: ${response.body}');
    }
  }
  
  // ============================================================
  // HEALTH CHECK
  // ============================================================
  
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _client.get(
      Uri.parse('http://localhost:5000/health'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Backend no disponible');
    }
  }
  
  void dispose() {
    _client.close();
  }
}
