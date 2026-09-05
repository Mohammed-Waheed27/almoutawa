import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Skeleton matching create-order: factory chips + customer card + notes.
class WorkOrderCreateSkeleton extends StatelessWidget {
  const WorkOrderCreateSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: AppColors.surfaceContainer,
        highlightColor: AppColors.surfaceContainerHighest,
      ),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.containerPadding),
        children: [
          Bone.text(words: 2, style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppSpacing.sm),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(child: Bone(height: 64, borderRadius: AppRadius.lgAll)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: Bone(height: 64, borderRadius: AppRadius.lgAll)),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AlmoutawaCard(
            variant: AlmoutawaCardVariant.tinted,
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Bone.text(
                  words: 3,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                SizedBox(height: AppSpacing.xs),
                Bone.text(
                  words: 4,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Bone.text(
                  words: 3,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Bone(height: 88, borderRadius: AppRadius.inputAll),
          SizedBox(height: AppSpacing.lg),
          Bone(height: 48, borderRadius: AppRadius.buttonAll),
        ],
      ),
    );
  }
}
