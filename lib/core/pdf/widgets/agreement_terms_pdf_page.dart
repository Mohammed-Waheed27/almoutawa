import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../domain/entities/company_settings.dart';
import '../../../domain/entities/factory_profile.dart';
import '../document_pdf_colors.dart';

class AgreementTermsPdfPage extends StatelessWidget {
  const AgreementTermsPdfPage({
    super.key,
    required this.terms,
    required this.settings,
    this.factory,
    this.logoBytes,
  });

  final String terms;
  final CompanySettings settings;
  final FactoryProfile? factory;
  final Uint8List? logoBytes;

  @override
  Widget build(BuildContext context) {
    final lines = terms
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                if (logoBytes != null)
                  Image.memory(logoBytes!, height: 78, fit: BoxFit.contain),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'الشروط والأحكام',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: DocumentPdfColors.navy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(height: 2.5, color: DocumentPdfColors.navy),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final line in lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          line,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: line.startsWith('الشروط') ? 18 : 15,
                            fontWeight: line.startsWith('الشروط')
                                ? FontWeight.w800
                                : FontWeight.w500,
                            height: 1.55,
                            color: DocumentPdfColors.navy,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Text(
              factory?.nameAr ?? 'ورشة محمد ياسين المطاوعة للحدادة',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: DocumentPdfColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
