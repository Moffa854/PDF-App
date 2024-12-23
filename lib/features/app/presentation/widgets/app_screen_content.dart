import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_app/features/app/presentation/manager/cubit/navigation_cubit.dart';
import 'package:pdf_app/features/app/presentation/manager/cubit/navigation_state.dart';
import 'package:pdf_app/features/home/presentation/screens/file_management_screen.dart';
import 'package:pdf_app/features/settings/presentation/screens/settings_screen.dart';

class AppScreenContent extends StatelessWidget {
  const AppScreenContent({super.key});

  static const List<({Widget page, String label, IconData icon})> _navigationItems = [
    (
      page: FileManagementScreen(),
      label: 'Home',
      icon: Icons.home,
    ),
    (
      page: SettingsScreen(),
      label: 'Settings',
      icon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: _navigationItems[state.index].page,
          bottomNavigationBar: _buildBottomNavigationBar(context, state.index),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onNavigationTap(context, index),
      items: _buildNavigationItems(),
    );
  }

  void _onNavigationTap(BuildContext context, int index) {
    context.read<NavigationCubit>().setIndex(index);
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    return _navigationItems
        .map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ))
        .toList();
  }
}