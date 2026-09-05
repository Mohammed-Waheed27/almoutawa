import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';

/// Single settings menu row — icon, title, subtitle, chevron.
class SettingsMenuRow extends StatelessWidget {
  const SettingsMenuRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.showChevron = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final accent = iconColor ?? AppColors.secondaryContainer;
    final well = dense ? 32.0 : 44.0;
    final iconSz = dense ? DesktopUiTokens.iconSize : 22.0;
    final minH = dense
        ? DesktopUiTokens.denseRowHeight + 8
        : AppLayout.listRowMinHeight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: dense
              ? BorderRadius.circular(DesktopUiTokens.radiusMd)
              : AppRadius.lgAll,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minH),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: dense ? DesktopUiTokens.gapMd : AppSpacing.md,
                vertical: dense ? DesktopUiTokens.gapSm : AppSpacing.sm,
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: well,
                    height: well,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Icon(icon, color: accent, size: iconSz),
                  ),
                  SizedBox(
                    width: dense ? DesktopUiTokens.gapSm : AppSpacing.md,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.titleOf(context).copyWith(
                            color: titleColor ?? AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: dense ? 2 : AppSpacing.xs),
                        Text(
                          subtitle,
                          style: AppTypography.bodyOf(
                            context,
                          ).copyWith(color: AppColors.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (showChevron)
                    Icon(
                      Icons.arrow_back_ios_new,
                      size: dense ? DesktopUiTokens.iconSize - 2 : 16,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
