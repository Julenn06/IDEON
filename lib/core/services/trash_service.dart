import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager/photo_manager.dart';

class TrashService {
  static const _key = 'trash_photos';
  static const _bytesKey = 'trash_bytes';

  // Guardar IDs de fotos marcadas
  static Future<void> saveMarkedPhotos(List<String> photoIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(photoIds));
  }

  // Guardar bytes totales
  static Future<void> saveTotalBytes(int bytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bytesKey, bytes);
  }

  // Obtener bytes totales
  static Future<int> getTotalBytes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bytesKey) ?? 0;
  }

  // Obtener IDs de fotos marcadas
  static Future<List<String>> getMarkedPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  // Cargar AssetEntity desde IDs guardados
  static Future<List<AssetEntity>> loadMarkedPhotosAsEntities() async {
    final ids = await getMarkedPhotos();
    if (ids.isEmpty) return [];

    final List<AssetEntity> entities = [];
    for (final id in ids) {
      final entity = await AssetEntity.fromId(id);
      if (entity != null) {
        entities.add(entity);
      }
    }
    return entities;
  }

  // Añadir foto a la papelera con tamaño
  static Future<void> addPhoto(String photoId, {int? bytes}) async {
    final current = await getMarkedPhotos();
    if (!current.contains(photoId)) {
      current.add(photoId);
      await saveMarkedPhotos(current);
      
      if (bytes != null) {
        final currentBytes = await getTotalBytes();
        await saveTotalBytes(currentBytes + bytes);
      }
    }
  }

  // Eliminar foto de la papelera (restaurar)
  static Future<void> removePhoto(String photoId, {int? bytes}) async {
    final current = await getMarkedPhotos();
    current.remove(photoId);
    await saveMarkedPhotos(current);
    
    if (bytes != null) {
      final currentBytes = await getTotalBytes();
      await saveTotalBytes((currentBytes - bytes).clamp(0, double.maxFinite.toInt()));
    }
  }

  // Limpiar papelera completamente
  static Future<void> clearTrash() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_bytesKey);
  }

  // Obtener cantidad de fotos en papelera
  static Future<int> getTrashCount() async {
    final photos = await getMarkedPhotos();
    return photos.length;
  }
}

