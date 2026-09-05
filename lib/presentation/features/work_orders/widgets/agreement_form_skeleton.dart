import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class AgreementFormSkeleton extends StatelessWidget {
  const AgreementFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: AppColors.surfaceContainer,
        highlightColor: AppColors.surfaceContainerHighest,
      ),
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.containerPadding),
        children: [
          _block(height: 44),
          SizedBox(height: AppSpacing.sm),
          _block(height: 88),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _block(height: 48)),
              SizedBox(width: AppSpacing.xs),
              Expanded(child: _block(height: 48)),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(child: _block(height: 48)),
              SizedBox(width: AppSpacing.xs),
              Expanded(child: _block(height: 48)),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _block(height: 14, width: 100),
          SizedBox(height: AppSpacing.xs),
          ...List.generate(
            2,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _block(height: 168),
            ),
          ),
          _block(height: 48),
        ],
      ),
    );
  }

  Widget _block({double height = 48, double? width}) => Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: AppRadius.mdAll,
    ),
  );
}
