import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/admin_report.dart';
import '../../../../domain/entities/commercial_order.dart';

class AdminReportsOrderFiltersSection extends StatelessWidget {
  const AdminReportsOrderFiltersSection({
    super.key,
    required this.orders,
    required this.selectedPhase,
    required this.selectedFactoryId,
    required this.selectedStaffId,
    required this.selectedCustomerId,
    required this.onPhaseSelected,
    required this.onFactorySelected,
    required this.onStaffSelected,
    required this.onCustomerSelected,
    required this.onClear,
  });

  final List<AdminReportOrderRow> orders;
  final String? selectedPhase;
  final String? selectedFactoryId;
  final String? selectedStaffId;
  final String? selectedCustomerId;
  final ValueChanged<String?> onPhaseSelected;
  final ValueChanged<String?> onFactorySelected;
  final ValueChanged<String?> onStaffSelected;
  final ValueChanged<String?> onCustomerSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final factories = <String, String>{};
    final staff = <String, String>{};
    final customers = <String, String>{};
    for (final row in orders) {
      if (row.factoryId != null) {
        factories[row.factoryId!] = row.factoryName ?? 'مصنع';
      }
      if (row.staffId != null) {
        staff[row.staffId!] = row.staffName ?? 'مندوب';
      }
      if (row.customerId.isNotEmpty) {
        customers[row.customerId] = row.customerName;
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChipRow(
            label: 'الحالة',
            dense: dense,
            children: [
              _FilterChip(
                label: 'الكل',
                selected: selectedPhase == null,
                onTap: () => onPhaseSelected(null),
              ),
              for (final phase in CommercialOrderPhase.values)
                _FilterChip(
                  label: phase.arabicLabel,
                  selected: selectedPhase == phase.dbValue,
                  onTap: () => onPhaseSelected(phase.dbValue),
                ),
            ],
          ),
          if (factories.isNotEmpty) ...[
            SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
            _ChipRow(
              label: 'المصنع',
              dense: dense,
              children: [
                _FilterChip(
                  label: 'الكل',
                  selected: selectedFactoryId == null,
                  onTap: () => onFactorySelected(null),
                ),
                for (final entry in factories.entries)
                  _FilterChip(
                    label: entry.value,
                    selected: selectedFactoryId == entry.key,
                    onTap: () => onFactorySelected(entry.key),
                  ),
              ],
            ),
          ],
          if (staff.isNotEmpty) ...[
            SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
            _ChipRow(
              label: 'المندوب',
              dense: dense,
              children: [
                _FilterChip(
                  label: 'الكل',
                  selected: selectedStaffId == null,
                  onTap: () => onStaffSelected(null),
                ),
                for (final entry in staff.entries.take(12))
                  _FilterChip(
                    label: entry.value,
                    selected: selectedStaffId == entry.key,
                    onTap: () => onStaffSelected(entry.key),
                  ),
              ],
            ),
          ],
          if (customers.length <= 12) ...[
            SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
            _ChipRow(
              label: 'العميل',
              dense: dense,
              children: [
                _FilterChip(
                  label: 'الكل',
                  selected: selectedCustomerId == null,
                  onTap: () => onCustomerSelected(null),
                ),
                for (final entry in customers.entries)
                  _FilterChip(
                    label: entry.value,
                    selected: selectedCustomerId == entry.key,
                    onTap: () => onCustomerSelected(entry.key),
                  ),
              ],
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onClear,
              child: Text(
                'إلغاء التصفية',
                style: AppTypography.labelOf(context).copyWith(
                  color: AppColors.onPrimaryFixedVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.label,
    required this.children,
    required this.dense,
  });

  final String label;
  final List<Widget> children;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTypography.labelOf(context).copyWith(
            color: AppColors.onPrimaryFixedVariant,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: dense ? DesktopUiTokens.gapXs : AppSpacing.xs),
        Wrap(
          spacing: dense ? DesktopUiTokens.gapXs : AppSpacing.xs,
          runSpacing: dense ? DesktopUiTokens.gapXs : AppSpacing.xs,
          textDirection: TextDirection.rtl,
          children: children,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.secondaryFixed : AppColors.surfaceContainerLow,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs + 2,
          ),
          child: Text(
            label,
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
