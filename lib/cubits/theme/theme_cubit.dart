import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences prefs;
  static const String _themeKey = 'theme_mode';
  static const String _schemeKey = 'color_scheme';

  ThemeCubit(this.prefs)
      : super(
          ThemeState(
            themeMode: ThemeMode.system,
            colorScheme: FlexScheme.material,
          ),
        ) {
    _loadThemeSettings();
  }

  void _loadThemeSettings() {
    final savedThemeMode = prefs.getString(_themeKey);
    final savedScheme = prefs.getString(_schemeKey);

    emit(
      state.copyWith(
        themeMode: savedThemeMode != null
            ? ThemeMode.values.firstWhere(
                (mode) => mode.toString() == savedThemeMode,
                orElse: () => ThemeMode.system,
              )
            : state.themeMode,
        colorScheme: savedScheme != null
            ? FlexScheme.values.firstWhere(
                (scheme) => scheme.toString() == savedScheme,
                orElse: () => FlexScheme.material,
              )
            : state.colorScheme,
      ),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await prefs.setString(_themeKey, mode.toString());
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setColorScheme(FlexScheme scheme) async {
    await prefs.setString(_schemeKey, scheme.toString());
    emit(state.copyWith(colorScheme: scheme));
  }
}
