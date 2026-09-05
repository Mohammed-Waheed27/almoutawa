import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sar_money.dart';
import '../../../../domain/entities/admin_report.dart';

class AdminReportsOrdersSection extends StatelessWidget {
  const AdminReportsOrdersSection({super.key, required this.rows});

  final List<AdminReportOrderRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Text(
        'لا توجد طلبات في الفترة المحددة',
        style: AppTypography.bodyMd().copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        textAlign: TextAlign.right,
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          for (final row in rows) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${row.orderNumber} · ${row.phaseLabel}',
                    style: AppTypography.labelBold(),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${row.customerName} · ${row.staffName ?? '—'} · ${row.factoryName ?? 'بدون مصنع'}',
                    style: AppTypography.caption().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 2),
                  Text(
                    SarMoney.format(row.orderValue),
                    style: AppTypography.labelBold().copyWith(
                      color: AppColors.onPrimaryFixedVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
