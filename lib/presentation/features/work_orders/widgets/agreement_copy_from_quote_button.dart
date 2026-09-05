import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Copy-from-quote CTA with a short success pulse animation.
class AgreementCopyFromQuoteButton extends StatefulWidget {
  const AgreementCopyFromQuoteButton({
    super.key,
    required this.onPressed,
    required this.copyGeneration,
    this.enabled = true,
  });

  final VoidCallback onPressed;
  final int copyGeneration;
  final bool enabled;

  @override
  State<AgreementCopyFromQuoteButton> createState() =>
      _AgreementCopyFromQuoteButtonState();
}

class _AgreementCopyFromQuoteButtonState
    extends State<AgreementCopyFromQuoteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glow;
  var _lastGen = 0;

  @override
  void initState() {
    super.initState();
    _lastGen = widget.copyGeneration;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scale = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 1, end: 0.96), weight: 20),
        TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.03), weight: 35),
        TweenSequenceItem(tween: Tween(begin: 1.03, end: 1), weight: 45),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _glow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 70),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant AgreementCopyFromQuoteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.copyGeneration > _lastGen) {
      _lastGen = widget.copyGeneration;
      HapticFeedback.mediumImpact();
      _pulse();
    }
  }

  Future<void> _pulse() async {
    await _controller.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = _glow.value;
        return Transform.scale(
          scale: _scale.value,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.buttonAll,
              boxShadow: glow <= 0.01
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.onPrimaryFixedVariant.withValues(
                          alpha: 0.22 * glow,
                        ),
                        blurRadius: 16 * glow,
                        spreadRadius: 1 * glow,
                      ),
                    ],
            ),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AlmoutawaButton(
            label: 'نسخ البنود من عرض السعر',
            icon: Icons.copy_all_rounded,
            variant: AlmoutawaButtonVariant.secondaryGlass,
            onPressed: widget.enabled ? widget.onPressed : null,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: _controller.isAnimating || _controller.value > 0
                ? Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xs),
                    child: FadeTransition(
                      opacity: _glow,
                      child: Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'تم نسخ البنود',
                            style: AppTypography.captionBold().copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
