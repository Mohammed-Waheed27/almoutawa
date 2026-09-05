import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';

/// Compact horizontal phase timeline — milestone nodes + labels (no progress bar).
class WorkOrderTimelineSection extends StatefulWidget {
  const WorkOrderTimelineSection({super.key, required this.phase});

  final CommercialOrderPhase phase;

  @override
  State<WorkOrderTimelineSection> createState() =>
      _WorkOrderTimelineSectionState();
}

class _WorkOrderTimelineSectionState extends State<WorkOrderTimelineSection>
    with SingleTickerProviderStateMixin {
  static const _steps = [
    CommercialOrderPhase.quote,
    CommercialOrderPhase.agreement,
    CommercialOrderPhase.manufacturingDraft,
    CommercialOrderPhase.manufacturing,
    CommercialOrderPhase.completed,
    CommercialOrderPhase.delivered,
  ];

  static const _icons = [
    Icons.request_quote_rounded,
    Icons.handshake_rounded,
    Icons.edit_note_rounded,
    Icons.precision_manufacturing_rounded,
    Icons.task_alt_rounded,
    Icons.local_shipping_rounded,
  ];

  static const _shortLabels = [
    'عرض سعر',
    'اتفاقية',
    'مسودة',
    'تصنيع',
    'مكتمل',
    'تسليم',
  ];

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant WorkOrderTimelineSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _activeIndex {
    if (widget.phase == CommercialOrderPhase.cancelled) return -1;
    final index = _steps.indexOf(widget.phase);
    return index < 0 ? 0 : index;
  }

  bool _isReached(int index) {
    final active = _activeIndex;
    if (active < 0) return false;
    return index <= active;
  }

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final cancelled = widget.phase == CommercialOrderPhase.cancelled;
    final activeIndex = _activeIndex;
    final nodeSize = dense ? 24.0 : 28.0;
    final iconSize = dense ? 13.0 : 15.0;
    final trackH = dense ? 2.0 : 3.0;
    final rowH = dense ? 28.0 : 36.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  'مراحل الطلب',
                  style: AppTypography.titleOf(context).copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              if (cancelled)
                Text(
                  'ملغي',
                  style: AppTypography.labelOf(context).copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.md),
          SizedBox(
            height: rowH,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                for (var i = 0; i < _steps.length; i++) ...[
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: trackH,
                        margin: EdgeInsets.symmetric(
                          horizontal: dense ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: cancelled
                              ? AppColors.error.withValues(alpha: 0.35)
                              : _isReached(i)
                              ? AppColors.success.withValues(alpha: 0.85)
                              : AppColors.outlineVariant.withValues(
                                  alpha: 0.7,
                                ),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                    ),
                  _TimelineNode(
                    icon: _icons[i],
                    reached: !cancelled && _isReached(i),
                    isCurrent: !cancelled && i == activeIndex,
                    cancelled: cancelled,
                    size: nodeSize,
                    iconSize: iconSize,
                    appear: CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                        (i * 0.14).clamp(0.0, 0.7),
                        (0.32 + i * 0.14).clamp(0.0, 1.0),
                        curve: Curves.easeOutBack,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapXs : AppSpacing.sm),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              for (var i = 0; i < _steps.length; i++)
                Expanded(
                  child: _TimelineLabel(
                    label: _shortLabels[i],
                    reached: !cancelled && _isReached(i),
                    isCurrent: !cancelled && i == activeIndex,
                    soon:
                        !cancelled &&
                        activeIndex >= 0 &&
                        i == activeIndex + 1 &&
                        i < _steps.length,
                    dense: dense,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.icon,
    required this.reached,
    required this.isCurrent,
    required this.cancelled,
    required this.appear,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final bool reached;
  final bool isCurrent;
  final bool cancelled;
  final Animation<double> appear;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final bg = cancelled
        ? AppColors.errorContainer
        : reached
        ? AppColors.success
        : AppColors.surfaceContainerHighest;
    final fg = cancelled
        ? AppColors.error
        : reached
        ? AppColors.white
        : AppColors.onSurfaceVariant;

    return ScaleTransition(
      scale: Tween<double>(begin: 0.55, end: 1).animate(appear),
      child: FadeTransition(
        opacity: appear,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(
              color: reached
                  ? AppColors.success
                  : AppColors.outlineVariant,
              width: isCurrent ? 2 : 1.25,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.28),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, size: iconSize, color: fg),
        ),
      ),
    );
  }
}

class _TimelineLabel extends StatelessWidget {
  const _TimelineLabel({
    required this.label,
    required this.reached,
    required this.isCurrent,
    required this.soon,
    required this.dense,
  });

  final String label;
  final bool reached;
  final bool isCurrent;
  final bool soon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelOf(context).copyWith(
            color: reached ? AppColors.success : AppColors.onSurfaceVariant,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
            fontSize: dense ? 10 : null,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (isCurrent || soon)
          Text(
            isCurrent ? 'الحالية' : 'قريباً',
            style: AppTypography.captionOf(context).copyWith(
              color: isCurrent
                  ? AppColors.success
                  : AppColors.onSurfaceVariant,
              fontSize: dense ? 9 : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
