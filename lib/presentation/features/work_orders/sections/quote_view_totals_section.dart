import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/layout/info_panel_section.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/commercial_order.dart';

class QuoteViewTotalsSection extends StatelessWidget {
  const QuoteViewTotalsSection({super.key, required this.quote});

  final OrderQuote quote;

  @override
  Widget build(BuildContext context) {
    return InfoPanelSection(
      title: 'الملخص المالي',
      compact: true,
      rows: [
        InfoPanelRow(
          label: 'إجمالي البنود',
          value: quote.subtotal.toStringAsFixed(2),
        ),
        for (final extra in quote.extraCharges.where(
          (item) => item.name.trim().isNotEmpty || item.amount != 0,
        ))
          InfoPanelRow(
            label: extra.name.trim().isEmpty
                ? 'مصروف إضافي'
                : extra.name.trim(),
            value: extra.amount.toStringAsFixed(2),
          ),
        InfoPanelRow(
          label: 'ضريبة ${(quote.vatRate * 100).toStringAsFixed(0)}%',
          value: quote.vatAmount.toStringAsFixed(2),
        ),
        if (quote.resolvedDiscountAmount > 0)
          InfoPanelRow(
            label: 'خصم',
            value: quote.resolvedDiscountAmount.toStringAsFixed(2),
          ),
        InfoPanelRow(
          label: 'الإجمالي',
          value: quote.grandTotal.toStringAsFixed(2),
          highlight: true,
          valueColor: AppColors.onPrimaryFixedVariant,
        ),
        if (quote.manufacturingDurationDays != null)
          InfoPanelRow(
            label: 'مدة التصنيع',
            value: '${quote.manufacturingDurationDays} يوم',
          ),
        if (quote.totalInWords != null && quote.totalInWords!.isNotEmpty)
          InfoPanelRow(label: 'تفقيط', value: quote.totalInWords!),
      ],
    );
  }
}
