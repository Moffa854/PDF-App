import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/file_item.dart';

class FileManagementViewModel extends ChangeNotifier {
  List<FileItem> _files = [];
  double _storageUsed = 0;
  double _cloudStorageUsed = 0;
  bool _isLoading = false;

  List<FileItem> get files => _files;
  double get storageUsed => _storageUsed;
  double get cloudStorageUsed => _cloudStorageUsed;
  bool get isLoading => _isLoading;

  Future<void> loadFiles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory(directory.path);
      
      List<FileItem> tempFiles = [];
      
      await for (var entity in dir.list(recursive: true)) {
        if (entity is File) {
          final name = entity.path.split('/').last;
          final type = name.split('.').last.toUpperCase();
          String icon = 'file';
          
          // Determine icon based on file type
          switch (type) {
            case 'PDF':
              icon = 'pdf';
              break;
            case 'DOC':
            case 'DOCX':
              icon = 'doc';
              break;
            case 'XLS':
            case 'XLSX':
              icon = 'xls';
              break;
            case 'PPT':
            case 'PPTX':
              icon = 'ppt';
              break;
            case 'JPG':
            case 'PNG':
              icon = 'img';
              break;
          }

          tempFiles.add(FileItem(
            name: name,
            type: type,
            icon: icon,
            size: await entity.length() / (1024 * 1024), // Convert to MB
          ));
        }
      }

      _files = tempFiles;
      _calculateStorageUsed();
    } catch (e) {
      debugPrint('Error loading files: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _calculateStorageUsed() {
    _storageUsed = _files.fold(0, (sum, file) => sum + file.size);
    // Mock cloud storage for demo
    _cloudStorageUsed = _storageUsed * 0.3;
    notifyListeners();
  }

  Future<void> deleteFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      
      if (await file.exists()) {
        await file.delete();
        await loadFiles(); // Reload the file list
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  Future<void> createFolder(String folderName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final newFolder = Directory('${directory.path}/$folderName');
      
      if (!await newFolder.exists()) {
        await newFolder.create();
        await loadFiles(); // Reload the file list
      }
    } catch (e) {
      debugPrint('Error creating folder: $e');
    }
  }
}
