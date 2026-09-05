import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/decorative_card_shell.dart';
import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ProductsListSkeleton extends StatelessWidget {
  const ProductsListSkeleton({super.key, this.itemCount = 6});

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
          AppSpacing.sm,
          AppSpacing.containerPadding,
          AppSpacing.md,
        ),
        children: [
          Bone(height: 48, borderRadius: BorderRadius.circular(14)),
          SizedBox(height: AppSpacing.sm),
          Bone.text(words: 1, style: Theme.of(context).textTheme.labelMedium),
          SizedBox(height: AppSpacing.sm),
          ...List.generate(
            itemCount,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
              child: DecorativeCardShell(
                tone: DecorativeCardTone.warm,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Bone.circle(size: 48),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: List.generate(
                                    2,
                                    (_) => Bone(
                                      width: 52,
                                      height: 22,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xs),
                                Bone.text(
                                  words: 2,
                                  style: AppTypography.headlineSm(),
                                ),
                                SizedBox(height: AppSpacing.xs),
                                Bone.text(
                                  words: 4,
                                  style: AppTypography.bodyMd(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Bone(height: 1, width: double.infinity),
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(
                            child: Bone.text(
                              words: 6,
                              style: AppTypography.labelMd(),
                            ),
                          ),
                          Bone(
                            width: 56,
                            height: 28,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
