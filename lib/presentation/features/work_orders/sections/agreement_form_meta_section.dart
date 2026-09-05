import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/commercial_order.dart';

/// Compact agreement header fields — dense form rhythm (matches quote meta).
class AgreementFormMetaSection extends StatelessWidget {
  const AgreementFormMetaSection({
    super.key,
    required this.detail,
    required this.cityController,
    required this.vatController,
    required this.daysController,
    required this.downController,
    required this.receiptController,
    this.onMetaChanged,
  });

  final CommercialOrderDetail detail;
  final TextEditingController cityController;
  final TextEditingController vatController;
  final TextEditingController daysController;
  final TextEditingController downController;
  final TextEditingController receiptController;

  /// Called when city / VAT / days / down / receipt change so totals stay live.
  final VoidCallback? onMetaChanged;

  @override
  Widget build(BuildContext context) {
    final customer = detail.customer;
    final agreementNumber = detail.agreement?.agreementNumber;

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
                  'بيانات الاتفاقية',
                  style: AppTypography.labelBold().copyWith(
                    color: AppColors.onPrimaryFixedVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                _MetaLine(
                  label: 'المصنع',
                  value: detail.factory?.displayName ?? 'لم يُحدد',
                ),
                _MetaLine(label: 'العميل', value: customer.displayName),
                _MetaLine(label: 'الهاتف', value: customer.phone ?? '—'),
                if (agreementNumber != null)
                  _MetaLine(label: 'رقم الاتفاقية', value: '$agreementNumber'),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: AlmoutawaTextField(
                  controller: cityController,
                  label: 'المدينة',
                  hint: 'مثال: الخليج - سيهات',
                  dense: true,
                  onChanged: (_) => onMetaChanged?.call(),
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AlmoutawaTextField(
                  controller: vatController,
                  label: 'الرقم الضريبي (اختياري)',
                  hint: 'مثال: 300421497900003',
                  dense: true,
                  onChanged: (_) => onMetaChanged?.call(),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: AlmoutawaTextField(
                  controller: daysController,
                  label: 'مدة التصنيع (يوم) (اختياري)',
                  hint: 'مثال: 45',
                  dense: true,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onMetaChanged?.call(),
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AlmoutawaTextField(
                  controller: downController,
                  label: 'الدفعة المقدمة',
                  hint: 'مثال: 13000',
                  dense: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => onMetaChanged?.call(),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          AlmoutawaTextField(
            controller: receiptController,
            label: 'بسند رقم (اختياري)',
            hint: 'مثال: شبكة',
            dense: true,
            onChanged: (_) => onMetaChanged?.call(),
          ),
        ],
      ),
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
      padding: EdgeInsets.only(bottom: 2),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
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
              style: AppTypography.captionBold().copyWith(
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
