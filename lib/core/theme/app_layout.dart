import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../layout/app_breakpoints.dart';
import 'app_density.dart';
import 'desktop_ui_tokens.dart';

/// Layout metrics — ScreenUtil on compact; logical [DesktopUiTokens] on expanded.
///
/// Prefer `*Of(context)` in shared chrome (app bar, icon buttons). Raw getters
/// remain for compact-only call sites that already sit under ScreenUtil scale-off
/// on desktop via [ScreenUtilConfig.allowScale].
abstract final class AppLayout {
  // Touch targets (Material minimum 48)
  static double get minTouchTarget => 48.w;
  static double get iconButtonSize => 40.w;

  // App bars
  static double get appBarHeight => 56.h;
  static double get hubAppBarSubtitleExtra => 32.h;
  static double get bottomNavHeight => 72.h;

  // Cards — bento / dashboard parity
  static double get bentoTileHeight => 128.h;
  static double get bentoTileHeightCompact => 88.h;
  static double get bentoTileHeightMini => 60.h;
  static double get listRowMinHeight => 72.h;
  static double get portalStatusBarWidth => 4.w;

  // Inputs
  static double get inputHeight => 52.h;
  static double get inputHeightDense => 40.h;
  static double get inputRadius => 8.r;

  // Buttons
  static double get buttonHeight => 48.h;
  static double get buttonRadius => 12.r;
  static double get fabSize => 56.w;

  // Content width caps
  static const double contentMaxWidthCompact = double.infinity;
  static const double contentMaxWidthExpanded = 960;

  static bool _dense(BuildContext context) {
    final d = AppDensityScope.maybeOf(context);
    if (d != null) return d.isExpanded;
    return AppBreakpoints.isExpanded(MediaQuery.sizeOf(context).width);
  }

  static double iconButtonSizeOf(BuildContext context) =>
      _dense(context) ? 36.0 : iconButtonSize;

  static double appBarHeightOf(BuildContext context) =>
      _dense(context) ? DesktopUiTokens.toolbarHeight : appBarHeight;

  static double hubAppBarSubtitleExtraOf(BuildContext context) =>
      _dense(context) ? 22.0 : hubAppBarSubtitleExtra;

  static double bentoTileHeightMiniOf(BuildContext context) =>
      _dense(context) ? 52.0 : bentoTileHeightMini;

  static double iconSizeOf(BuildContext context, {double compactSp = 22}) =>
      _dense(context) ? DesktopUiTokens.iconSize + 2 : compactSp.sp;
}
