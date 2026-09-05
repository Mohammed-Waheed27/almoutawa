import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../layout/hub_icon_well.dart';
import 'decorative_card_shell.dart';
import 'decorative_card_tone.dart';

class DecorativeSummaryMetric {
  const DecorativeSummaryMetric({
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;
}

/// Entity summary row — header + divider + metric strip (customers, workers, etc.).
class DecorativeSummaryCard extends StatelessWidget {
  const DecorativeSummaryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.badge,
    this.trailing,
    this.metrics = const [],
    this.tone = DecorativeCardTone.blue,
    this.onTap,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? badge;
  final Widget? trailing;
  final List<DecorativeSummaryMetric> metrics;
  final DecorativeCardTone tone;
  final VoidCallback? onTap;

  /// Smaller header + metric strip for document / order detail pages.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final headerPad = compact ? AppSpacing.sm : AppSpacing.md;
    final metricHeight = compact ? 44.0 : 52.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecorativeCardShell(
        tone: tone,
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(headerPad),
              child: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    HubIconWell(icon: icon!, color: tone.accent),
                    SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: compact
                              ? AppTypography.titleSm().copyWith(
                                  fontWeight: FontWeight.w800,
                                )
                              : AppTypography.titleMd(),
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle!,
                            style: (compact
                                    ? AppTypography.caption()
                                    : AppTypography.bodyMd())
                                .copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (badge != null) ...[
                    SizedBox(width: AppSpacing.sm),
                    _BadgeChip(label: badge!, tone: tone),
                  ],
                  if (trailing != null) ...[
                    SizedBox(width: AppSpacing.sm),
                    trailing!,
                  ] else if (onTap != null) ...[
                    SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.arrow_back_ios_new,
                      size: 14,
                      color: AppColors.outline,
                    ),
                  ],
                ],
              ),
            ),
            if (metrics.isNotEmpty) ...[
              Divider(height: 1, color: tone.border.withValues(alpha: 0.65)),
              SizedBox(
                height: metricHeight,
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < metrics.length; i++) ...[
                      if (i > 0)
                        VerticalDivider(
                          width: 1,
                          color: tone.border.withValues(alpha: 0.65),
                        ),
                      Expanded(
                        child: _MetricCell(
                          metric: metrics[i],
                          tone: tone,
                          compact: compact,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, required this.tone});

  final String label;
  final DecorativeCardTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.border),
      ),
      child: Text(
        label,
        style: AppTypography.captionBold().copyWith(color: tone.accent),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.metric,
    required this.tone,
    this.compact = false,
  });

  final DecorativeSummaryMetric metric;
  final DecorativeCardTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final vPad = compact ? AppSpacing.xs : AppSpacing.sm;
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          metric.label,
          style: AppTypography.caption().copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          metric.value,
          style: AppTypography.captionBold().copyWith(
            color: metric.valueColor ?? tone.accent,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (metric.onTap == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: vPad),
        child: content,
      );
    }

    return InkWell(
      onTap: metric.onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPad),
        child: content,
      ),
    );
  }
}
