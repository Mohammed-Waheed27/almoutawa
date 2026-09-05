import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/layout/document_line_detail_sheet.dart';
import '../../../../core/shared/widgets/layout/document_lines_table.dart';
import '../../../../core/utils/dimension_cm.dart';
import '../../../../core/utils/sar_money.dart';
import '../../../../domain/entities/commercial_order.dart';

class QuoteViewLinesSection extends StatelessWidget {
  const QuoteViewLinesSection({super.key, required this.lines});

  final List<QuoteLine> lines;

  void _openDetail(BuildContext context, int index) {
    final line = lines[index];
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
          label: 'العرض',
          value: DimensionCm.formatWithUnit(line.widthCm),
        ),
        DocumentLineDetailField(
          label: 'الارتفاع',
          value: DimensionCm.formatWithUnit(line.heightCm),
        ),
        DocumentLineDetailField(
          label: 'المساحة',
          value: '${line.areaM2.toStringAsFixed(2)} م²',
        ),
        DocumentLineDetailField(label: 'العدد', value: '${line.quantity}'),
        DocumentLineDetailField(
          label: 'سعر المتر',
          value: SarMoney.format(line.unitPrice),
        ),
        DocumentLineDetailField(
          label: 'إجمالي البند',
          value: SarMoney.format(line.lineTotal),
        ),
        if (line.productId != null && line.productId!.isNotEmpty)
          DocumentLineDetailField(label: 'مرتبط بمنتج', value: 'نعم'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DocumentLinesTable(
      title: 'بنود العرض',
      hint: 'اضغط على أي بند لعرض الاسم والتفاصيل كاملة',
      columns: const ['البيان', 'المقاس', 'م²', 'عدد', 'السعر', 'المجموع'],
      columnWidths: const [112, 110, 44, 36, 56, 64],
      onRowTap: (index) => _openDetail(context, index),
      rows: [
        for (final line in lines)
          DocumentLineTableRow(
            cells: [
              line.description.trim().isEmpty ? '—' : line.description.trim(),
              DimensionCm.labeledWidthHeight(
                widthCm: line.widthCm,
                heightCm: line.heightCm,
              ),
              line.areaM2.toStringAsFixed(2),
              '${line.quantity}',
              SarMoney.amount(line.unitPrice),
              SarMoney.amount(line.lineTotal),
            ],
          ),
      ],
    );
  }
}
