import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/cards/decorative_summary_card.dart';
import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../domain/entities/commercial_order.dart';

class AgreementViewHeaderSection extends StatelessWidget {
  const AgreementViewHeaderSection({super.key, required this.detail});

  final CommercialOrderDetail detail;

  static final _dateFmt = intl.DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final agreement = detail.agreement!;
    final dense = context.density.isExpanded;

    if (dense) {
      return DesktopEntityHeaderStrip(
        title: 'اتفاقية #${agreement.agreementNumber}',
        subtitle:
            '${detail.customer.displayName} · ${_dateFmt.format(agreement.agreementDate)}',
        badge: agreement.status.arabicLabel,
        icon: Icons.handshake_outlined,
        metrics: [
          DesktopEntityMetric(
            label: 'الإجمالي',
            value: agreement.grandTotal.toStringAsFixed(2),
          ),
          DesktopEntityMetric(
            label: 'مقدم',
            value: agreement.downPayment.toStringAsFixed(2),
          ),
          DesktopEntityMetric(
            label: 'أيام',
            value: agreement.manufacturingDays?.toString() ?? '—',
          ),
        ],
      );
    }

    return DecorativeSummaryCard(
      tone: DecorativeCardTone.teal,
      compact: true,
      title: 'اتفاقية #${agreement.agreementNumber}',
      subtitle:
          '${detail.customer.displayName} · ${_dateFmt.format(agreement.agreementDate)}',
      badge: agreement.status.arabicLabel,
      metrics: [
        DecorativeSummaryMetric(
          label: 'الإجمالي',
          value: agreement.grandTotal.toStringAsFixed(2),
          valueColor: AppColors.onPrimaryFixedVariant,
        ),
        DecorativeSummaryMetric(
          label: 'مقدم',
          value: agreement.downPayment.toStringAsFixed(2),
        ),
        DecorativeSummaryMetric(
          label: 'أيام',
          value: agreement.manufacturingDays?.toString() ?? '—',
        ),
      ],
    );
  }
}
