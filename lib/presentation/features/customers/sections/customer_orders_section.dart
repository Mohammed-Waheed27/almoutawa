import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../widgets/customer_order_row.dart';

class CustomerOrdersSection extends StatelessWidget {
  const CustomerOrdersSection({
    super.key,
    required this.orders,
    required this.onOrderTap,
  });

  final List<CommercialOrderSummary> orders;
  final ValueChanged<String> onOrderTap;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'طلبات العمل',
            style: AppTypography.headlineSm().copyWith(
              fontSize: dense ? DesktopUiTokens.pageTitle : null,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapMd : AppSpacing.md),
          if (orders.isEmpty)
            Text(
              'لا توجد طلبات عمل لهذا العميل',
              style: AppTypography.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: dense ? DesktopUiTokens.body : null,
              ),
            )
          else
            ...orders.map(
              (summary) => Padding(
                padding: EdgeInsets.only(
                  bottom: dense ? DesktopUiTokens.gapSm : AppSpacing.stackGap,
                ),
                child: CustomerOrderRow(
                  summary: summary,
                  onTap: () => onOrderTap(summary.order.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
