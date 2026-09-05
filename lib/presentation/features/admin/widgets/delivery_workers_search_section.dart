import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/inputs/almoutawa_search_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/staff_profile.dart';

enum DeliveryWorkerListFilter { all, active, suspended }

extension DeliveryWorkerListFilterX on DeliveryWorkerListFilter {
  String get arabicLabel => switch (this) {
    DeliveryWorkerListFilter.all => 'الكل',
    DeliveryWorkerListFilter.active => 'نشط',
    DeliveryWorkerListFilter.suspended => 'موقوف',
  };

  bool matches(StaffProfile worker) => switch (this) {
    DeliveryWorkerListFilter.all => true,
    DeliveryWorkerListFilter.active => worker.isActive,
    DeliveryWorkerListFilter.suspended => !worker.isActive,
  };
}

class DeliveryWorkersSearchSection extends StatelessWidget {
  const DeliveryWorkersSearchSection({
    super.key,
    required this.controller,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final DeliveryWorkerListFilter selectedFilter;
  final ValueChanged<DeliveryWorkerListFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final chips = DeliveryWorkerListFilter.values.map((filter) {
      final selected = filter == selectedFilter;
      return _WorkerFilterChip(
        label: filter.arabicLabel,
        selected: selected,
        fullWidth: dense,
        onTap: () => onFilterChanged(filter),
      );
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!dense) SizedBox(height: AppSpacing.md),
          AlmoutawaSearchField(
            controller: controller,
            hint: 'ابحث عن مندوب، بريد، أو رقم هاتف...',
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
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

class _WorkerFilterChip extends StatelessWidget {
  const _WorkerFilterChip({
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
        : AppRadius.mdAll;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: dense ? DesktopUiTokens.gapMd : AppSpacing.md,
            vertical: dense ? DesktopUiTokens.gapSm : AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.secondaryFixed
                : AppColors.surfaceContainerLow,
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? AppColors.primaryFixedDim.withValues(alpha: 0.5)
                  : AppColors.secondaryFixed.withValues(alpha: 0.6),
            ),
          ),
          child: Text(
            label,
            textAlign: fullWidth ? TextAlign.center : TextAlign.start,
            style: AppTypography.labelOf(context).copyWith(
              color: selected
                  ? AppColors.onPrimaryFixed
                  : AppColors.onPrimaryFixedVariant,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
