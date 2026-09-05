import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

/// Segmented tab control — single rounded shell, sliding gradient pill.
///
/// Pass [controller] for swipe-synced animation with a [TabBarView].
class SegmentedTabBar extends StatelessWidget {
  const SegmentedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    this.controller,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// When set, the pill tracks [TabController.animation] for smooth swipes.
  final TabController? controller;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.lgAll,
          boxShadow: AppShadows.card,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / tabs.length;
            final tabController = controller;

            return Stack(
              children: [
                if (tabController != null)
                  AnimatedBuilder(
                    animation: tabController.animation!,
                    builder: (context, _) {
                      final value = tabController.animation!.value.clamp(
                        0.0,
                        (tabs.length - 1).toDouble(),
                      );
                      // RTL: index 0 sits on the right.
                      final left = (tabs.length - 1 - value) * tabWidth;
                      return Positioned(
                        top: 0,
                        bottom: 0,
                        left: left,
                        width: tabWidth,
                        child: const _SlidingPill(),
                      );
                    },
                  )
                else
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    top: 0,
                    bottom: 0,
                    left: (tabs.length - 1 - selectedIndex) * tabWidth,
                    width: tabWidth,
                    child: const _SlidingPill(),
                  ),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    for (var i = 0; i < tabs.length; i++)
                      Expanded(
                        child: _TabLabel(
                          label: tabs[i],
                          selected: i == selectedIndex,
                          onTap: () => onSelected(i),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlidingPill extends StatelessWidget {
  const _SlidingPill();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.action,
          borderRadius: AppRadius.mdAll,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.22),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            style: AppTypography.labelMd().copyWith(
              color: selected
                  ? AppColors.onPrimary
                  : AppColors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
