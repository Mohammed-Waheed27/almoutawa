import 'package:flutter/material.dart';

/// Animates an integer from 0 (or [begin]) up to [value] when it changes.
class AnimatedCountText extends StatelessWidget {
  const AnimatedCountText({
    super.key,
    required this.value,
    required this.style,
    this.begin,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    this.textAlign,
    this.maxLines = 1,
  });

  final int value;
  final TextStyle style;
  final int? begin;
  final Duration duration;
  final Curve curve;
  final TextAlign? textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final start = begin ?? 0;
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(value),
      tween: Tween<double>(begin: start.toDouble(), end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, animated, _) {
        return Text(
          animated.round().toString(),
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
