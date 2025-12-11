import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/trash_service.dart';
import '../../core/services/haptic_service.dart';

class TrashReviewScreen extends StatefulWidget {
  final List<AssetEntity> markedPhotos;

  const TrashReviewScreen({
    super.key,
    required this.markedPhotos,
  });

  @override
  State<TrashReviewScreen> createState() => _TrashReviewScreenState();
}

class _TrashReviewScreenState extends State<TrashReviewScreen> {
  late List<AssetEntity> _photos;
  final Set<String> _selectedToRestore = {};
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.markedPhotos);
  }

  void _toggleSelection(AssetEntity photo) {
    setState(() {
      if (_selectedToRestore.contains(photo.id)) {
        _selectedToRestore.remove(photo.id);
      } else {
        _selectedToRestore.add(photo.id);
      }
    });
    HapticService.light();
  }

  Future<void> _restoreSelected() async {
    if (_selectedToRestore.isEmpty) return;

    HapticService.medium();
    
    // Eliminar de la papelera
    for (final id in _selectedToRestore) {
      await TrashService.removePhoto(id);
    }

    // Eliminar de la lista visual
    setState(() {
      _photos.removeWhere((photo) => _selectedToRestore.contains(photo.id));
      _selectedToRestore.clear();
    });

    if (_photos.isEmpty) {
      if (mounted) Navigator.of(context).pop(true);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fotos restauradas'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar fotos'),
        content: Text(
          '¿Eliminar permanentemente ${_photos.length} ${_photos.length == 1 ? 'foto' : 'fotos'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      // Obtener IDs de las fotos a eliminar
      final idsToDelete = _photos.map((p) => p.id).toList();

      // Eliminar físicamente
      await PhotoManager.editor.deleteWithIds(idsToDelete);

      // Limpiar papelera
      await TrashService.clearTrash();

      HapticService.success();

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_photos.length} fotos eliminadas'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      HapticService.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Papelera (${_photos.length})'),
        actions: [
          if (_selectedToRestore.isNotEmpty)
            TextButton.icon(
              onPressed: _restoreSelected,
              icon: const Icon(Icons.restore),
              label: Text('Restaurar (${_selectedToRestore.length})'),
            ),
        ],
      ),
      body: _photos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 80,
                    color: theme.colorScheme.outline,
                  ).animate().scale(delay: 100.ms),
                  const SizedBox(height: 16),
                  Text(
                    'La papelera está vacía',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                final isSelected = _selectedToRestore.contains(photo.id);

                return GestureDetector(
                  onTap: () => _toggleSelection(photo),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AssetEntityImage(
                        photo,
                        isOriginal: false,
                        thumbnailSize: const ThumbnailSize.square(300),
                        fit: BoxFit.cover,
                      ),
                      // Overlay de selección
                      if (isSelected)
                        Container(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 32,
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1, 1),
                              duration: 150.ms,
                            )
                            .fadeIn(duration: 150.ms),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: _photos.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _isDeleting ? null : _deleteAll,
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.delete_forever),
                  label: Text(
                    _isDeleting
                        ? 'Eliminando...'
                        : 'Eliminar todas (${_photos.length})',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
    );
  }
}
