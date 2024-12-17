import 'package:flutter/material.dart';

class AnimatedPdfPreview extends StatelessWidget {
  final String filePath;
  final DateTime lastOpened;
  final int sizeInBytes;
  final VoidCallback onTap;

  const AnimatedPdfPreview({
    super.key,
    required this.filePath,
    required this.lastOpened,
    required this.sizeInBytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = filePath.split('/').last;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: onTap,
          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
          title: Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _getFileInfo(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  String _getFileInfo() {
    final sizeInMb = (sizeInBytes / (1024 * 1024)).toStringAsFixed(1);
    return '${lastOpened.day}/${lastOpened.month}/${lastOpened.year} - $sizeInMb MB';
  }
}
