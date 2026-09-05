import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/customer.dart';

class CustomerInfoSection extends StatelessWidget {
  const CustomerInfoSection({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final fields = <Widget>[
      if (customer.address?.isNotEmpty == true)
        _InfoField(label: 'العنوان', value: customer.address!, dense: dense),
      _InfoField(
        label: 'المحافظة',
        value: customer.governorate?.isNotEmpty == true
            ? customer.governorate!
            : 'غير محدد',
        dense: dense,
      ),
      _InfoField(
        label: 'الهاتف',
        value: customer.primaryPhone,
        valueColor: AppColors.secondary,
        dense: dense,
      ),
      if (customer.type == CustomerType.company) ...[
        if (customer.responsiblePerson?.isNotEmpty == true)
          _InfoField(
            label: 'المسؤول',
            value: customer.responsiblePerson!,
            dense: dense,
          ),
        if (customer.commercialRegister?.isNotEmpty == true)
          _InfoField(
            label: 'السجل التجاري',
            value: customer.commercialRegister!,
            dense: dense,
          ),
      ],
      _InfoField(
        label: 'ملاحظات',
        value: customer.notes?.isNotEmpty == true
            ? customer.notes!
            : 'لا توجد ملاحظات',
        dense: dense,
      ),
      _InfoField(
        label: 'أضيف بواسطة',
        value: customer.createdByDisplayName ?? '—',
        dense: dense,
      ),
      _InfoField(
        label: 'تاريخ الإضافة',
        value: _formatDate(customer.createdAt),
        dense: dense,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlmoutawaCard(
        variant: dense
            ? AlmoutawaCardVariant.solid
            : AlmoutawaCardVariant.glass,
        padding: EdgeInsets.all(dense ? DesktopUiTokens.gapMd : AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (dense)
              Wrap(
                spacing: DesktopUiTokens.gapLg,
                runSpacing: DesktopUiTokens.gapMd,
                textDirection: TextDirection.rtl,
                children: [
                  for (final f in fields) SizedBox(width: 280, child: f),
                ],
              )
            else
              ...fields,
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
    required this.dense,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool dense;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: dense ? DesktopUiTokens.gapSm : AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelBold().copyWith(
              color: AppColors.outline,
              fontSize: dense ? DesktopUiTokens.label : null,
              letterSpacing: dense ? 0 : 0.8,
            ),
          ),
          SizedBox(height: dense ? 2 : AppSpacing.xs),
          Text(
            value,
            maxLines: dense ? 3 : null,
            overflow: dense ? TextOverflow.ellipsis : TextOverflow.visible,
            style: AppTypography.bodyMd().copyWith(
              color: valueColor ?? AppColors.onSurface,
              fontSize: dense ? DesktopUiTokens.body : null,
              fontWeight: valueColor != null ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }
}
