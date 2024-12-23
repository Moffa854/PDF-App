// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../../favourite/presentation/cubit/favorites/favorites_cubit.dart';
import '../../../favourite/presentation/cubit/favorites/favorites_state.dart';
import '../cubit/pdf/pdf_cubit.dart';
import '../cubit/pdf/pdf_state.dart';
import 'pdf_search_delegate.dart';
import 'pdf_viewer_screen.dart';
import '../cubit/pdf/pdf_viewmodel.dart';

class PdfFilesScreen extends StatefulWidget {
  const PdfFilesScreen({super.key});

  @override
  State<PdfFilesScreen> createState() => _PdfFilesScreenState();
}

class _PdfFilesScreenState extends State<PdfFilesScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<int, AnimationController> _animationControllers = {};
  bool _isScrollingDown = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    context.read<PdfCubit>().loadPdfFiles();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // Dispose all animation controllers
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (!_isScrollingDown) {
        setState(() {
          _isScrollingDown = true;
        });
      }
    }
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (_isScrollingDown) {
        setState(() {
          _isScrollingDown = false;
        });
      }
    }
  }

  Widget _buildAnimatedListItem(BuildContext context, int index, Widget child) {
    if (!_animationControllers.containsKey(index)) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (index * 50)),
      );
      _animationControllers[index] = controller;
      
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );

      controller.forward();

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PdfCubit()..loadPdfFiles()),
        BlocProvider(
          create: (context) =>
              FavoritesCubit(context.read<SharedPreferences>()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.pdfFiles,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: PdfSearchDelegate(
                    context.read<PdfCubit>().state.pdfFiles,
                  ),
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

                  if (state.pdfFiles.isEmpty) {
                    return Center(
                      child: Text(l10n.noPdfFiles),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final newPdfFiles = await context.read<PdfCubit>().checkNewPdfFiles();
                      if (newPdfFiles.isNotEmpty) {
                        await context.read<PdfCubit>().loadPdfFiles();
                        await context.read<FavoritesCubit>().loadFavorites();
                      }

                      await context.read<PdfCubit>().loadPdfFiles();
                      await context.read<FavoritesCubit>().loadFavorites();
                    },
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: state.pdfFiles.length,
                      itemBuilder: (context, index) {
                        final filePath = state.pdfFiles[index];
                        final viewModel = context.read<PdfViewModel>();
                        final fileName = viewModel.getFileName(filePath);
                        final fileSize = viewModel.getFileSize(filePath);
                        final lastModified = viewModel.getLastModified(filePath);

                        return _buildAnimatedListItem(
                          context,
                          index,
                          Slidable(
                            key: ValueKey(filePath),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    final file = File(filePath);
                                    if (await file.exists()) {
                                      await file.delete();
                                      context.read<PdfCubit>().loadPdfFiles();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.fileDeleted),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: l10n.delete,
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 32,
                              ),
                              title: Text(
                                fileName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '${l10n.size}: $fileSize • ${l10n.modified}: ${DateFormat('MMM d, y').format(lastModified)}',
                              ),
                              trailing:
                                  BlocBuilder<FavoritesCubit, FavoritesState>(
                                builder: (context, favoriteState) {
                                  final isFavorite = favoriteState.favoritePdfs
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(isFavorite
                                              ? l10n.removedFromFavorites
                                              : l10n.addedToFavorites),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              onTap: () => _openPdfFile(context, filePath),
                            ),
                          ),
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
    );
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