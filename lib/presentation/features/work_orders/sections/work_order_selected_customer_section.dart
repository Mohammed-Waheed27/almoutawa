import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/customer.dart';

/// Quote-style customer meta box — selection opens the dedicated picker page.
class WorkOrderSelectedCustomerSection extends StatelessWidget {
  const WorkOrderSelectedCustomerSection({
    super.key,
    required this.customer,
    this.onSelect,
  });

  final Customer? customer;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final hasCustomer = customer != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onSelect,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: AppColors.secondaryFixed.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Text(
                        'بيانات العميل في الطلب',
                        style: AppTypography.labelBold().copyWith(
                          color: AppColors.onPrimaryFixedVariant,
                        ),
                      ),
                    ),
                    if (onSelect != null)
                      TextButton(
                        onPressed: onSelect,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: AppColors.onPrimaryFixedVariant,
                        ),
                        child: Text(
                          hasCustomer ? 'تغيير' : 'اختيار العميل',
                          style: AppTypography.labelMd().copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                if (!hasCustomer)
                  Text(
                    'اضغط لاختيار العميل من قائمة العملاء',
                    style: AppTypography.caption().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  )
                else ...[
                  _MetaLine(
                    label: 'العميل',
                    value: 'المحترم / ${customer!.displayName}',
                  ),
                  _MetaLine(
                    label: 'رقم العميل',
                    value: '${customer!.customerNumber}',
                  ),
                  _MetaLine(label: 'الهاتف', value: customer!.primaryPhone),
                  _MetaLine(
                    label: 'العنوان',
                    value: [
                      if ((customer!.address ?? '').isNotEmpty)
                        customer!.address,
                      if ((customer!.governorate ?? '').isNotEmpty)
                        customer!.governorate,
                    ].whereType<String>().join(' - ').ifEmpty('—'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: AppTypography.caption().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.captionBold(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
