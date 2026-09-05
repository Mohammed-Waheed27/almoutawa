import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Staggered fade + slide after copying lines — no extra card chrome.
class AgreementCopiedLineShell extends StatefulWidget {
  const AgreementCopiedLineShell({
    super.key,
    required this.index,
    required this.copyGeneration,
    required this.child,
  });

  final int index;
  final int copyGeneration;
  final Widget child;

  @override
  State<AgreementCopiedLineShell> createState() =>
      _AgreementCopiedLineShellState();
}

class _AgreementCopiedLineShellState extends State<AgreementCopiedLineShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  var _lastGen = 0;

  @override
  void initState() {
    super.initState();
    _lastGen = widget.copyGeneration;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.copyGeneration > 0) {
      _play();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant AgreementCopiedLineShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.copyGeneration > _lastGen) {
      _lastGen = widget.copyGeneration;
      _play();
    }
  }

  Future<void> _play() async {
    await Future<void>.delayed(Duration(milliseconds: 45 * widget.index));
    if (!mounted) return;
    await _controller.forward(from: 0);
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
        position: _offset,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final highlight = (1 - _controller.value).clamp(0.0, 1.0);
            return DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: highlight < 0.05
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.onPrimaryFixedVariant.withValues(
                            alpha: 0.12 * highlight,
                          ),
                          blurRadius: 10 * highlight,
                        ),
                      ],
              ),
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
