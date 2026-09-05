import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

/// Soft informational callout above form submit actions.
class FormInfoBanner extends StatelessWidget {
  const FormInfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.secondaryFixed.withValues(alpha: 0.45),
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.12),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.secondaryContainer),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyMd().copyWith(
                    color: AppColors.onPrimaryFixed,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
