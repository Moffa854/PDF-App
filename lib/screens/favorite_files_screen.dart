import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../cubits/favorites/favorites_cubit.dart';
import '../cubits/favorites/favorites_state.dart';
import 'pdf_viewer_screen.dart';

class FavoriteFilesScreen extends StatelessWidget {
  const FavoriteFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.favoriteFiles,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<FavoritesCubit, FavoritesState>(
        listener: (context, state) {
          // This will be called whenever the state changes
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: Text(l10n.loading));
          }

          if (state.error != null) {
            return Center(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state.favoritePdfs.isEmpty) {
            return Center(
              child: Text(l10n.noFavoriteFiles),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<FavoritesCubit>().loadFavorites();
            },
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: state.favoritePdfs.length,
              itemBuilder: (context, index) {
                final filePath = state.favoritePdfs[index];
                final file = File(filePath);
                final fileName = file.path.split('/').last;
                final fileSize =
                    '${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB';
                final lastModified = file.lastModifiedSync();

                return ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: 32,
                  ),
                  subtitle: Text(
                    '${l10n.size}: $fileSize • ${l10n.modified}: ${DateFormat('MMM d, y').format(lastModified)}',
                  ),
                  title: Text(
                    fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outlined,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      context.read<FavoritesCubit>().toggleFavorite(filePath);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          filePath: filePath,
                          fileName: fileName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
