// ignore_for_file: unused_element, unused_local_variable

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_app/cubits/language/language_state.dart';

import '../cubits/language/language_cubit.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(l10n.appearance),
              SwitchListTile(
                title: Text(l10n.darkMode),
                subtitle: Text(l10n.enableDarkTheme),
                value: themeState.isDarkMode,
                onChanged: (value) {
                  context.read<ThemeCubit>().setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              ),
              ListTile(
                title: Text(l10n.colorScheme),
                subtitle: Text(themeState.colorScheme.name),
                trailing: const Icon(Icons.palette),
                onTap: () => _showColorSchemeDialog(context),
              ),
              const Divider(),
              _buildSectionHeader(l10n.notifications),
              SwitchListTile(
                title: Text(l10n.pushNotifications),
                subtitle: Text(l10n.notificationsSubtitle),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              const Divider(),
              _buildSectionHeader(l10n.appLanguage),
              BlocBuilder<LanguageCubit, LanguageState>(
                builder: (context, state) {
                  final languageCubit = context.read<LanguageCubit>();
                  return ListTile(
                    title: Text(l10n.language),
                    subtitle: Text(languageCubit
                        .getLanguageName(state.locale.languageCode)),
                    trailing: const Icon(Icons.language),
                    onTap: () => _showLanguageDialog(context),
                  );
                },
              ),
              const Divider(),
              _buildSectionHeader(l10n.about),
              ListTile(
                title: Text(l10n.version),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                title: Text(l10n.termsOfService),
                onTap: () {
                  // TODO: Implement terms of service
                },
              ),
              ListTile(
                title: Text(l10n.privacyPolicy),
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

  Widget _buildLanguageOption(BuildContext context, String code, String name) {
    final languageCubit = context.read<LanguageCubit>();

    return ListTile(
      title: Text(name),
      leading: Radio<String>(
        value: code,
        groupValue: languageCubit.getCurrentLanguage(),
        onChanged: (value) {
          if (value != null) {
            languageCubit.setLanguage(value);
            Navigator.pop(context);
          }
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
        ),
      ),
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
                    backgroundColor:
                        FlexColorScheme.light(scheme: scheme).primary,
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

  void _showLanguageDialog(BuildContext context) {
    // ignore: unused_local_variable
    context.read<LanguageCubit>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Select Language',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, 'en', 'English'),
              _buildLanguageOption(context, 'ar', 'العربية'),
              _buildLanguageOption(context, 'fr', 'Français'),
            ],
          ),
        );
      },
    );
  }
}
