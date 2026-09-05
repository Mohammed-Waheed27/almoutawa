import 'package:flutter/material.dart';

/// Soft fade + slide when the role shell switches tabs on expanded (Windows).
///
/// Keeps [StatefulNavigationShell]'s IndexedStack mounted — only the visible
/// content is animated so branch state (scroll, blocs) is preserved.
class DesktopTabBodyAnimator extends StatefulWidget {
  const DesktopTabBodyAnimator({
    super.key,
    required this.tabIndex,
    required this.child,
    this.duration = const Duration(milliseconds: 240),
  });

  final int tabIndex;
  final Widget child;
  final Duration duration;

  @override
  State<DesktopTabBodyAnimator> createState() => _DesktopTabBodyAnimatorState();
}

class _DesktopTabBodyAnimatorState extends State<DesktopTabBodyAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0.018, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant DesktopTabBodyAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabIndex != widget.tabIndex) {
      _controller.forward(from: 0);
    }
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
