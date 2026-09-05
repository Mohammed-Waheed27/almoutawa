import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class AlmoutawaNavItem {
  const AlmoutawaNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Shared bottom navigation — soft pill on active tab with fluid motion.
class AlmoutawaBottomNav extends StatelessWidget {
  const AlmoutawaBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    this.centerIndex,
  });

  final List<AlmoutawaNavItem> items;
  final int currentIndex;

  /// Optional visual emphasis for the primary hub tab (e.g. admin orders).
  final int? centerIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sm),
          ),
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: AppShadows.card.first.color,
              blurRadius: 16.r,
              offset: Offset(0, -6.h),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppLayout.bottomNavHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i = 0; i < items.length; i++)
                  _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    emphasized: centerIndex == i,
                    onTap: () => onSelected(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    this.emphasized = false,
    required this.onTap,
  });

  final AlmoutawaNavItem item;
  final bool selected;
  final bool emphasized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? AppColors.white
        : emphasized
        ? AppColors.onPrimaryFixedVariant
        : AppColors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? AppSpacing.md : AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.primaryAppBar : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.appBarPrimaryEnd.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.12 : (emphasized ? 1.06 : 1.0),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    key: ValueKey(selected),
                    color: fg,
                    size: selected ? 24 : 22,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: AppTypography.labelMd().copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
