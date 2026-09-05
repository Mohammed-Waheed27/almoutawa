import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/commercial_order.dart';
import '../../domain/entities/company_settings.dart';
import '../../domain/entities/manufacturing_card.dart';
import '../../domain/repositories/company_settings_repository.dart';
import 'flutter_pdf_composer.dart';
import 'widgets/manufacturing_card_pdf_page.dart';

/// Arabic or English manufacturing-card PDF layout.
enum ManufacturingCardPdfLocale {
  arabic,
  english;

  bool get isArabic => this == ManufacturingCardPdfLocale.arabic;

  String get fileSuffix => isArabic ? 'ar' : 'en';

  String get uiLabel => isArabic ? 'PDF عربي' : 'PDF English';
}

/// Flutter-layout كارت تصنيع, rasterized to A4 like quote/agreement.
class ManufacturingCardPdfBuilder {
  ManufacturingCardPdfBuilder(this._companySettings);

  final CompanySettingsRepository _companySettings;
  final FlutterPdfComposer _composer = FlutterPdfComposer();

  static const _logoAsset = 'assets/branding/quote_logo.png';

  Future<Uint8List> build({
    required CommercialOrderDetail detail,
    required ManufacturingCard card,
    required BuildContext context,
    ManufacturingCardPdfLocale locale = ManufacturingCardPdfLocale.arabic,
  }) async {
    CompanySettings? settings;
    try {
      settings = await _companySettings.fetchSettings();
    } catch (_) {
      settings = null;
    }
    final logo = await _loadLogo();
    final productImageBytes = _hasUrl(card.productImageUrl)
        ? await _fetchBytes(card.productImageUrl!)
        : null;
    final colorImageBytes = _hasUrl(card.colorImageUrl)
        ? await _fetchBytes(card.colorImageUrl!)
        : null;
    final propertyImageBytes = <int, Uint8List>{};
    final sortedProps = [...card.properties]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    for (var i = 0; i < sortedProps.length; i++) {
      final url = sortedProps[i].imageUrl;
      if (url == null || url.trim().isEmpty) continue;
      final bytes = await _fetchBytes(url);
      if (bytes != null) propertyImageBytes[i] = bytes;
    }
    if (!context.mounted) {
      throw StateError('تعذر إنشاء الملف — أعد فتح الصفحة ثم حاول مرة أخرى');
    }
    return _composer.compose(
      context: context,
      textDirection: locale.isArabic ? TextDirection.rtl : TextDirection.ltr,
      pages: [
        ManufacturingCardPdfPage(
          detail: detail,
          card: card,
          isArabic: locale.isArabic,
          settings: settings,
          logoBytes: logo,
          productImageBytes: productImageBytes,
          colorImageBytes: colorImageBytes,
          propertyImageBytes: propertyImageBytes,
        ),
      ],
    );
  }

  Future<Uint8List?> _loadLogo() async {
    try {
      final data = await rootBundle.load(_logoAsset);
      return data.buffer.asUint8List();
    } catch (_) {
      try {
        final fallback = await rootBundle.load(
          'assets/branding/mfg_card_logo.png',
        );
        return fallback.buffer.asUint8List();
      } catch (_) {
        return null;
      }
    }
  }

  bool _hasUrl(String? url) => url != null && url.trim().isNotEmpty;

  Future<Uint8List?> _fetchBytes(String url) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      if (response.statusCode == 200) {
        final bytes = <int>[];
        await for (final chunk in response) {
          bytes.addAll(chunk);
        }
        client.close();
        return Uint8List.fromList(bytes);
      }
      client.close();
    } catch (_) {}
    return null;
  }
}
