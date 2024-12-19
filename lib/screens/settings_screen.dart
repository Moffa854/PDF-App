// ignore_for_file: unused_element, unused_local_variable

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_app/cubits/language/language_state.dart';

import '../cubits/language/language_cubit.dart';
import '../cubits/theme/theme_cubit.dart';
import '../cubits/theme/theme_state.dart';
import '../screens/terms_of_service_screen.dart';
import '../screens/privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool notificationsEnabled = true;
  bool autoDeleteEnabled = false;
  String sortBy = 'name';
  late AnimationController _controller;
  late List<Animation<Offset>> _slideAnimations;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'settings_title',
          child: Text(
            l10n.settings,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAnimatedSection(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(l10n.appearance),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: SwitchListTile(
                        key: ValueKey(themeState.isDarkMode),
                        title: Text(l10n.darkMode),
                        subtitle: Text(l10n.enableDarkTheme),
                        value: themeState.isDarkMode,
                        onChanged: (value) {
                          context.read<ThemeCubit>().setThemeMode(
                                value ? ThemeMode.dark : ThemeMode.light,
                              );
                        },
                      ),
                    ),
                    _buildTappableListTile(
                      onTap: () => _showColorSchemeDialog(context),
                      child: ListTile(
                        title: Text(l10n.colorScheme),
                        subtitle: Text(themeState.colorScheme.name),
                        trailing: const Icon(Icons.palette),
                      ),
                    ),
                  ],
                ),
                _slideAnimations[0],
              ),
              const Divider(),
              _buildAnimatedSection(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(l10n.appLanguage),
                    BlocBuilder<LanguageCubit, LanguageState>(
                      builder: (context, state) {
                        final languageCubit = context.read<LanguageCubit>();
                        return _buildTappableListTile(
                          onTap: () => _showLanguageDialog(context),
                          child: ListTile(
                            title: Text(l10n.language),
                            subtitle: Text(languageCubit
                                .getLanguageName(state.locale.languageCode)),
                            trailing: const Icon(Icons.language),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                _slideAnimations[2],
              ),
              const Divider(),
              _buildAnimatedSection(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(l10n.about),
                    ListTile(
                      title: Text(l10n.version),
                      subtitle: const Text('1.0.0'),
                    ),
                    ListTile(
                      title: Text(l10n.termsOfService),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsOfServiceScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: Text(l10n.privacyPolicy),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                _slideAnimations[3],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create staggered animations for each section
    _slideAnimations = List.generate(
      4, // Number of sections
      (index) => Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2, // Stagger the animations
            0.6 + (index * 0.1),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  Widget _buildAnimatedSection(Widget child, Animation<Offset> animation) {
    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: _controller,
        child: child,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
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

  Widget _buildTappableListTile({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: InkWell(
        onTapDown: (_) {
          setState(() {});
        },
        onTapUp: (_) {
          setState(() {});
          if (onTap != null) onTap();
        },
        onTapCancel: () {
          setState(() {});
        },
        child: child,
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
