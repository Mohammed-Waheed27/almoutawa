import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/customer.dart';

class CustomerLedgerSection extends StatelessWidget {
  const CustomerLedgerSection({
    super.key,
    required this.balance,
    required this.entries,
    this.onExportPdf,
  });

  final double balance;
  final List<CustomerAccountEntry> entries;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final formatter = NumberFormat('#,##0.00', 'ar');
    final balanceText = formatter.format(balance);
    final balanceColor = balance > 0 ? AppColors.error : AppColors.success;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'كشف حساب',
                style: AppTypography.headlineSm().copyWith(
                  fontSize: dense ? DesktopUiTokens.pageTitle : null,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (onExportPdf != null)
                    AlmoutawaButton(
                      label: 'تصدير PDF',
                      icon: Icons.picture_as_pdf_outlined,
                      variant: AlmoutawaButtonVariant.tertiaryText,
                      size: AlmoutawaButtonSize.sm,
                      onPressed: onExportPdf,
                    ),
                  Text(
                    'الرصيد الحالي',
                    style: AppTypography.labelBold().copyWith(
                      color: AppColors.outline,
                      fontSize: dense ? DesktopUiTokens.label : null,
                      letterSpacing: dense ? 0 : null,
                    ),
                  ),
                  Text(
                    '$balanceText ج.م',
                    style: AppTypography.headlineMd().copyWith(
                      color: balanceColor,
                      fontSize: dense ? DesktopUiTokens.pageTitle + 2 : null,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapMd : AppSpacing.lg),
          if (entries.isNotEmpty) ...[
            _OrderPaymentsStrip(entries: entries, formatter: formatter),
            SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.md),
          ],
          if (entries.isEmpty)
            Text(
              'لا توجد حركات على الحساب بعد',
              style: AppTypography.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: dense ? DesktopUiTokens.body : null,
              ),
            )
          else
            AlmoutawaCard(
              variant: AlmoutawaCardVariant.solid,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    color: AppColors.surfaceContainerLow,
                    padding: EdgeInsets.symmetric(
                      horizontal: dense ? DesktopUiTokens.gapMd : AppSpacing.lg,
                      vertical: dense ? DesktopUiTokens.gapSm : AppSpacing.md,
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'التاريخ',
                            style: AppTypography.labelBold().copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: dense ? DesktopUiTokens.label : null,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'الوصف',
                            style: AppTypography.labelBold().copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: dense ? DesktopUiTokens.label : null,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'مدين',
                            textAlign: TextAlign.end,
                            style: AppTypography.labelBold().copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: dense ? DesktopUiTokens.label : null,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'دائن',
                            textAlign: TextAlign.end,
                            style: AppTypography.labelBold().copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: dense ? DesktopUiTokens.label : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...entries.map(
                    (entry) => _LedgerRow(
                      entry: entry,
                      formatter: formatter,
                      dense: dense,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.entry,
    required this.formatter,
    required this.dense,
  });

  final CustomerAccountEntry entry;
  final NumberFormat formatter;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final isCredit = entry.entryType == LedgerEntryType.credit;
    final amount = formatter.format(entry.amount);
    final date = DateFormat('yyyy/MM/dd', 'ar').format(entry.occurredAt);
    final bodyStyle = AppTypography.bodyMd().copyWith(
      fontSize: dense ? DesktopUiTokens.body : null,
    );

    return Container(
      constraints: BoxConstraints(
        minHeight: dense ? DesktopUiTokens.denseRowHeight : 0,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: dense ? DesktopUiTokens.gapMd : AppSpacing.lg,
        vertical: dense ? DesktopUiTokens.gapSm : AppSpacing.lg,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(date, style: bodyStyle)),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  entry.description,
                  maxLines: dense ? 2 : null,
                  overflow: dense
                      ? TextOverflow.ellipsis
                      : TextOverflow.visible,
                  style: bodyStyle,
                ),
                if ((entry.orderNumber ?? '').isNotEmpty ||
                    (entry.collectedByName ?? '').isNotEmpty)
                  Text(
                    [
                      if ((entry.orderNumber ?? '').isNotEmpty)
                        'طلب ${entry.orderNumber}',
                      if ((entry.collectedByName ?? '').isNotEmpty)
                        'المندوب: ${entry.collectedByName}',
                    ].join(' · '),
                    style: bodyStyle.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: dense ? DesktopUiTokens.label : 12,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              isCredit ? '—' : amount,
              textAlign: TextAlign.end,
              style: bodyStyle.copyWith(
                color: isCredit ? AppColors.onSurface : AppColors.error,
                fontWeight: isCredit ? null : FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isCredit ? amount : '—',
              textAlign: TextAlign.end,
              style: bodyStyle.copyWith(
                color: isCredit
                    ? AppColors.onTertiaryContainer
                    : AppColors.onSurface,
                fontWeight: isCredit ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderPaymentsStrip extends StatelessWidget {
  const _OrderPaymentsStrip({required this.entries, required this.formatter});

  final List<CustomerAccountEntry> entries;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final groups = <String, _OrderPaymentGroup>{};
    for (final entry in entries) {
      final key = entry.commercialOrderId ?? entry.orderNumber ?? entry.id;
      final current = groups.putIfAbsent(
        key,
        () => _OrderPaymentGroup(
          orderNumber: entry.orderNumber,
          collectorName: entry.collectedByName,
        ),
      );
      if ((current.orderNumber == null || current.orderNumber!.isEmpty) &&
          (entry.orderNumber ?? '').isNotEmpty) {
        current.orderNumber = entry.orderNumber;
      }
      if ((current.collectorName == null || current.collectorName!.isEmpty) &&
          (entry.collectedByName ?? '').isNotEmpty) {
        current.collectorName = entry.collectedByName;
      }
      if (entry.entryType == LedgerEntryType.debit) {
        current.value += entry.amount;
      } else {
        current.paid += entry.amount;
      }
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      textDirection: TextDirection.rtl,
      children: [
        for (final group in groups.values)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  group.orderNumber == null || group.orderNumber!.isEmpty
                      ? 'حركة عامة'
                      : 'طلب ${group.orderNumber}',
                  style: AppTypography.labelBold(),
                ),
                Text(
                  'القيمة ${formatter.format(group.value)} · المدفوع ${formatter.format(group.paid)}',
                  style: AppTypography.caption().copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  group.remaining <= 0.009
                      ? 'مسدد بالكامل'
                      : 'المتبقي ${formatter.format(group.remaining)}',
                  style: AppTypography.captionBold().copyWith(
                    color: group.remaining <= 0.009
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
                if ((group.collectorName ?? '').isNotEmpty)
                  Text(
                    'المندوب: ${group.collectorName}',
                    style: AppTypography.caption().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _OrderPaymentGroup {
  _OrderPaymentGroup({this.orderNumber, this.collectorName});

  String? orderNumber;
  String? collectorName;
  double value = 0;
  double paid = 0;
  double get remaining => value - paid;
}
