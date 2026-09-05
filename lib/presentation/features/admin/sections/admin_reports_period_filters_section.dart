import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/admin_report.dart';

class AdminReportsPeriodFiltersSection extends StatelessWidget {
  const AdminReportsPeriodFiltersSection({
    super.key,
    required this.selected,
    required this.onPeriodSelected,
    required this.onPickCustomRange,
  });

  final AdminReportPeriod selected;
  final ValueChanged<AdminReportPeriod> onPeriodSelected;
  final VoidCallback onPickCustomRange;

  static const _presets = [
    AdminReportPeriod.today,
    AdminReportPeriod.week,
    AdminReportPeriod.month,
    AdminReportPeriod.quarter,
    AdminReportPeriod.year,
    AdminReportPeriod.all,
  ];

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final chips = <Widget>[
      for (final period in _presets)
        _PeriodChip(
          label: period.arabicLabel,
          selected: selected == period,
          fullWidth: dense,
          onTap: () => onPeriodSelected(period),
        ),
      _PeriodChip(
        label: selected == AdminReportPeriod.custom ? 'مخصص ✓' : 'مخصص',
        selected: selected == AdminReportPeriod.custom,
        fullWidth: dense,
        onTap: onPickCustomRange,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الفترة',
            style: AppTypography.labelOf(context).copyWith(
              color: AppColors.onPrimaryFixedVariant,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapXs : AppSpacing.xs),
          if (dense)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < chips.length; i++) ...[
                  if (i > 0) const SizedBox(height: DesktopUiTokens.gapXs),
                  chips[i],
                ],
              ],
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    if (i > 0) SizedBox(width: AppSpacing.xs),
                    chips[i],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final radius = dense && fullWidth
        ? BorderRadius.circular(DesktopUiTokens.radiusMd)
        : AppRadius.smAll;

    return Material(
      color: selected
          ? AppColors.secondaryFixed
          : AppColors.surfaceContainerLow,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: dense ? DesktopUiTokens.gapMd : AppSpacing.sm,
            vertical: dense ? DesktopUiTokens.gapSm : AppSpacing.xs + 2,
          ),
          child: Text(
            label,
            textAlign: fullWidth ? TextAlign.center : TextAlign.start,
            style: AppTypography.labelOf(context).copyWith(
              fontWeight: FontWeight.w700,
              color: selected
                  ? AppColors.onPrimaryFixed
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
