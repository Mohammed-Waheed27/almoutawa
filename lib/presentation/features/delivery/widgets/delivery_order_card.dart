import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/delivery_order.dart';

class DeliveryOrderCard extends StatelessWidget {
  const DeliveryOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final DeliveryOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final timeLabel = order.readyAt != null
        ? DateFormat('hh:mm a', 'ar').format(order.readyAt!)
        : '—';
    final phoneLabel = order.customerPhone.isNotEmpty
        ? order.customerPhone
        : 'لا يوجد هاتف';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlmoutawaCard(
        variant: AlmoutawaCardVariant.tinted,
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: const Icon(
                      Icons.door_front_door_outlined,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طلب ${order.orderNumber}',
                          style: AppTypography.titleMd().copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          order.customerName,
                          style: AppTypography.bodyMd().copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          order.customerAddress,
                          style: AppTypography.bodyMd().copyWith(
                            color: AppColors.outline,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          order.status.arabicLabel,
                          style: AppTypography.captionBold().copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      const Icon(
                        Icons.arrow_back_ios_new,
                        size: 14,
                        color: AppColors.outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceContainer),
            SizedBox(
              height: AppLayout.listRowMinHeight * 0.65,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: _StatCell(label: 'الوقت', value: timeLabel),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: AppColors.surfaceContainer,
                  ),
                  Expanded(
                    child: _StatCell(label: 'الهاتف', value: phoneLabel),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: AppColors.surfaceContainer,
                  ),
                  Expanded(
                    child: _StatCell(
                      label: 'الحالة',
                      value: order.status.arabicLabel,
                      valueColor: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTypography.caption().copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.captionBold().copyWith(
            color: valueColor ?? AppColors.primary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
