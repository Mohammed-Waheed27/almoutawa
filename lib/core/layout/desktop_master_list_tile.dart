import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/desktop_ui_tokens.dart';

/// Flat dense row for master list panes on expanded layouts.
class DesktopMasterListTile extends StatelessWidget {
  const DesktopMasterListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.secondaryFixed.withValues(alpha: 0.55)
          : AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: DesktopUiTokens.denseRowHeight + 8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesktopUiTokens.gapMd,
            vertical: DesktopUiTokens.gapSm,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: DesktopUiTokens.gapSm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMd().copyWith(
                          fontSize: DesktopUiTokens.body,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMd().copyWith(
                            fontSize: DesktopUiTokens.label,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: DesktopUiTokens.gapSm),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
