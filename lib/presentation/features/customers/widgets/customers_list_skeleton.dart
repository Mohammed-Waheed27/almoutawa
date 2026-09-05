import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Skeleton placeholder rows for the customers list initial load.
class CustomersListSkeleton extends StatelessWidget {
  const CustomersListSkeleton({super.key, this.itemCount = 6});

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
          Bone(
            height: 48,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            textDirection: TextDirection.rtl,
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(left: AppSpacing.xs),
                child: Bone(
                  width: 64,
                  height: 36,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ...List.generate(itemCount, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _CustomerRowSkeleton(),
            );
          }),
        ],
      ),
    );
  }
}

class _CustomerRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlmoutawaCard(
      variant: AlmoutawaCardVariant.softGradient,
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone.text(
                        words: 2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Bone.text(
                        words: 1,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Bone(
                  width: 44,
                  height: 22,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.secondaryFixed.withValues(alpha: 0.35),
          ),
          SizedBox(
            height: AppLayout.listRowMinHeight * 0.6,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(child: _SkeletonStatCell()),
                Container(
                  width: 1,
                  height: 32,
                  color: AppColors.secondaryFixed.withValues(alpha: 0.35),
                ),
                Expanded(child: _SkeletonStatCell()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonStatCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Bone.text(words: 1, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Bone.text(words: 1, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
