import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/datasources/pdf_cache_service.dart';
import 'pdf_state.dart';

class PdfCubit extends Cubit<PdfState> {
  final Set<String> _scannedPaths = {};
  final Set<String> _restrictedPaths = {
    '/storage/emulated/0/Android/obb',
    '/storage/emulated/0/Android/data',
  };

  final List<String> _priorityDirs = [
    'Download',
    'Downloads',
    'Documents',
    'Document',
    'WhatsApp',
    'Telegram',
    'DCIM',
    'Pictures',
    'Camera',
    'PDFs',
    'Books',
    'ebooks',
    'Documents/Books',
    'Music/Books',
    'bluetooth',
    'Audiobooks',
  ];

  int _totalFiles = 0;
  int _totalDirs = 0;
  int _foundPdfs = 0;
  int _skippedDirs = 0;
  final Stopwatch _stopwatch = Stopwatch();
  final PdfCacheService _cacheService = PdfCacheService();

  PdfCubit() : super(const PdfState()) {
    _initCache();
  }

  Future<void> _initCache() async {
    await _cacheService.init();
  }

  Future<void> loadPdfFiles() async {
    try {
      _stopwatch.start();
      _resetStats();
      emit(state.copyWith(
        isLoading: true,
        error: null,
        scanProgress: 0,
        currentDirectory: 'Requesting permissions...',
      ));

      if (!await _requestPermissions()) {
        throw Exception('Storage permissions are required to scan PDF files');
      }

      // First, try to get files from cache
      final cachedEntries = await _cacheService.getCacheEntries();
      if (cachedEntries.isNotEmpty) {
        emit(state.copyWith(
          pdfFiles: cachedEntries.map((e) => e.originalPath).toList(),
          isLoading: false,
          scanProgress: 100,
          currentDirectory: 'Loaded ${cachedEntries.length} PDFs from cache',
        ));
        return;
      }

      // If no cached files, perform full scan
      final Set<String> pdfFiles = {};

      final List<String> storagePaths = await _getAllStoragePaths();
      print('Found ${storagePaths.length} storage locations');

      // First scan priority directories
      for (final storagePath in storagePaths) {
        for (final priorityDir in _priorityDirs) {
          final dir = Directory('$storagePath/$priorityDir');
          if (await _canAccessDirectory(dir)) {
            await _deepScanDirectory(dir, pdfFiles);
          }
        }
      }

      // Then scan remaining directories
      for (final storagePath in storagePaths) {
        final rootDir = Directory(storagePath);
        if (await _canAccessDirectory(rootDir)) {
          await _deepScanDirectory(rootDir, pdfFiles);
        }
      }

      // Sort files by name
      final sortedPdfFiles = pdfFiles.toList()
        ..sort((a, b) => path
            .basename(a)
            .toLowerCase()
            .compareTo(path.basename(b).toLowerCase()));

      // Cache all found PDF files
      await _cachePdfFiles(sortedPdfFiles);

      _stopwatch.stop();
      _printScanSummary(sortedPdfFiles.length);

      if (sortedPdfFiles.isEmpty) {
        emit(state.copyWith(
          error: 'No PDF files found on device',
          isLoading: false,
          scanProgress: 100,
          currentDirectory: '',
          pdfFiles: [],
        ));
      } else {
        emit(state.copyWith(
          pdfFiles: sortedPdfFiles,
          isLoading: false,
          scanProgress: 100,
          currentDirectory: '',
          error: null,
        ));
      }
    } catch (e) {
      print('Error during PDF scan: $e');
      emit(state.copyWith(
        error: 'Error scanning files: ${e.toString()}',
        isLoading: false,
        scanProgress: 0,
        currentDirectory: '',
        pdfFiles: [],
      ));
    }
  }

  Future<void> _cachePdfFiles(List<String> pdfFiles) async {
    try {
      int total = pdfFiles.length;
      int current = 0;

      for (var filePath in pdfFiles) {
        current++;
        emit(state.copyWith(
          scanProgress: (current / total * 100).round().toDouble(),
          currentDirectory: 'Caching: ${path.basename(filePath)}',
        ));

        await _cacheService.cacheFile(filePath);
      }
    } catch (e) {
      print('Error caching PDF files: $e');
    }
  }

  Future<String> getPdfPath(String originalPath) async {
    try {
      final cachedPath = await _cacheService.getCachedFilePath(originalPath);
      if (cachedPath != null) {
        return cachedPath;
      }
      // If not cached, cache it now
      return await _cacheService.cacheFile(originalPath);
    } catch (e) {
      print('Error getting PDF path: $e');
      return originalPath;
    }
  }

  Future<void> clearCache() async {
    try {
      await _cacheService.clearCache();
      emit(state.copyWith(currentDirectory: 'Cache cleared'));
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  Future<String> getCacheSize() async {
    final bytes = await _cacheService.getCacheSize();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ... rest of the existing methods (unchanged) ...
  Future<void> refreshPdfFiles() async {
    await loadPdfFiles();
  }

  Future<bool> _canAccessDirectory(Directory dir) async {
    try {
      if (_scannedPaths.contains(dir.path)) return false;
      if (_restrictedPaths.any((path) => dir.path.startsWith(path))) {
        _skippedDirs++;
        return false;
      }
      return await dir.exists();
    } catch (e) {
      return false;
    }
  }

  Future<void> _deepScanDirectory(
      Directory directory, Set<String> pdfFiles) async {
    if (!await _canAccessDirectory(directory)) return;

    try {
      _scannedPaths.add(directory.path);
      _totalDirs++;

      emit(state.copyWith(
        currentDirectory: 'Scanning: ${path.basename(directory.path)}',
        scanProgress: (_totalDirs % 100) * 1.0,
      ));

      final List<FileSystemEntity> entities = await directory.list().toList();

      for (final entity in entities) {
        if (entity is File) {
          _totalFiles++;
          if (_isPdfFile(entity.path)) {
            try {
              if (await entity.length() > 0) {
                pdfFiles.add(entity.path);
                _foundPdfs++;
                print('Found PDF: ${path.basename(entity.path)}');
              }
            } catch (e) {
              print('Error accessing file ${entity.path}: $e');
            }
          }
        }
      }

      for (final entity in entities) {
        if (entity is Directory) {
          final dirname = path.basename(entity.path);
          if (!dirname.startsWith('.') &&
              !_restrictedPaths.contains(entity.path)) {
            await _deepScanDirectory(entity, pdfFiles);
          }
        }
      }
    } catch (e) {
      print('Error scanning directory ${directory.path}: $e');
      _skippedDirs++;
    }
  }

  Future<List<String>> _getAllStoragePaths() async {
    final Set<String> paths = {};
    paths.add('/storage/emulated/0');

    try {
      final List<Directory>? externalDirs =
          await getExternalStorageDirectories();
      if (externalDirs != null) {
        for (var dir in externalDirs) {
          final String rootPath = dir.path.split('Android')[0];
          if (!paths.contains(rootPath)) {
            paths.add(rootPath);
            print('Found storage path: $rootPath');
          }
        }
      }

      final potentialPaths = [
        '/storage/sdcard0',
        '/storage/sdcard1',
        '/storage/extSdCard',
        '/storage/emulated/legacy',
      ];

      for (final potentialPath in potentialPaths) {
        final dir = Directory(potentialPath);
        if (await dir.exists() && !paths.contains(potentialPath)) {
          paths.add(potentialPath);
          print('Found additional storage: $potentialPath');
        }
      }
    } catch (e) {
      print('Error accessing storage paths: $e');
    }

    return paths.toList();
  }

  bool _isPdfFile(String filePath) {
    return path.extension(filePath).toLowerCase() == '.pdf';
  }

  void _printScanSummary(int totalPdfs) {
    print('\n=== PDF Scan Summary ===');
    print('Scan Duration: ${_stopwatch.elapsed.inSeconds} seconds');
    print('Total Directories Scanned: $_totalDirs');
    print('Total Files Checked: $_totalFiles');
    print('PDFs Found: $totalPdfs');
    print('Skipped Directories: $_skippedDirs');
    print('=====================\n');
  }

  Future<bool> _requestPermissions() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt >= 30) {
      if (!await Permission.manageExternalStorage.isGranted) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          return await Permission.storage.request().isGranted;
        }
      }
      return true;
    } else {
      return await Permission.storage.request().isGranted;
    }
  }

  void _resetStats() {
    _scannedPaths.clear();
    _totalFiles = 0;
    _totalDirs = 0;
    _foundPdfs = 0;
    _skippedDirs = 0;
    _stopwatch.reset();
  }

  Future<List<String>> checkNewPdfFiles() async {
    try {
      final Set<String> newPdfFiles = {};
      final currentPdfFiles = Set<String>.from(state.pdfFiles);
      _resetStats();

      final List<String> storagePaths = await _getAllStoragePaths();

      // First scan priority directories
      for (final storagePath in storagePaths) {
        for (final priorityDir in _priorityDirs) {
          final dir = Directory('$storagePath/$priorityDir');
          if (await _canAccessDirectory(dir)) {
            await _deepScanDirectory(dir, newPdfFiles);
          }
        }
      }

      // Then scan remaining directories
      for (final storagePath in storagePaths) {
        final rootDir = Directory(storagePath);
        if (await _canAccessDirectory(rootDir)) {
          await _deepScanDirectory(rootDir, newPdfFiles);
        }
      }

      // Filter out existing files to get only new ones
      final List<String> actualNewFiles = newPdfFiles
          .where((file) => !currentPdfFiles.contains(file))
          .toList();

      return actualNewFiles;
    } catch (e) {
      print('Error checking for new PDF files: $e');
      return [];
    }
  }
}