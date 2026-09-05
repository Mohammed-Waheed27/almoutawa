import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/layout/hub_operation_tile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../routes/app_routes.dart';

class DeliveryOperationsSection extends StatelessWidget {
  const DeliveryOperationsSection({
    super.key,
    required this.readyCount,
    required this.onRefresh,
  });

  final int readyCount;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'العمليات',
            style: AppTypography.headlineSm().copyWith(
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          HubOperationTile(
            title: 'الطلبات الجاهزة',
            subtitle: 'استلام وتسليم الطلبات الجاهزة للتوصيل',
            icon: Icons.receipt_long_outlined,
            accentColor: AppColors.secondary,
            badge: readyCount > 0 ? '$readyCount' : null,
            onTap: () => context.go(AppRoutes.deliveryOrders),
          ),
          SizedBox(height: AppSpacing.stackGap),
          HubOperationTile(
            title: 'العملاء',
            subtitle: 'عرض العملاء وإضافة عميل جديد',
            icon: Icons.people_outline_rounded,
            accentColor: AppColors.onTertiaryContainer,
            onTap: () => context.go(AppRoutes.deliveryCustomers),
          ),
          SizedBox(height: AppSpacing.stackGap),
          HubOperationTile(
            title: 'تحديث البيانات',
            subtitle: 'مزامنة قائمة الطلبات من الخادم',
            icon: Icons.refresh_rounded,
            accentColor: AppColors.primaryContainer,
            onTap: onRefresh,
          ),
        ],
      ),
    );
  }
}
