import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';
import '../feedback/animated_count_text.dart';
import 'almoutawa_card.dart';

enum StatsBentoTileSize { standard, compact, mini }

/// Bento stat tile — fixed height for dashboard grid parity.

class StatsBentoTile extends StatelessWidget {
  const StatsBentoTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.hero = false,
    this.valueColor,
    this.iconColor,
    this.size = StatsBentoTileSize.standard,
    this.animatedCount,
  });

  final String label;

  final String value;

  final IconData icon;

  final bool hero;

  final Color? valueColor;

  final Color? iconColor;

  final StatsBentoTileSize size;

  /// When set, the value animates from 0 → this count (preferred over [value]).
  final int? animatedCount;

  bool get _mini => size == StatsBentoTileSize.mini;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final tileHeight = switch (size) {
      StatsBentoTileSize.mini => AppLayout.bentoTileHeightMiniOf(context),
      StatsBentoTileSize.compact =>
        dense ? 72.0 : AppLayout.bentoTileHeightCompact,
      StatsBentoTileSize.standard => dense ? 96.0 : AppLayout.bentoTileHeight,
    };

    final padding = switch (size) {
      StatsBentoTileSize.mini => dense ? DesktopUiTokens.gapSm : AppSpacing.sm,
      StatsBentoTileSize.compact =>
        dense ? DesktopUiTokens.gapMd : AppSpacing.md,
      StatsBentoTileSize.standard =>
        dense ? DesktopUiTokens.gapMd : AppSpacing.lg,
    };

    final labelStyle = switch (size) {
      StatsBentoTileSize.mini => AppTypography.bentoLabelMini().copyWith(
        fontSize: dense ? DesktopUiTokens.label : null,
      ),
      StatsBentoTileSize.compact => AppTypography.bentoLabelCompact().copyWith(
        fontSize: dense ? DesktopUiTokens.label : null,
      ),
      StatsBentoTileSize.standard =>
        AppTypography.bentoLabelStandard().copyWith(
          fontSize: dense ? DesktopUiTokens.label : null,
        ),
    };

    final valueStyle = switch (size) {
      StatsBentoTileSize.mini => AppTypography.bentoValueMini(
        hero: hero,
      ).copyWith(fontSize: dense ? DesktopUiTokens.title : null),
      StatsBentoTileSize.compact => AppTypography.bentoValueCompact(
        hero: hero,
      ).copyWith(fontSize: dense ? DesktopUiTokens.pageTitle : null),
      StatsBentoTileSize.standard => AppTypography.bentoValueStandard(
        hero: hero,
      ).copyWith(fontSize: dense ? 22.0 : null),
    };

    final iconSize = switch (size) {
      StatsBentoTileSize.mini => dense ? DesktopUiTokens.iconSize - 2 : 14.0,
      StatsBentoTileSize.compact => dense ? DesktopUiTokens.iconSize : 16.0,
      StatsBentoTileSize.standard =>
        dense ? DesktopUiTokens.iconSize + 2 : 20.0,
    };

    return Directionality(
      textDirection: TextDirection.rtl,

      child: SizedBox(
        height: tileHeight,

        child: AlmoutawaCard(
          variant: _mini
              ? AlmoutawaCardVariant.tinted
              : (hero
                    ? AlmoutawaCardVariant.gradient
                    : AlmoutawaCardVariant.solid),
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: _mini ? AppSpacing.xs : padding,
          ),
          child: _mini
              ? _MiniTileBody(
                  label: label,
                  value: value,
                  animatedCount: animatedCount,
                  icon: icon,
                  iconSize: iconSize,
                  labelStyle: labelStyle,
                  valueStyle: valueStyle,
                  valueColor: valueColor,
                  iconColor: iconColor,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(
                          icon,
                          size: iconSize,
                          color: hero
                              ? AppColors.white.withValues(alpha: 0.9)
                              : (iconColor ?? AppColors.secondary),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            label,
                            style: labelStyle.copyWith(
                              color: hero
                                  ? AppColors.white.withValues(alpha: 0.85)
                                  : AppColors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _StatValue(
                      value: value,
                      animatedCount: animatedCount,
                      style: valueStyle.copyWith(
                        color: hero
                            ? AppColors.white
                            : (valueColor ?? AppColors.primary),
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  const _StatValue({
    required this.value,
    required this.style,
    this.animatedCount,
  });

  final String value;
  final TextStyle style;
  final int? animatedCount;

  @override
  Widget build(BuildContext context) {
    if (animatedCount != null) {
      return AnimatedCountText(value: animatedCount!, style: style);
    }
    return Text(value, style: style);
  }
}

/// Single-row KPI for [StatsBentoTileSize.mini] — fits 60px mobile strip.
class _MiniTileBody extends StatelessWidget {
  const _MiniTileBody({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconSize,
    required this.labelStyle,
    required this.valueStyle,
    this.animatedCount,
    this.valueColor,
    this.iconColor,
  });

  final String label;
  final String value;
  final int? animatedCount;
  final IconData icon;
  final double iconSize;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final Color? valueColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? AppColors.onPrimaryFixedVariant,
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: labelStyle.copyWith(color: AppColors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        _StatValue(
          value: value,
          animatedCount: animatedCount,
          style: valueStyle.copyWith(
            color: valueColor ?? AppColors.onSurface,
            height: 1,
          ),
        ),
      ],
    );
  }
}
