import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/decorative_card_shell.dart';
import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class PropertyDefinitionsListSkeleton extends StatelessWidget {
  const PropertyDefinitionsListSkeleton({super.key, this.itemCount = 5});

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
          AppSpacing.sectionMargin,
        ),
        children: [
          Bone(
            height: 48,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          SizedBox(height: AppSpacing.sm),
          Bone.text(words: 1, style: Theme.of(context).textTheme.labelMedium),
          SizedBox(height: AppSpacing.sm),
          ...List.generate(
            itemCount,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
              child: DecorativeCardShell(
                tone: DecorativeCardTone.blue,
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Bone.circle(size: 48),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Bone(
                            width: 56,
                            height: 22,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Bone.text(
                            words: 2,
                            style: AppTypography.headlineSm(),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Bone.text(words: 3, style: AppTypography.bodyMd()),
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
