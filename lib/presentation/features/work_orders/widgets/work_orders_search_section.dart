import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/inputs/almoutawa_filter_dropdown.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_search_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import 'work_orders_list_filters.dart';

class WorkOrdersSearchSection extends StatelessWidget {
  const WorkOrdersSearchSection({
    super.key,
    required this.controller,
    required this.filters,
    required this.customerOptions,
    required this.onFiltersChanged,
  });

  final TextEditingController controller;
  final WorkOrdersListFilters filters;
  final List<WorkOrderCustomerFilterOption> customerOptions;
  final ValueChanged<WorkOrdersListFilters> onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final dropdowns = <Widget>[
      AlmoutawaFilterDropdown<WorkOrderActivityFilter>(
        typeLabel: 'النوع',
        value: filters.activity,
        fullWidth: dense,
        options: [
          for (final value in WorkOrderActivityFilter.values)
            AlmoutawaFilterOption(value: value, label: value.arabicLabel),
        ],
        onChanged: (value) => onFiltersChanged(
          filters.copyWith(
            activity: value,
            clearPhase: value != WorkOrderActivityFilter.all,
          ),
        ),
      ),
      AlmoutawaFilterDropdown<String>(
        typeLabel: 'المرحلة',
        value: filters.phase?.dbValue ?? 'all',
        fullWidth: dense,
        options: [
          const AlmoutawaFilterOption(value: 'all', label: 'الكل'),
          for (final phase in CommercialOrderPhase.values)
            AlmoutawaFilterOption(
              value: phase.dbValue,
              label: phase.arabicLabel,
            ),
        ],
        onChanged: (value) {
          if (value == 'all') {
            onFiltersChanged(filters.copyWith(clearPhase: true));
            return;
          }
          onFiltersChanged(
            filters.copyWith(
              phase: CommercialOrderPhase.fromDbValue(value),
              activity: WorkOrderActivityFilter.all,
            ),
          );
        },
      ),
      AlmoutawaFilterDropdown<String>(
        typeLabel: 'الحالة',
        value: filters.documentStatus?.dbValue ?? 'all',
        fullWidth: dense,
        options: [
          const AlmoutawaFilterOption(value: 'all', label: 'الكل'),
          for (final status in DocumentIssueStatus.values)
            AlmoutawaFilterOption(
              value: status.dbValue,
              label: status.arabicLabel,
            ),
        ],
        onChanged: (value) {
          if (value == 'all') {
            onFiltersChanged(filters.copyWith(clearDocumentStatus: true));
            return;
          }
          onFiltersChanged(
            filters.copyWith(
              documentStatus: DocumentIssueStatus.fromDbValue(value),
            ),
          );
        },
      ),
      AlmoutawaFilterDropdown<String>(
        typeLabel: 'العميل',
        value: filters.customerId ?? 'all',
        fullWidth: dense,
        options: [
          const AlmoutawaFilterOption(value: 'all', label: 'الكل'),
          for (final customer in customerOptions)
            AlmoutawaFilterOption(value: customer.id, label: customer.label),
        ],
        onChanged: (value) {
          if (value == 'all') {
            onFiltersChanged(filters.copyWith(clearCustomerId: true));
            return;
          }
          onFiltersChanged(filters.copyWith(customerId: value));
        },
      ),
      if (filters.hasActiveFilters)
        _ClearFiltersChip(
          dense: dense,
          onTap: () => onFiltersChanged(WorkOrdersListFilters.empty),
        ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AlmoutawaSearchField(
            controller: controller,
            hint: 'ابحث برقم الطلب أو اسم العميل...',
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
          if (dense)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < dropdowns.length; i++) ...[
                  if (i > 0) const SizedBox(height: DesktopUiTokens.gapXs),
                  dropdowns[i],
                ],
              ],
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  for (var i = 0; i < dropdowns.length; i++) ...[
                    if (i > 0) SizedBox(width: AppSpacing.xs),
                    dropdowns[i],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ClearFiltersChip extends StatelessWidget {
  const _ClearFiltersChip({required this.onTap, required this.dense});

  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          dense ? DesktopUiTokens.radiusMd : AppRadius.full,
        ),
        onTap: onTap,
        child: Container(
          width: dense ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: dense ? DesktopUiTokens.gapMd : AppSpacing.sm,
            vertical: dense ? DesktopUiTokens.gapSm : 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.errorContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(
              dense ? DesktopUiTokens.radiusMd : AppRadius.full,
            ),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.28)),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: dense ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: dense
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                Icons.close_rounded,
                size: dense ? DesktopUiTokens.iconSize : 14,
                color: AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                dense ? 'إلغاء التصفية' : 'إلغاء',
                style: AppTypography.caption().copyWith(
                  fontSize: dense ? DesktopUiTokens.label : null,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
