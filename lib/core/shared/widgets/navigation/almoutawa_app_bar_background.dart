import 'package:flutter/material.dart';

import '../../../theme/app_gradients.dart';

/// Primary = shell tab roots. Secondary = pushed sub-pages with back.
enum AlmoutawaAppBarVariant { primary, secondary }

class AlmoutawaAppBarBackground extends StatelessWidget {
  const AlmoutawaAppBarBackground({
    super.key,
    required this.variant,
    required this.child,
  });

  final AlmoutawaAppBarVariant variant;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gradient = switch (variant) {
      AlmoutawaAppBarVariant.primary => AppGradients.primaryAppBar,
      AlmoutawaAppBarVariant.secondary => AppGradients.secondaryAppBar,
    };

    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _AppBarPatternPainter()),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Soft geometric shapes — reference ERP header pattern.
class _AppBarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final soft = Paint()..color = Colors.white.withValues(alpha: 0.14);
    final softer = Paint()..color = Colors.white.withValues(alpha: 0.08);

    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.15),
      size.height * 0.55,
      softer,
    );
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.85),
      size.height * 0.45,
      soft,
    );

    final diamond = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.72, size.height * 0.2),
        width: size.height * 0.35,
        height: size.height * 0.35,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(diamond, softer);

    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 1.1),
      size.height * 0.38,
      softer,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Legacy aliases — map old variant names to the unified enum.
enum AlmoutawaAppBarBackgroundVariant { hub, subpage }

extension AlmoutawaAppBarBackgroundVariantX
    on AlmoutawaAppBarBackgroundVariant {
  AlmoutawaAppBarVariant get unified => switch (this) {
    AlmoutawaAppBarBackgroundVariant.hub => AlmoutawaAppBarVariant.primary,
    AlmoutawaAppBarBackgroundVariant.subpage =>
      AlmoutawaAppBarVariant.secondary,
  };
}
