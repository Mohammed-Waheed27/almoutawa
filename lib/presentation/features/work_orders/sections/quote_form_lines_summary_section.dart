import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/layout/document_line_detail_sheet.dart';
import '../../../../core/shared/widgets/layout/document_lines_table.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/dimension_cm.dart';
import '../../../../core/utils/sar_money.dart';
import '../../../../domain/entities/commercial_order.dart';

/// Read-only summary of all quote بنود — mirrors viewer table before save.
class QuoteFormLinesSummarySection extends StatelessWidget {
  const QuoteFormLinesSummarySection({super.key, required this.lines});

  final List<QuoteLineDraft> lines;

  void _openDetail(
    BuildContext context,
    List<QuoteLineDraft> filled,
    int index,
  ) {
    final line = filled[index];
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filled = lines
        .where((l) => l.description.trim().isNotEmpty || l.lineTotal > 0)
        .toList(growable: false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ملخص البنود',
            style: AppTypography.titleSm().copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            filled.isEmpty
                ? 'أضف بنوداً أعلاه لعرض الملخص هنا'
                : '${filled.length} بند — اضغط على الصف لعرض التفاصيل',
            style: AppTypography.caption().copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: AppSpacing.sm),
          DocumentLinesTable(
            title: 'بنود عرض السعر',
            hint: 'اضغط على أي بند لعرض الاسم والتفاصيل كاملة',
            columns: const [
              'البيان',
              'عرض سم',
              'ارتفاع سم',
              'م²',
              'عدد',
              'سعر ر.س',
              'إجمالي ر.س',
            ],
            columnWidths: const [100, 56, 56, 44, 36, 64, 72],
            onRowTap: filled.isEmpty
                ? null
                : (index) => _openDetail(context, filled, index),
            rows: [
              for (final line in filled)
                DocumentLineTableRow(
                  cells: [
                    line.description.trim().isEmpty ? '—' : line.description,
                    DimensionCm.format(line.widthCm).ifEmpty('—'),
                    DimensionCm.format(line.heightCm).ifEmpty('—'),
                    line.areaM2.toStringAsFixed(2),
                    '${line.quantity}',
                    SarMoney.amount(line.unitPrice),
                    SarMoney.amount(line.lineTotal),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
