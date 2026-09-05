import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sar_money.dart';
import '../../../../domain/entities/commercial_order.dart';

/// Compact financial summary strip matching PDF totals block.
class QuoteFormTotalsSection extends StatelessWidget {
  const QuoteFormTotalsSection({super.key, required this.draft});

  final QuoteDraft draft;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: AppColors.secondaryFixed.withValues(alpha: 0.75),
          ),
        ),
        child: Column(
          children: [
            _TotalRow(label: 'إجمالي البنود', value: draft.subtotal),
            for (final extra in draft.extraCharges.where(
              (item) => item.name.trim().isNotEmpty || item.amount != 0,
            ))
              _TotalRow(
                label: extra.name.trim().isEmpty
                    ? 'مصروف إضافي'
                    : extra.name.trim(),
                value: extra.amount,
              ),
            _TotalRow(
              label: 'ضريبة ${(draft.vatRate * 100).toStringAsFixed(0)}%',
              value: draft.vatAmount,
            ),
            if (draft.discountAmount > 0)
              _TotalRow(label: 'خصم بعد الضريبة', value: draft.discountAmount),
            Divider(height: AppSpacing.sm, color: AppColors.outlineVariant),
            _TotalRow(
              label: 'الإجمالي النهائي',
              value: draft.grandTotal,
              emphasize: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? AppTypography.labelBold().copyWith(
            color: AppColors.onPrimaryFixedVariant,
            fontWeight: FontWeight.w800,
          )
        : AppTypography.caption().copyWith(color: AppColors.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(child: Text(label, style: style)),
          Text(SarMoney.format(value), style: style),
        ],
      ),
    );
  }
}
