import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/cards/decorative_summary_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Skeleton for delivery workers list — search, filter chips, and summary cards.
class DeliveryWorkersListSkeleton extends StatelessWidget {
  const DeliveryWorkersListSkeleton({super.key, this.itemCount = 5});

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
          0,
          AppSpacing.containerPadding,
          AppSpacing.md,
        ),
        children: [
          SizedBox(height: AppSpacing.md),
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
                  width: 56,
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
              child: DecorativeSummaryCard(
                title: 'مندوب التسليم',
                subtitle: '01012345678',
                icon: Icons.local_shipping_rounded,
                badge: 'نشط',
                tone: DecorativeCardTone.green,
                metrics: const [
                  DecorativeSummaryMetric(
                    label: 'البريد',
                    value: 'worker@example.com',
                  ),
                  DecorativeSummaryMetric(
                    label: 'تاريخ الإضافة',
                    value: '2026/01/01',
                  ),
                  DecorativeSummaryMetric(label: 'الحالة', value: 'يعمل'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
