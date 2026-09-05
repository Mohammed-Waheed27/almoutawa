import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/decorative_card_shell.dart';
import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/feedback/animated_count_text.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';

/// Compact hub KPI tile — blob shell, label+icon top-right, centered count-up value.
class AdminHomeStatCard extends StatelessWidget {
  const AdminHomeStatCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.tone,
    this.animate = true,
  });

  final String label;
  final int count;
  final IconData icon;
  final DecorativeCardTone tone;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final height = dense ? 72.0 : 80.0;
    final valueStyle = (dense
            ? AppTypography.titleOf(context)
            : AppTypography.displaySm())
        .copyWith(
          color: tone.accent,
          height: 1.1,
          fontWeight: FontWeight.w800,
          fontSize: dense ? 24 : null,
        );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecorativeCardShell(
        tone: tone,
        padding: EdgeInsets.symmetric(
          horizontal: dense ? DesktopUiTokens.gapMd : AppSpacing.md,
          vertical: dense ? DesktopUiTokens.gapSm : AppSpacing.sm,
        ),
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  _CompactIconWell(
                    icon: icon,
                    color: tone.accent,
                    size: dense ? 24 : 28,
                    iconSize: dense ? DesktopUiTokens.iconSize - 2 : 15,
                  ),
                  SizedBox(width: dense ? DesktopUiTokens.gapXs : AppSpacing.xs),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.labelOf(context).copyWith(
                        color: tone.accent.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: dense ? DesktopUiTokens.gapSm : AppSpacing.sm,
                ),
                child: animate
                    ? AnimatedCountText(
                        value: count,
                        style: valueStyle,
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        '$count',
                        style: valueStyle,
                        textAlign: TextAlign.center,
                      ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactIconWell extends StatelessWidget {
  const _CompactIconWell({
    required this.icon,
    required this.color,
    this.size = 28,
    this.iconSize = 15,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.smAll,
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
