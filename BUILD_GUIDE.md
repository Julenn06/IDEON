# 🛠️ Guía de Compilación - IDEON

## Requisitos del Sistema

### Software Necesario
- **Flutter SDK**: 3.0 o superior
- **Dart SDK**: 3.0 o superior
- **Android Studio**: Arctic Fox o superior (para desarrollo Android)
- **VS Code**: (opcional, recomendado con extensiones de Flutter)
- **Git**: Para control de versiones

### SDK de Android
- **Android SDK**: API 21 (Android 5.0) o superior
- **Build Tools**: 30.0.3 o superior
- **NDK**: (opcional) para características nativas

---

## Configuración Inicial

### 1. Verificar Instalación de Flutter

```powershell
flutter doctor -v
```

Debes ver ✓ en:
- Flutter SDK
- Android toolchain
- Android Studio
- VS Code (si lo usas)

### 2. Clonar el Proyecto

```powershell
cd "C:\Users\TU_USUARIO\Desktop"
git clone <url-del-repositorio> ideon
cd ideon
```

### 3. Instalar Dependencias

```powershell
flutter pub get
```

Esto descargará todos los paquetes necesarios definidos en `pubspec.yaml`.

---

## Compilación para Desarrollo

### Modo Debug (Desarrollo)

**Conectar dispositivo físico:**
1. Activa "Opciones de desarrollador" en tu Android
2. Activa "Depuración USB"
3. Conecta el dispositivo por USB
4. Autoriza la conexión en el dispositivo

**Verificar dispositivos conectados:**
```powershell
flutter devices
```

**Ejecutar en modo debug:**
```powershell
flutter run
```

**Con hot reload automático:**
```powershell
flutter run --hot
```

### Modo Debug en Emulador

**Crear emulador (si no tienes uno):**
```powershell
# Desde Android Studio: Tools > Device Manager > Create Device
```

**Listar emuladores:**
```powershell
flutter emulators
```

**Iniciar emulador:**
```powershell
flutter emulators --launch <emulator_id>
```

**Ejecutar app:**
```powershell
flutter run
```

---

## Compilación para Producción

### Preparativos

#### 1. Configurar Firma de App

Edita `android/key.properties` (crear si no existe):
```properties
storePassword=tu_password
keyPassword=tu_password
keyAlias=key
storeFile=C:/Users/TU_USUARIO/keystore.jks
```

#### 2. Generar Keystore (Primera vez)

```powershell
keytool -genkey -v -keystore C:\Users\TU_USUARIO\keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

Responde las preguntas y guarda el password.

#### 3. Configurar build.gradle

Verifica que `android/app/build.gradle` tenga:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}
```

### Compilar APK (Desarrollo/Testing)

**APK Split (múltiples APKs por arquitectura):**
```powershell
flutter build apk --split-per-abi
```

Genera:
- `app-armeabi-v7a-release.apk` (~20 MB)
- `app-arm64-v8a-release.apk` (~22 MB)
- `app-x86_64-release.apk` (~25 MB)

Ubicación: `build/app/outputs/flutter-apk/`

**APK Universal (un solo APK):**
```powershell
flutter build apk
```

Genera: `app-release.apk` (~50 MB)

### Compilar App Bundle (Google Play)

**Recomendado para publicación en Play Store:**
```powershell
flutter build appbundle
```

Genera: `app-release.aab`
Ubicación: `build/app/outputs/bundle/release/`

---

## Optimizaciones de Compilación

### Reducir Tamaño

**Con obfuscación:**
```powershell
flutter build apk --obfuscate --split-debug-info=build/debug-info
```

**Con tree-shaking:**
```powershell
flutter build apk --tree-shake-icons
```

**Todo junto:**
```powershell
flutter build apk --release --obfuscate --split-debug-info=build/debug-info --tree-shake-icons --split-per-abi
```

### Compilación Específica

**Solo para ARM64 (mayoría de dispositivos modernos):**
```powershell
flutter build apk --target-platform android-arm64
```

**Para testing rápido:**
```powershell
flutter build apk --debug
```

---

## Análisis y Verificación

### Analizar Tamaño del APK

```powershell
flutter build apk --analyze-size
```

### Verificar Performance

```powershell
flutter build apk --profile
flutter run --profile
```

### Tests

**Ejecutar todos los tests:**
```powershell
flutter test
```

**Tests con coverage:**
```powershell
flutter test --coverage
```

---

## Instalación del APK

### Método 1: ADB (Recomendado)

```powershell
# Dispositivo conectado por USB
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Método 2: Transferencia Manual

1. Copia el APK a tu dispositivo
2. Abre el archivo con un gestor de archivos
3. Activa "Instalar desde fuentes desconocidas" si es necesario
4. Instala

---

## Publicación en Google Play

### 1. Crear Cuenta de Desarrollador
- Regístrate en [Google Play Console](https://play.google.com/console)
- Pago único de $25 USD

### 2. Preparar Assets

**Iconos requeridos:**
- 512x512 px (high-res icon)
- 1024x500 px (feature graphic)

**Screenshots requeridos:**
- Teléfono: 2-8 screenshots (mínimo 320x320, máximo 3840x3840)
- Tablet: (opcional) 2-8 screenshots

**Video promocional:** (opcional)
- YouTube link

### 3. Información de la App

**Título**: IDEON - Clean & Clash (máx 50 caracteres)

**Descripción corta** (máx 80 caracteres):
```
Limpia tu galería con swipes y compite con amigos
```

**Descripción completa** (máx 4000 caracteres):
```
IDEON combina limpieza inteligente de fotos con juegos sociales.

🧹 PHOTOSWEEP
Desliza fotos para limpiar tu galería de forma rápida e intuitiva.

🎮 PHOTOCLASH
Compite con amigos enviando fotos según desafíos divertidos.

CARACTERÍSTICAS:
✓ Interfaz moderna Material Design 3
✓ Temas claro y oscuro
✓ Múltiples idiomas
✓ Animaciones fluidas
✓ Sin anuncios

[Continúa con más detalles...]
```

### 4. Categoría
- Herramientas (PhotoSweep principal)
- o Casual (PhotoClash principal)

### 5. Contenido
- Clasificación: PEGI 12+ (por modo NSFW opcional)
- Privacidad: Sin anuncios, sin tracking

### 6. Subir App Bundle

```powershell
# Compilar bundle
flutter build appbundle --release

# Ubicación del bundle
build/app/outputs/bundle/release/app-release.aab
```

Sube este archivo a Google Play Console.

### 7. Versiones

En `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

- `1.0.0`: Version Name (visible para usuarios)
- `+1`: Version Code (interno, debe incrementar)

Para actualizar:
```yaml
version: 1.0.1+2
```

---

## Troubleshooting

### Error: "Flutter SDK not found"
```powershell
# Verifica la instalación
flutter doctor

# Actualiza Flutter
flutter upgrade
```

### Error: "Gradle build failed"
```powershell
# Limpia el build
cd android
.\gradlew clean
cd ..

# Rebuild
flutter build apk
```

### Error: "Keystore not found"
- Verifica la ruta en `android/key.properties`
- Asegúrate de que el keystore existe

### Error: "minSdkVersion"
En `android/app/build.gradle`:
```gradle
defaultConfig {
    minSdkVersion 21  // Android 5.0+
    targetSdkVersion 33
}
```

### APK muy grande
```powershell
# Usa split-per-abi
flutter build apk --split-per-abi

# Con obfuscación
flutter build apk --obfuscate --split-debug-info=build/debug-info
```

### Hot reload no funciona
```powershell
# Reinicia con hot reload explícito
flutter run --hot
```

---

## Comandos Útiles

### Limpiar proyecto
```powershell
flutter clean
flutter pub get
```

### Actualizar dependencias
```powershell
flutter pub upgrade
```

### Ver dependencias obsoletas
```powershell
flutter pub outdated
```

### Analizar código
```powershell
flutter analyze
```

### Formatear código
```powershell
flutter format lib/
```

### Generar iconos (si cambias el icono)
```powershell
flutter pub run flutter_launcher_icons:main
```

---

## Build Scripts Útiles

### Script para build completo (PowerShell)

Crea `build_release.ps1`:
```powershell
# Limpiar
Write-Host "Limpiando proyecto..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Analizar
Write-Host "Analizando código..." -ForegroundColor Yellow
flutter analyze

# Tests
Write-Host "Ejecutando tests..." -ForegroundColor Yellow
flutter test

# Build
Write-Host "Compilando APK..." -ForegroundColor Green
flutter build apk --release --obfuscate --split-debug-info=build/debug-info --split-per-abi

Write-Host "¡Build completado!" -ForegroundColor Green
Write-Host "APKs en: build/app/outputs/flutter-apk/" -ForegroundColor Cyan
```

Ejecutar:
```powershell
.\build_release.ps1
```

---

## Checklist Pre-Publicación

- [ ] Tests pasan
- [ ] No hay errores de análisis
- [ ] Screenshots actualizados
- [ ] Descripción revisada
- [ ] Versión incrementada
- [ ] Keystore configurado
- [ ] Probado en múltiples dispositivos
- [ ] Permisos mínimos necesarios
- [ ] Políticas de privacidad actualizadas
- [ ] Iconos de calidad
- [ ] APK/Bundle firmado correctamente

---

## Recursos

- [Flutter Build Docs](https://docs.flutter.dev/deployment/android)
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [Signing Apps](https://developer.android.com/studio/publish/app-signing)

---

¡Buena suerte con tu publicación! 🚀
