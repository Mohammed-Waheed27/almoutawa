import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/cards/decorative_summary_card.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../core/utils/sar_money.dart';
import '../../../../domain/entities/admin_report.dart';
import '../../../../domain/entities/user_role.dart';

class AdminReportsStaffTableSection extends StatelessWidget {
  const AdminReportsStaffTableSection({
    super.key,
    required this.rows,
    required this.roleFilter,
    required this.onRoleFilterChanged,
    this.onStaffSelected,
  });

  final List<StaffPerformanceRow> rows;
  final UserRole? roleFilter;
  final ValueChanged<UserRole?> onRoleFilterChanged;
  final ValueChanged<StaffPerformanceRow>? onStaffSelected;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أداء الموظفين',
            style: AppTypography.titleOf(
              context,
            ).copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: dense ? 2 : AppSpacing.xs),
          Text(
            'طلبات أنشأها كل مندوب / مدير تشغيل خلال الفترة المختارة',
            style: AppTypography.captionOf(
              context,
            ).copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
          Wrap(
            spacing: dense ? DesktopUiTokens.gapXs : AppSpacing.xs,
            runSpacing: dense ? DesktopUiTokens.gapXs : AppSpacing.xs,
            textDirection: TextDirection.rtl,
            children: [
              _RoleChip(
                label: 'الكل',
                selected: roleFilter == null,
                onTap: () => onRoleFilterChanged(null),
              ),
              _RoleChip(
                label: UserRole.deliveryWorker.arabicLabel,
                selected: roleFilter == UserRole.deliveryWorker,
                onTap: () => onRoleFilterChanged(UserRole.deliveryWorker),
              ),
              _RoleChip(
                label: UserRole.productionManager.arabicLabel,
                selected: roleFilter == UserRole.productionManager,
                onTap: () => onRoleFilterChanged(UserRole.productionManager),
              ),
            ],
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapMd : AppSpacing.md),
          if (rows.isEmpty)
            const EmptyStateWidget(
              message: 'لا يوجد نشاط موظفين في هذه الفترة',
              icon: Icons.badge_outlined,
            )
          else if (dense)
            for (final row in rows) ...[
              DesktopActionRow(
                title: row.displayName,
                subtitle:
                    '${row.role.arabicLabel}'
                    '${row.isActive ? '' : ' · موقوف'}'
                    '${row.phone == null || row.phone!.isEmpty ? '' : ' · ${row.phone}'}',
                leadingIcon: Icons.badge_outlined,
                statusColor: row.isActive
                    ? AppColors.success
                    : AppColors.onSurfaceVariant,
                onTap: onStaffSelected == null
                    ? null
                    : () => onStaffSelected!(row),
                trailing: Text(
                  SarMoney.amount(row.agreementValue),
                  style: AppTypography.labelOf(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.onPrimaryFixedVariant,
                  ),
                ),
              ),
              const SizedBox(height: DesktopUiTokens.gapXs),
              _DenseMetricsStrip(
                cells: [
                  ('طلبات', '${row.ordersCreated}'),
                  ('مكتملة', '${row.completedOrders}'),
                  ('إجراءات', '${row.opsActions}'),
                  ('ملغاة', '${row.cancelledOrders}'),
                  ('مقدمات محصّلة', SarMoney.amount(row.downPayments)),
                ],
              ),
              const SizedBox(height: DesktopUiTokens.gapSm),
            ]
          else
            for (final row in rows) ...[
              DecorativeSummaryCard(
                tone: DecorativeCardTone.blue,
                title: row.displayName,
                subtitle:
                    '${row.role.arabicLabel}'
                    '${row.isActive ? '' : ' · موقوف'}'
                    '${row.phone == null || row.phone!.isEmpty ? '' : ' · ${row.phone}'}',
                onTap: onStaffSelected == null
                    ? null
                    : () => onStaffSelected!(row),
                metrics: [
                  DecorativeSummaryMetric(
                    label: 'طلبات',
                    value: '${row.ordersCreated}',
                  ),
                  DecorativeSummaryMetric(
                    label: 'مكتملة',
                    value: '${row.completedOrders}',
                  ),
                  DecorativeSummaryMetric(
                    label: 'قيمة',
                    value: SarMoney.amount(row.agreementValue),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              _StaffDetailStrip(row: row),
              SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}

class _DenseMetricsStrip extends StatelessWidget {
  const _DenseMetricsStrip({required this.cells});

  final List<(String, String)> cells;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesktopUiTokens.gapSm,
        vertical: DesktopUiTokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(DesktopUiTokens.radiusSm),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Wrap(
        spacing: DesktopUiTokens.gapLg,
        runSpacing: DesktopUiTokens.gapXs,
        textDirection: TextDirection.rtl,
        children: [
          for (final cell in cells)
            SizedBox(
              width: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    cell.$1,
                    style: AppTypography.labelOf(
                      context,
                    ).copyWith(color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    cell.$2,
                    style: AppTypography.bodyOf(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StaffDetailStrip extends StatelessWidget {
  const _StaffDetailStrip({required this.row});

  final StaffPerformanceRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _MiniStat(label: 'إجراءات تشغيل', value: '${row.opsActions}'),
          _MiniStat(label: 'ملغاة', value: '${row.cancelledOrders}'),
          _MiniStat(
            label: 'مقدمات محصّلة',
            value: SarMoney.amount(row.downPayments),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.caption().copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.captionBold().copyWith(
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: AppTypography.labelOf(context).copyWith(
          color: selected
              ? AppColors.onPrimaryFixed
              : AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.secondaryFixed,
      backgroundColor: AppColors.surfaceContainerLow,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }
}
