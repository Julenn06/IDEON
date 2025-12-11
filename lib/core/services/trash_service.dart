import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager/photo_manager.dart';

class TrashService {
  static const _key = 'trash_photos';

  // Guardar IDs de fotos marcadas
  static Future<void> saveMarkedPhotos(List<String> photoIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(photoIds));
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

  // Añadir foto a la papelera
  static Future<void> addPhoto(String photoId) async {
    final current = await getMarkedPhotos();
    if (!current.contains(photoId)) {
      current.add(photoId);
      await saveMarkedPhotos(current);
    }
  }

  // Eliminar foto de la papelera (restaurar)
  static Future<void> removePhoto(String photoId) async {
    final current = await getMarkedPhotos();
    current.remove(photoId);
    await saveMarkedPhotos(current);
  }

  // Limpiar papelera completamente
  static Future<void> clearTrash() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // Obtener cantidad de fotos en papelera
  static Future<int> getTrashCount() async {
    final photos = await getMarkedPhotos();
    return photos.length;
  }
}
