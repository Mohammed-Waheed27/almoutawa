import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';
import '../cards/almoutawa_card.dart';

/// Grouped settings section with header — reference-style admin settings.
class SettingsGroupSection extends StatelessWidget {
  const SettingsGroupSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: dense ? DesktopUiTokens.gapXs : AppSpacing.xs,
              bottom: dense ? DesktopUiTokens.gapXs : AppSpacing.sm,
            ),
            child: Text(
              title,
              style: AppTypography.labelOf(
                context,
              ).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
            ),
          ),
          AlmoutawaCard(
            variant: AlmoutawaCardVariant.solid,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
