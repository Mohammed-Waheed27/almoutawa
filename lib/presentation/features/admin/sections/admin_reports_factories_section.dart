import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sar_money.dart';
import '../../../../domain/entities/admin_report.dart';

class AdminReportsFactoriesSection extends StatelessWidget {
  const AdminReportsFactoriesSection({super.key, required this.orders});

  final List<AdminReportOrderRow> orders;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, _FactoryAgg>{};
    for (final order in orders) {
      final key = order.factoryId ?? 'unassigned';
      final agg = grouped.putIfAbsent(
        key,
        () => _FactoryAgg(name: order.factoryName ?? 'بدون مصنع'),
      );
      agg.orders += 1;
      agg.value += order.orderValue;
      if (order.phase == 'manufacturing' ||
          order.phase == 'manufacturing_draft') {
        agg.inProduction += 1;
      }
      if (order.phase == 'completed') agg.completed += 1;
      if (order.phase == 'delivered') agg.delivered += 1;
    }

    if (grouped.isEmpty) {
      return Text(
        'لا توجد بيانات مصانع في الفترة المحددة',
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
          for (final factory in grouped.values) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    factory.name,
                    style: AppTypography.titleSm(),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'الطلبات: ${factory.orders} · قيد التصنيع: ${factory.inProduction} · مكتمل: ${factory.completed} · تسليم: ${factory.delivered}',
                    style: AppTypography.caption().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    SarMoney.format(factory.value),
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

class _FactoryAgg {
  _FactoryAgg({required this.name});

  final String name;
  int orders = 0;
  int inProduction = 0;
  int completed = 0;
  int delivered = 0;
  double value = 0;
}
