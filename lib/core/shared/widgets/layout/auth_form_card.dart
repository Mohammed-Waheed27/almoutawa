import 'package:flutter/material.dart';

import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../surfaces/liquid_glass_surface.dart';

/// Glass panel wrapper for auth forms and detail sections.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      borderRadius: AppRadius.smAll,
      blurSigma: 8,
      tintOpacity: 0.85,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}
