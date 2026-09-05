import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/inputs/almoutawa_search_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/customer.dart';

enum CustomerListFilter { all, company, individual }

extension CustomerListFilterX on CustomerListFilter {
  String get arabicLabel => switch (this) {
    CustomerListFilter.all => 'الكل',
    CustomerListFilter.company => 'مؤسسات',
    CustomerListFilter.individual => 'أفراد',
  };

  bool matches(Customer customer) => switch (this) {
    CustomerListFilter.all => true,
    CustomerListFilter.company => customer.type == CustomerType.company,
    CustomerListFilter.individual => customer.type == CustomerType.individual,
  };
}

class CustomersSearchSection extends StatelessWidget {
  const CustomersSearchSection({
    super.key,
    required this.controller,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final CustomerListFilter selectedFilter;
  final ValueChanged<CustomerListFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.md),
          AlmoutawaSearchField(
            controller: controller,
            hint: 'ابحث عن عميل، مؤسسة، أو موقع...',
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
          if (dense)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final filter in CustomerListFilter.values) ...[
                  _RoundedFilterChip(
                    label: filter.arabicLabel,
                    selected: filter == selectedFilter,
                    dense: true,
                    expanded: true,
                    onTap: () => onFilterChanged(filter),
                  ),
                  const SizedBox(height: DesktopUiTokens.gapXs),
                ],
              ],
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                textDirection: TextDirection.rtl,
                children: CustomerListFilter.values.map((filter) {
                  final selected = filter == selectedFilter;
                  return Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xs),
                    child: _RoundedFilterChip(
                      label: filter.arabicLabel,
                      selected: selected,
                      dense: false,
                      expanded: false,
                      onTap: () => onFilterChanged(filter),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundedFilterChip extends StatelessWidget {
  const _RoundedFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.dense,
    required this.expanded,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: dense
            ? BorderRadius.circular(DesktopUiTokens.radiusMd)
            : AppRadius.mdAll,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: expanded ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: dense ? DesktopUiTokens.gapMd : AppSpacing.md,
            vertical: dense ? DesktopUiTokens.gapSm : AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.secondaryFixed
                : AppColors.surfaceContainerLow,
            borderRadius: dense
                ? BorderRadius.circular(DesktopUiTokens.radiusMd)
                : AppRadius.mdAll,
            border: Border.all(
              color: selected
                  ? AppColors.primaryFixedDim.withValues(alpha: 0.5)
                  : AppColors.secondaryFixed.withValues(alpha: 0.6),
            ),
            boxShadow: selected && !dense
                ? [
                    BoxShadow(
                      color: AppColors.primaryFixedDim.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: expanded ? TextAlign.right : TextAlign.center,
            style: AppTypography.labelMd().copyWith(
              fontSize: dense ? DesktopUiTokens.label : null,
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
