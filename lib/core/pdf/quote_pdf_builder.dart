import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/commercial_order.dart';
import '../../domain/entities/company_settings.dart';
import '../../domain/repositories/company_settings_repository.dart';
import 'flutter_pdf_composer.dart';
import 'widgets/quote_pdf_page.dart';

class QuotePdfBuilder {
  QuotePdfBuilder(this._companySettings);

  final CompanySettingsRepository _companySettings;
  final FlutterPdfComposer _composer = FlutterPdfComposer();

  static const _logoAsset = 'assets/branding/quote_logo.png';

  Future<Uint8List> build(
    CommercialOrderDetail detail, {
    required BuildContext context,
  }) async {
    if (detail.quote == null) {
      throw StateError('لا يوجد عرض سعر لهذا الطلب');
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
    return _composer.compose(
      context: context,
      pages: [
        QuotePdfPage(detail: detail, settings: settings, logoBytes: logo),
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
