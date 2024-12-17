// ignore_for_file: deprecated_member_use, depend_on_referenced_packages, duplicate_ignore

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf_app/screens/app_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cubits/favorites/favorites_cubit.dart';
import 'cubits/pdf/pdf_cubit.dart';
import 'cubits/storage/storage_cubit.dart';
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

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    Provider<SharedPreferences>.value(
      value: prefs,
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: context.watch<SharedPreferences>()),
        BlocProvider(create: (context) => StorageCubit()),
        BlocProvider(create: (context) => PdfCubit()..loadPdfFiles()),
        BlocProvider(
            create: (context) =>
                FavoritesCubit(context.read<SharedPreferences>())),
      ],
      child: MaterialApp(
        title: 'PDF Master',
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const AppScreen(),
      ),
    );
  }
}
