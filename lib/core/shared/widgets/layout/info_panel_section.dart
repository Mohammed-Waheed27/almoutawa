import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';
import '../cards/almoutawa_card.dart';

/// Order / entity summary panel — glass on phone, solid outlined on desktop.
class InfoPanelSection extends StatelessWidget {
  const InfoPanelSection({
    super.key,
    required this.title,
    required this.rows,
    this.compact = false,
  });

  final String title;
  final List<InfoPanelRow> rows;

  /// Tighter padding / gaps for document viewers.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final pad = dense
        ? DesktopUiTokens.gapSm
        : (compact ? AppSpacing.md : AppSpacing.lg);
    final titleGap = dense
        ? DesktopUiTokens.gapXs
        : (compact ? AppSpacing.sm : AppSpacing.lg);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlmoutawaCard(
        variant: dense
            ? AlmoutawaCardVariant.solid
            : AlmoutawaCardVariant.glass,
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTypography.titleOf(context).copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: titleGap),
            if (dense)
              Wrap(
                spacing: DesktopUiTokens.gapLg,
                runSpacing: DesktopUiTokens.gapXs,
                textDirection: TextDirection.rtl,
                children: [
                  for (final row in rows)
                    SizedBox(
                      width: 160,
                      child: _InfoRow(row: row, compact: true, dense: true),
                    ),
                ],
              )
            else
              ...rows.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key == rows.length - 1
                        ? 0
                        : (compact ? AppSpacing.sm : AppSpacing.md),
                  ),
                  child: _InfoRow(row: entry.value, compact: compact),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class InfoPanelRow {
  const InfoPanelRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.highlight = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool highlight;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.row, this.compact = false, this.dense = false});

  final InfoPanelRow row;
  final bool compact;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (dense) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            row.label,
            style: AppTypography.labelOf(context).copyWith(
              color: AppColors.outline,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            row.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyOf(context).copyWith(
              color: row.valueColor ?? AppColors.onSurface,
              fontWeight: row.highlight ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: compact ? 88 : 96,
          child: Text(
            compact ? row.label : row.label.toUpperCase(),
            style: AppTypography.captionBold().copyWith(
              color: AppColors.outline,
              letterSpacing: compact ? 0 : 0.6,
            ),
          ),
        ),
        Expanded(
          child: Text(
            row.value,
            style: AppTypography.bodyMd().copyWith(
              color: row.valueColor ?? AppColors.onSurface,
              fontWeight: row.highlight ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
