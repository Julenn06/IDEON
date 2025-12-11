# IDEON - Clean & Clash 🎨📸

Una aplicación móvil moderna desarrollada con Flutter que combina dos experiencias únicas: limpieza inteligente de fotos y juegos sociales competitivos.

## 🌟 Características Principales

### 📱 PhotoSweep - Limpieza Inteligente de Fotos
- **Sistema de Swipe Intuitivo**: Desliza izquierda para eliminar, derecha para conservar
- **Modo Aleatorio**: Revisa tus fotos en orden completamente random
- **Modo Nostalgia**: Comienza con las fotos más antiguas de tu galería
- **Recuperación Temporal**: Guarda las últimas 5 fotos eliminadas para recuperación rápida
- **Estadísticas en Tiempo Real**: Ve cuántas fotos has eliminado y espacio liberado
- **Feedback Háptico**: Vibraciones suaves para cada acción
- **Confirmación Opcional**: Activa confirmaciones antes de eliminar (configurable)

### 🎮 PhotoClash - Juego Social PVP
- **Salas Privadas**: Crea salas con códigos únicos de 6 caracteres
- **2-6 Jugadores**: Juega con amigos en partidas competitivas
- **Múltiples Modos de Juego**:
  - Normal: Frases divertidas para todos
  - Locas: Desafíos más atrevidos
  - NSFW: Contenido para adultos (opcional, activable en ajustes)
- **Configuración Personalizada**:
  - Número de rondas (5-30)
  - Tiempo por ronda (30s, 60s, 90s)
  - Máximo de jugadores (2, 4, 6)
  - Idioma (Español/English)
- **Sistema de Votación**: Todos votan la mejor foto de cada ronda
- **Puntuación**: Sistema de puntos con ganador al final
- **Frases Dinámicas**: Más de 15 frases únicas por modo e idioma

### ⚙️ Ajustes Completos
- **Temas**: Claro, Oscuro, Sistema
- **7 Colores Principales**: Personaliza el color de la app
- **Idiomas**: Español e Inglés
- **Control de Vibraciones**: Activa/desactiva feedback háptico
- **Modo NSFW**: Control parental para contenido adulto
- **Confirmación de Eliminación**: Seguridad adicional en PhotoSweep

## 🎨 Diseño UI/UX

- **Material Design 3**: Diseño moderno siguiendo las últimas guías de Google
- **Animaciones Fluidas**: Transiciones suaves con flutter_animate
- **Microinteracciones**: Feedback visual y háptico en cada acción
- **Tarjetas 3D**: Elevaciones y sombras elegantes
- **Gradientes Dinámicos**: Fondos que se adaptan al tema
- **Iconos Minimalistas**: Interfaz limpia y profesional
- **Bordes Redondeados**: Radio de 16-24dp para suavidad visual

## 🏗️ Arquitectura Técnica

### Tecnologías Utilizadas
- **Flutter 3+**: Framework multiplataforma
- **Riverpod**: State management reactivo y eficiente
- **photo_manager**: Acceso completo a la galería del dispositivo
- **Firebase**: Backend para PhotoClash (próximamente integrado)
- **flutter_animate**: Animaciones declarativas
- **shared_preferences**: Persistencia local de configuraciones
- **vibration**: Feedback háptico

### Estructura del Proyecto
```
lib/
├── core/
│   ├── models/          # Modelos de datos
│   ├── providers/       # Proveedores Riverpod
│   ├── services/        # Servicios (háptico, etc.)
│   ├── theme/           # Temas y estilos
│   ├── constants/       # Constantes (frases, etc.)
│   └── utils/           # Utilidades
├── screens/
│   ├── home_screen.dart
│   ├── photosweep/     # Módulo PhotoSweep
│   ├── photoclash/     # Módulo PhotoClash
│   └── settings/       # Pantalla de ajustes
└── main.dart
```

## 🚀 Instalación y Configuración

### Requisitos Previos
- Flutter SDK 3.0 o superior
- Dart 3.0 o superior
- Android Studio / VS Code con extensiones de Flutter
- Dispositivo Android físico o emulador

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd ideon
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Verificar configuración de Flutter**
```bash
flutter doctor
```

4. **Ejecutar en modo debug**
```bash
flutter run
```

5. **Compilar para producción**
```bash
flutter build apk --release
# o
flutter build appbundle --release
```

## 📋 Permisos Requeridos

### Android
La app requiere los siguientes permisos (ya configurados en AndroidManifest.xml):
- `READ_EXTERNAL_STORAGE` (Android ≤12)
- `WRITE_EXTERNAL_STORAGE` (Android ≤10)
- `READ_MEDIA_IMAGES` (Android ≥13)
- `INTERNET` (Para PhotoClash)
- `VIBRATE` (Para feedback háptico)

## 🎮 Cómo Usar

### PhotoSweep
1. Toca el panel "PhotoSweep" en la pantalla principal
2. Concede permisos de acceso a fotos
3. Elige entre modo aleatorio o modo nostalgia
4. Desliza las fotos:
   - ⬅️ Izquierda = Eliminar (rojo)
   - ➡️ Derecha = Conservar (verde)
5. Usa los botones flotantes como alternativa al swipe
6. Ve tus estadísticas en la parte superior

### PhotoClash
1. Toca el panel "PhotoClash" en la pantalla principal
2. **Crear Sala**:
   - Ingresa tu nombre
   - Configura la partida
   - Comparte el código con amigos
3. **Unirse a Sala**:
   - Ingresa tu nombre
   - Introduce el código de 6 caracteres
4. **Jugar**:
   - Lee la frase del desafío
   - Selecciona una foto de tu galería
   - Espera a que todos suban sus fotos
   - Vota la mejor foto (no puedes votarte a ti mismo)
   - ¡Gana puntos y conviértete en el campeón!

### Ajustes
- Personaliza el tema (claro/oscuro/sistema)
- Elige tu color favorito de entre 7 opciones
- Cambia el idioma (ES/EN)
- Activa/desactiva vibraciones
- Configura confirmaciones de eliminación
- Activa modo NSFW para PhotoClash

## 🎯 Roadmap / Próximas Características

- [ ] Integración completa de Firebase para PhotoClash
- [ ] Sistema de chat en tiempo real durante partidas
- [ ] Logros y estadísticas globales
- [ ] Frases personalizadas del usuario
- [ ] Modo público para PhotoClash
- [ ] Compartir resultados en redes sociales
- [ ] Backup automático de fotos eliminadas
- [ ] Machine Learning para sugerencias de limpieza
- [ ] Widget de estadísticas en pantalla principal
- [ ] Modo espectador en PhotoClash
- [ ] Ranking global de jugadores
- [ ] Temas personalizados completos

## 🐛 Problemas Conocidos

- La integración de Firebase está parcialmente implementada (PhotoClash actualmente solo muestra UI)
- La recuperación de fotos eliminadas está en desarrollo
- Algunas animaciones pueden variar según el dispositivo

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es privado y de uso personal.

## 👨‍💻 Autor

Desarrollado con ❤️ usando Flutter

## 🙏 Agradecimientos

- Flutter Team por el increíble framework
- Riverpod por el excelente state management
- Comunidad de Flutter por los paquetes open source

---

**IDEON - Clean & Clash** - Donde la limpieza se encuentra con la diversión 🎉
