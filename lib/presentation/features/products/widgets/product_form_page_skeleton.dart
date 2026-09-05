import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ProductFormPageSkeleton extends StatelessWidget {
  const ProductFormPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.containerPadding),
        children: [
          Bone.text(words: 3, style: AppTypography.headlineSm()),
          SizedBox(height: AppSpacing.sm),
          Bone.text(words: 8),
          SizedBox(height: AppSpacing.md),
          Bone.multiText(lines: 2),
          SizedBox(height: AppSpacing.sm),
          Bone.multiText(lines: 4),
          SizedBox(height: AppSpacing.md),
          Bone.square(size: 140),
          SizedBox(height: AppSpacing.md),
          Bone.multiText(lines: 3),
        ],
      ),
    );
  }
}
