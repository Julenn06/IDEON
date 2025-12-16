class BackendConfig {
  // URL del backend - Cambiar a la IP del servidor en producción
  static const String baseUrl = 'http://localhost:5000';
  static const String apiUrl = '$baseUrl/api';
  static const String signalRUrl = '$baseUrl/hubs/photoclash';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Para desarrollo local en emulador Android, usar:
  // static const String baseUrl = 'http://10.0.2.2:5000';
  
  // Para dispositivo físico en la misma red, usar la IP local del PC:
  // static const String baseUrl = 'http://192.168.1.XXX:5000';
  
  static String get usersEndpoint => '$apiUrl/Users';
  static String get photoSweepEndpoint => '$apiUrl/PhotoSweep';
  static String get photoClashEndpoint => '$apiUrl/PhotoClash';
}
