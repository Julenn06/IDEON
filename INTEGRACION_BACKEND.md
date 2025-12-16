# Guía de Integración Frontend-Backend IDEON

## ✅ Configuración Completada

### Backend (C# - ASP.NET Core)
- ✅ API REST en `http://localhost:5000`
- ✅ Swagger UI en `http://localhost:5000`
- ✅ SignalR Hub en `http://localhost:5000/hubs/photoclash`
- ✅ Base de datos PostgreSQL/CrateDB configurada
- ✅ Validación UUID en todos los endpoints
- ✅ Manejo de errores global

### Frontend (Flutter)
- ✅ `ApiService` actualizado con endpoints correctos
- ✅ `SignalRService` para comunicación en tiempo real
- ✅ `BackendConfig` para configuración centralizada
- ✅ Paquetes necesarios agregados (`http`, `signalr_netcore`)

---

## 🚀 Pasos para Conectar

### 1. Instalar dependencias de Flutter

```bash
cd C:\Users\in2dm3-d.ELORRIETA\Desktop\IA\IDEON
flutter pub get
```

### 2. Verificar que el backend esté corriendo

El backend debe estar ejecutándose en `http://localhost:5000`

### 3. Configurar URL del backend según dispositivo

**📱 Emulador Android:**
```dart
// En backend_config.dart, cambiar a:
static const String baseUrl = 'http://10.0.2.2:5000';
```

**📱 Dispositivo físico (misma red WiFi):**
```dart
// En backend_config.dart, cambiar a la IP de tu PC:
static const String baseUrl = 'http://192.168.1.XXX:5000';
```

Para saber tu IP local:
```bash
# Windows
ipconfig
# Buscar "Dirección IPv4" de tu adaptador WiFi/Ethernet
```

**💻 Navegador web (Flutter Web):**
```dart
// Mantener:
static const String baseUrl = 'http://localhost:5000';
```

---

## 📋 Flujo de Uso

### **Paso 1: Crear Usuario**

```dart
final apiService = ApiService();

// Crear usuario al iniciar la app por primera vez
final user = await apiService.createUser(
  username: 'mi_usuario',
  avatarUrl: 'https://i.pravatar.cc/150?img=1',
);

// Guardar userId en SharedPreferences
final userId = user['Id']; // UUID como string
await prefs.setString('userId', userId);

// Actualizar último login
await apiService.updateLastLogin(userId);
```

### **Paso 2A: PhotoSweep (Limpieza)**

```dart
// 1. Registrar todas las fotos del dispositivo
final photos = await PhotoManager.getAssetListRange(...);

for (var photo in photos) {
  await apiService.registerPhoto(
    userId: userId,
    uri: photo.uri,
    dateTaken: photo.createDateTime,
  );
}

// 2. Obtener fotos no revisadas
final unreviewedPhotos = await apiService.getUnreviewedPhotos(userId);

// 3. Usuario desliza foto
// Derecha → Mantener
await apiService.keepPhoto(photoId);

// Izquierda → Eliminar
await apiService.deletePhoto(photoId);

// 4. Ver estadísticas
final stats = await apiService.getStats(userId);
print('Espacio liberado: ${stats['FormattedSpaceFreed']}');

// 5. Recuperar fotos eliminadas
final deleted = await apiService.getDeletedPhotos(userId, limit: 5);
await apiService.recoverPhoto(deleted[0]['Id']);
```

### **Paso 2B: PhotoClash (PVP)**

#### **Crear Sala**

```dart
final room = await apiService.createRoom(
  hostUserId: userId,
  roundsTotal: 10,
  secondsPerRound: 60,
  nsfwAllowed: false,
);

final roomId = room['Id'];
final code = room['Code']; // Compartir este código con otros jugadores
```

#### **Unirse a Sala**

```dart
final room = await apiService.joinRoom(
  code: 'ABCD12',
  userId: userId,
);

final roomId = room['Id'];
```

#### **Conectar SignalR para Tiempo Real**

```dart
final signalR = SignalRService();

// Conectar al hub
await signalR.connect(roomId);

// Escuchar eventos
signalR.events.listen((event) {
  if (event is RoundStartedEvent) {
    print('Ronda ${event.roundNumber}: ${event.phrase}');
    print('Tiempo: ${event.seconds}s');
  }
  
  if (event is TimerTickEvent) {
    print('Quedan ${event.secondsRemaining}s');
  }
  
  if (event is PhotoUploadedEvent) {
    print('${event.playerName} subió su foto');
  }
  
  if (event is VotingStartedEvent) {
    print('¡Fase de votación!');
  }
  
  if (event is RoundFinishedEvent) {
    print('Ganador: ${event.winnerName} (+${event.points} pts)');
  }
  
  if (event is GameFinishedEvent) {
    print('🏆 Campeón: ${event.winnerName}');
  }
});
```

#### **Iniciar Partida**

```dart
// El host inicia la partida
await apiService.startGame(roomId: roomId, language: 'es');
```

#### **Subir Foto en Ronda**

```dart
// 1. Obtener ronda actual
final round = await apiService.getCurrentRound(roomId);
final roundId = round['Id'];
final phrase = round['PromptPhrase'];

// 2. Usuario selecciona foto
final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

// 3. Subir a Firebase Storage (o tu CDN)
final photoUrl = await uploadToStorage(pickedFile);

// 4. Registrar foto en backend
final roundPhoto = await apiService.uploadPhoto(
  roundId: roundId,
  playerId: playerId, // ID del RoomPlayer obtenido al unirse
  photoUrl: photoUrl,
);

// 5. Notificar via SignalR
await signalR.notifyPhotoUploaded(roomId, playerId, username);
```

#### **Votar**

```dart
// 1. Obtener fotos de la ronda
final photos = await apiService.getRoundPhotos(roundId);

// 2. Mostrar galería y usuario vota
await apiService.vote(
  roundId: roundId,
  voterPlayerId: myPlayerId,
  votedPlayerId: selectedPlayerId,
);

// 3. Notificar via SignalR
await signalR.notifyVoteRegistered(roomId, username);
```

#### **Ver Resultados**

```dart
// Al finalizar el juego
final result = await apiService.getGameResult(roomId);
print('Ganador: ${result['WinnerPlayerName']}');
print('Puntos totales: ${result['WinnerTotalPoints']}');
```

#### **Desconectar**

```dart
await signalR.leaveRoom(roomId);
await signalR.disconnect();
```

---

## 🎨 Configuración de Usuario

```dart
// Obtener configuración
final settings = await apiService.getUserSettings(userId);

// Actualizar configuración
await apiService.updateUserSettings(
  userId: userId,
  darkMode: true,
  notifications: true,
  language: 'es',
);
```

---

## ⚠️ Manejo de Errores

```dart
try {
  final user = await apiService.createUser(username: 'test');
} catch (e) {
  if (e.toString().contains('400')) {
    // Error de validación (ej: UUID inválido)
    print('Datos inválidos');
  } else if (e.toString().contains('404')) {
    // No encontrado
    print('Recurso no existe');
  } else if (e.toString().contains('500')) {
    // Error del servidor
    print('Error interno');
  } else {
    // Error de conexión
    print('No se pudo conectar al backend');
  }
}
```

---

## 🔄 Verificar Conexión

```dart
final isOnline = await apiService.isBackendAvailable();
if (!isOnline) {
  // Mostrar mensaje "Backend no disponible"
}
```

---

## 📦 Estructura de Datos Importante

### Usuario
```dart
{
  "Id": "uuid-string",
  "Username": "string",
  "AvatarUrl": "string",
  "CreatedAt": "2025-12-16T11:00:00Z",
  "LastLogin": "2025-12-16T11:00:00Z"
}
```

### Sala
```dart
{
  "Id": "uuid-string",
  "Code": "ABC123",
  "HostUserId": "uuid-string",
  "RoundsTotal": 10,
  "SecondsPerRound": 60,
  "Status": "Waiting", // Waiting, Playing, Finished
  "Players": [...],
  "CurrentRoundNumber": 1
}
```

### Foto PhotoSweep
```dart
{
  "Id": "uuid-string",
  "UserId": "uuid-string",
  "Uri": "string",
  "DateTaken": "2025-12-16T11:00:00Z",
  "ReviewStatus": "Pending", // Pending, Kept, Deleted
  "ReviewedAt": null
}
```

---

## ✨ Próximos Pasos

1. ✅ **Instalar dependencias**: `flutter pub get`
2. ✅ **Configurar IP del backend** en `backend_config.dart`
3. ✅ **Implementar flujo de usuario** (crear/cargar usuario existente)
4. ✅ **Integrar PhotoSweep** con `photo_manager`
5. ✅ **Integrar PhotoClash** con SignalR
6. ✅ **Probar en emulador/dispositivo**

---

## 🐛 Debugging

**Si no conecta:**
1. Verificar que el backend esté corriendo
2. Verificar firewall de Windows (permitir puerto 5000)
3. Verificar IP correcta en `backend_config.dart`
4. Ver logs en el terminal del backend
5. Ver logs en Flutter DevTools

**Backend logs:**
```bash
cd C:\Users\in2dm3-d.ELORRIETA\Desktop\IA\ideonBack
dotnet run
```

**Flutter logs:**
```bash
flutter run
# Ver output en consola
```
