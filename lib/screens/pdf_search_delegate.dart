import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_app/screens/pdf_viewer_screen.dart';

class PdfSearchDelegate extends SearchDelegate<String> {
  final List<String> pdfFiles;

  PdfSearchDelegate(this.pdfFiles);

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
    // Implement the logic to display search results
    return _buildResultList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = pdfFiles
        .where((file) => file.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildResultList(suggestions);
  }

  Widget _buildResultList([List<String>? suggestions]) {
    final items = suggestions ?? pdfFiles;
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(
            Icons.picture_as_pdf,
            color: Colors.red,
            size: 32,
          ),
          title: Text(
            path.basename(items[index]),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          onTap: () {
            // Implement logic to open the selected PDF file
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PdfViewerScreen(
                  filePath: items[index],
                  fileName: path.basename(items[index]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
