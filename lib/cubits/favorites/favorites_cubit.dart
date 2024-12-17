import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final SharedPreferences _prefs;
  static const String _favoritesKey = 'favorite_pdfs';

  FavoritesCubit(this._prefs) : super(const FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      emit(state.copyWith(isLoading: true));
      final favorites = _prefs.getStringList(_favoritesKey) ?? [];
      emit(state.copyWith(
        favoritePdfs: favorites,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Error loading favorites: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> toggleFavorite(String pdfPath) async {
    try {
      final currentFavorites = List<String>.from(state.favoritePdfs);
      if (currentFavorites.contains(pdfPath)) {
        currentFavorites.remove(pdfPath);
      } else {
        currentFavorites.add(pdfPath);
      }
      
      await _prefs.setStringList(_favoritesKey, currentFavorites);
      emit(state.copyWith(favoritePdfs: currentFavorites));
    } catch (e) {
      emit(state.copyWith(error: 'Error updating favorites: $e'));
    }
  }

  bool isFavorite(String pdfPath) {
    return state.favoritePdfs.contains(pdfPath);
  }
}
