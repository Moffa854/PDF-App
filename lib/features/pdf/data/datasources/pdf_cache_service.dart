import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/pdf_cache_model.dart';

class PdfCacheService {
  static const String _cacheBoxName = 'pdf_cache_box';
  static final PdfCacheService _instance = PdfCacheService._internal();
  Box<PdfCacheModel>? _cacheBox;
  bool _isInitialized = false;

  factory PdfCacheService() {
    return _instance;
  }

  PdfCacheService._internal();

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Ensure Hive is initialized
      await Hive.initFlutter();
      
      // Register adapter if needed
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PdfCacheModelAdapter());
      }
      
      // Open the box
      _cacheBox = await Hive.openBox<PdfCacheModel>(_cacheBoxName);
      _isInitialized = true;
      print('PDF Cache Service initialized successfully');
    } catch (e) {
      print('Error initializing PDF Cache Service: $e');
      rethrow;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  Future<String> cacheFile(String filePath) async {
    await _ensureInitialized();
    
    try {
      final cacheDir = await getCacheDirectory();
      final cacheKey = _generateCacheKey(filePath);
      final extension = path.extension(filePath);
      final cachedFilePath = path.join(cacheDir, '$cacheKey$extension');
      
      // Copy the file to cache
      final originalFile = File(filePath);
      if (await originalFile.exists()) {
        final cachedFile = await originalFile.copy(cachedFilePath);
        final fileStats = await cachedFile.stat();
        
        // Store cache metadata in Hive
        await _cacheBox?.put(cacheKey, PdfCacheModel(
          originalPath: filePath,
          cachePath: cachedFilePath,
          lastAccessed: DateTime.now(),
          lastModified: fileStats.modified,
          fileSize: fileStats.size,
        ));
        
        print('Successfully cached file: ${path.basename(filePath)}');
        return cachedFilePath;
      }
      throw Exception('Original file does not exist');
    } catch (e) {
      print('Error caching file: $e');
      return filePath; // Return original path if caching fails
    }
  }

  Future<void> clearCache() async {
    await _ensureInitialized();
    
    try {
      // Delete all cached files
      final cacheDir = Directory(await getCacheDirectory());
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }
      
      // Clear Hive box
      await _cacheBox?.clear();
      print('Cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  Future<String?> getCachedFilePath(String originalFilePath) async {
    await _ensureInitialized();
    
    try {
      final cacheKey = _generateCacheKey(originalFilePath);
      final cacheData = _cacheBox?.get(cacheKey);
      
      if (cacheData != null) {
        final cachedFile = File(cacheData.cachePath);
        if (await cachedFile.exists()) {
          final originalFile = File(originalFilePath);
          if (await originalFile.exists()) {
            final originalStat = await originalFile.stat();
            
            // Check if original file has been modified
            if (originalStat.modified.isAfter(cacheData.lastModified)) {
              print('Original file modified, updating cache');
              return await cacheFile(originalFilePath);
            }
          }
          
          // Update last accessed time
          await _cacheBox?.put(cacheKey, PdfCacheModel(
            originalPath: originalFilePath,
            cachePath: cacheData.cachePath,
            lastAccessed: DateTime.now(),
            lastModified: cacheData.lastModified,
            fileSize: cacheData.fileSize,
          ));
          
          print('Using cached file: ${path.basename(originalFilePath)}');
          return cacheData.cachePath;
        } else {
          // Cached file doesn't exist anymore, remove from Hive
          await _cacheBox?.delete(cacheKey);
          print('Cached file not found, removing from index');
        }
      }
      return null;
    } catch (e) {
      print('Error getting cached file: $e');
      return null;
    }
  }

  Future<String> getCacheDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory(path.join(appDir.path, 'pdf_cache'));
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      return cacheDir.path;
    } catch (e) {
      print('Error getting cache directory: $e');
      rethrow;
    }
  }

  Future<List<PdfCacheModel>> getCacheEntries() async {
    await _ensureInitialized();
    try {
      final entries = _cacheBox?.values.toList() ?? [];
      // Filter out entries where the cached file no longer exists
      final validEntries = <PdfCacheModel>[];
      
      for (var entry in entries) {
        final cachedFile = File(entry.cachePath);
        final originalFile = File(entry.originalPath);
        
        if (await cachedFile.exists() && await originalFile.exists()) {
          validEntries.add(entry);
        } else {
          // Remove invalid entries from cache
          final cacheKey = _generateCacheKey(entry.originalPath);
          await _cacheBox?.delete(cacheKey);
        }
      }
      
      return validEntries;
    } catch (e) {
      print('Error getting cache entries: $e');
      return [];
    }
  }

  Future<int> getCacheSize() async {
    await _ensureInitialized();
    
    try {
      int totalSize = 0;
      final entries = _cacheBox?.values ?? [];
      for (var cacheData in entries) {
        totalSize += cacheData.fileSize;
      }
      return totalSize;
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0;
    }
  }

  String _generateCacheKey(String filePath) {
    final bytes = utf8.encode(filePath);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}
