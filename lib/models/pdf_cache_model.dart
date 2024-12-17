import 'package:hive_flutter/hive_flutter.dart';

part 'pdf_cache_model.g.dart';

@HiveType(typeId: 1)
class PdfCacheModel {
  @HiveField(0)
  final String originalPath;

  @HiveField(1)
  final String cachePath;

  @HiveField(2)
  final DateTime lastAccessed;

  @HiveField(3)
  final DateTime lastModified;

  @HiveField(4)
  final int fileSize;

  PdfCacheModel({
    required this.originalPath,
    required this.cachePath,
    required this.lastAccessed,
    required this.lastModified,
    required this.fileSize,
  });
}
