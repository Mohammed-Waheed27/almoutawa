import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../domain/entities/commercial_order.dart';
import '../../../domain/entities/company_settings.dart';
import '../document_pdf_colors.dart';

class AgreementPdfPage extends StatelessWidget {
  const AgreementPdfPage({
    super.key,
    required this.detail,
    required this.settings,
    this.logoBytes,
  });

  final CommercialOrderDetail detail;
  final CompanySettings settings;
  final Uint8List? logoBytes;

  static final dateFmt = DateFormat('dd / MM / yyyy');
  static final numFmt = NumberFormat('#,##0.##', 'en');
  static final moneyFmt = NumberFormat('#,##0', 'en');

  @override
  Widget build(BuildContext context) {
    final agreement = detail.agreement!;
    final factory = detail.factory;
    final extras = agreement.extraCharges;
    final remaining = (agreement.grandTotal - agreement.downPayment).clamp(
      0,
      double.infinity,
    );
    final phones = settings.pdfPhones;
    final phoneLine = phones.isEmpty
        ? [
            if ((factory?.phone ?? '').trim().isNotEmpty)
              factory!.phone!.trim(),
            if ((factory?.mobile ?? '').trim().isNotEmpty)
              factory!.mobile!.trim(),
          ].join(' - ')
        : phones.map((item) => item.phone).join(' - ');
    final factoryAr = factory?.nameAr ?? 'ورشة محمد ياسين المطاوعة للحدادة';

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factory?.nameEn ??
                            'Mohamed Yassin Al Mutawa Blacksmith Workshop',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: DocumentPdfColors.navy,
                          height: 1.3,
                        ),
                      ),
                      if ((factory?.commercialRegister ?? '').trim().isNotEmpty)
                        Text(
                          'C.R : ${factory!.commercialRegister}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: DocumentPdfColors.navy,
                          ),
                        ),
                      if ((factory?.vatNumber ?? '').trim().isNotEmpty)
                        Text(
                          'VAT No.: ${factory!.vatNumber}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: DocumentPdfColors.navy,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 176,
                  height: 142,
                  child: logoBytes == null
                      ? const SizedBox.shrink()
                      : Image.memory(
                          logoBytes!,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        factoryAr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: DocumentPdfColors.navy,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      if ((factory?.commercialRegister ?? '').trim().isNotEmpty)
                        Text(
                          'س.ت : ${factory!.commercialRegister}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: DocumentPdfColors.navy,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      if ((factory?.vatNumber ?? '').trim().isNotEmpty)
                        Text(
                          'الرقم الضريبي : ${factory!.vatNumber}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: DocumentPdfColors.navy,
                          ),
                          textAlign: TextAlign.right,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: DocumentPdfColors.navy, width: 1.6),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  'اتفاقية عمل',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: DocumentPdfColors.navy,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'تم الاتفاق بين كل من:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        'الطرف الأول: $factoryAr',
                        style: const TextStyle(fontSize: 11, height: 1.35),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        'الطرف الثاني / العميل: ${detail.customer.displayName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'No. ${agreement.agreementNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: DocumentPdfColors.red,
                        ),
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                      ),
                      Text(
                        'التاريخ: ${dateFmt.format(agreement.agreementDate)}',
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ClientMetaStrip(
              name: detail.customer.displayName,
              city: agreement.clientCity,
              phone: detail.customer.phone,
              vat: agreement.clientVatNumber,
            ),
            const SizedBox(height: 8),
            const Text(
              'على أن يقوم الطرف الأول بعمل الآتي:',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            _AgreementTable(agreement: agreement, extras: extras),
            const SizedBox(height: 10),
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _rich(
                        'بقيمة إجمالية قدرها : ',
                        '${moneyFmt.format(agreement.grandTotal)} ريال',
                      ),
                      _rich(
                        'وقد قام الطرف الثاني بدفع مبلغ وقدره : ',
                        '${moneyFmt.format(agreement.downPayment)} ريال',
                      ),
                      if ((agreement.receiptReference ?? '').trim().isNotEmpty)
                        _rich(
                          'بسند رقم : ',
                          agreement.receiptReference!.trim(),
                        ),
                      _rich('المتبقي : ', '${moneyFmt.format(remaining)} ريال'),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _moneyRow('القيمة', agreement.subtotal),
                      for (final extra in extras)
                        _moneyRow(
                          extra.name.trim().isEmpty
                              ? 'بند إضافي'
                              : extra.name.trim(),
                          extra.amount,
                        ),
                      _moneyRow(
                        'ضريبة القيمة المضافة ${(agreement.vatRate * 100).toStringAsFixed(0)} %',
                        agreement.vatAmount,
                      ),
                      if (agreement.discountAmount > 0)
                        _moneyRow(
                          'الخصم (بعد الضريبة)',
                          agreement.discountAmount,
                        ),
                      _moneyRow('الإجمالي', agreement.grandTotal, strong: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'وبتوقيع الطرفين على هذه الاتفاقية يعتبر الطرفان موافقين على كافة الشروط والأحكام المذكورة أدناه وفي الصفحة التالية والتزامهما بها.',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: _SignBlock(
                    title: 'الطرف الأول / $factoryAr',
                    nameLine:
                        'المندوب / ${detail.createdBy?.displayName ?? '........................'}',
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: _SignBlock(
                    title: 'الطرف الثاني / العميل',
                    nameLine: 'الاسم / ${detail.customer.displayName}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              agreement.manufacturingDays == null
                  ? 'مدة التصنيع: ........ يوم عمل من تاريخ اعتماد المخطط والدفعة المقدمة، ويبدأ العمل بعد اعتماد المخطط.'
                  : 'مدة التصنيع: ${agreement.manufacturingDays} يوم عمل من تاريخ اعتماد المخطط والدفعة المقدمة، ويبدأ العمل بعد اعتماد المخطط.',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const Text(
              'يتم حجز موعد التسليم خلال ٧ أيام عمل من استلام الدفعة الأخيرة.',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              color: DocumentPdfColors.navy,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                '${(factory?.addressAr ?? 'شارع الملك عبدالعزيز - حي الخضرية - الدمام')}   $phoneLine\n'
                '${(factory?.addressEn ?? 'King Abdulaziz Street - Khodariya Area - Dammam')}   $phoneLine',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _rich(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: label, style: const TextStyle(fontSize: 11)),
            TextSpan(
              text: value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  static Widget _moneyRow(String label, double value, {bool strong = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: strong ? DocumentPdfColors.navySoft : Colors.white,
        border: Border.all(color: DocumentPdfColors.navy, width: 0.7),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            moneyFmt.format(value),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ClientMetaStrip extends StatelessWidget {
  const _ClientMetaStrip({
    required this.name,
    required this.city,
    required this.phone,
    required this.vat,
  });

  final String name;
  final String? city;
  final String? phone;
  final String? vat;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DocumentPdfColors.navy, width: 0.9),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _metaCell('الطرف الثاني / العميل', name, flex: 4),
          _metaCell('المدينة', city?.trim().isNotEmpty == true ? city! : '—'),
          _metaCell('الجوال', phone?.trim().isNotEmpty == true ? phone! : '—'),
          _metaCell(
            'الرقم الضريبي',
            vat?.trim().isNotEmpty == true ? vat! : '—',
          ),
        ],
      ),
    );
  }

  Widget _metaCell(String label, String value, {int flex = 3}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: DocumentPdfColors.navy, width: 0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: DocumentPdfColors.navy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignBlock extends StatelessWidget {
  const _SignBlock({required this.title, required this.nameLine});

  final String title;
  final String nameLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          nameLine,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: DocumentPdfColors.line,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgreementTable extends StatelessWidget {
  const _AgreementTable({required this.agreement, required this.extras});

  final OrderAgreement agreement;
  final List<DocumentExtraCharge> extras;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: DocumentPdfColors.navy, width: 0.7),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(5),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(2),
        5: FlexColumnWidth(2),
        6: FlexColumnWidth(2),
        7: FlexColumnWidth(3),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: DocumentPdfColors.navy),
          children: const [
            _HeadCell('م'),
            _HeadCell('البيان'),
            _HeadCell('الكمية'),
            _HeadCell('اللون'),
            _HeadCell('العرض /سم'),
            _HeadCell('الارتفاع /سم'),
            _HeadCell('السعر م²'),
            _HeadCell('الملاحظات'),
          ],
        ),
        for (var i = 0; i < agreement.lines.length; i++)
          _line(i + 1, agreement.lines[i]),
        for (var i = 0; i < extras.length; i++)
          _extra(agreement.lines.length + i + 1, extras[i]),
      ],
    );
  }

  TableRow _line(int index, AgreementLine line) {
    return _row(
      index: index,
      description: line.description,
      qty: line.quantity == null
          ? '—'
          : AgreementPdfPage.numFmt.format(line.quantity),
      color: (line.color ?? '').trim().isEmpty ? '—' : line.color!,
      width: line.widthCm == null
          ? '—'
          : AgreementPdfPage.numFmt.format(line.widthCm),
      height: line.heightCm == null
          ? '—'
          : AgreementPdfPage.numFmt.format(line.heightCm),
      price: AgreementPdfPage.numFmt.format(line.unitPrice),
      notes: (line.notes ?? '').trim().isEmpty ? '—' : line.notes!,
    );
  }

  TableRow _extra(int index, DocumentExtraCharge extra) {
    return _row(
      index: index,
      description: extra.name.trim().isEmpty ? 'بند إضافي' : extra.name.trim(),
      qty: '1',
      color: '—',
      width: '—',
      height: '—',
      price: AgreementPdfPage.moneyFmt.format(extra.amount),
      notes: 'تكلفة إضافية',
    );
  }

  TableRow _row({
    required int index,
    required String description,
    required String qty,
    required String color,
    required String width,
    required String height,
    required String price,
    required String notes,
  }) {
    return TableRow(
      children: [
        _C('$index'),
        _C(description, align: TextAlign.right),
        _C(qty),
        _C(color),
        _C(width),
        _C(height),
        _C(price),
        _C(notes, align: TextAlign.right),
      ],
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _C extends StatelessWidget {
  const _C(this.text, {this.align = TextAlign.center});
  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(fontSize: 10.5, height: 1.3),
      ),
    );
  }
}
