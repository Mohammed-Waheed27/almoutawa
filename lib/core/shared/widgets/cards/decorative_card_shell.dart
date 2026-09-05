import 'package:flutter/material.dart';

import '../../../theme/app_radius.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import 'decorative_card_tone.dart';

/// Rounded shell with soft overlapping circle blobs — base for Sapphire decorative cards.
class DecorativeCardShell extends StatelessWidget {
  const DecorativeCardShell({
    super.key,
    required this.child,
    this.tone = DecorativeCardTone.blue,
    this.onTap,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final DecorativeCardTone tone;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lgAll;
    final contentPadding = padding ?? EdgeInsets.all(AppSpacing.lg);

    Widget card = RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tone.fill,
          borderRadius: radius,
          border: Border.all(color: tone.border),
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: -28,
                left: -24,
                child: _BlobCircle(
                  size: 96,
                  color: tone.blobPrimary,
                ),
              ),
              Positioned(
                bottom: -36,
                right: -18,
                child: _BlobCircle(
                  size: 112,
                  color: tone.blobSecondary,
                ),
              ),
              Positioned(
                top: 12,
                right: -40,
                child: _BlobCircle(
                  size: 72,
                  color: tone.blobSecondary,
                ),
              ),
              Padding(padding: contentPadding, child: child),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: radius, child: card),
    );
  }
}

class _BlobCircle extends StatelessWidget {
  const _BlobCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
