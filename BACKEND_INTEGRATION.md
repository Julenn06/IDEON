# Integración Backend IDEON - Flutter

## 🔧 Configuración

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Iniciar el backend

El backend ASP.NET Core debe estar ejecutándose en `http://localhost:5000`.

```bash
cd ../ideonBack
dotnet run
```

### 3. Configurar la URL del API (opcional)

Si el backend está en otra dirección, edita `lib/core/services/api_service.dart`:

```dart
static const String baseUrl = 'http://tu-servidor:puerto/api';
```

## 📦 Nuevos archivos añadidos

### Servicios
- `lib/core/services/api_service.dart` - Cliente HTTP para comunicarse con el backend

### Modelos
- `lib/core/models/backend_models.dart` - Modelos que coinciden con los DTOs del backend

### Providers
- `lib/core/providers/user_provider.dart` - Gestión de usuarios y autenticación
- `lib/core/providers/photoclash_api_provider.dart` - Gestión de PhotoClash (PvP)
- `lib/core/providers/photosweep_api_provider.dart` - Gestión de PhotoSweep (limpieza)

## 🎮 Uso de los Providers

### Inicializar usuario

```dart
// En tu pantalla principal
final userNotifier = ref.read(userProvider.notifier);

// Registrar nuevo usuario
await userNotifier.registerUser('MiNombreDeUsuario');

// O cargar usuario existente
await userNotifier.loadUser('user-id-guardado');

// Usuario actual
final user = ref.watch(userProvider).user;
```

### PhotoClash (Modo PvP)

```dart
final photoClashNotifier = ref.read(photoClashProvider.notifier);
final photoClashState = ref.watch(photoClashProvider);

// Crear sala
await photoClashNotifier.createRoom(
  hostUserId: user.id,
  roundsTotal: 10,
  secondsPerRound: 60,
  nsfwAllowed: false,
);

// Unirse a sala
await photoClashNotifier.joinRoom(
  code: 'ABC123',
  userId: user.id,
);

// Iniciar juego
await photoClashNotifier.startGame(language: 'es');

// Subir foto
await photoClashNotifier.uploadPhoto('url-de-la-foto');

// Votar
await photoClashNotifier.vote('player-id-votado');

// Código de la sala
final roomCode = photoClashState.currentRoom?.code;

// Jugadores
final players = photoClashState.currentRoom?.players ?? [];

// Ronda actual
final round = photoClashState.currentRound;
final promptPhrase = round?.promptPhrase;

// Fotos de la ronda
final photos = photoClashState.currentPhotos;

// Estado del juego
final isLoading = photoClashState.isLoading;
final error = photoClashState.error;
```

### PhotoSweep (Limpieza de fotos)

```dart
final photoSweepNotifier = ref.read(photoSweepProvider.notifier);
final photoSweepState = ref.watch(photoSweepProvider);

// Establecer usuario
photoSweepNotifier.setCurrentUser(user.id);

// Registrar foto
await photoSweepNotifier.registerPhoto(
  uri: 'file://path/to/photo.jpg',
  dateTaken: DateTime.now(),
);

// Marcar como mantener
await photoSweepNotifier.keepPhoto(photoId);

// Marcar como eliminar
await photoSweepNotifier.deletePhoto(photoId);

// Recuperar foto eliminada
await photoSweepNotifier.recoverPhoto(photoId);

// Fotos pendientes de revisar
final pendingPhotos = photoSweepState.pendingPhotos;

// Estadísticas
final stats = photoSweepState.stats;
final totalPhotos = stats?.totalPhotos ?? 0;
final kept = stats?.kept ?? 0;
final deleted = stats?.deleted ?? 0;

// Fotos eliminadas recientemente
final recentDeleted = photoSweepState.recentDeleted;
```

### Configuración de usuario

```dart
final userNotifier = ref.read(userProvider.notifier);
final userState = ref.watch(userProvider);

// Actualizar configuración
await userNotifier.updateSettings(
  darkMode: true,
  notifications: true,
  language: 'es',
);

// Configuración actual
final settings = userState.settings;
final darkMode = settings?.darkMode ?? false;
final language = settings?.language ?? 'es';
```

## 🔄 Migración desde Firebase

Si estabas usando Firebase anteriormente:

1. Los providers de Firebase (`firebase_service.dart`) siguen disponibles
2. Puedes usar ambos sistemas simultáneamente
3. Para cambiar completamente al nuevo backend:
   - Reemplaza las referencias a `FirebaseService` por `ApiService`
   - Usa los nuevos providers (`photoclash_api_provider`, `photosweep_api_provider`)
   - Los modelos son compatibles (ambos usan String para IDs)

## 🌐 Endpoints disponibles

### Users
- `POST /api/Users/register` - Registrar usuario
- `GET /api/Users/{userId}` - Obtener usuario
- `PUT /api/Users/{userId}/avatar` - Actualizar avatar
- `GET /api/Users/{userId}/settings` - Obtener configuración
- `PUT /api/Users/{userId}/settings` - Actualizar configuración

### PhotoClash
- `POST /api/PhotoClash/rooms` - Crear sala
- `POST /api/PhotoClash/rooms/join` - Unirse a sala
- `GET /api/PhotoClash/rooms/{roomId}` - Obtener sala
- `POST /api/PhotoClash/rooms/start` - Iniciar partida
- `POST /api/PhotoClash/photos` - Subir foto
- `POST /api/PhotoClash/votes` - Votar
- `POST /api/PhotoClash/rooms/{roomId}/finish` - Finalizar juego

### PhotoSweep
- `POST /api/PhotoSweep/register` - Registrar foto
- `POST /api/PhotoSweep/keep` - Mantener foto
- `POST /api/PhotoSweep/delete` - Eliminar foto
- `GET /api/PhotoSweep/stats/{userId}` - Estadísticas
- `POST /api/PhotoSweep/recover` - Recuperar foto

## 🐛 Debugging

### Verificar conexión con el backend

```dart
final apiService = ApiService();
try {
  final health = await apiService.healthCheck();
  print('Backend status: ${health['status']}');
} catch (e) {
  print('Error conectando con backend: $e');
}
```

### Errores comunes

1. **Backend no disponible**: Asegúrate de que `dotnet run` esté ejecutándose en el proyecto `ideonBack`
2. **CORS errors**: El backend ya está configurado con CORS habilitado
3. **Connection refused**: Verifica que la URL base sea `http://localhost:5000/api`

## 📝 Notas importantes

- Todos los IDs son strings (compatibles con UUID)
- Las fechas se manejan como DateTime en Flutter y se serializan a ISO 8601
- El backend usa CrateDB (compatible con protocolo PostgreSQL)
- SignalR no está implementado aún en Flutter (para eventos en tiempo real)
