import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// Geometric "Portal" motifs — door frames anchored to containers.
abstract final class AppShapes {
  /// Vertical status bar for order cards (leading edge in RTL = right).
  static BoxDecoration statusBar({
    required Color color,
    BorderRadius? borderRadius,
  }) => BoxDecoration(
    color: color,
    borderRadius: borderRadius ?? AppRadius.lgAll,
  );

  /// Door-frame corner accent — top-leading geometric cut.
  static Border portalFrameBorder({Color? color, double width = 1.5}) =>
      Border.all(
        color: color ?? AppColors.secondary.withValues(alpha: 0.22),
        width: width,
      );

  /// Pill chip for manufacturing status.
  static BoxDecoration statusChip({
    required Color background,
    required Color foreground,
  }) => BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(AppRadius.full),
    border: Border.all(color: foreground.withValues(alpha: 0.2)),
  );

  /// Icon enclosure — small tool-like square.
  static BoxDecoration iconEnclosure({Color? fill}) => BoxDecoration(
    color: fill ?? AppColors.secondary.withValues(alpha: 0.1),
    borderRadius: AppRadius.mdAll,
  );

  /// Circular icon well.
  static BoxDecoration circularIconWell({Color? fill}) => BoxDecoration(
    color: fill ?? AppColors.primaryContainer.withValues(alpha: 0.12),
    shape: BoxShape.circle,
  );
}
