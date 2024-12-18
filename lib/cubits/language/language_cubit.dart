import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  final SharedPreferences _prefs;
  static const String _languageKey = 'app_language';

  LanguageCubit(this._prefs) : super(LanguageState.initial()) {
    final savedLanguage = _prefs.getString(_languageKey);
    if (savedLanguage != null) {
      emit(LanguageState(locale: Locale(savedLanguage)));
    }
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
    emit(LanguageState(locale: Locale(languageCode)));
  }

  String getCurrentLanguage() {
    return state.locale.languageCode;
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      case 'en':
      default:
        return 'English';
    }
  }
}
