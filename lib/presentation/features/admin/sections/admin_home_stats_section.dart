import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../work_orders/sections/work_orders_stats_section.dart';
import '../widgets/admin_home_stat_card.dart';

class AdminHomeStatsSection extends StatelessWidget {
  const AdminHomeStatsSection({
    super.key,
    required this.items,
    required this.totalCount,
  });

  final List<CommercialOrderSummary> items;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final gap = dense ? DesktopUiTokens.gapSm : AppSpacing.sm;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminHomeStatCard(
            label: 'إجمالي الطلبات',
            count: totalCount,
            icon: Icons.inventory_2_outlined,
            tone: DecorativeCardTone.blue,
          ),
          SizedBox(height: gap),
          WorkOrdersStatsSection(items: items),
        ],
      ),
    );
  }
}
