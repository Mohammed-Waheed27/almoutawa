import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../work_orders/sections/work_orders_stats_section.dart';
import 'admin_home_stat_card.dart';

class AdminHomeStatsSkeleton extends StatelessWidget {
  const AdminHomeStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final gap = dense ? DesktopUiTokens.gapSm : AppSpacing.sm;

    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: AppColors.surfaceContainer,
        highlightColor: AppColors.surfaceContainerHighest,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AdminHomeStatCard(
              label: 'إجمالي الطلبات',
              count: 0,
              animate: false,
              icon: Icons.inventory_2_outlined,
              tone: DecorativeCardTone.blue,
            ),
            SizedBox(height: gap),
            const WorkOrdersStatsSection(items: []),
          ],
        ),
      ),
    );
  }
}
