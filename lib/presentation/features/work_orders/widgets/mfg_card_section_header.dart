import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Compact RTL section title used on manufacturing-card form.
class MfgCardSectionHeader extends StatelessWidget {
  const MfgCardSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.labelBold().copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[SizedBox(width: AppSpacing.sm), trailing!],
        ],
      ),
    );
  }
}
