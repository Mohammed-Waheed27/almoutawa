import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';
import '../cards/almoutawa_card.dart';

/// One data row in [DocumentLinesTable] — cell count must match [columns].
class DocumentLineTableRow {
  const DocumentLineTableRow({required this.cells});

  final List<String> cells;
}

/// Dense RTL line-items table for quote / agreement viewers.
///
/// When [onRowTap] is set, rows are tappable and show a chevron affordance.
class DocumentLinesTable extends StatelessWidget {
  const DocumentLinesTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.columnWidths,
    this.onRowTap,
    this.hint,
  });

  final String title;
  final List<String> columns;
  final List<DocumentLineTableRow> rows;

  /// Optional fixed widths per column (logical px). Defaults to a balanced set.
  final List<double>? columnWidths;

  /// Opens full بند details when a row is pressed.
  final ValueChanged<int>? onRowTap;

  /// Optional caption under the title (e.g. اضغط على البند لعرض التفاصيل).
  final String? hint;

  static const _defaultWidths = <double>[
    120, // description
    64,
    48,
    40,
    56,
    64,
  ];

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final widths =
        columnWidths ??
        List<double>.generate(
          columns.length,
          (i) => i < _defaultWidths.length ? _defaultWidths[i] : 56,
        );
    final hPad = dense ? DesktopUiTokens.gapSm : AppSpacing.sm;
    final chevronW = onRowTap != null ? (dense ? 22.0 : 28.0) : 0.0;
    // Include horizontal padding in outer width — Row children alone used to
    // overflow by ~16px (gapSm × 2) on desktop.
    final contentWidth = widths.fold<double>(0, (sum, w) => sum + w) + chevronW;
    final tableWidth = contentWidth + (hPad * 2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTypography.titleOf(context).copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.right,
          ),
          if (hint != null) ...[
            SizedBox(height: dense ? 2 : AppSpacing.xs),
            Text(
              hint!,
              style: AppTypography.labelOf(context).copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
          ],
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
          AlmoutawaCard(
            variant: AlmoutawaCardVariant.solid,
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: dense
                  ? BorderRadius.circular(DesktopUiTokens.radiusMd)
                  : AppRadius.lgAll,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: SizedBox(
                  width: tableWidth < 320 ? 320 : tableWidth,
                  child: Column(
                    children: [
                      _HeaderRow(
                        columns: columns,
                        widths: widths,
                        showChevronSlot: onRowTap != null,
                        dense: dense,
                        chevronWidth: chevronW,
                        horizontalPad: hPad,
                      ),
                      if (rows.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(
                            dense ? DesktopUiTokens.gapMd : AppSpacing.md,
                          ),
                          child: Text(
                            'لا توجد بنود',
                            style: AppTypography.bodyOf(context).copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...rows.asMap().entries.map(
                          (entry) => _DataRow(
                            cells: entry.value.cells,
                            widths: widths,
                            striped: entry.key.isOdd,
                            isLast: entry.key == rows.length - 1,
                            tappable: onRowTap != null,
                            dense: dense,
                            chevronWidth: chevronW,
                            horizontalPad: hPad,
                            onTap: onRowTap == null
                                ? null
                                : () => onRowTap!(entry.key),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.columns,
    required this.widths,
    required this.showChevronSlot,
    required this.dense,
    required this.chevronWidth,
    required this.horizontalPad,
  });

  final List<String> columns;
  final List<double> widths;
  final bool showChevronSlot;
  final bool dense;
  final double chevronWidth;
  final double horizontalPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: dense ? DesktopUiTokens.gapXs : AppSpacing.sm,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          for (var i = 0; i < columns.length; i++)
            SizedBox(
              width: widths[i],
              child: Text(
                columns[i],
                style: AppTypography.labelOf(context).copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: i == 0 ? TextAlign.right : TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (showChevronSlot) SizedBox(width: chevronWidth),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.cells,
    required this.widths,
    required this.striped,
    required this.isLast,
    required this.tappable,
    required this.dense,
    required this.chevronWidth,
    required this.horizontalPad,
    this.onTap,
  });

  final List<String> cells;
  final List<double> widths;
  final bool striped;
  final bool isLast;
  final bool tappable;
  final bool dense;
  final double chevronWidth;
  final double horizontalPad;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      constraints: BoxConstraints(
        minHeight: dense ? DesktopUiTokens.denseRowHeight : 0,
      ),
      decoration: BoxDecoration(
        color: striped
            ? AppColors.surfaceContainerLow.withValues(alpha: 0.45)
            : null,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.outlineVariant, width: 0.8),
              ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: dense ? DesktopUiTokens.gapXs : AppSpacing.sm,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < cells.length; i++)
            SizedBox(
              width: widths[i],
              child: Text(
                cells[i],
                style: i == cells.length - 1
                    ? AppTypography.labelOf(context).copyWith(
                        color: AppColors.onPrimaryFixedVariant,
                        fontWeight: FontWeight.w700,
                      )
                    : AppTypography.labelOf(context).copyWith(
                        color: AppColors.onSurface,
                        fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w400,
                      ),
                textAlign: i == 0 ? TextAlign.right : TextAlign.center,
                maxLines: i == 0 || i == 1 ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (tappable)
            SizedBox(
              width: chevronWidth,
              child: Icon(
                Icons.chevron_left_rounded,
                size: dense ? DesktopUiTokens.iconSize : 18,
                color: AppColors.onPrimaryFixedVariant.withValues(alpha: 0.75),
              ),
            ),
        ],
      ),
    );

    if (!tappable || onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}
