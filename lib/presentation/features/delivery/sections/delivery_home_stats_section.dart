import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/stats_bento_tile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Compact KPI strip for the delivery home hub — minimal mobile footprint.
class DeliveryHomeStatsSection extends StatelessWidget {
  const DeliveryHomeStatsSection({super.key, required this.readyCount});

  final int readyCount;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: StatsBentoTile(
              size: StatsBentoTileSize.mini,
              label: 'طلبات جاهزة',
              value: '$readyCount',
              icon: Icons.local_shipping_rounded,
              iconColor: AppColors.onPrimaryFixedVariant,
              valueColor: AppColors.onSurface,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: StatsBentoTile(
              size: StatsBentoTileSize.mini,
              label: 'للتسليم',
              value: '$readyCount',
              icon: Icons.task_alt_rounded,
              valueColor: AppColors.onTertiaryContainer,
              iconColor: AppColors.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
