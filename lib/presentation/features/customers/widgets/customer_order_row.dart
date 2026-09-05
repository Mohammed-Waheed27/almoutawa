import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/shared/widgets/cards/portal_list_row.dart';
import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/commercial_order.dart';

class CustomerOrderRow extends StatelessWidget {
  const CustomerOrderRow({
    super.key,
    required this.summary,
    required this.onTap,
  });

  final CommercialOrderSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final order = summary.order;
    final date = DateFormat('yyyy/MM/dd', 'ar').format(order.createdAt);
    final subtitleParts = <String>[
      order.phase.arabicLabel,
      if (summary.quoteStatus != null)
        'عرض: ${summary.quoteStatus!.arabicLabel}',
      date,
    ];
    final subtitle = subtitleParts.join(' · ');
    final statusColor = _phaseColor(order.phase);

    if (context.density.isExpanded) {
      return DesktopActionRow(
        title: order.orderNumber,
        subtitle: subtitle,
        leadingIcon: Icons.assignment_outlined,
        statusColor: statusColor,
        onTap: onTap,
        trailing: Text(
          order.phase.arabicLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelOf(context).copyWith(
            color: AppColors.onPrimaryFixedVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return PortalListRow(
      onTap: onTap,
      statusColor: statusColor,
      title: order.orderNumber,
      subtitle: subtitle,
      trailing: Text(
        order.phase.arabicLabel,
        style: AppTypography.labelMd().copyWith(
          color: AppColors.onPrimaryFixedVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _phaseColor(CommercialOrderPhase phase) => switch (phase) {
    CommercialOrderPhase.quote => AppColors.secondaryContainer,
    CommercialOrderPhase.agreement => AppColors.onTertiaryContainer,
    CommercialOrderPhase.manufacturingDraft => AppColors.outline,
    CommercialOrderPhase.manufacturing => AppColors.tertiary,
    CommercialOrderPhase.completed => AppColors.secondary,
    CommercialOrderPhase.delivered => AppColors.success,
    CommercialOrderPhase.cancelled => AppColors.error,
  };
}
