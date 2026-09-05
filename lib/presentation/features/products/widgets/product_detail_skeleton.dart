import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/decorative_card_shell.dart';
import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

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
          DecorativeCardShell(
            tone: DecorativeCardTone.warm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(
                  words: 3,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: AppSpacing.sm),
                Bone.text(words: 5),
                SizedBox(height: AppSpacing.md),
                Bone(
                  height: 52,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Bone(height: 44, borderRadius: BorderRadius.circular(AppRadius.lg)),
          SizedBox(height: AppSpacing.md),
          Bone(height: 120, borderRadius: BorderRadius.circular(AppRadius.lg)),
          SizedBox(height: AppSpacing.md),
          ...List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
              child: Bone(
                height: 72,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
