// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

import '../cubits/favorites/favorites_cubit.dart';
import '../cubits/favorites/favorites_state.dart';
import '../cubits/pdf/pdf_cubit.dart';
import '../cubits/pdf/pdf_state.dart';
import '../screens/favorite_files_screen.dart';
import '../screens/pdf_search_delegate.dart';
import '../screens/pdf_viewer_screen.dart';
import '../viewmodels/pdf_viewmodel.dart';

class PdfFilesScreen extends StatefulWidget {
  const PdfFilesScreen({super.key});

  @override
  State<PdfFilesScreen> createState() => _PdfFilesScreenState();
}

class _PdfFilesScreenState extends State<PdfFilesScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PdfViewModel(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => PdfCubit()..loadPdfFiles()),
          BlocProvider(
            create: (context) =>
                FavoritesCubit(context.read<SharedPreferences>()),
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('PDF Files'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: BlocProvider.of<FavoritesCubit>(context),
                        child: const FavoriteFilesScreen(),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: PdfSearchDelegate(
                        context.read<PdfCubit>().state.pdfFiles),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<PdfCubit, PdfState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.error != null) {
                      return Center(
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (state.pdfFiles.isEmpty) {
                      return const Center(
                        child: Text('No PDF files found'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<PdfCubit>().loadPdfFiles();
                        await context.read<FavoritesCubit>().loadFavorites();
                      },
                      child: ListView.builder(
                        itemCount: state.pdfFiles.length,
                        itemBuilder: (context, index) {
                          final filePath = state.pdfFiles[index];
                          final viewModel = context.read<PdfViewModel>();
                          final fileName = viewModel.getFileName(filePath);
                          final fileSize = viewModel.getFileSize(filePath);
                          final lastModified =
                              viewModel.getLastModified(filePath);

                          return ListTile(
                            leading: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 32,
                            ),
                            title: Text(
                              fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '$fileSize • Modified: ${DateFormat('MMM d, y').format(lastModified)}',
                            ),
                            trailing:
                                BlocBuilder<FavoritesCubit, FavoritesState>(
                              builder: (context, favoritesState) {
                                final isFavorite = favoritesState.favoritePdfs
                                    .contains(filePath);
                                return IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<FavoritesCubit>()
                                        .toggleFavorite(filePath);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isFavorite
                                            ? 'Removed from favorites'
                                            : 'Added to favorites'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            onTap: () => _openPdfFile(context, filePath),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<PdfCubit>().loadPdfFiles();
  }

  Future<void> _openPdfFile(BuildContext context, String filePath) async {
    try {
      final fileName = path.basename(filePath);
      final pdfCubit = context.read<PdfCubit>();
      final cachedPath = await pdfCubit.getPdfPath(filePath);

      if (!mounted) return;

      await Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            filePath: cachedPath,
            fileName: fileName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
