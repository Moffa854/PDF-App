import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_app/features/pdf/presentation/screens/pdf_viewer_screen.dart';

class PdfSearchDelegate extends SearchDelegate<String> {
  final List<String> pdfFiles;

  PdfSearchDelegate(this.pdfFiles);

  @override
  String get searchFieldLabel {
    return ''; // Return an empty string or a default value if needed
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filteredFiles = pdfFiles
        .where((file) => file.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (query.isEmpty) {
      return ListView.separated(
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          height: 1,
        ),
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          final filePath = pdfFiles[index];
          final file = File(filePath);
          final bytes = file.lengthSync();
          final lastModified = file.lastModifiedSync();

          // Format file size
          String fileSize;
          if (bytes < 1024) {
            fileSize = '$bytes B';
          } else if (bytes < 1024 * 1024) {
            fileSize = '${(bytes / 1024).toStringAsFixed(1)} KB';
          } else {
            fileSize = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
          }

          return ListTile(
            leading: const Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 32,
            ),
            subtitle: Text(
              '${l10n?.size}: $fileSize • ${l10n?.modified}: ${DateFormat('MMM d, y').format(lastModified)}',
            ),
            title: Text(
              path.basename(pdfFiles[index]),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PdfViewerScreen(
                    filePath: pdfFiles[index],
                    fileName: path.basename(pdfFiles[index]),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    if (filteredFiles.isEmpty) {
      return Center(
        child: Text(l10n?.noFilesFound ?? ''),
      );
    }

    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(
        thickness: 1,
        height: 1,
      ),
      itemCount: filteredFiles.length,
      itemBuilder: (context, index) {
        final filePath = filteredFiles[index];
        final file = File(filePath);
        final bytes = file.lengthSync();
        final lastModified = file.lastModifiedSync();

        // Format file size
        String fileSize;
        if (bytes < 1024) {
          fileSize = '$bytes B';
        } else if (bytes < 1024 * 1024) {
          fileSize = '${(bytes / 1024).toStringAsFixed(1)} KB';
        } else {
          fileSize = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }

        return ListTile(
          leading: const Icon(
            Icons.picture_as_pdf,
            color: Colors.red,
            size: 32,
          ),
          subtitle: Text(
            '${l10n?.size}: $fileSize • ${l10n?.modified}: ${DateFormat('MMM d, y').format(lastModified)}',
          ),
          title: Text(
            path.basename(filteredFiles[index]),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PdfViewerScreen(
                  filePath: filteredFiles[index],
                  fileName: path.basename(filteredFiles[index]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
