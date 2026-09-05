import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class QuoteFormSkeleton extends StatelessWidget {
  const QuoteFormSkeleton({super.key});

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
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Bone(height: 48, borderRadius: AppRadius.inputAll),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Bone(height: 48, borderRadius: AppRadius.inputAll),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Bone(height: 72, borderRadius: AppRadius.inputAll),
          SizedBox(height: AppSpacing.sm),
          Bone(height: 96, borderRadius: AppRadius.inputAll),
          SizedBox(height: AppSpacing.md),
          ...List.generate(
            2,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Bone(height: 160, borderRadius: AppRadius.mdAll),
            ),
          ),
          Bone(height: 100, borderRadius: AppRadius.mdAll),
          SizedBox(height: AppSpacing.md),
          Bone(height: 48, borderRadius: AppRadius.buttonAll),
        ],
      ),
    );
  }
}
