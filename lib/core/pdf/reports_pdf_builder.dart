import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/admin_report.dart';
import '../../domain/entities/customer.dart';
import 'pdf_font_loader.dart';

class ReportsPdfBuilder {
  static final _dateFmt = DateFormat('dd/MM/yyyy');
  static final _moneyFmt = NumberFormat('#,##0.##', 'en');

  Future<Uint8List> buildBundle(AdminReportsBundle bundle) async {
    final fonts = await PdfFontLoader.load();
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
    );
    final overview = bundle.overview;
    final orders = bundle.orders;
    final periodLabel = _periodLabel(bundle.range);

    final byStaff = <String, List<AdminReportOrderRow>>{};
    final byCustomer = <String, List<AdminReportOrderRow>>{};
    for (final row in orders) {
      final staffKey = (row.staffName ?? '').trim().isEmpty
          ? 'بدون مندوب'
          : row.staffName!.trim();
      byStaff.putIfAbsent(staffKey, () => []).add(row);
      final customerKey = row.customerName.trim().isEmpty
          ? 'بدون عميل'
          : row.customerName.trim();
      byCustomer.putIfAbsent(customerKey, () => []).add(row);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Text(
            'تقرير النظام',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.right,
          ),
          pw.Text(
            'الفترة: $periodLabel',
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.right,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'إجمالي الطلبات: ${overview.ordersTotal}',
            textAlign: pw.TextAlign.right,
          ),
          pw.Text(
            'عرض سعر: ${overview.ordersQuote} · اتفاقية: ${overview.ordersAgreement} · مسودة: ${overview.ordersManufacturingDraft}',
            textAlign: pw.TextAlign.right,
          ),
          pw.Text(
            'قيد التصنيع: ${overview.ordersManufacturing} · مكتمل: ${overview.ordersCompleted} · تسليم: ${overview.ordersDelivered} · ملغي: ${overview.ordersCancelled}',
            textAlign: pw.TextAlign.right,
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'الموظفون',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.right,
          ),
          if (byStaff.isEmpty)
            pw.Text('لا توجد طلبات في الفترة', textAlign: pw.TextAlign.right)
          else
            for (final entry in byStaff.entries) ...[
              pw.SizedBox(height: 6),
              pw.Text(
                '${entry.key} — ${entry.value.length} طلب',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.right,
              ),
              pw.Text(
                entry.value.map((row) => row.orderNumber).join(' · '),
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.right,
              ),
            ],
          pw.SizedBox(height: 12),
          pw.Text(
            'العملاء',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.right,
          ),
          if (byCustomer.isEmpty)
            pw.Text('لا توجد طلبات في الفترة', textAlign: pw.TextAlign.right)
          else
            for (final entry in byCustomer.entries) ...[
              pw.SizedBox(height: 6),
              pw.Text(
                '${entry.key} — ${entry.value.length} طلب',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.right,
              ),
              pw.Text(
                entry.value.map((row) => row.orderNumber).join(' · '),
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.right,
              ),
            ],
          pw.SizedBox(height: 12),
          pw.Text(
            'كل الطلبات',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.right,
          ),
          for (final row in orders)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(
                '${row.orderNumber} · ${row.phaseLabel} · ${row.customerName} · ${row.staffName ?? '—'} · ${_moneyFmt.format(row.orderValue)}',
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.right,
              ),
            ),
        ],
      ),
    );
    return doc.save();
  }

  String _periodLabel(AdminReportDateRange range) {
    if (range.period == AdminReportPeriod.custom &&
        range.from != null &&
        range.to != null) {
      return '${_dateFmt.format(range.from!)} — ${_dateFmt.format(range.to!)}';
    }
    return range.period.arabicLabel;
  }

  Future<Uint8List> buildCustomerStatement({
    required Customer customer,
    required List<CustomerAccountEntry> entries,
    required double balance,
  }) async {
    final fonts = await PdfFontLoader.load();
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Text(
            'كشف حساب العميل',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.right,
          ),
          pw.SizedBox(height: 6),
          pw.Text(customer.displayName, textAlign: pw.TextAlign.right),
          pw.Text(
            'الرصيد: ${_moneyFmt.format(balance)}',
            textAlign: pw.TextAlign.right,
          ),
          pw.SizedBox(height: 10),
          for (final entry in entries)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                '${_dateFmt.format(entry.occurredAt)} · ${entry.description} · ${_moneyFmt.format(entry.amount)}',
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.right,
              ),
            ),
        ],
      ),
    );
    return doc.save();
  }
}
