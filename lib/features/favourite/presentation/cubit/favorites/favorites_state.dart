import 'package:equatable/equatable.dart';

class FavoritesState extends Equatable {
  final List<String> favoritePdfs;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favoritePdfs = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<String>? favoritePdfs,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favoritePdfs: favoritePdfs ?? this.favoritePdfs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [favoritePdfs, isLoading, error];
}
