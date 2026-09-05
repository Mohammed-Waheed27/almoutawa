import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/portal_list_row.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/commercial_order.dart';

class WorkOrderListCard extends StatelessWidget {
  const WorkOrderListCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  final CommercialOrderSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final order = summary.order;
    final theme = Theme.of(context).textTheme;
    return PortalListRow(
      onTap: onTap,
      statusColor: _phaseColor(order.phase),
      title: summary.customer.displayName,
      subtitle:
          '${order.orderNumber} · رقم العميل ${summary.customer.customerNumber}',
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            order.phase.arabicLabel,
            style: theme.labelMedium?.copyWith(
              color: AppColors.onPrimaryFixedVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (summary.quoteStatus != null)
            Text(
              'عرض: ${summary.quoteStatus!.arabicLabel}',
              style: theme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
        ],
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
