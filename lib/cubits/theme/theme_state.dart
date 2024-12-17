import 'package:equatable/equatable.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final FlexScheme colorScheme;

  const ThemeState({
    required this.themeMode,
    required this.colorScheme,
  });

  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeData get lightTheme => FlexThemeData.light(
        scheme: colorScheme,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 9,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          bottomNavigationBarElevation: 2,
          bottomNavigationBarOpacity: 0.95,
          navigationBarIndicatorOpacity: 0.20,
          inputDecoratorIsFilled: true,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorRadius: 8,
          chipRadius: 8,
          cardRadius: 12,
          popupMenuRadius: 8,
          dialogRadius: 16,
          timePickerElementRadius: 12,
        ),
        keyColors: const FlexKeyColors(
          useSecondary: true,
          useTertiary: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      );

  ThemeData get darkTheme => FlexThemeData.dark(
        scheme: colorScheme,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          bottomNavigationBarElevation: 2,
          bottomNavigationBarOpacity: 0.95,
          navigationBarIndicatorOpacity: 0.20,
          inputDecoratorIsFilled: true,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorRadius: 8,
          chipRadius: 8,
          cardRadius: 12,
          popupMenuRadius: 8,
          dialogRadius: 16,
          timePickerElementRadius: 12,
        ),
        keyColors: const FlexKeyColors(
          useSecondary: true,
          useTertiary: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      );

  @override
  List<Object?> get props => [themeMode, colorScheme];

  ThemeState copyWith({
    ThemeMode? themeMode,
    FlexScheme? colorScheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }
}
