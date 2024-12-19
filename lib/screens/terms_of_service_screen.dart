import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.termsOfService,
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
              'Welcome to PDFox',
              'By using PDFox, you agree to these terms. Please read them carefully.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using PDFox, you accept and agree to be bound by the terms and provisions of this agreement.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '2. Use License',
              'Permission is granted to temporarily download one copy of PDFox for personal, non-commercial transitory viewing only.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '3. PDF File Management',
              'You are responsible for all PDF files you manage through our app. We do not access, store, or transmit your PDF files to any external servers.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '4. Privacy',
              'Your privacy is important to us. All PDF operations are performed locally on your device. We do not collect any personal information or PDF content.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '5. User Obligations',
              '• You must not use PDFox for any illegal purposes\n'
                  '• You are responsible for maintaining the security of your device\n'
                  '• You should not attempt to modify, reverse engineer, or hack the app',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '6. Disclaimer',
              'PDFox is provided "as is" without any warranties, expressed or implied. We do not guarantee that the app will be error-free or uninterrupted.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '7. Updates',
              'We may update these terms from time to time. Continued use of PDFox after any modifications indicates your acceptance of the updated terms.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '8. Contact',
              'If you have any questions about these Terms of Service, please contact us.\n'
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
