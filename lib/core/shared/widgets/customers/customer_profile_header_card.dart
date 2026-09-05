import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../cards/almoutawa_card.dart';

/// Shared customer profile header — soft gradient, no avatar placeholder.
class CustomerProfileHeaderCard extends StatelessWidget {
  const CustomerProfileHeaderCard({super.key, required this.customer});

  final CustomerProfileData customer;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlmoutawaCard(
        variant: AlmoutawaCardVariant.softGradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.displayName,
              style: AppTypography.headlineMd().copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              textDirection: TextDirection.rtl,
              children: [
                _StatusChip(
                  label: customer.typeLabel,
                  background: AppColors.white.withValues(alpha: 0.72),
                  foreground: AppColors.onPrimaryFixedVariant,
                ),
                const _StatusChip(
                  label: 'نشط',
                  background: AppColors.tertiaryFixed,
                  foreground: AppColors.onTertiaryFixedVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerProfileData {
  const CustomerProfileData({
    required this.displayName,
    required this.typeLabel,
    required this.isCompany,
  });

  final String displayName;
  final String typeLabel;
  final bool isCompany;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.captionBold().copyWith(color: foreground),
      ),
    );
  }
}
