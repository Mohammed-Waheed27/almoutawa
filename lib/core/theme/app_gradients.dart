import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand gradients — action CTAs and ambient mesh backgrounds.
abstract final class AppGradients {
  /// Primary CTA — operational blue (matches hub / reference ERP headers).
  static const LinearGradient action = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondaryContainer, AppColors.secondary],
  );

  /// Primary app bar — saturated teal-to-blue (shell tab roots).
  static const LinearGradient primaryAppBar = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.appBarPrimaryStart, AppColors.appBarPrimaryEnd],
  );

  /// Secondary app bar — same family, slightly deeper (pushed sub-pages).
  static const LinearGradient secondaryAppBar = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.appBarSecondaryStart, AppColors.appBarSecondaryEnd],
  );

  /// Tab hub app bar — legacy light wash (prefer [primaryAppBar]).
  @Deprecated('Use primaryAppBar for shell tab roots')
  static const LinearGradient hubHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surfaceContainerHighest,
      AppColors.secondaryFixed,
      AppColors.primaryFixedDim,
    ],
  );

  /// Sub-page app bar — legacy light wash (prefer [secondaryAppBar]).
  @Deprecated('Use secondaryAppBar for sub-pages')
  static const LinearGradient subpageHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFF4FF), Color(0xFFD3E4FE)],
  );

  /// Deep brand strip — rare brand moments only, not tab hubs.
  static const LinearGradient sapphireHeader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primary, AppColors.primaryContainer],
  );

  /// Bento stat hero tile — stays in the blue family.
  static const LinearGradient bentoHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondaryContainer, AppColors.secondary],
  );

  /// Subtle card highlight wash.
  static const LinearGradient cardHighlight = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.surfaceContainerLow, AppColors.surfaceContainerHighest],
  );

  /// Customer list / profile rows — lighter blue family, reduced intensity.
  static const LinearGradient customerCard = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      AppColors.surfaceContainerHighest,
      AppColors.secondaryFixed,
      AppColors.surfaceContainerLow,
    ],
  );

  /// Glass nav bar fade.
  static LinearGradient get glassNav => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.white.withValues(alpha: 0.88),
      AppColors.white.withValues(alpha: 0.72),
    ],
  );

  /// Mesh background radial blobs (use with Stack + blur).
  static RadialGradient meshBlob({
    required Color color,
    double radius = 0.85,
  }) => RadialGradient(
    colors: [color, color.withValues(alpha: 0)],
    radius: radius,
  );

  static RadialGradient get meshSecondaryBlob =>
      meshBlob(color: AppColors.meshSecondary);

  static RadialGradient get meshTertiaryBlob =>
      meshBlob(color: AppColors.meshTertiary);

  static RadialGradient get meshPrimaryBlob =>
      meshBlob(color: AppColors.meshPrimary);
}
