import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/layout/document_line_detail_sheet.dart';
import '../../../../core/shared/widgets/layout/document_lines_table.dart';
import '../../../../core/utils/dimension_cm.dart';
import '../../../../core/utils/sar_money.dart';
import '../../../../domain/entities/commercial_order.dart';

class AgreementViewLinesSection extends StatelessWidget {
  const AgreementViewLinesSection({super.key, required this.lines});

  final List<AgreementLine> lines;

  /// Aggregated line notes for [ExpandableNotesCard] on the viewer page.
  static String aggregatedNotes(List<AgreementLine> lines) {
    final parts = <String>[];
    for (final line in lines) {
      final note = line.notes?.trim();
      if (note == null || note.isEmpty) continue;
      parts.add('• ${line.description}: $note');
    }
    return parts.join('\n');
  }

  void _openDetail(BuildContext context, int index) {
    final line = lines[index];
    final w = line.widthCm;
    final h = line.heightCm;
    DocumentLineDetailSheet.show(
      context,
      title: 'تفاصيل البند ${index + 1}',
      subtitle: line.description.trim().isEmpty ? '—' : line.description.trim(),
      fields: [
        DocumentLineDetailField(
          label: 'البيان / الاسم',
          value: line.description.trim().isEmpty
              ? '—'
              : line.description.trim(),
        ),
        DocumentLineDetailField(
          label: 'اللون',
          value: (line.color == null || line.color!.trim().isEmpty)
              ? '—'
              : line.color!.trim(),
        ),
        DocumentLineDetailField(
          label: 'العرض',
          value: w == null ? '—' : DimensionCm.formatWithUnit(w),
        ),
        DocumentLineDetailField(
          label: 'الارتفاع',
          value: h == null ? '—' : DimensionCm.formatWithUnit(h),
        ),
        DocumentLineDetailField(
          label: 'المساحة',
          value: '${line.areaM2.toStringAsFixed(2)} م²',
        ),
        DocumentLineDetailField(
          label: 'العدد',
          value: line.quantity == null
              ? '—'
              : line.quantity!.toStringAsFixed(
                  line.quantity == line.quantity!.roundToDouble() ? 0 : 1,
                ),
        ),
        DocumentLineDetailField(
          label: 'سعر المتر',
          value: SarMoney.format(line.unitPrice),
        ),
        DocumentLineDetailField(
          label: 'إجمالي البند',
          value: SarMoney.format(line.lineTotal),
        ),
        DocumentLineDetailField(
          label: 'ملاحظات',
          value: (line.notes == null || line.notes!.trim().isEmpty)
              ? '—'
              : line.notes!.trim(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DocumentLinesTable(
      title: 'بنود الاتفاقية',
      hint: 'اضغط على أي بند لعرض الاسم والتفاصيل كاملة',
      columns: const ['البيان', 'اللون', 'المقاس', 'عدد', 'السعر', 'المجموع'],
      columnWidths: const [104, 56, 110, 36, 56, 64],
      onRowTap: (index) => _openDetail(context, index),
      rows: [
        for (final line in lines)
          DocumentLineTableRow(
            cells: [
              line.description.trim().isEmpty ? '—' : line.description.trim(),
              (line.color == null || line.color!.isEmpty) ? '—' : line.color!,
              _sizeLabel(line),
              line.quantity == null
                  ? '—'
                  : line.quantity!.toStringAsFixed(
                      line.quantity! == line.quantity!.roundToDouble() ? 0 : 1,
                    ),
              SarMoney.amount(line.unitPrice),
              SarMoney.amount(line.lineTotal),
            ],
          ),
      ],
    );
  }

  String _sizeLabel(AgreementLine line) {
    final w = line.widthCm;
    final h = line.heightCm;
    if (w == null || h == null) return '—';
    return DimensionCm.labeledWidthHeight(widthCm: w, heightCm: h);
  }
}
