import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_shadows.dart';

/// Frosted glass shell — use for cards, buttons, and app bars.
class LiquidGlassSurface extends StatelessWidget {
  const LiquidGlassSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.blurSigma = 10,
    this.tintOpacity = 0.82,
    this.borderOpacity = 0.2,
    this.showShadow = true,
    this.gradient,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final double tintOpacity;
  final double borderOpacity;
  final bool showShadow;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lgAll;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null
                ? AppColors.white.withValues(alpha: tintOpacity)
                : null,
            borderRadius: radius,
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: borderOpacity),
            ),
            boxShadow: showShadow ? AppShadows.card : null,
          ),
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );
  }
}
