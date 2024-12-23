import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_app/features/app/presentation/widgets/app_screen_content.dart';
import 'package:pdf_app/features/home/presentation/screens/file_management_screen.dart';
import 'package:pdf_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:pdf_app/features/app/presentation/manager/cubit/navigation_cubit.dart';
import 'package:pdf_app/features/app/presentation/manager/cubit/navigation_state.dart';

/// A screen that manages the main navigation of the app.
class AppScreen extends StatelessWidget {
  /// Creates an [AppScreen] widget.
  const AppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: const AppScreenContent(),
    );
  }
}


