import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class CustomerDetailSkeleton extends StatelessWidget {
  const CustomerDetailSkeleton({super.key});

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
          AlmoutawaCard(
            variant: AlmoutawaCardVariant.softGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(
                  words: 2,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: AppSpacing.sm),
                Bone(
                  width: 72,
                  height: 24,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Bone(height: 44, borderRadius: BorderRadius.circular(AppRadius.lg)),
          SizedBox(height: AppSpacing.md),
          AlmoutawaCard(
            variant: AlmoutawaCardVariant.glass,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == 4 ? 0 : AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone.text(
                        words: 1,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Bone.text(
                        words: 2,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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
