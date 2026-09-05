import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import 'almoutawa_card.dart';

/// Portal list row — status bar on trailing edge (RTL: right), icon well, chevron.
class PortalListRow extends StatelessWidget {
  const PortalListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.statusColor,
    this.leading,
    this.trailing,
    this.badge,
    this.meta,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Color? statusColor;
  final Widget? leading;
  final Widget? trailing;
  final Widget? badge;
  final Widget? meta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlmoutawaCard(
        variant: AlmoutawaCardVariant.portal,
        statusColor: statusColor ?? AppColors.secondary,
        minHeight: AppLayout.listRowMinHeight,
        onTap: onTap,
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: AppSpacing.lg),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.bodyLg().copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: AppSpacing.sm),
                        badge!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: AppTypography.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (meta != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    meta!,
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: AppSpacing.xs),
              child:
                  trailing ??
                  const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: AppColors.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
