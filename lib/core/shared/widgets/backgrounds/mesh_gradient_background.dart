import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Lightweight page canvas — white base with soft shapes at the bottom.
class MeshGradientBackground extends StatelessWidget {
  const MeshGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(child: _MeshCanvas()),
        child,
      ],
    );
  }
}

/// White scaffold fill + bottom accent blobs — no full-page blur.
class _MeshCanvas extends StatelessWidget {
  const _MeshCanvas();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.white,
      child: CustomPaint(painter: _BottomShapePainter()),
    );
  }
}

class _BottomShapePainter extends CustomPainter {
  const _BottomShapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawBlob(
      canvas,
      center: Offset(size.width * 0.12, size.height * 0.92),
      radius: size.width * 0.38,
      color: AppColors.secondary.withValues(alpha: 0.07),
    );
    _drawBlob(
      canvas,
      center: Offset(size.width * 0.88, size.height * 0.96),
      radius: size.width * 0.42,
      color: AppColors.onTertiaryContainer.withValues(alpha: 0.06),
    );
    _drawBlob(
      canvas,
      center: Offset(size.width * 0.55, size.height * 0.88),
      radius: size.width * 0.28,
      color: AppColors.primaryContainer.withValues(alpha: 0.05),
    );

    final shapePaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.05);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.04,
          size.height * 0.82,
          size.width * 0.14,
          size.height * 0.08,
        ),
        const Radius.circular(4),
      ),
      shapePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.78,
          size.height * 0.78,
          size.width * 0.16,
          size.height * 0.1,
        ),
        const Radius.circular(4),
      ),
      shapePaint..color = AppColors.secondaryContainer.withValues(alpha: 0.08),
    );
  }

  void _drawBlob(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
