import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../utils/bilingual_label.dart';
import '../../../domain/entities/commercial_order.dart';
import '../../../domain/entities/company_settings.dart';
import '../../../domain/entities/manufacturing_card.dart';
import '../../../domain/entities/product_property.dart';
import '../document_pdf_colors.dart';

class ManufacturingCardPdfPage extends StatelessWidget {
  const ManufacturingCardPdfPage({
    super.key,
    required this.detail,
    required this.card,
    required this.isArabic,
    this.settings,
    this.logoBytes,
    this.productImageBytes,
    this.colorImageBytes,
    this.propertyImageBytes = const {},
  });

  final CommercialOrderDetail detail;
  final ManufacturingCard card;
  final bool isArabic;
  final CompanySettings? settings;
  final Uint8List? logoBytes;
  final Uint8List? productImageBytes;
  final Uint8List? colorImageBytes;
  final Map<int, Uint8List> propertyImageBytes;

  TextDirection get _dir => isArabic ? TextDirection.rtl : TextDirection.ltr;

  @override
  Widget build(BuildContext context) {
    final imageColumn = _MfgProductColumn(
      card: card,
      isArabic: isArabic,
      productImageBytes: productImageBytes,
      colorImageBytes: colorImageBytes,
    );
    final specsColumn = _MfgSpecsPanel(
      card: card,
      isArabic: isArabic,
      propertyImageBytes: propertyImageBytes,
    );

    return Directionality(
      textDirection: _dir,
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MfgHeader(isArabic: isArabic, logoBytes: logoBytes),
              const SizedBox(height: 10),
              _MfgPillRow(
                isArabic: isArabic,
                label: isArabic ? 'موديل' : 'Model',
                value: bilingualLabel(
                  arabic: card.modelNameAr,
                  english: card.modelNameEn,
                  preferEnglish: !isArabic,
                ),
              ),
              const SizedBox(height: 6),
              _MfgPillRow(
                isArabic: isArabic,
                label: isArabic ? 'اسم العميل' : 'Customer',
                value: detail.customer.displayName,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  textDirection: _dir,
                  children: [
                    Expanded(flex: 5, child: specsColumn),
                    const SizedBox(width: 10),
                    Expanded(flex: 4, child: imageColumn),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _MfgNotesAlertRow(card: card, isArabic: isArabic),
              const SizedBox(height: 8),
              _MfgFooter(
                detail: detail,
                settings: settings,
                isArabic: isArabic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MfgHeader extends StatelessWidget {
  const _MfgHeader({required this.isArabic, required this.logoBytes});

  final bool isArabic;
  final Uint8List? logoBytes;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      isArabic ? 'كرت تصنيع' : 'Manufacturing Card',
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: DocumentPdfColors.mfgRed,
        height: 1,
      ),
    );
    final logo = logoBytes == null
        ? const SizedBox(width: 168, height: 72)
        : SizedBox(
            width: 168,
            height: 72,
            child: Image.memory(
              logoBytes!,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          );

    return Row(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isArabic
          ? [title, const Spacer(), logo]
          : [logo, const Spacer(), title],
    );
  }
}

class _MfgPillRow extends StatelessWidget {
  const _MfgPillRow({
    required this.isArabic,
    required this.label,
    required this.value,
  });

  final bool isArabic;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final labelBox = Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: DocumentPdfColors.mfgRed,
        borderRadius: isArabic
            ? const BorderRadius.only(
                topRight: Radius.circular(22),
                bottomRight: Radius.circular(22),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    final valueBox = Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: DocumentPdfColors.mfgDark,
          borderRadius: isArabic
              ? const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                )
              : const BorderRadius.only(
                  topRight: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
        ),
        alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          value.trim().isEmpty ? '—' : value.trim(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

    return Row(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: isArabic ? [labelBox, valueBox] : [labelBox, valueBox],
    );
  }
}

class _MfgProductColumn extends StatelessWidget {
  const _MfgProductColumn({
    required this.card,
    required this.isArabic,
    required this.productImageBytes,
    required this.colorImageBytes,
  });

  final ManufacturingCard card;
  final bool isArabic;
  final Uint8List? productImageBytes;
  final Uint8List? colorImageBytes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 7,
          child: _MfgDoorWithDims(
            card: card,
            isArabic: isArabic,
            productImageBytes: productImageBytes,
          ),
        ),
        const SizedBox(height: 6),
        _MfgColorBlock(
          card: card,
          isArabic: isArabic,
          colorImageBytes: colorImageBytes,
        ),
      ],
    );
  }
}

class _MfgDoorWithDims extends StatelessWidget {
  const _MfgDoorWithDims({
    required this.card,
    required this.isArabic,
    required this.productImageBytes,
  });

  final ManufacturingCard card;
  final bool isArabic;
  final Uint8List? productImageBytes;

  @override
  Widget build(BuildContext context) {
    final widthLabel = _MfgDim.format(card.widthCm);
    final heightLabel = _MfgDim.format(card.heightCm);
    final heightRail = SizedBox(
      width: 36,
      child: Row(
        textDirection: TextDirection.ltr,
        children: isArabic
            ? [
                Expanded(
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        heightLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: DocumentPdfColors.mfgBlack,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1.6, color: DocumentPdfColors.mfgBlack),
              ]
            : [
                Container(width: 1.6, color: DocumentPdfColors.mfgBlack),
                Expanded(
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        heightLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: DocumentPdfColors.mfgBlack,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
      ),
    );

    final image = Expanded(
      child: Center(
        child: productImageBytes != null
            ? Image.memory(
                productImageBytes!,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              )
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  bilingualLabel(
                    arabic: card.modelNameAr,
                    english: card.modelNameEn,
                    preferEnglish: !isArabic,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: DocumentPdfColors.mfgGrey,
                  ),
                ),
              ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DocumentPdfColors.mfgBlack, width: 1.2),
      ),
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widthLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DocumentPdfColors.mfgBlack,
            ),
          ),
          const SizedBox(height: 2),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: SizedBox(
              height: 1.6,
              child: ColoredBox(color: DocumentPdfColors.mfgBlack),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [image, heightRail],
            ),
          ),
        ],
      ),
    );
  }
}

class _MfgColorBlock extends StatelessWidget {
  const _MfgColorBlock({
    required this.card,
    required this.isArabic,
    required this.colorImageBytes,
  });

  final ManufacturingCard card;
  final bool isArabic;
  final Uint8List? colorImageBytes;

  @override
  Widget build(BuildContext context) {
    final title = isArabic ? 'لون الباب' : 'Door Color';
    final name = bilingualLabel(
      arabic: card.colorNameAr ?? '',
      english: card.colorNameEn,
      preferEnglish: !isArabic,
    );
    final code = card.colorCode?.trim() ?? '';
    final hasImage = colorImageBytes != null;
    final label = [
      if (name.isNotEmpty) name,
      if (code.isNotEmpty) code,
    ].join('  ');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DocumentPdfColors.mfgBlack, width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: DocumentPdfColors.mfgBlack,
            child: SizedBox(
              height: 28,
              child: Stack(
                children: [
                  Align(
                    alignment: isArabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: const ColoredBox(
                      color: DocumentPdfColors.mfgRed,
                      child: SizedBox(width: 10, height: 28),
                    ),
                  ),
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: hasImage ? 84 : 52,
            color: Colors.white,
            padding: const EdgeInsets.all(6),
            alignment: Alignment.center,
            child: hasImage
                ? Column(
                    children: [
                      Expanded(
                        child: Image.memory(
                          colorImageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      if (label.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          label.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  )
                : Text(
                    label.isEmpty
                        ? (isArabic ? 'بدون لون محدد' : 'No color set')
                        : label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: DocumentPdfColors.mfgBlack,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MfgSpecsPanel extends StatelessWidget {
  const _MfgSpecsPanel({
    required this.card,
    required this.isArabic,
    this.propertyImageBytes = const {},
  });

  final ManufacturingCard card;
  final bool isArabic;
  final Map<int, Uint8List> propertyImageBytes;

  @override
  Widget build(BuildContext context) {
    final title = isArabic ? 'مواصفات الباب' : 'Door Specs';
    final props = [...card.properties]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DocumentPdfColors.mfgBlack, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: DocumentPdfColors.mfgBlack,
            child: SizedBox(
              height: 36,
              child: Stack(
                children: [
                  Align(
                    alignment: isArabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: const ColoredBox(
                      color: DocumentPdfColors.mfgRed,
                      child: SizedBox(width: 12, height: 36),
                    ),
                  ),
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (props.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  isArabic ? 'لا توجد مواصفات' : 'No specs',
                  style: const TextStyle(
                    fontSize: 13,
                    color: DocumentPdfColors.mfgGrey,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < props.length; i++)
                    Expanded(
                      child: _MfgSpecRow(
                        property: props[i],
                        isArabic: isArabic,
                        alt: i.isOdd,
                        valueImageBytes: propertyImageBytes[i],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MfgSpecRow extends StatelessWidget {
  const _MfgSpecRow({
    required this.property,
    required this.isArabic,
    required this.alt,
    this.valueImageBytes,
  });

  final ManufacturingCardProperty property;
  final bool isArabic;
  final bool alt;
  final Uint8List? valueImageBytes;

  bool get _isOpening {
    final n = '${property.nameAr} ${property.nameEn ?? ''}'.toLowerCase();
    return n.contains('اتجاه') ||
        n.contains('فتح') ||
        n.contains('open') ||
        n.contains('swing');
  }

  @override
  Widget build(BuildContext context) {
    final name = bilingualLabel(
      arabic: property.nameAr,
      english: property.nameEn,
      preferEnglish: !isArabic,
    );
    final value = bilingualLabel(
      arabic: property.valueAr,
      english: property.valueEn,
      preferEnglish: !isArabic,
    );
    final icon = productPropertyIconFromKey(property.iconKey);

    final label = Container(
      width: 168,
      color: const Color(0xFFF2F2F2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Icon(icon, size: 18, color: DocumentPdfColors.mfgRed),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: DocumentPdfColors.mfgBlack,
              ),
            ),
          ),
        ],
      ),
    );

    final valueSide = Expanded(
      child: ColoredBox(
        color: alt ? DocumentPdfColors.mfgRow : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                child: Text(
                  value.isEmpty ? '—' : value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: DocumentPdfColors.mfgBlack,
                  ),
                ),
              ),
              if (valueImageBytes != null) ...[
                const SizedBox(width: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(
                    valueImageBytes!,
                    width: 46,
                    height: 32,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ] else if (_isOpening) ...[
                const SizedBox(width: 6),
                Container(
                  width: 46,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: DocumentPdfColors.mfgGrey,
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DocumentPdfColors.mfgGrey, width: 0.45),
        ),
      ),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [label, valueSide],
      ),
    );
  }
}

class _MfgNotesAlertRow extends StatelessWidget {
  const _MfgNotesAlertRow({required this.card, required this.isArabic});

  final ManufacturingCard card;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final alertTitle = isArabic ? 'تنبيه مهم' : 'Important alert';
    final notesTitle = isArabic ? 'ملاحظات' : 'Notes';
    final rawAlert = card.alertNote.trim().isEmpty
        ? defaultManufacturingCardAlert
        : card.alertNote.trim();
    final alertBody = rawAlert
        .replaceFirst(RegExp(r'^تنبيه مهم\s*:?\s*'), '')
        .replaceFirst(
          RegExp(r'^Important alert\s*:?\s*', caseSensitive: false),
          '',
        );
    final notes = card.notes?.trim() ?? '';

    final alertBox = Expanded(
      flex: 4,
      child: Container(
        constraints: const BoxConstraints(minHeight: 78),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD0D0D0), width: 1.1),
        ),
        child: Row(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: DocumentPdfColors.mfgRed,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$alertTitle: ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: DocumentPdfColors.mfgRed,
                      ),
                    ),
                    TextSpan(
                      text: alertBody,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: DocumentPdfColors.mfgBlack,
                      ),
                    ),
                  ],
                ),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );

    final notesBox = Expanded(
      flex: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            notesTitle,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: DocumentPdfColors.mfgRed,
            ),
          ),
          const SizedBox(height: 6),
          if (notes.isNotEmpty)
            Text(
              notes,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: const TextStyle(fontSize: 12, height: 1.35),
            )
          else
            Column(
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 14,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: DocumentPdfColors.mfgGrey,
                          width: 0.9,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: isArabic
          ? [notesBox, const SizedBox(width: 10), alertBox]
          : [alertBox, const SizedBox(width: 10), notesBox],
    );
  }
}

class _MfgFooter extends StatelessWidget {
  const _MfgFooter({
    required this.detail,
    required this.settings,
    required this.isArabic,
  });

  final CommercialOrderDetail detail;
  final CompanySettings? settings;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final factory = detail.factory;
    final pdfPhones = settings?.pdfPhones ?? const <CompanyContactPhone>[];
    final phones = pdfPhones.isEmpty
        ? <String>[
            if ((factory?.phone ?? '').trim().isNotEmpty)
              factory!.phone!.trim(),
            if ((factory?.mobile ?? '').trim().isNotEmpty)
              factory!.mobile!.trim(),
          ]
        : pdfPhones.map((item) => item.phone).toList(growable: false);
    final ig = (factory?.instagram ?? '').trim().replaceFirst('@', '');
    final address = factory == null
        ? ''
        : (isArabic
              ? (factory.addressAr ?? factory.addressEn ?? '')
              : (factory.addressEn ?? factory.addressAr ?? ''));

    final contact = Expanded(
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (phones.isNotEmpty)
            Text(
              phones.join('   ·   '),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          if (ig.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '@$ig',
              style: const TextStyle(
                color: DocumentPdfColors.mfgRed,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (address.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              address,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ],
      ),
    );

    return Column(
      children: [
        const ColoredBox(
          color: DocumentPdfColors.mfgRed,
          child: SizedBox(height: 3, width: double.infinity),
        ),
        ColoredBox(
          color: DocumentPdfColors.mfgBlack,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [contact],
            ),
          ),
        ),
      ],
    );
  }
}

class _MfgDim {
  static String format(double cm) {
    if ((cm - cm.roundToDouble()).abs() < 0.05) {
      return cm.round().toString();
    }
    return cm.toStringAsFixed(1);
  }
}
