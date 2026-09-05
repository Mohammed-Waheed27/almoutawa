import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Corner radii — soft industrial curves (no sharp 4px shells).
abstract final class AppRadius {
  static const double _sm = 8;
  static const double _md = 12;
  static const double _lg = 16;
  static const double _xl = 24;

  /// Form fields — soft corners, tighter than cards (was 14).
  static const double _input = 8;
  static const double _button = 12;

  static double get sm => _sm.r;
  static double get md => _md.r;
  static double get lg => _lg.r;
  static double get xl => _xl.r;
  static double get input => _input.r;
  static double get button => _button.r;
  static double get full => 9999.r;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get inputAll => BorderRadius.circular(input);
  static BorderRadius get buttonAll => BorderRadius.circular(button);
}
