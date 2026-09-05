import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class DeliveryOrderDetailSkeleton extends StatelessWidget {
  const DeliveryOrderDetailSkeleton({super.key});

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
            variant: AlmoutawaCardVariant.glass,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == 3 ? 0 : AppSpacing.sm,
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Bone.text(
                          words: 1,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
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
          SizedBox(height: AppSpacing.sectionMargin),
          Bone(
            height: 88,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
        ],
      ),
    );
  }
}
