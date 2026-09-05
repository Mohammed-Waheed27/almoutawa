import 'package:flutter/material.dart';

import '../../../../domain/entities/customer.dart';
import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class CustomerListCard extends StatelessWidget {
  const CustomerListCard({
    super.key,
    required this.customer,
    required this.onTap,
  });

  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompany = customer.type == CustomerType.company;
    final phoneLabel = customer.primaryPhone.isNotEmpty
        ? customer.primaryPhone
        : 'لا يوجد رقم هاتف';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlmoutawaCard(
        variant: AlmoutawaCardVariant.softGradient,
        onTap: onTap,
        padding: EdgeInsets.zero,
        borderRadius: AppRadius.lgAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.displayName,
                          style: AppTypography.titleMd(),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          phoneLabel,
                          style: AppTypography.bodyMd().copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.65),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      isCompany ? 'مؤسسة' : 'فرد',
                      style: AppTypography.captionBold().copyWith(
                        color: AppColors.onPrimaryFixedVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.arrow_back_ios_new,
                    size: 14,
                    color: AppColors.outline,
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: AppColors.secondaryFixed.withValues(alpha: 0.35),
            ),
            SizedBox(
              height: AppLayout.listRowMinHeight * 0.6,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: _StatCell(
                      label: 'أضيف بواسطة',
                      value: customer.createdByDisplayName == null
                          ? '—'
                          : '${customer.createdByDisplayName}${customer.createdByRoleLabel == null ? '' : ' (${customer.createdByRoleLabel})'}',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: AppColors.secondaryFixed.withValues(alpha: 0.35),
                  ),
                  Expanded(
                    child: _StatCell(
                      label: 'التقرير',
                      value: 'اضغط للعرض',
                      valueColor: AppColors.onTertiaryContainer,
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
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.captionBold().copyWith(
            color: valueColor ?? AppColors.onPrimaryFixedVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
