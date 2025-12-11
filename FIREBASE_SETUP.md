## Configuración de Firebase para PhotoClash

### Pasos para integrar Firebase (Futuro)

1. **Crear proyecto en Firebase Console**
   - Ve a https://console.firebase.google.com/
   - Crea un nuevo proyecto llamado "IDEON"
   - Activa Google Analytics (opcional)

2. **Registrar app Android**
   - En la consola de Firebase, agrega una app Android
   - Package name: `com.example.ideon` (o el que uses)
   - Descarga `google-services.json`
   - Colócalo en `android/app/`

3. **Configurar Firebase en el proyecto**
   
   Agrega al archivo `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```

   Agrega al archivo `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

4. **Activar servicios en Firebase**
   - **Realtime Database**: Para salas en tiempo real
   - **Cloud Storage**: Para subir fotos de partidas
   - **Authentication** (opcional): Para usuarios registrados

5. **Reglas de seguridad sugeridas**

   **Realtime Database:**
   ```json
   {
     "rules": {
       "rooms": {
         "$roomId": {
           ".read": true,
           ".write": true
         }
       }
     }
   }
   ```

   **Cloud Storage:**
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /photoclash/{roomId}/{fileName} {
         allow read, write: if true;
       }
     }
   }
   ```

6. **Inicializar Firebase en main.dart**
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     
     SystemChrome.setPreferredOrientations([
       DeviceOrientation.portraitUp,
       DeviceOrientation.portraitDown,
     ]);

     runApp(const ProviderScope(child: MyApp()));
   }
   ```

### Estructura de datos sugerida

**Salas (Realtime Database):**
```json
{
  "rooms": {
    "ABC123": {
      "id": "uuid-here",
      "code": "ABC123",
      "hostId": "player1",
      "maxPlayers": 6,
      "rounds": 10,
      "timePerRound": 60,
      "phraseMode": "normal",
      "language": "es",
      "status": 0,
      "currentRound": 1,
      "players": {
        "player1": {
          "id": "player1",
          "name": "Juan",
          "score": 3,
          "ready": true
        }
      },
      "roundsData": {
        "1": {
          "phrase": "La foto más rara de tu galería",
          "submissions": {
            "player1": {
              "playerId": "player1",
              "photoUrl": "gs://...",
              "timestamp": "2024-01-01T00:00:00Z"
            }
          },
          "votes": {
            "player2": "player1"
          }
        }
      }
    }
  }
}
```

### Estado actual del proyecto

⚠️ **NOTA IMPORTANTE**: 
- Las dependencias de Firebase ya están agregadas al `pubspec.yaml`
- Los modelos de datos ya están creados en `lib/core/models/game_room.dart`
- La UI de PhotoClash está completa y funcional
- **PENDIENTE**: Implementar la lógica de comunicación con Firebase

### Tareas pendientes para PhotoClash:

- [ ] Crear servicio `FirebaseService` en `lib/core/services/`
- [ ] Implementar creación de salas en Realtime Database
- [ ] Implementar unión a salas existentes
- [ ] Crear sistema de listeners para cambios en tiempo real
- [ ] Implementar subida de fotos a Cloud Storage
- [ ] Crear pantalla de lobby (espera de jugadores)
- [ ] Crear pantalla de juego en vivo
- [ ] Implementar sistema de votación
- [ ] Crear pantalla de resultados finales
- [ ] Agregar manejo de errores y desconexiones

### Recursos útiles

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Realtime Database](https://firebase.google.com/docs/database)
- [Cloud Storage for Flutter](https://firebase.google.com/docs/storage/flutter/start)
