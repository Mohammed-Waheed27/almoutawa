import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import 'almoutawa_card.dart';

/// Portal card — 16px radius, optional status bar on leading edge (RTL: right).
class PortalCard extends StatelessWidget {
  const PortalCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.statusColor,
    this.onTap,
    this.child,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? statusColor;
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlmoutawaCard(
        variant: AlmoutawaCardVariant.portal,
        statusColor: statusColor,
        onTap: onTap,
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMd()),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: AppTypography.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (child != null) ...[
                    SizedBox(height: AppSpacing.md),
                    child!,
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }
}
