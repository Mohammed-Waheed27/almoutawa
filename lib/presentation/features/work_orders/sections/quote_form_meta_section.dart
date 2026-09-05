import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/commercial_order.dart';

/// Compact customer snapshot + quote date / discount for the PDF meta block.
class QuoteFormMetaSection extends StatelessWidget {
  const QuoteFormMetaSection({
    super.key,
    required this.detail,
    required this.quoteDate,
    required this.discountController,
    required this.onPickDate,
    required this.onDiscountChanged,
  });

  final CommercialOrderDetail detail;
  final DateTime quoteDate;
  final TextEditingController discountController;
  final VoidCallback onPickDate;
  final ValueChanged<String> onDiscountChanged;

  static final _dateFmt = intl.DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final customer = detail.customer;
    final quoteNumber = detail.quote?.quoteNumber;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: AppColors.secondaryFixed.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'بيانات العميل في العرض',
                  style: AppTypography.labelBold().copyWith(
                    color: AppColors.onPrimaryFixedVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                _MetaLine(
                  label: 'المصنع',
                  value: detail.factory?.displayName ?? 'لم يُحدد',
                ),
                _MetaLine(
                  label: 'العميل',
                  value: 'المحترم / ${customer.displayName}',
                ),
                _MetaLine(
                  label: 'رقم العميل',
                  value: '${customer.customerNumber}',
                ),
                _MetaLine(label: 'الهاتف', value: customer.phone ?? '—'),
                _MetaLine(
                  label: 'العنوان',
                  value: [
                    if ((customer.address ?? '').isNotEmpty) customer.address,
                    if ((customer.governorate ?? '').isNotEmpty)
                      customer.governorate,
                  ].whereType<String>().join(' - ').ifEmpty('—'),
                ),
                if (quoteNumber != null)
                  _MetaLine(label: 'رقم التسعيرة', value: '$quoteNumber'),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DateField(
                  label: 'تاريخ العرض',
                  value: _dateFmt.format(quoteDate),
                  onTap: onPickDate,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AlmoutawaTextField(
                  controller: discountController,
                  label: 'الخصم ر.س',
                  hint: 'مثال: 500',
                  dense: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: onDiscountChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Matches [AlmoutawaTextField] layout: external label above + dense field.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.outlineVariant.withValues(alpha: 0.65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTypography.labelMd().copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Material(
          color: AppColors.white,
          borderRadius: AppRadius.inputAll,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.inputAll,
            child: InputDecorator(
              isEmpty: false,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs + 2,
                ),
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.55),
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.inputAll,
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputAll,
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputAll,
                  borderSide: BorderSide(
                    color: AppColors.secondary.withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                ),
              ),
              child: Text(
                value,
                style: AppTypography.bodyMd(),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: AppTypography.caption().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.captionBold(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
