import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/settings/settings_group_section.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class CompanySettingsSkeleton extends StatelessWidget {
  const CompanySettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: AppColors.surfaceContainer,
        highlightColor: AppColors.surfaceContainerHighest,
      ),
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.containerPadding),
        children: const [
          SettingsGroupSection(
            title: 'الضريبة',
            children: [SizedBox(height: 120)],
          ),
          SizedBox(height: 12),
          SettingsGroupSection(
            title: 'أرقام التواصل',
            children: [SizedBox(height: 180)],
          ),
        ],
      ),
    );
  }
}
