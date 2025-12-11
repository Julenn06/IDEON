import 'package:photo_manager/photo_manager.dart';

class PhotoItem {
  final String id;
  final AssetEntity asset;
  final DateTime createdDate;
  final int size;

  PhotoItem({
    required this.id,
    required this.asset,
    required this.createdDate,
    required this.size,
  });

  static Future<PhotoItem> fromAsset(AssetEntity asset) async {
    final file = await asset.file;
    final size = await file?.length() ?? 0;
    
    return PhotoItem(
      id: asset.id,
      asset: asset,
      createdDate: asset.createDateTime,
      size: size,
    );
  }
}
