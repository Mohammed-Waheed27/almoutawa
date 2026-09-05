import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Tonal layering shadows — soft industrial depth.
abstract final class AppShadows {
  static const Color _shadowColor = Color(0x140F2557); // rgba(15,37,87,0.08)
  static const Color _shadowColorElevated = Color(0x1F0F2557); // 0.12

  /// Level 1 — cards and list rows.
  static List<BoxShadow> get card => [
    BoxShadow(color: _shadowColor, blurRadius: 12.r, offset: Offset(0, 4.h)),
  ];

  /// Level 2 — modals, active panels.
  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: _shadowColorElevated,
      blurRadius: 24.r,
      offset: Offset(0, 8.h),
    ),
  ];

  /// Primary-tinted glow for glass / hero emphasis.
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: AppColors.secondary.withValues(alpha: 0.18),
      blurRadius: 20.r,
      offset: Offset(0, 4.h),
    ),
  ];
}
