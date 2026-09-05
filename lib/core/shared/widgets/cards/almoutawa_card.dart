import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../surfaces/liquid_glass_surface.dart';

/// Card visual variants for the Sapphire design system.
enum AlmoutawaCardVariant {
  /// White elevated surface — dense lists.
  solid,

  /// Frosted glass — emphasis panels.
  glass,

  /// Gradient hero — KPI / bento tiles.
  gradient,

  /// Portal edge bar (RTL start) — navigable rows.
  portal,

  /// Light blue list surface — customer/order rows.
  tinted,

  /// Soft blue gradient — customer profile / list rows.
  softGradient,
}

/// Unified card shell — solid, glass, gradient, or portal.
class AlmoutawaCard extends StatelessWidget {
  const AlmoutawaCard({
    super.key,
    required this.child,
    this.variant = AlmoutawaCardVariant.solid,
    this.onTap,
    this.padding,
    this.statusColor,
    this.minHeight,
    this.borderRadius,
  });

  final Widget child;
  final AlmoutawaCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? statusColor;
  final double? minHeight;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lgAll;
    final contentPadding = padding ?? EdgeInsets.all(AppSpacing.lg);

    Widget card = switch (variant) {
      AlmoutawaCardVariant.glass => LiquidGlassSurface(
        borderRadius: radius,
        padding: contentPadding,
        blurSigma: 12,
        tintOpacity: 0.78,
        borderOpacity: 0.22,
        child: child,
      ),
      AlmoutawaCardVariant.gradient => DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.bentoHero,
          borderRadius: radius,
          boxShadow: AppShadows.card,
        ),
        child: Padding(padding: contentPadding, child: child),
      ),
      AlmoutawaCardVariant.portal => _PortalShell(
        statusColor: statusColor ?? AppColors.secondary,
        borderRadius: radius,
        padding: contentPadding,
        child: child,
      ),
      AlmoutawaCardVariant.solid => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: radius,
          boxShadow: AppShadows.card,
          border: Border.all(color: AppColors.surfaceContainer),
        ),
        child: Padding(padding: contentPadding, child: child),
      ),
      AlmoutawaCardVariant.tinted => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: radius,
          boxShadow: AppShadows.card,
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.18),
          ),
        ),
        child: Padding(padding: contentPadding, child: child),
      ),
      AlmoutawaCardVariant.softGradient => DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.customerCard,
          borderRadius: radius,
          boxShadow: AppShadows.card,
          border: Border.all(
            color: AppColors.secondaryFixed.withValues(alpha: 0.45),
          ),
        ),
        child: Padding(padding: contentPadding, child: child),
      ),
    };

    if (minHeight != null) {
      card = ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight!),
        child: card,
      );
    }

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: radius, child: card),
    );
  }
}

class _PortalShell extends StatelessWidget {
  const _PortalShell({
    required this.statusColor,
    required this.borderRadius,
    required this.padding,
    required this.child,
  });

  final Color statusColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: borderRadius,
        boxShadow: AppShadows.card,
        border: BorderDirectional(
          start: BorderSide(
            color: statusColor,
            width: AppLayout.portalStatusBarWidth,
          ),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
