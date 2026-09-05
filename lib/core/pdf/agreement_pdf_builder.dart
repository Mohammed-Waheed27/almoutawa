import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/agreement_terms.dart';
import '../../domain/entities/commercial_order.dart';
import '../../domain/entities/company_settings.dart';
import '../../domain/repositories/company_settings_repository.dart';
import 'flutter_pdf_composer.dart';
import 'widgets/agreement_pdf_page.dart';
import 'widgets/agreement_terms_pdf_page.dart';

class AgreementPdfBuilder {
  AgreementPdfBuilder(this._companySettings);

  final CompanySettingsRepository _companySettings;
  final FlutterPdfComposer _composer = FlutterPdfComposer();

  static const _logoAsset = 'assets/branding/quote_logo.png';

  Future<Uint8List> build(
    CommercialOrderDetail detail, {
    required BuildContext context,
  }) async {
    if (detail.agreement == null) {
      throw StateError('لا توجد اتفاقية لهذا الطلب');
    }
    CompanySettings settings;
    try {
      settings = await _companySettings.fetchSettings();
    } catch (_) {
      settings = const CompanySettings(vatRate: 0.15, phones: []);
    }
    final logo = await _loadLogo();
    if (!context.mounted) {
      throw StateError('تعذر إنشاء الملف — أعد فتح الصفحة ثم حاول مرة أخرى');
    }
    final stored = (detail.agreement!.termsSnapshot ?? '').trim();
    final terms = stored.isNotEmpty
        ? stored
        : (settings.agreementTermsAr.trim().isNotEmpty
              ? settings.agreementTermsAr.trim()
              : defaultAgreementTermsAr);
    return _composer.compose(
      context: context,
      pages: [
        AgreementPdfPage(
          detail: detail,
          settings: settings,
          logoBytes: logo,
        ),
        AgreementTermsPdfPage(
          terms: terms,
          settings: settings,
          factory: detail.factory,
          logoBytes: logo,
        ),
      ],
    );
  }

  Future<Uint8List?> _loadLogo() async {
    try {
      final data = await rootBundle.load(_logoAsset);
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}
