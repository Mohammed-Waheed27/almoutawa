import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_breakpoints.dart';

/// Design canvas for [ScreenUtilInit] — standard mobile reference (375×812).
///
/// On **expanded** (≥1024) widths, ScreenUtil scale must be **off**. Otherwise
/// `.w` / `.h` / `.sp` inflate spacing/icons relative to text (`minTextAdapt`)
/// and copy appears to “float” in oversized empty chrome.
abstract final class ScreenUtilConfig {
  static const Size designSize = Size(375, 812);

  static const bool minTextAdapt = true;
  static const bool splitScreenMode = true;

  /// Compact / medium phones & tablets — allow ScreenUtil scale.
  static bool allowScale() {
    try {
      return ScreenUtil().screenWidth < AppBreakpoints.expanded;
    } catch (_) {
      return true;
    }
  }
}
