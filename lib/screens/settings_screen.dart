import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import '../cubits/theme/theme_cubit.dart';
import '../cubits/theme/theme_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool autoDeleteEnabled = false;
  String sortBy = 'name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Appearance'),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: themeState.isDarkMode,
                onChanged: (value) {
                  context.read<ThemeCubit>().setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
              ListTile(
                title: const Text('Color Scheme'),
                subtitle: Text(themeState.colorScheme.name),
                trailing: const Icon(Icons.palette),
                onTap: () => _showColorSchemeDialog(context),
              ),
              const Divider(),
              _buildSectionHeader('Notifications'),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Get notified about important updates'),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              const Divider(),
              _buildSectionHeader('File Management'),
              ListTile(
                title: const Text('Sort Files By'),
                subtitle: Text(sortBy.toUpperCase()),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showSortByDialog();
                },
              ),
              SwitchListTile(
                title: const Text('Auto Delete'),
                subtitle: const Text('Automatically delete files after 30 days'),
                value: autoDeleteEnabled,
                onChanged: (value) {
                  setState(() {
                    autoDeleteEnabled = value;
                  });
                },
              ),
              const Divider(),
              _buildSectionHeader('About'),
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Terms of Service'),
                onTap: () {
                  // TODO: Implement terms of service
                },
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                onTap: () {
                  // TODO: Implement privacy policy
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _showColorSchemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Select Color Scheme',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: FlexScheme.values.length,
              itemBuilder: (context, index) {
                final scheme = FlexScheme.values[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: FlexColorScheme.light(scheme: scheme).primary,
                    radius: 15,
                  ),
                  title: Text(scheme.name),
                  onTap: () {
                    context.read<ThemeCubit>().setColorScheme(scheme);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String option) {
    return ListTile(
      title: Text(option),
      leading: Radio<String>(
        value: option.toLowerCase(),
        groupValue: sortBy,
        onChanged: (value) {
          setState(() {
            sortBy = value!;
            Navigator.pop(context);
          });
        },
      ),
    );
  }

  void _showSortByDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Sort Files By',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption('Name'),
              _buildSortOption('Date'),
              _buildSortOption('Size'),
            ],
          ),
        );
      },
    );
  }
}
