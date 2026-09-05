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

class ProductionRecentWorkOrdersSection extends StatelessWidget {
  const ProductionRecentWorkOrdersSection({
    super.key,
    required this.items,
    required this.showSkeleton,
  });

  final List<CommercialOrderSummary> items;
  final bool showSkeleton;

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
                  onPressed: () => context.go(AppRoutes.productionOrders),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          if (!showSkeleton && items.isNotEmpty)
            ...items
                .take(2)
                .map(
                  (summary) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
                    child: WorkOrderListCard(
                      summary: summary,
                      onTap: () => context.push(
                        AppRoutes.workOrderDetailPath(
                          'production',
                          summary.order.id,
                        ),
                      ),
                    ),
                  ),
                )
          else if (!showSkeleton)
            const EmptyStateWidget(
              message: 'لا توجد طلبات عمل حالياً',
              icon: Icons.request_quote_outlined,
            ),
        ],
      ),
    );
  }
}
