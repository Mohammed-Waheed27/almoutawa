import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';

/// Outlined entity header strip for expanded detail panes (not phone gradient cards).
class DesktopEntityHeaderStrip extends StatelessWidget {
  const DesktopEntityHeaderStrip({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    this.metrics = const [],
    this.trailing,
    this.icon = Icons.assignment_outlined,
  });

  final String title;
  final String? subtitle;
  final String? badge;
  final List<DesktopEntityMetric> metrics;
  final Widget? trailing;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(DesktopUiTokens.radiusLg),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.75),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesktopUiTokens.gapMd,
            vertical: DesktopUiTokens.gapSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed.withValues(alpha: 0.65),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(
                      icon,
                      size: DesktopUiTokens.iconSize,
                      color: AppColors.onPrimaryFixed,
                    ),
                  ),
                  const SizedBox(width: DesktopUiTokens.gapSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleOf(context).copyWith(
                            fontSize: DesktopUiTokens.pageTitle,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyOf(context).copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: DesktopUiTokens.gapSm),
                    _Badge(label: badge!),
                  ],
                  if (trailing != null) ...[
                    const SizedBox(width: DesktopUiTokens.gapSm),
                    trailing!,
                  ],
                ],
              ),
              if (metrics.isNotEmpty) ...[
                const SizedBox(height: DesktopUiTokens.gapSm),
                const Divider(height: 1),
                const SizedBox(height: DesktopUiTokens.gapSm),
                Wrap(
                  spacing: DesktopUiTokens.gapLg,
                  runSpacing: DesktopUiTokens.gapXs,
                  textDirection: TextDirection.rtl,
                  children: [for (final m in metrics) _MetricCell(metric: m)],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DesktopEntityMetric {
  const DesktopEntityMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesktopUiTokens.gapSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed,
        borderRadius: BorderRadius.circular(DesktopUiTokens.radiusSm),
      ),
      child: Text(
        label,
        style: AppTypography.labelMd().copyWith(
          fontSize: DesktopUiTokens.label,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimaryFixed,
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.metric});

  final DesktopEntityMetric metric;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            metric.label,
            style: AppTypography.labelOf(context).copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyOf(context).copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dense outlined action / document row for expanded layouts.
class DesktopActionRow extends StatelessWidget {
  const DesktopActionRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon = Icons.description_outlined,
    this.trailing,
    this.onTap,
    this.statusColor,
  });

  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(DesktopUiTokens.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesktopUiTokens.radiusMd),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: DesktopUiTokens.denseRowHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesktopUiTokens.gapMd,
            vertical: DesktopUiTokens.gapXs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesktopUiTokens.radiusMd),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                if (statusColor != null) ...[
                  Container(
                    width: 3,
                    height: 22,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: DesktopUiTokens.gapSm),
                ],
                Icon(
                  leadingIcon,
                  size: DesktopUiTokens.iconSize,
                  color: AppColors.onPrimaryFixedVariant,
                ),
                const SizedBox(width: DesktopUiTokens.gapSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyOf(context).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelOf(context).copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                ?trailing,
                if (onTap != null)
                  Icon(
                    Icons.chevron_left_rounded,
                    size: DesktopUiTokens.iconSize,
                    color: AppColors.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
