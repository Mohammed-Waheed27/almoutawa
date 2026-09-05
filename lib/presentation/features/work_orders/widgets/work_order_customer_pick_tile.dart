import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/customer.dart';

class WorkOrderCustomerPickTile extends StatelessWidget {
  const WorkOrderCustomerPickTile({
    super.key,
    required this.customer,
    required this.selected,
    required this.onTap,
  });

  final Customer customer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: selected
            ? AppColors.secondaryFixed
            : AppColors.surfaceContainerLow,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          borderRadius: AppRadius.lgAll,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.person_outline_rounded,
                  color: selected
                      ? AppColors.onPrimaryFixed
                      : AppColors.onSurfaceVariant,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.displayName,
                        style: AppTypography.bodyLg().copyWith(
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.onPrimaryFixed
                              : AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'رقم ${customer.customerNumber} · ${customer.primaryPhone}',
                        style: AppTypography.caption().copyWith(
                          color: selected
                              ? AppColors.onPrimaryFixed.withValues(alpha: 0.85)
                              : AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
