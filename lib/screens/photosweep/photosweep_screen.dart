import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/trash_service.dart';
import '../../core/services/stats_service.dart';
import '../../core/constants/cleaning_tips.dart';
import '../../core/providers/settings_provider.dart';
import 'trash_review_screen.dart';

class PhotoSweepScreen extends ConsumerStatefulWidget {
  const PhotoSweepScreen({super.key});

  @override
  ConsumerState<PhotoSweepScreen> createState() => _PhotoSweepScreenState();
}

class _PhotoSweepScreenState extends ConsumerState<PhotoSweepScreen> with TickerProviderStateMixin {
  List<AssetEntity> _photos = [];
  int _currentIndex = 0;
  final List<AssetEntity> _photosToDelete = [];
  bool _isLoading = true;
  int _trashCount = 0;
  int _totalBytesDeleted = 0; // Nuevo: contador de bytes liberados

  double _dragX = 0;
  double _dragY = 0;

  late AnimationController _swipeController;
  late AnimationController _cardController;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _loadPhotos();
    _loadTrashCount();
  }

  Future<void> _loadTrashCount() async {
    final count = await TrashService.getTrashCount();
    if (mounted) {
      setState(() => _trashCount = count);
    }
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final recentAlbum = albums.first;
    final photos = await recentAlbum.getAssetListRange(
      start: 0,
      end: await recentAlbum.assetCountAsync,
    );

    photos.shuffle();

    setState(() {
      _photos = photos;
      _isLoading = false;
    });
  }

  Future<void> _deletePhoto(AssetEntity photo) async {
    await HapticService.medium();
    
    // Obtener tamaño de la foto
    final file = await photo.file;
    final fileSize = file?.lengthSync() ?? 0;
    
    // Guardar en papelera persistente con tamaño
    await TrashService.addPhoto(photo.id, bytes: fileSize);
    
    setState(() {
      _photosToDelete.add(photo);
      _totalBytesDeleted += fileSize;
    });

    await _loadTrashCount();
    _nextPhoto();
  }

  Future<void> _openTrashReview() async {
    // Cargar fotos de la papelera persistente
    final markedPhotos = await TrashService.loadMarkedPhotosAsEntities();
    
    if (!mounted) return;

    if (markedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La papelera está vacía'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navegar a la pantalla de revisión
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TrashReviewScreen(
          markedPhotos: markedPhotos,
        ),
      ),
    );

    // Actualizar contador si se realizaron cambios
    if (result == true) {
      await _loadTrashCount();
      setState(() {
        _photosToDelete.clear();
      });
    }
  }

  void _nextPhoto() {
    if (_currentIndex < _photos.length - 1) {
      setState(() => _currentIndex++);
      _cardController.forward(from: 0);
      
      // Mostrar consejo cada 10 fotos
      if ((_currentIndex + 1) % 10 == 0) {
        _showTip();
      }
    } else {
      _showCompletionDialog();
    }
  }

  void _showTip() {
    final settings = ref.read(settingsProvider);
    final tip = CleaningTips.getRandomTip(settings.language);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tip['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(tip['message']!),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _showCompletionDialog() async {
    final totalInTrash = await TrashService.getTrashCount();
    
    // Guardar estadísticas de la sesión
    if (_trashCount > 0) {
      await StatsService.recordSession(_trashCount, _totalBytesDeleted);
    }
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Limpieza completada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('Has revisado todas las fotos'),
            if (totalInTrash > 0) ...[
              const SizedBox(height: 8),
              Text('$totalInTrash fotos en la papelera'),
              Text(
                'Espacio: ${_formatBytes(_totalBytesDeleted)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (totalInTrash > 0)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _openTrashReview();
              },
              child: const Text('Revisar papelera'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _handleSwipe(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
      _dragY += details.delta.dy;
    });
  }

  void _handleSwipeEnd(DragEndDetails details) async {
    const threshold = 100;
    
    if (_dragX.abs() > threshold) {
      await HapticService.medium();
      
      if (_dragX < 0) {
        // Swipe left - Delete
        await _swipeController.forward();
        if (_currentIndex < _photos.length) {
          await _deletePhoto(_photos[_currentIndex]);
        }
        _nextPhoto();
      } else {
        // Swipe right - Keep
        await _swipeController.forward();
        await HapticService.light();
        _nextPhoto();
      }
      
      _swipeController.reset();
    }
    
    setState(() {
      _dragX = 0;
      _dragY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('PhotoSweep')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_photos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('PhotoSweep')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_rounded, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              const Text('No se encontraron fotos'),
            ],
          ),
        ),
      );
    }

    final currentPhoto = _currentIndex < _photos.length ? _photos[_currentIndex] : null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        Text(
                          '${_currentIndex + 1} / ${_photos.length}',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          'Papelera: $_trashCount',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _trashCount == 0 
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                                : Colors.red,
                            fontWeight: _trashCount == 0 ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        if (_totalBytesDeleted > 0)
                          Text(
                            'Espacio: ${_formatBytes(_totalBytesDeleted)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_sweep_rounded,
                        color: _trashCount == 0 ? null : Colors.red,
                      ),
                      onPressed: _trashCount == 0 ? null : () async {
                        await HapticService.medium();
                        await _openTrashReview();
                      },
                    ),
                  ],
                ),
              ),

              // Photo Card
              Expanded(
                child: Center(
                  child: currentPhoto == null
                      ? const CircularProgressIndicator()
                      : GestureDetector(
                          onPanUpdate: _handleSwipe,
                          onPanEnd: _handleSwipeEnd,
                          child: Transform.translate(
                            offset: Offset(_dragX, _dragY),
                            child: Transform.rotate(
                              angle: _dragX * 0.001,
                              child: AnimatedBuilder(
                                animation: _cardController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 - (_cardController.value * 0.1),
                                    child: child,
                                  );
                                },
                                child: Stack(
                                  children: [
                                    // Photo
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.9,
                                      height: MediaQuery.of(context).size.height * 0.6,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: AssetEntityImage(
                                          currentPhoto,
                                          fit: BoxFit.contain,
                                          isOriginal: false,
                                        ),
                                      ),
                                    ),

                                    // Delete Overlay
                                    if (_dragX < -50)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.7),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Icon(
                                            Icons.delete_rounded,
                                            size: 80,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                    // Keep Overlay
                                    if (_dragX > 50)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.7),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            size: 80,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Delete Button
                    FloatingActionButton.large(
                      heroTag: 'delete',
                      onPressed: () async {
                        setState(() {
                          _dragX = -200;
                        });
                        await Future.delayed(const Duration(milliseconds: 100));
                        _handleSwipeEnd(DragEndDetails());
                      },
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.delete_rounded, size: 32),
                    ),

                    // Keep Button
                    FloatingActionButton.large(
                      heroTag: 'keep',
                      onPressed: () async {
                        setState(() {
                          _dragX = 200;
                        });
                        await Future.delayed(const Duration(milliseconds: 100));
                        _handleSwipeEnd(DragEndDetails());
                      },
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.check_rounded, size: 32),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
