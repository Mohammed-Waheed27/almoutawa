import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/stats_bento_tile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/sar_money.dart';
import '../../../../domain/entities/admin_report.dart';

class AdminReportsOverviewSection extends StatelessWidget {
  const AdminReportsOverviewSection({super.key, required this.overview});

  final AdminReportsOverview overview;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.mini,
                  label: 'إجمالي الطلبات',
                  value: '${overview.ordersTotal}',
                  icon: Icons.assignment_outlined,
                  iconColor: AppColors.onPrimaryFixedVariant,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.mini,
                  label: 'مكتملة',
                  value: '${overview.ordersCompleted}',
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.mini,
                  label: 'قيد التصنيع',
                  value: '${overview.ordersManufacturing}',
                  icon: Icons.precision_manufacturing_outlined,
                  iconColor: AppColors.onTertiaryContainer,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.mini,
                  label: 'ملغاة',
                  value: '${overview.ordersCancelled}',
                  icon: Icons.cancel_outlined,
                  iconColor: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.mini,
                  label: 'مسودة تصنيع',
                  value: '${overview.ordersManufacturingDraft}',
                  icon: Icons.edit_note_outlined,
                  iconColor: AppColors.outline,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.mini,
                  label: 'تم التسليم',
                  value: '${overview.ordersDelivered}',
                  icon: Icons.local_shipping_outlined,
                  iconColor: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.mini,
                  label: 'عملاء نشطون',
                  value: '${overview.activeCustomers}',
                  icon: Icons.groups_outlined,
                  iconColor: AppColors.onPrimaryFixedVariant,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.mini,
                  label: 'موظفون نشطون',
                  value: '${overview.activeStaff}',
                  icon: Icons.badge_outlined,
                  iconColor: AppColors.onTertiaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.compact,
                  label: 'قيمة الاتفاقيات',
                  value: SarMoney.amount(overview.agreementValue),
                  icon: Icons.payments_outlined,
                  iconColor: AppColors.success,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.compact,
                  label: 'الدفعات المقدمة',
                  value: SarMoney.amount(overview.downPayments),
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.onPrimaryFixedVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.mini,
                  label: 'عروض أسعار',
                  value: '${overview.ordersQuote}',
                  icon: Icons.request_quote_outlined,
                  iconColor: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatsBentoTile(
                  size: StatsBentoTileSize.mini,
                  label: 'اتفاقيات',
                  value: '${overview.ordersAgreement}',
                  icon: Icons.handshake_outlined,
                  iconColor: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminReportsOverviewSkeleton extends StatelessWidget {
  const AdminReportsOverviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const fake = AdminReportsOverview(
      ordersTotal: 12,
      ordersQuote: 3,
      ordersAgreement: 2,
      ordersManufacturing: 4,
      ordersManufacturingDraft: 1,
      ordersCompleted: 2,
      ordersDelivered: 1,
      ordersCancelled: 1,
      quoteValue: 10000,
      agreementValue: 20000,
      downPayments: 5000,
      activeCustomers: 5,
      activeStaff: 3,
    );
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: AppColors.surfaceContainer,
        highlightColor: AppColors.surfaceContainerHighest,
      ),
      child: const AdminReportsOverviewSection(overview: fake),
    );
  }
}
