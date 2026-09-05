import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../cards/almoutawa_card.dart';
import 'hub_icon_well.dart';

/// Hub operation tile — portal list row pattern for role dashboards.
class HubOperationTile extends StatelessWidget {
  const HubOperationTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accentColor,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? accentColor;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.secondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlmoutawaCard(
        variant: AlmoutawaCardVariant.portal,
        statusColor: color,
        minHeight: AppLayout.listRowMinHeight,
        onTap: onTap,
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            HubIconWell(icon: icon, color: color),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMd()),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: AppRadius.smAll,
                ),
                child: Text(
                  badge!,
                  style: AppTypography.labelBold().copyWith(color: color),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
            ],
            Icon(Icons.arrow_back_ios_new, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
