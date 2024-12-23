import 'package:equatable/equatable.dart';

class StorageState extends Equatable {
  final double totalSpace;
  final double freeSpace;
  final double usedSpace;
  final double appSize;
  final bool isLoading;
  final String? error;
  final Map<String, List<String>> files;

  const StorageState({
    this.totalSpace = 0,
    this.freeSpace = 0,
    this.usedSpace = 0,
    this.appSize = 0,
    this.isLoading = false,
    this.error,
    this.files = const {},
  });

  StorageState copyWith({
    double? totalSpace,
    double? freeSpace,
    double? usedSpace,
    double? appSize,
    bool? isLoading,
    String? error,
    Map<String, List<String>>? files,
  }) {
    return StorageState(
      totalSpace: totalSpace ?? this.totalSpace,
      freeSpace: freeSpace ?? this.freeSpace,
      usedSpace: usedSpace ?? this.usedSpace,
      appSize: appSize ?? this.appSize,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      files: files ?? this.files,
    );
  }

  @override
  List<Object?> get props => [totalSpace, freeSpace, usedSpace, appSize, isLoading, error, files];
}