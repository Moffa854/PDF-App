// ignore_for_file: deprecated_member_use, depend_on_referenced_packages, duplicate_ignore

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf_app/cubits/language/language_state.dart';
import 'package:pdf_app/screens/app_screen.dart';
import 'package:pdf_app/screens/splash_screen.dart';
import 'package:pdf_app/viewmodels/pdf_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cubits/favorites/favorites_cubit.dart';
import 'cubits/language/language_cubit.dart';
import 'cubits/pdf/pdf_cubit.dart';
import 'cubits/storage/storage_cubit.dart';
import 'cubits/theme/theme_cubit.dart';
import 'cubits/theme/theme_state.dart';
import 'models/pdf_cache_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(PdfCacheModelAdapter());
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Remove global orientation constraint to allow per-screen control

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => Provider<SharedPreferences>.value(
        value: prefs,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<PdfViewModel>(
              create: (_) => PdfViewModel(),
            ),
            BlocProvider(
              create: (context) => StorageCubit(),
            ),
            BlocProvider(
              create: (context) => PdfCubit()..loadPdfFiles(),
            ),
            BlocProvider(
              create: (context) => FavoritesCubit(prefs),
            ),
            BlocProvider(
              create: (context) => ThemeCubit(prefs),
            ),
            BlocProvider(
              create: (context) => LanguageCubit(prefs),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, languageState) {
            return MaterialApp(
              title: 'PDFox',
              debugShowCheckedModeBanner: false,
              useInheritedMediaQuery: true,
              locale: languageState.locale,
              supportedLocales: const [
                Locale('en'), // English
                Locale('ar'), // Arabic
                Locale('fr'), // French
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: DevicePreview.appBuilder,
              theme: themeState.lightTheme,
              darkTheme: themeState.darkTheme,
              themeMode: themeState.themeMode,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
