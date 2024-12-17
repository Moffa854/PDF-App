import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final SharedPreferences prefs;
  static const String _themeKey = 'theme_mode';
  static const String _schemeKey = 'color_scheme';

  ThemeProvider(this.prefs) {
    _loadThemeMode();
    _loadColorScheme();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  FlexScheme _colorScheme = FlexScheme.material;
  FlexScheme get colorScheme => _colorScheme;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadThemeMode() {
    final savedThemeMode = prefs.getString(_themeKey);
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  void _loadColorScheme() {
    final savedScheme = prefs.getString(_schemeKey);
    if (savedScheme != null) {
      _colorScheme = FlexScheme.values.firstWhere(
        (scheme) => scheme.toString() == savedScheme,
        orElse: () => FlexScheme.material,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }

  Future<void> setColorScheme(FlexScheme scheme) async {
    _colorScheme = scheme;
    await prefs.setString(_schemeKey, scheme.toString());
    notifyListeners();
  }

  ThemeData get lightTheme => FlexThemeData.light(
        scheme: _colorScheme,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      );

  ThemeData get darkTheme => FlexThemeData.dark(
        scheme: _colorScheme,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      );
}
