import 'package:equatable/equatable.dart';

class PdfState extends Equatable {
  final List<String> pdfFiles;
  final bool isLoading;
  final String? error;
  final double? scanProgress;
  final String currentDirectory;

  const PdfState({
    this.pdfFiles = const [],
    this.isLoading = false,
    this.error,
    this.scanProgress = 0,
    this.currentDirectory = '',
  });

  PdfState copyWith({
    List<String>? pdfFiles,
    bool? isLoading,
    String? error,
    double? scanProgress,
    String? currentDirectory,
  }) {
    return PdfState(
      pdfFiles: pdfFiles ?? this.pdfFiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,  
      scanProgress: scanProgress ?? this.scanProgress,
      currentDirectory: currentDirectory ?? this.currentDirectory,
    );
  }

  @override
  List<Object?> get props =>
      [pdfFiles, isLoading, error, scanProgress, currentDirectory];
}