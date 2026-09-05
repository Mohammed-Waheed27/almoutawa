import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_surface_styles.dart';
import '../../../theme/app_typography.dart';

/// Elevated navigable list row — solid surface per Sapphire Blueprint.
class ElevatedListCard extends StatelessWidget {
  const ElevatedListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: Ink(
            decoration: AppSurfaceStyles.elevatedCard(),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.titleMd(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle!,
                            style: AppTypography.bodyMd().copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    SizedBox(width: AppSpacing.md),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Muted icon badge for trailing list actions.
class TrailingMutedIconBadge extends StatelessWidget {
  const TrailingMutedIconBadge({super.key, required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (color ?? AppColors.secondary).withValues(alpha: 0.1),
        borderRadius: AppRadius.mdAll,
      ),
      child: Icon(icon, color: color ?? AppColors.secondary, size: 24),
    );
  }
}
