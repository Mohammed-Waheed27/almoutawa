import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/layout/info_panel_section.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/commercial_order.dart';

class AgreementViewTotalsSection extends StatelessWidget {
  const AgreementViewTotalsSection({super.key, required this.agreement});

  final OrderAgreement agreement;

  @override
  Widget build(BuildContext context) {
    return InfoPanelSection(
      title: 'ملخص الاتفاقية',
      compact: true,
      rows: [
        if (agreement.clientCity != null && agreement.clientCity!.isNotEmpty)
          InfoPanelRow(label: 'المدينة', value: agreement.clientCity!),
        if (agreement.clientVatNumber != null &&
            agreement.clientVatNumber!.isNotEmpty)
          InfoPanelRow(
            label: 'الرقم الضريبي',
            value: agreement.clientVatNumber!,
          ),
        InfoPanelRow(
          label: 'مدة التصنيع',
          value: agreement.manufacturingDays == null
              ? '—'
              : '${agreement.manufacturingDays} يوم عمل',
        ),
        InfoPanelRow(
          label: 'القيمة',
          value: agreement.subtotal.toStringAsFixed(2),
        ),
        for (final extra in agreement.extraCharges.where(
          (item) => item.name.trim().isNotEmpty || item.amount != 0,
        ))
          InfoPanelRow(
            label: extra.name.trim().isEmpty
                ? 'مصروف إضافي'
                : extra.name.trim(),
            value: extra.amount.toStringAsFixed(2),
          ),
        InfoPanelRow(
          label:
              'ضريبة القيمة المضافة ${(agreement.vatRate * 100).toStringAsFixed(0)}%',
          value: agreement.vatAmount.toStringAsFixed(2),
        ),
        if (agreement.discountAmount > 0)
          InfoPanelRow(
            label: 'خصم بعد الضريبة',
            value: agreement.discountAmount.toStringAsFixed(2),
          ),
        InfoPanelRow(
          label: 'الإجمالي',
          value: agreement.grandTotal.toStringAsFixed(2),
          highlight: true,
          valueColor: AppColors.onPrimaryFixedVariant,
        ),
        InfoPanelRow(
          label: 'الدفعة المقدمة',
          value: agreement.downPayment.toStringAsFixed(2),
        ),
        if (agreement.receiptReference != null &&
            agreement.receiptReference!.isNotEmpty)
          InfoPanelRow(label: 'بسند رقم', value: agreement.receiptReference!),
        InfoPanelRow(
          label: 'المتبقي',
          value: (agreement.grandTotal - agreement.downPayment)
              .clamp(0, double.infinity)
              .toStringAsFixed(2),
        ),
      ],
    );
  }
}
