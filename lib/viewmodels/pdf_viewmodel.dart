// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../services/pdf_cache_service.dart';
import '../models/pdf_cache_model.dart';

class PdfViewModel extends ChangeNotifier {
  final PdfCacheService _cacheService = PdfCacheService();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _cacheService.init();
      _isInitialized = true;
    }
  }
  
  String getFileName(String filePath) {
    return path.basename(filePath);
  }

  String getFileSize(String filePath) {
    final file = File(filePath);
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  DateTime getLastModified(String filePath) {
    final file = File(filePath);
    return file.lastModifiedSync();
  }

  Future<String> getPdfPath(String originalPath) async {
    await initialize();
    try {
      // Try to get cached version first
      final cachedPath = await _cacheService.getCachedFilePath(originalPath);
      if (cachedPath != null) {
        return cachedPath;
      }
      
      // If not cached, cache it and return the cached path
      return await _cacheService.cacheFile(originalPath);
    } catch (e) {
      print('Error accessing PDF file: $e');
      return originalPath; // Fallback to original path if caching fails
    }
  }

  Future<void> clearCache() async {
    await initialize();
    await _cacheService.clearCache();
    notifyListeners();
  }

  Future<String> getCacheSize() async {
    await initialize();
    final bytes = await _cacheService.getCacheSize();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<List<PdfCacheModel>> getCacheEntries() async {
    await initialize();
    return _cacheService.getCacheEntries();
  }
}
