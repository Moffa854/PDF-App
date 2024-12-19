// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_app/cubits/favorites/favorites_cubit.dart';
import 'package:pdf_app/cubits/pdf/pdf_cubit.dart';
import 'package:pdf_app/screens/favorite_files_screen.dart';
import 'package:pdf_app/widgets/sizes_app.dart';
import 'package:permission_handler/permission_handler.dart';

import '../cubits/storage/storage_cubit.dart';
import '../cubits/storage/storage_state.dart';
import '../screens/pdf_files_screen.dart'; // Import PdfFilesScreen

class FileManagementScreen extends StatefulWidget {
  const FileManagementScreen({super.key});

  @override
  State<FileManagementScreen> createState() => _FileManagementScreenState();
}

class _FileManagementScreenState extends State<FileManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider.value(
          value: context.read<StorageCubit>(),
          child: SingleChildScrollView(
            key: const PageStorageKey<String>('file_management_scroll'),
            child: Column(
              children: [
                _buildSearchBar(context),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildFileTypes(),
                ),
                const SizedBox(height: 24),
                _buildStorageSection(),
              ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideX(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initializeStorage();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget _buildFileTypes() {
    final fileTypes = [
      {
        'icon': Icons.picture_as_pdf,
        'label': 'PDF',
        'color': Colors.red,
        'asset': null
      },
      {
        'icon': Icons.favorite,
        'label': 'Favorites',
        'color': Colors.pink,
        'asset': null
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: sizesApp(context, 50, 180, 70).toDouble(),
        mainAxisSpacing: sizesApp(context, 50, 180, 70).toDouble(),
        childAspectRatio: 1.5,
      ),
      itemCount: fileTypes.length,
      itemBuilder: (context, index) {
        final type = fileTypes[index];
        return GestureDetector(
          onTap: () async {
            if (type['label'] == 'PDF') {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Scanning PDF files...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              // Initialize PDF scanning
              final pdfCubit = context.read<PdfCubit>();
              await pdfCubit.loadPdfFiles();

              // Close loading dialog
              if (mounted) {
                Navigator.pop(context); // Close loading dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfFilesScreen(),
                  ),
                );
              }
            }
            if (type['label'] == 'Favorites') {
              // Initialize Favorites scanning
              final favoritesCubit = context.read<FavoritesCubit>();
              await favoritesCubit.loadFavorites();
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoriteFilesScreen(),
                  ),
                );
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: (type['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: type['color'] as Color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: type['asset'] != null
                        ? SvgPicture.asset(
                            type['asset'] as String,
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          )
                        : Icon(
                            type['icon'] as IconData,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  type['label'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: (100 * index).ms)
              .slideY(begin: 0.2, delay: (100 * index).ms),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        l10n.fileManagement,
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStorageItem({
    required IconData icon,
    required String title,
    required String space,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            space,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<StorageCubit, StorageState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading storage information...'),
                ],
              ),
            );
          }

          if (state.error != null) {
            return Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(state.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeStorage(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Storage',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildStorageItem(
                icon: Icons.storage,
                title: 'Device Storage',
                space:
                    '${state.usedSpace.toStringAsFixed(1)} GB / ${state.totalSpace.toStringAsFixed(1)} GB',
                progress: state.usedSpace / state.totalSpace,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildStorageItem(
                icon: Icons.folder,
                title: 'App Storage',
                space: '${state.appSize.toStringAsFixed(2)} GB',
                progress: state.appSize / state.totalSpace,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildStorageItem(
                icon: Icons.cloud,
                title: 'Cloud Storage',
                space: 'Not Available',
                progress: 0,
                color: Colors.grey,
              ),
              if (state.freeSpace < 1.0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Low storage space! Only ${state.freeSpace.toStringAsFixed(2)} GB remaining',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _initializeStorage() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      if (mounted) {
        context.read<StorageCubit>().loadStorageInfo();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Storage permission is required to show storage information'),
          ),
        );
      }
    }
  }
}
