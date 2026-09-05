import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

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

class AdminReportsCustomersSection extends StatelessWidget {
  const AdminReportsCustomersSection({
    super.key,
    required this.rows,
    this.onCustomerSelected,
  });

  final List<CustomerPerformanceRow> rows;
  final ValueChanged<CustomerPerformanceRow>? onCustomerSelected;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'نشاط العملاء',
          style: AppTypography.titleOf(
            context,
          ).copyWith(fontWeight: FontWeight.w800),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: dense ? 2 : AppSpacing.xs),
        Text(
          'كم طلبًا وقيمة عمل لكل عميل خلال الفترة',
          style: AppTypography.captionOf(
            context,
          ).copyWith(color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: dense ? DesktopUiTokens.gapMd : AppSpacing.md),
        if (rows.isEmpty)
          const EmptyStateWidget(
            message: 'لا يوجد عملاء لديهم طلبات في هذه الفترة',
            icon: Icons.groups_outlined,
          )
        else if (dense)
          for (final row in rows) ...[
            DesktopActionRow(
              title: row.displayName,
              subtitle:
                  '#${row.customerNumber} · ${row.customerTypeLabel}'
                  '${row.governorate == null || row.governorate!.isEmpty ? '' : ' · ${row.governorate}'}',
              leadingIcon: Icons.person_outline_rounded,
              statusColor: row.activeOrders > 0
                  ? AppColors.success
                  : AppColors.onSurfaceVariant,
              onTap: onCustomerSelected == null
                  ? null
                  : () => onCustomerSelected!(row),
              trailing: Text(
                SarMoney.amount(row.agreementValue),
                style: AppTypography.labelOf(context).copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPrimaryFixedVariant,
                ),
              ),
            ),
            const SizedBox(height: DesktopUiTokens.gapXs),
            Container(
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
                  _DenseCell(label: 'طلبات', value: '${row.ordersCount}'),
                  _DenseCell(label: 'نشطة', value: '${row.activeOrders}'),
                  _DenseCell(label: 'مكتملة', value: '${row.completedOrders}'),
                  _DenseCell(label: 'ملغاة', value: '${row.cancelledOrders}'),
                  _DenseCell(
                    label: 'مقدم',
                    value: SarMoney.amount(row.downPayments),
                  ),
                  _DenseCell(
                    label: 'آخر طلب',
                    value: row.lastOrderAt == null
                        ? '—'
                        : DateFormat('dd/MM').format(row.lastOrderAt!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesktopUiTokens.gapSm),
          ]
        else
          for (final row in rows) ...[
            DecorativeSummaryCard(
              tone: DecorativeCardTone.teal,
              title: row.displayName,
              subtitle:
                  '#${row.customerNumber} · ${row.customerTypeLabel}'
                  '${row.governorate == null || row.governorate!.isEmpty ? '' : ' · ${row.governorate}'}'
                  '${row.phone == null || row.phone!.isEmpty ? '' : ' · ${row.phone}'}',
              badge: row.activeOrders > 0 ? 'نشط' : null,
              onTap: onCustomerSelected == null
                  ? null
                  : () => onCustomerSelected!(row),
              metrics: [
                DecorativeSummaryMetric(
                  label: 'طلبات',
                  value: '${row.ordersCount}',
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
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _Cell(label: 'قيد التنفيذ', value: '${row.activeOrders}'),
                  _Cell(label: 'ملغاة', value: '${row.cancelledOrders}'),
                  _Cell(
                    label: 'مقدم',
                    value: SarMoney.amount(row.downPayments),
                  ),
                  _Cell(
                    label: 'آخر طلب',
                    value: row.lastOrderAt == null
                        ? '—'
                        : DateFormat('dd/MM').format(row.lastOrderAt!),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}

class _DenseCell extends StatelessWidget {
  const _DenseCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: AppTypography.labelOf(
              context,
            ).copyWith(color: AppColors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: AppTypography.bodyOf(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value});

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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.captionBold().copyWith(
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
