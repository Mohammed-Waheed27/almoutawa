import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../domain/entities/commercial_order.dart';
import '../../../domain/entities/company_settings.dart';
import '../../../domain/entities/factory_profile.dart';
import '../document_pdf_colors.dart';

class QuotePdfPage extends StatelessWidget {
  const QuotePdfPage({
    super.key,
    required this.detail,
    required this.settings,
    this.logoBytes,
  });

  final CommercialOrderDetail detail;
  final CompanySettings settings;
  final Uint8List? logoBytes;

  static final dateFmt = DateFormat('dd/MM/yyyy');
  static final numFmt = NumberFormat('#,##0.##', 'en');
  static final moneyFmt = NumberFormat('#,##0.00', 'en');

  @override
  Widget build(BuildContext context) {
    final quote = detail.quote!;
    final factory = detail.factory;
    final customer = detail.customer;
    final extras = quote.extraCharges
        .where((item) => item.name.trim().isNotEmpty || item.amount != 0)
        .toList(growable: false);
    final totalM2 = quote.lines.fold<double>(0, (s, l) => s + l.areaM2);
    final totalQty = quote.lines.fold<int>(0, (s, l) => s + l.quantity);

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QuoteHeader(
              factory: factory,
              quote: quote,
              customer: customer,
              settings: settings,
              logoBytes: logoBytes,
            ),
            const SizedBox(height: 8),
            _CustomerStrip(customer: customer),
            const SizedBox(height: 10),
            _QuoteTable(
              quote: quote,
              extras: extras,
              totalM2: totalM2,
              totalQty: totalQty,
            ),
            const SizedBox(height: 10),
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _CommentsPanel(
                    comments: quote.otherComments,
                    iban: factory?.iban,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: _TotalsPanel(quote: quote, extras: extras),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _QuoteHeader extends StatelessWidget {
  const _QuoteHeader({
    required this.factory,
    required this.quote,
    required this.customer,
    required this.settings,
    required this.logoBytes,
  });

  final FactoryProfile? factory;
  final OrderQuote quote;
  final CommercialOrderCustomerSnapshot customer;
  final CompanySettings settings;
  final Uint8List? logoBytes;

  @override
  Widget build(BuildContext context) {
    final phones = settings.pdfPhones;
    final phoneLine = phones.isEmpty
        ? [
            if ((factory?.phone ?? '').trim().isNotEmpty) factory!.phone!.trim(),
            if ((factory?.mobile ?? '').trim().isNotEmpty)
              factory!.mobile!.trim(),
          ].join('  |  ')
        : phones.map((item) => '${item.label}: ${item.phone}').join('  |  ');

    return Row(
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                factory?.nameEn ??
                    'Al-Mutawa Factory for Stainless Steel, Aluminum and Cladding Doors',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              if ((factory?.addressEn ?? factory?.addressAr ?? '')
                  .trim()
                  .isNotEmpty)
                Text(
                  (factory?.addressEn ?? factory?.addressAr)!.trim(),
                  style: const TextStyle(fontSize: 10, height: 1.3),
                ),
              if (phoneLine.isNotEmpty)
                Text(
                  phoneLine,
                  style: const TextStyle(fontSize: 10, height: 1.3),
                ),
              if ((factory?.website ?? '').trim().isNotEmpty)
                Text(
                  factory!.website.trim(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if ((factory?.instagram ?? '').trim().isNotEmpty)
                Text(
                  factory!.instagram.trim(),
                  style: const TextStyle(fontSize: 10),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: logoBytes == null
                ? const SizedBox.shrink()
                : Image.memory(
                    logoBytes!,
                    height: 158,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'عرض السعر المبدئي',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: DocumentPdfColors.teal,
                ),
              ),
              const Text(
                'Offer initial price',
                style: TextStyle(fontSize: 11, color: Color(0xFF555555)),
              ),
              if ((factory?.vatNumber ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  factory!.vatNumber!.trim(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: DocumentPdfColors.red,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              _MetaGrid(
                rows: [
                  (
                    'DATE / التاريخ',
                    QuotePdfPage.dateFmt.format(quote.quoteDate),
                  ),
                  ('Quotation # / رقم التسعيرة', '${quote.quoteNumber}'),
                  (
                    'CUSTOMER ID / رقم العميل',
                    '${customer.customerNumber}',
                  ),
                  if (quote.manufacturingDurationDays != null)
                    (
                      'مدة التصنيع / الأيام',
                      '${quote.manufacturingDurationDays}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DocumentPdfColors.hair),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              decoration: BoxDecoration(
                border: i == rows.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: DocumentPdfColors.hair),
                      ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: Text(
                      rows[i].$1,
                      style: const TextStyle(fontSize: 9),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Text(
                    rows[i].$2,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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

class _CustomerStrip extends StatelessWidget {
  const _CustomerStrip({required this.customer});

  final CommercialOrderCustomerSnapshot customer;

  @override
  Widget build(BuildContext context) {
    final address = [
      if ((customer.address ?? '').trim().isNotEmpty) customer.address!.trim(),
      if ((customer.governorate ?? '').trim().isNotEmpty)
        customer.governorate!.trim(),
    ].join(' — ');

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: DocumentPdfColors.teal,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          child: const Text(
            'بيانات العميل  /  Customer name',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: DocumentPdfColors.hair),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              _cell('اسم العميل', 'المحترم / ${customer.displayName}'),
              _cell('رقم الهاتف', customer.phone ?? '—'),
              _cell('العنوان', address.isEmpty ? '—' : address),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteTable extends StatelessWidget {
  const _QuoteTable({
    required this.quote,
    required this.extras,
    required this.totalM2,
    required this.totalQty,
  });

  final OrderQuote quote;
  final List<DocumentExtraCharge> extras;
  final double totalM2;
  final int totalQty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DocumentPdfColors.line, width: 0.7),
      ),
      child: Column(
        children: [
          Container(
            color: DocumentPdfColors.teal,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: const Row(
              textDirection: TextDirection.rtl,
              children: [
                _HeadCell('البيان DESCRIPTION', flex: 5),
                _HeadCell('(م2) اجمالي', flex: 2),
                _HeadCell('العدد QTY', flex: 2),
                _HeadCell('سعر المتر / UP', flex: 2),
                _HeadCell('المجموع TOTAL', flex: 2),
              ],
            ),
          ),
          if (quote.specsDescription.trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: DocumentPdfColors.hair),
                ),
              ),
              child: Text(
                quote.specsDescription.trim(),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 10, height: 1.35),
              ),
            ),
          for (var i = 0; i < quote.lines.length; i++)
            _line(i + 1, quote.lines[i], i.isOdd),
          for (final extra in extras) _extra(extra),
          Container(
            color: const Color(0xFFE7E7E7),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const _BodyCell('الإجمالي', flex: 5, align: TextAlign.right, bold: true),
                _BodyCell(
                  QuotePdfPage.numFmt.format(totalM2),
                  flex: 2,
                  bold: true,
                ),
                _BodyCell('$totalQty', flex: 2, bold: true),
                const _BodyCell('', flex: 2),
                const _BodyCell('', flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(int index, QuoteLine line, bool zebra) {
    final desc =
        '$index — ${line.description}\nالعرض: ${QuotePdfPage.numFmt.format(line.widthCm)} سم\nالارتفاع: ${QuotePdfPage.numFmt.format(line.heightCm)} سم';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: zebra ? DocumentPdfColors.zebra : Colors.white,
        border: const Border(
          bottom: BorderSide(color: DocumentPdfColors.hair),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BodyCell(desc, flex: 5, align: TextAlign.right),
          _BodyCell(QuotePdfPage.numFmt.format(line.areaM2), flex: 2),
          _BodyCell('${line.quantity}', flex: 2),
          _BodyCell(QuotePdfPage.numFmt.format(line.unitPrice), flex: 2),
          _BodyCell(
            QuotePdfPage.moneyFmt.format(line.lineTotal),
            flex: 2,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _extra(DocumentExtraCharge extra) {
    final name = extra.name.trim().isEmpty ? 'بند إضافي' : extra.name.trim();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: const BoxDecoration(
        color: Color(0xFFEEF6F6),
        border: Border(bottom: BorderSide(color: DocumentPdfColors.hair)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _BodyCell(name, flex: 5, align: TextAlign.right, bold: true),
          const _BodyCell('—', flex: 2),
          const _BodyCell('1', flex: 2),
          _BodyCell(QuotePdfPage.moneyFmt.format(extra.amount), flex: 2),
          _BodyCell(
            QuotePdfPage.moneyFmt.format(extra.amount),
            flex: 2,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell(this.text, {required this.flex});
  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(
    this.text, {
    required this.flex,
    this.align = TextAlign.center,
    this.bold = false,
  });

  final String text;
  final int flex;
  final TextAlign align;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

class _CommentsPanel extends StatelessWidget {
  const _CommentsPanel({required this.comments, required this.iban});

  final String comments;
  final String? iban;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: DocumentPdfColors.teal,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: const Text(
            'ملاحظات أخرى  /  OTHER COMMENTS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            border: Border.all(color: DocumentPdfColors.hair),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final line in comments.split('\n'))
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    line,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: line.toUpperCase().contains('IBAN')
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: line.toUpperCase().contains('IBAN')
                          ? DocumentPdfColors.red
                          : const Color(0xFF111111),
                    ),
                  ),
                ),
              if ((iban ?? '').trim().isNotEmpty &&
                  !comments.toUpperCase().contains(iban!.trim().toUpperCase()))
                Text(
                  'IBAN: ${iban!.trim()}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: DocumentPdfColors.red,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalsPanel extends StatelessWidget {
  const _TotalsPanel({required this.quote, required this.extras});

  final OrderQuote quote;
  final List<DocumentExtraCharge> extras;

  @override
  Widget build(BuildContext context) {
    final vatPct = (quote.vatRate * 100).toStringAsFixed(0);
    return Column(
      children: [
        _row('إجمالي البنود', QuotePdfPage.moneyFmt.format(quote.subtotal)),
        for (final extra in extras)
          _row(
            extra.name.trim().isEmpty ? 'بند إضافي' : extra.name.trim(),
            QuotePdfPage.moneyFmt.format(extra.amount),
          ),
        _row(
          'ضريبة القيمة المضافة $vatPct%',
          QuotePdfPage.moneyFmt.format(quote.vatAmount),
        ),
        if (quote.resolvedDiscountAmount > 0)
          _row(
            'الخصم (بعد الضريبة)',
            QuotePdfPage.moneyFmt.format(quote.resolvedDiscountAmount),
          ),
        _row(
          'الإجمالي بعد الضريبة SAR',
          QuotePdfPage.moneyFmt.format(quote.grandTotal),
          emphasize: true,
        ),
        if ((quote.totalInWords ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            quote.totalInWords!.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, height: 1.3),
          ),
        ],
      ],
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      color: emphasize ? DocumentPdfColors.teal : const Color(0xFFF3F3F3),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10,
                color: emphasize ? Colors.white : const Color(0xFF111111),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: emphasize ? Colors.white : const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}
