import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../routes/app_routes.dart';
import '../../work_orders/widgets/work_order_list_card.dart';

/// Compact (mobile) recent commercial orders on the admin home hub.
class AdminRecentWorkOrdersSection extends StatelessWidget {
  const AdminRecentWorkOrdersSection({
    super.key,
    required this.items,
    this.maxPreview = 3,
  });

  final List<CommercialOrderSummary> items;
  final int maxPreview;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  'أحدث طلبات العمل',
                  style: AppTypography.titleMd().copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (items.isNotEmpty)
                AlmoutawaButton(
                  label: 'عرض الكل',
                  variant: AlmoutawaButtonVariant.tertiaryText,
                  size: AlmoutawaButtonSize.sm,
                  expanded: false,
                  onPressed: () => context.push(AppRoutes.adminWorkOrders),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          if (items.isEmpty)
            const EmptyStateWidget(
              message: 'لا توجد طلبات عمل حالياً',
              icon: Icons.request_quote_outlined,
            )
          else
            ...items.take(maxPreview).map(
              (summary) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
                child: WorkOrderListCard(
                  summary: summary,
                  onTap: () => context.push(
                    AppRoutes.workOrderDetailPath('admin', summary.order.id),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
