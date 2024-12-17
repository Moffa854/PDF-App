import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _showFab = true;
  bool _showToolbar = false;
  bool _isLoading = true;
  String? _errorMessage;
  PdfAnnotationMode _annotationMode = PdfAnnotationMode.none;
  final TextEditingController _textController = TextEditingController();
  final List<int> _bookmarkedPages = [];
  final TextEditingController _annotationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              _pdfViewerController.zoomLevel =
                  _pdfViewerController.zoomLevel + 1.0;
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              _pdfViewerController.zoomLevel =
                  _pdfViewerController.zoomLevel - 1.0;
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_errorMessage != null)
            _buildErrorWidget()
          else
            GestureDetector(
              onTap: () {
                if (_annotationMode == PdfAnnotationMode.none) {
                  setState(() {
                    _showFab = !_showFab;
                    if (!_showFab) {
                      _showToolbar = false;
                    }
                  });
                }
              },
              child: SfPdfViewer.file(
                File(widget.filePath),
                key: _pdfViewerKey,
                controller: _pdfViewerController,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                enableDoubleTapZooming: true,
                enableTextSelection: true,
                onAnnotationAdded: (details) {
                  setState(() {
                    _annotationMode = PdfAnnotationMode.none;
                  });
                },
                
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  setState(() {
                    _errorMessage = 'Failed to load PDF: ${details.error}';
                  });
                },
              ),
            ),
          
          if (_bookmarkedPages.isNotEmpty) _buildBookmarksList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _textController.dispose();
    _annotationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _validateAndLoadPdf();
  }

  

  Widget _buildBookmarksList() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 60,
        color: Colors.black.withOpacity(0.1),
        child: ListView.builder(
          itemCount: _bookmarkedPages.length,
          itemBuilder: (context, index) {
            return IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () {
                _pdfViewerController.jumpToPage(_bookmarkedPages[index]);
              },
            );
          },
        ),
      ),
    );
  }


  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Error loading PDF',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }


  

  void _showBookmarksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bookmarks'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _bookmarkedPages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Page ${_bookmarkedPages[index]}'),
                onTap: () {
                  _pdfViewerController.jumpToPage(_bookmarkedPages[index]);
                  Navigator.pop(context);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _bookmarkedPages.removeAt(index);
                    });
                    if (_bookmarkedPages.isEmpty) {
                      Navigator.pop(context);
                    }
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }



  

  void _toggleBookmark() {
    final currentPage = _pdfViewerController.pageNumber;
    setState(() {
      if (_bookmarkedPages.contains(currentPage)) {
        _bookmarkedPages.remove(currentPage);
      } else {
        _bookmarkedPages.add(currentPage);
      }
    });
  }

  void _toggleToolbar() {
    setState(() {
      _showToolbar = !_showToolbar;
      if (!_showToolbar) {
        _annotationMode = PdfAnnotationMode.none;
      }
    });
  }

  Future<void> _validateAndLoadPdf() async {
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        setState(() {
          _errorMessage = 'PDF file not found';
          _isLoading = false;
        });
        return;
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        setState(() {
          _errorMessage = 'PDF file is empty';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }
}
