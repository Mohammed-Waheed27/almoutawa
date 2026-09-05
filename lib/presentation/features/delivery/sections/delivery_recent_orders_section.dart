import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/delivery_order.dart';
import '../../../routes/app_routes.dart';
import '../widgets/delivery_order_card.dart';
import '../widgets/delivery_orders_preview_skeleton.dart';

class DeliveryRecentOrdersSection extends StatelessWidget {
  const DeliveryRecentOrdersSection({
    super.key,
    required this.orders,
    required this.showSkeleton,
  });

  final List<DeliveryOrder> orders;
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
                  'أحدث الطلبات',
                  style: AppTypography.titleMd().copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (orders.isNotEmpty)
                AlmoutawaButton(
                  label: 'عرض الكل',
                  variant: AlmoutawaButtonVariant.tertiaryText,
                  size: AlmoutawaButtonSize.sm,
                  expanded: false,
                  onPressed: () => context.go(AppRoutes.deliveryOrders),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          if (showSkeleton)
            const DeliveryOrdersPreviewSkeleton()
          else if (orders.isNotEmpty)
            ...orders
                .take(2)
                .map(
                  (order) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
                    child: DeliveryOrderCard(
                      order: order,
                      onTap: () => context.push(
                        AppRoutes.deliveryOrderDetailPath(order.id),
                      ),
                    ),
                  ),
                )
          else if (!showSkeleton)
            const EmptyStateWidget(
              message: 'لا توجد طلبات جاهزة حالياً',
              icon: Icons.inventory_2_outlined,
            ),
        ],
      ),
    );
  }
}
