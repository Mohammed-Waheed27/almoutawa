import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import 'app_brand_logo.dart';

/// Role hub greeting — used on home dashboards (no app bar).
class HubGreeting extends StatelessWidget {
  const HubGreeting({super.key, required this.displayName, this.subtitle});

  final String displayName;
  final String? subtitle;

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير،';
    return 'مساء الخير،';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.containerPadding,
          AppSpacing.sm,
          AppSpacing.containerPadding,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _timeGreeting,
              style: AppTypography.labelMd().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'أهلاً بك، $displayName',
              style: AppTypography.displayLg().copyWith(
                color: AppColors.primary,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTypography.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Branded auth hero — login / bootstrap headers.
class AuthHeroHeader extends StatelessWidget {
  const AuthHeroHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showLogo = false,
    this.logoHeight = 128,
  });

  final String? title;
  final String? subtitle;
  final bool showLogo;
  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showLogo) ...[
            Center(child: AppBrandLogo(height: logoHeight)),
            if (title != null || subtitle != null)
              SizedBox(height: AppSpacing.md),
          ],
          if (title != null)
            Text(
              title!,
              textAlign: showLogo ? TextAlign.center : TextAlign.start,
              style: AppTypography.displayLg().copyWith(
                color: AppColors.primary,
              ),
            ),
          if (subtitle != null) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              subtitle!,
              textAlign: showLogo ? TextAlign.center : TextAlign.start,
              style: AppTypography.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
