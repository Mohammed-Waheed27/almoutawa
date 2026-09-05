import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class ManufacturingCardFormSkeleton extends StatelessWidget {
  const ManufacturingCardFormSkeleton({super.key});

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
          _block(height: 14, width: 140),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _block(height: 48)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _block(height: 48)),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _block(height: 48)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _block(height: 48)),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _block(height: 14, width: 100),
          SizedBox(height: AppSpacing.sm),
          _block(height: 40),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: List.generate(4, (_) => _block(height: 28, width: 72)),
          ),
          SizedBox(height: AppSpacing.md),
          _block(height: 14, width: 120),
          SizedBox(height: AppSpacing.sm),
          ...List.generate(
            3,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs),
              child: _block(height: 72),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _block(height: 48),
          SizedBox(height: AppSpacing.sm),
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
