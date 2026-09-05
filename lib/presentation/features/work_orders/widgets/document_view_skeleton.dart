import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Skeleton for quote / agreement read-only viewers.
class DocumentViewSkeleton extends StatelessWidget {
  const DocumentViewSkeleton({super.key});

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
            variant: AlmoutawaCardVariant.tinted,
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Bone.text(
                  words: 3,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: AppSpacing.xs),
                Bone.text(
                  words: 4,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: AppSpacing.sm),
                Bone(
                  height: 40,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          AlmoutawaCard(
            variant: AlmoutawaCardVariant.glass,
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: EdgeInsets.only(
                    bottom: i == 3 ? 0 : AppSpacing.sm,
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Bone.text(
                          words: 1,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Bone.text(
                        words: 2,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Bone.text(words: 2, style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppSpacing.sm),
          AlmoutawaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Bone(
                  height: 36,
                  borderRadius: BorderRadius.zero,
                ),
                ...List.generate(
                  3,
                  (i) => Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    child: Bone(
                      height: 28,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          AlmoutawaCard(
            variant: AlmoutawaCardVariant.glass,
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: EdgeInsets.only(
                    bottom: i == 3 ? 0 : AppSpacing.sm,
                  ),
                  child: Bone(
                    height: 18,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
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
