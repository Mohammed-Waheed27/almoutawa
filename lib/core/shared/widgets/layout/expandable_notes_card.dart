import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../cards/almoutawa_card.dart';

/// Compact notes panel with animated expand / collapse ("عرض المزيد").
class ExpandableNotesCard extends StatefulWidget {
  const ExpandableNotesCard({
    super.key,
    required this.title,
    required this.body,
    this.collapsedMaxLines = 3,
  });

  final String title;
  final String body;
  final int collapsedMaxLines;

  @override
  State<ExpandableNotesCard> createState() => _ExpandableNotesCardState();
}

class _ExpandableNotesCardState extends State<ExpandableNotesCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _needsToggle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureOverflow());
  }

  @override
  void didUpdateWidget(covariant ExpandableNotesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.body != widget.body ||
        oldWidget.collapsedMaxLines != widget.collapsedMaxLines) {
      _expanded = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureOverflow());
    }
  }

  void _measureOverflow() {
    if (!mounted || widget.body.trim().isEmpty) return;
    final painter = TextPainter(
      text: TextSpan(text: widget.body, style: AppTypography.bodyMd()),
      textDirection: TextDirection.rtl,
      maxLines: widget.collapsedMaxLines,
    )..layout(maxWidth: MediaQuery.sizeOf(context).width - 64);
    final needs = painter.didExceedMaxLines;
    if (needs != _needsToggle) {
      setState(() => _needsToggle = needs);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.body.trim().isEmpty) return const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlmoutawaCard(
        variant: AlmoutawaCardVariant.tinted,
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: AppTypography.titleSm().copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: AppSpacing.sm),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: Text(
                widget.body,
                style: AppTypography.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.right,
                maxLines: _expanded ? null : widget.collapsedMaxLines,
                overflow: _expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ),
            if (_needsToggle) ...[
              SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.onPrimaryFixedVariant,
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        _expanded ? 'عرض أقل' : 'عرض المزيد',
                        style: AppTypography.labelBold().copyWith(
                          color: AppColors.onPrimaryFixedVariant,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.onPrimaryFixedVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
