import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 4px baseline grid from Sapphire Blueprint — scaled via ScreenUtil.
abstract final class AppSpacing {
  static const double _unit = 4;

  static double get unit => _unit.w;

  static double get xs => _unit.w;
  static double get sm => (_unit * 2).w;
  static double get md => (_unit * 3).w;
  static double get lg => (_unit * 4).w;
  static double get xl => (_unit * 6).w;
  static double get xxl => (_unit * 8).w;

  static double get containerPadding => 16.w;
  static double get stackGap => 12.w;
  static double get gridGutter => 16.w;
  static double get sectionMargin => 24.w;
}
