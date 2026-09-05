import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/desktop_master_list_tile.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../routes/app_routes.dart';
import '../../work_orders/widgets/work_order_list_card.dart';

class DeliveryRecentWorkOrdersSection extends StatelessWidget {
  const DeliveryRecentWorkOrdersSection({
    super.key,
    required this.items,
    required this.showSkeleton,
  });

  final List<CommercialOrderSummary> items;
  final bool showSkeleton;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
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
                    fontSize: dense ? DesktopUiTokens.pageTitle - 1 : null,
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
                  onPressed: () => context.go(AppRoutes.deliveryOrders),
                ),
            ],
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
          if (!showSkeleton && items.isNotEmpty)
            ...items.take(dense ? 4 : 2).map((summary) {
              if (dense) {
                return DesktopMasterListTile(
                  title: summary.order.orderNumber,
                  subtitle:
                      '${summary.customer.displayName} · ${summary.order.phase.arabicLabel}',
                  trailing: Icon(
                    Icons.chevron_left_rounded,
                    size: DesktopUiTokens.iconSize,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onTap: () => context.push(
                    AppRoutes.workOrderDetailPath('delivery', summary.order.id),
                  ),
                );
              }
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
                child: WorkOrderListCard(
                  summary: summary,
                  onTap: () => context.push(
                    AppRoutes.workOrderDetailPath('delivery', summary.order.id),
                  ),
                ),
              );
            })
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
