import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Skeleton for work-orders list — mirrors stats + search + rows.
class WorkOrdersListSkeleton extends StatelessWidget {
  const WorkOrdersListSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: AppColors.surfaceContainer,
        highlightColor: AppColors.surfaceContainerHighest,
      ),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.containerPadding,
          AppSpacing.md,
          AppSpacing.containerPadding,
          AppSpacing.md,
        ),
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Bone(
                  height: AppLayout.bentoTileHeightMini,
                  borderRadius: AppRadius.lgAll,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Bone(
                  height: AppLayout.bentoTileHeightMini,
                  borderRadius: AppRadius.lgAll,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Bone(
            height: 48,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            textDirection: TextDirection.rtl,
            children: List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(left: AppSpacing.xs),
                child: Bone(
                  width: 72,
                  height: 36,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ...List.generate(
            itemCount,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
              child: const AlmoutawaCard(
                child: SizedBox(
                  height: 72,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('طلب عمل · عميل · مرحلة'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
