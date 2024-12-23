import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.privacyPolicy,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Privacy Policy for PDFox',
              'Your privacy is critically important to us. At PDFox, we have a few fundamental principles:',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '1. Data Collection',
              'PDFox is designed with privacy in mind:\n'
                  '• We do not collect any personal information\n'
                  '• We do not track your usage or behavior\n'
                  '• We do not store or transmit your PDF files to any servers\n'
                  '• All operations are performed locally on your device',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '2. File Access',
              'PDFox requires access to your device storage only to:\n'
                  '• Read and display your PDF files\n'
                  '• Save any changes you make to PDF files\n'
                  '• Create and manage a local cache for better performance\n'
                  'We never access files outside of the permissions you grant.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '3. Data Storage',
              'All data, including:\n'
                  '• PDF files\n'
                  '• App settings\n'
                  '• Cache files\n'
                  'are stored locally on your device and are never uploaded to any external servers.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '4. Third-Party Services',
              'PDFox does not integrate with any third-party services that could compromise your privacy. We do not include any advertising or analytics services.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '5. Children\'s Privacy',
              'Our app does not specifically target or collect information from children under 13. We recommend parental guidance for users under 13.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '6. Security',
              'While we don\'t collect your data, we still implement security best practices:\n'
                  '• All file operations are performed in a secure sandbox environment\n'
                  '• We use modern encryption standards for cached data\n'
                  '• Regular security updates are provided through app updates',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '7. Changes to This Policy',
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this screen and updating the app.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '8. Contact Us',
              'If you have any questions about our Privacy Policy, please contact us:\n'
                  'Email: mustafamoffa@gmail.com\n'
                  'Phone: +20 1552735127',
            ),
            const SizedBox(height: 32),
            Text(
              'Last updated: December 19, 2023',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
