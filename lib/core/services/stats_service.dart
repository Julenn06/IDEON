import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static const _totalDeletedKey = 'stats_total_deleted';
  static const _totalBytesKey = 'stats_total_bytes';
  static const _sessionsKey = 'stats_sessions';
  static const _lastSessionKey = 'stats_last_session';

  // Incrementar contador total de fotos eliminadas
  static Future<void> addDeletedPhotos(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalDeletedKey) ?? 0;
    await prefs.setInt(_totalDeletedKey, current + count);
  }

  // Incrementar bytes totales liberados
  static Future<void> addFreedBytes(int bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalBytesKey) ?? 0;
    await prefs.setInt(_totalBytesKey, current + bytes);
  }

  // Registrar una sesión de limpieza
  static Future<void> recordSession(int photosDeleted, int bytesFreed) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Actualizar totales
    await addDeletedPhotos(photosDeleted);
    await addFreedBytes(bytesFreed);
    
    // Incrementar contador de sesiones
    final sessions = prefs.getInt(_sessionsKey) ?? 0;
    await prefs.setInt(_sessionsKey, sessions + 1);
    
    // Guardar fecha de última sesión
    await prefs.setString(_lastSessionKey, DateTime.now().toIso8601String());
  }

  // Obtener estadísticas totales
  static Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'totalDeleted': prefs.getInt(_totalDeletedKey) ?? 0,
      'totalBytes': prefs.getInt(_totalBytesKey) ?? 0,
      'sessions': prefs.getInt(_sessionsKey) ?? 0,
      'lastSession': prefs.getString(_lastSessionKey),
    };
  }

  // Resetear estadísticas
  static Future<void> resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_totalDeletedKey);
    await prefs.remove(_totalBytesKey);
    await prefs.remove(_sessionsKey);
    await prefs.remove(_lastSessionKey);
  }
}
