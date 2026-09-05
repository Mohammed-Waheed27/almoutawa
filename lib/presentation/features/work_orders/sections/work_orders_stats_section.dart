import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/stats_bento_tile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';

/// Compact analysis strip: active vs finished commercial work orders.
class WorkOrdersStatsSection extends StatelessWidget {
  const WorkOrdersStatsSection({
    super.key,
    required this.items,
    this.onActiveTap,
    this.onFinishedTap,
  });

  final List<CommercialOrderSummary> items;
  final VoidCallback? onActiveTap;
  final VoidCallback? onFinishedTap;

  int get _activeCount =>
      items.where((item) => item.order.phase.isActive).length;

  int get _finishedCount =>
      items.where((item) => item.order.phase.isFinished).length;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final gap = dense ? DesktopUiTokens.gapSm : AppSpacing.sm;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: _TappableStat(
              onTap: onActiveTap,
              child: StatsBentoTile(
                size: StatsBentoTileSize.mini,
                label: 'نشطة',
                value: '$_activeCount',
                animatedCount: _activeCount,
                icon: Icons.pending_actions_rounded,
                iconColor: AppColors.onPrimaryFixedVariant,
                valueColor: AppColors.onSurface,
              ),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _TappableStat(
              onTap: onFinishedTap,
              child: StatsBentoTile(
                size: StatsBentoTileSize.mini,
                label: 'منتهية',
                value: '$_finishedCount',
                animatedCount: _finishedCount,
                icon: Icons.task_alt_rounded,
                iconColor: AppColors.onTertiaryContainer,
                valueColor: AppColors.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TappableStat extends StatelessWidget {
  const _TappableStat({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    final dense = context.density.isExpanded;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: dense
            ? BorderRadius.circular(DesktopUiTokens.radiusLg)
            : AppRadius.lgAll,
        child: child,
      ),
    );
  }
}
