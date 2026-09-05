import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/cards/decorative_summary_card.dart';
import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../domain/entities/commercial_order.dart';

class QuoteViewHeaderSection extends StatelessWidget {
  const QuoteViewHeaderSection({super.key, required this.detail});

  final CommercialOrderDetail detail;

  static final _dateFmt = intl.DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final quote = detail.quote!;
    final dense = context.density.isExpanded;

    if (dense) {
      return DesktopEntityHeaderStrip(
        title: 'عرض سعر #${quote.quoteNumber}',
        subtitle:
            '${detail.customer.displayName} · ${_dateFmt.format(quote.quoteDate)}',
        badge: quote.status.arabicLabel,
        icon: Icons.request_quote_outlined,
        metrics: [
          DesktopEntityMetric(
            label: 'الإجمالي',
            value: quote.grandTotal.toStringAsFixed(2),
          ),
          DesktopEntityMetric(
            label: 'الضريبة',
            value: quote.vatAmount.toStringAsFixed(2),
          ),
          DesktopEntityMetric(label: 'البنود', value: '${quote.lines.length}'),
        ],
      );
    }

    return DecorativeSummaryCard(
      tone: DecorativeCardTone.blue,
      compact: true,
      title: 'عرض سعر #${quote.quoteNumber}',
      subtitle:
          '${detail.customer.displayName} · ${_dateFmt.format(quote.quoteDate)}',
      badge: quote.status.arabicLabel,
      metrics: [
        DecorativeSummaryMetric(
          label: 'الإجمالي',
          value: quote.grandTotal.toStringAsFixed(2),
          valueColor: AppColors.onPrimaryFixedVariant,
        ),
        DecorativeSummaryMetric(
          label: 'الضريبة',
          value: quote.vatAmount.toStringAsFixed(2),
        ),
        DecorativeSummaryMetric(
          label: 'البنود',
          value: '${quote.lines.length}',
        ),
      ],
    );
  }
}
