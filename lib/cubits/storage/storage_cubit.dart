// ignore_for_file: avoid_print, unused_local_variable

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'storage_state.dart';

class StorageCubit extends Cubit<StorageState> {
  StorageCubit() : super(const StorageState());

  Future<void> loadStorageInfo() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      // Get app's directory
      final appDir = await getApplicationDocumentsDirectory();
      final appDirSize = await _getDirectorySize(appDir);

      // Get external storage directory
      final List<Directory>? externalDirs =
          await getExternalStorageDirectories();
      double totalSpace = 0;
      double freeSpace = 0;

      // Scan and categorize files
      Map<String, List<String>> filesByType = {
        'PDF': [],
        'Document': [],
        'Image': [],
        'Video': [],
        'Audio': [],
        'Other': [],
      };

      if (externalDirs != null && externalDirs.isNotEmpty) {
        final storageDir = externalDirs[0];

        // Get storage information
        if (Platform.isAndroid) {
          final statFs = await File(storageDir.path).stat();
          // Convert to GB
          totalSpace = statFs.size / (1024 * 1024 * 1024);
          freeSpace = (statFs.size - statFs.modified.millisecondsSinceEpoch) /
              (1024 * 1024 * 1024);

          // Scan files
          await for (var entity in storageDir.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final extension = entity.path.split('.').last.toLowerCase();
              switch (extension) {
                case 'pdf':
                  filesByType['PDF']!.add(entity.path);
                  break;
                case 'doc':
                case 'docx':
                case 'txt':
                case 'rtf':
                  filesByType['Document']!.add(entity.path);
                  break;
                case 'jpg':
                case 'jpeg':
                case 'png':
                case 'gif':
                  filesByType['Image']!.add(entity.path);
                  break;
                case 'mp4':
                case 'avi':
                case 'mov':
                  filesByType['Video']!.add(entity.path);
                  break;
                case 'mp3':
                case 'wav':
                case 'm4a':
                  filesByType['Audio']!.add(entity.path);
                  break;
                default:
                  filesByType['Other']!.add(entity.path);
              }
            }
          }
        } else {
          // For other platforms, use a default value
          totalSpace = 32.0; // 32 GB
          freeSpace = 16.0; // 16 GB
        }
      } else {
        // Fallback values if we can't get storage info
        totalSpace = 32.0;
        freeSpace = 16.0;
      }

      double usedSpace = totalSpace - freeSpace;
      double appSize = appDirSize / (1024 * 1024 * 1024); // Convert to GB

      emit(state.copyWith(
        totalSpace: totalSpace,
        freeSpace: freeSpace,
        usedSpace: usedSpace,
        appSize: appSize,
        isLoading: false,
        files: filesByType,
      ));
    } catch (e) {
      print('Error loading storage info: $e');
      emit(state.copyWith(
        error: 'Failed to load storage information: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  Future<int> _getDirectorySize(Directory directory) async {
    int totalSize = 0;
    try {
      if (await directory.exists()) {
        await for (var entity
            in directory.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
      return totalSize;
    } catch (e) {
      print('Error calculating directory size: $e');
      return 0;
    }
  }
}
