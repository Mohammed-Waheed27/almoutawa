import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/stats_bento_tile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Placeholder layout for the delivery home hub during skeleton reload.
class DeliveryHomeHubSkeleton extends StatelessWidget {
  const DeliveryHomeHubSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: StatsBentoTile(
                    size: StatsBentoTileSize.mini,
                    label: 'نشطة',
                    value: '0',
                    icon: Icons.pending_actions_rounded,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatsBentoTile(
                    size: StatsBentoTileSize.mini,
                    label: 'منتهية',
                    value: '0',
                    icon: Icons.task_alt_rounded,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Bone(
              height: AppLayout.listRowMinHeight,
              borderRadius: AppRadius.lgAll,
            ),
            SizedBox(height: AppSpacing.stackGap),
            Bone(
              height: AppLayout.listRowMinHeight,
              borderRadius: AppRadius.lgAll,
            ),
          ],
        ),
      ),
    );
  }
}
