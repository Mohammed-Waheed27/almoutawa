import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';
import '../layout/app_brand_logo.dart';
import '../layout/developer_credit.dart';
import 'almoutawa_bottom_nav.dart';

/// Side navigation rail for expanded role shells — same destinations as bottom nav.
class RoleDesktopShell extends StatelessWidget {
  const RoleDesktopShell({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
    this.extended = true,
    this.centerIndex,
  });

  final List<AlmoutawaNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget body;
  final bool extended;
  final int? centerIndex;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DesktopNavRail(
            items: items,
            selectedIndex: selectedIndex,
            onSelected: onSelected,
            extended: extended,
            centerIndex: centerIndex,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _DesktopNavRail extends StatelessWidget {
  const _DesktopNavRail({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.extended,
    this.centerIndex,
  });

  final List<AlmoutawaNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool extended;
  final int? centerIndex;

  @override
  Widget build(BuildContext context) {
    final width = extended ? 220.0 : 72.0;
    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
        child: SafeArea(
          left: false,
          right: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesktopUiTokens.gapMd,
                  DesktopUiTokens.gapLg,
                  DesktopUiTokens.gapMd,
                  DesktopUiTokens.gapMd,
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: AppBrandLogo(height: extended ? 52 : 28),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesktopUiTokens.gapSm,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = index == selectedIndex;
                    final emphasized = centerIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: DesktopUiTokens.gapXs,
                      ),
                      child: _RailDestination(
                        item: item,
                        selected: selected,
                        emphasized: emphasized,
                        extended: extended,
                        onTap: () => onSelected(index),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesktopUiTokens.gapSm,
                  DesktopUiTokens.gapXs,
                  DesktopUiTokens.gapSm,
                  DesktopUiTokens.gapMd,
                ),
                child: const DeveloperCredit(compact: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailDestination extends StatelessWidget {
  const _RailDestination({
    required this.item,
    required this.selected,
    required this.emphasized,
    required this.extended,
    required this.onTap,
  });

  final AlmoutawaNavItem item;
  final bool selected;
  final bool emphasized;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? item.selectedIcon : item.icon;
    final fg = selected ? AppColors.white : AppColors.onSurfaceVariant;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesktopUiTokens.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesktopUiTokens.radiusMd),
            gradient: selected ? AppGradients.action : null,
            color: selected
                ? null
                : (emphasized
                      ? AppColors.surfaceContainer.withValues(alpha: 0.55)
                      : AppColors.transparent),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: extended
                  ? DesktopUiTokens.gapMd
                  : DesktopUiTokens.gapSm,
              vertical: DesktopUiTokens.gapSm + 2,
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(icon, size: DesktopUiTokens.iconSize + 2, color: fg),
                if (extended) ...[
                  const SizedBox(width: DesktopUiTokens.gapSm),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd().copyWith(
                        fontSize: DesktopUiTokens.label + 1,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
