# ✅ IDEON - Conexión Backend-Frontend COMPLETADA

## 🎯 Estado Actual

### Backend (C# ASP.NET Core 8) ✅
- **URL**: http://localhost:5000
- **Swagger**: http://localhost:5000 (documentación interactiva)
- **SignalR Hub**: http://localhost:5000/hubs/photoclash
- **Base de datos**: PostgreSQL/CrateDB en AWS
- **Compilación**: ✅ Sin errores
- **Ejecución**: ✅ Servidor corriendo

**Endpoints disponibles:**
- ✅ **Users**: POST crear, GET por UUID, GET settings, POST login
- ✅ **PhotoSweep**: POST photos, GET unreviewed, POST keep/delete/recover, GET stats/deleted
- ✅ **PhotoClash**: POST rooms, POST join, POST start, GET room/round, POST photos/votes

### Frontend (Flutter) ✅
- **Dependencias**: ✅ Instaladas (`flutter pub get` exitoso)
- **ApiService**: ✅ Actualizado con endpoints correctos
- **SignalRService**: ✅ Creado para tiempo real PhotoClash
- **BackendConfig**: ✅ Configuración centralizada
- **Estructura**: ✅ core/services, core/models, screens

---

## 🚀 Para Empezar a Desarrollar

### 1. Backend ya está corriendo
El backend debe seguir ejecutándose en la terminal actual.

### 2. Configurar IP en Flutter

**Editar**: `lib/core/constants/backend_config.dart`

**Para Emulador Android:**
```dart
static const String baseUrl = 'http://10.0.2.2:5000';
```

**Para Dispositivo Físico (misma WiFi):**
```dart
// Obtener tu IP local:
// Windows: ipconfig → "Dirección IPv4"
static const String baseUrl = 'http://192.168.1.XXX:5000';
```

**Para Navegador Web:**
```dart
static const String baseUrl = 'http://localhost:5000';
```

### 3. Ejecutar Flutter
```bash
cd C:\Users\in2dm3-d.ELORRIETA\Desktop\IA\IDEON
flutter run
```

---

## 📝 Flujo Mínimo de Integración

### 1️⃣ Crear Usuario (Primera vez)
```dart
final apiService = ApiService();
final user = await apiService.createUser(
  username: 'usuario_test',
  avatarUrl: 'https://i.pravatar.cc/150?img=1',
);
String userId = user['Id']; // Guardar en SharedPreferences
```

### 2️⃣ PhotoSweep - Registrar y Limpiar Fotos
```dart
// Registrar foto
await apiService.registerPhoto(
  userId: userId,
  uri: 'content://...',
  dateTaken: DateTime.now(),
);

// Obtener no revisadas
final photos = await apiService.getUnreviewedPhotos(userId);

// Marcar como mantener/eliminar
await apiService.keepPhoto(photoId);
await apiService.deletePhoto(photoId);
```

### 3️⃣ PhotoClash - Crear/Unir Sala
```dart
// Crear sala
final room = await apiService.createRoom(
  hostUserId: userId,
  roundsTotal: 10,
  secondsPerRound: 60,
);
String code = room['Code']; // Compartir código

// Unirse a sala
final room = await apiService.joinRoom(
  code: 'ABC123',
  userId: userId,
);
```

### 4️⃣ PhotoClash - Tiempo Real con SignalR
```dart
final signalR = SignalRService();
await signalR.connect(roomId);

signalR.events.listen((event) {
  if (event is RoundStartedEvent) {
    print('Ronda ${event.roundNumber}: ${event.phrase}');
  }
  if (event is TimerTickEvent) {
    print('${event.secondsRemaining}s restantes');
  }
});

// Iniciar juego (solo host)
await apiService.startGame(roomId: roomId);
```

---

## 📚 Documentación Completa

Ver **`INTEGRACION_BACKEND.md`** para:
- ✅ Configuración detallada
- ✅ Ejemplos de todos los endpoints
- ✅ Manejo de errores
- ✅ Estructura de datos JSON
- ✅ Debugging y troubleshooting

---

## 🎨 Arquitectura

```
┌─────────────────────────────────────────────────┐
│            Flutter App (Frontend)               │
│  ┌──────────────────────────────────────────┐  │
│  │  Screens (UI)                            │  │
│  │  - HomeScreen                            │  │
│  │  - PhotoSweepScreen                      │  │
│  │  - PhotoClashScreen                      │  │
│  └────────────┬─────────────────────────────┘  │
│               │                                 │
│  ┌────────────▼─────────────────────────────┐  │
│  │  Services                                │  │
│  │  - ApiService (HTTP REST)                │  │
│  │  - SignalRService (WebSocket real-time) │  │
│  └────────────┬─────────────────────────────┘  │
└───────────────┼─────────────────────────────────┘
                │
                │ HTTP/WebSocket
                │
┌───────────────▼─────────────────────────────────┐
│         C# Backend (ASP.NET Core 8)             │
│  ┌──────────────────────────────────────────┐  │
│  │  API Controllers                         │  │
│  │  - UsersController                       │  │
│  │  - PhotoSweepController                  │  │
│  │  - PhotoClashController                  │  │
│  └────────────┬─────────────────────────────┘  │
│               │                                 │
│  ┌────────────▼─────────────────────────────┐  │
│  │  Services (Business Logic)               │  │
│  │  - UserService                           │  │
│  │  - PhotoSweepService                     │  │
│  │  - PhotoClashService                     │  │
│  └────────────┬─────────────────────────────┘  │
│               │                                 │
│  ┌────────────▼─────────────────────────────┐  │
│  │  Repositories (Data Access)              │  │
│  │  - UserRepository                        │  │
│  │  - PhotoRepository                       │  │
│  │  - RoomRepository                        │  │
│  └────────────┬─────────────────────────────┘  │
└───────────────┼─────────────────────────────────┘
                │
                │ EF Core + Npgsql
                │
┌───────────────▼─────────────────────────────────┐
│      PostgreSQL/CrateDB (Database)              │
│  Tables:                                        │
│  - users, photos, rooms, room_players           │
│  - rounds, round_photos, votes, match_results   │
│  - app_settings                                 │
└─────────────────────────────────────────────────┘
```

---

## 🧪 Probar Conexión

### Opción 1: Desde Swagger (Backend)
1. Abrir http://localhost:5000
2. Probar `POST /api/Users` con:
   ```json
   {
     "Username": "test",
     "AvatarUrl": "https://i.pravatar.cc/150?img=1"
   }
   ```
3. Copiar el `Id` devuelto (UUID)
4. Probar `GET /api/Users/{id}` con ese UUID

### Opción 2: Desde Flutter
```dart
// En main.dart o en un botón de prueba
void testBackend() async {
  final api = ApiService();
  
  try {
    final isOnline = await api.isBackendAvailable();
    print('Backend disponible: $isOnline');
    
    if (isOnline) {
      final user = await api.createUser(
        username: 'flutter_test',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
      );
      print('Usuario creado: ${user['Id']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## ⚠️ Notas Importantes

### UUIDs son Obligatorios
Todos los IDs son UUIDs (formato: `550e8400-e29b-41d4-a716-446655440000`)
- ✅ **Correcto**: `"550e8400-e29b-41d4-a716-446655440000"`
- ❌ **Incorrecto**: `"1"`, `"user123"`

### Foreign Keys
Para crear fotos, el usuario debe existir primero:
```dart
// 1. Crear usuario
final user = await api.createUser(...);
// 2. Registrar fotos con ese userId
await api.registerPhoto(userId: user['Id'], ...);
```

### CORS ya configurado
El backend permite peticiones desde cualquier origen en desarrollo.

### Firewall Windows
Si no conecta desde dispositivo físico, permitir puerto 5000 en el firewall.

---

## 🎉 ¡Todo Listo!

El backend y frontend están **completamente conectados** y listos para desarrollo.

**Siguiente paso:** Implementar la UI de Flutter consumiendo estos servicios.

Ver **`INTEGRACION_BACKEND.md`** para ejemplos completos de cada funcionalidad.
