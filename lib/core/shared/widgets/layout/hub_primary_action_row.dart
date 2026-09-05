import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class HubPrimaryActionItem {
  const HubPrimaryActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

/// Side-by-side primary hub actions — reference-style compact CTAs.
class HubPrimaryActionRow extends StatelessWidget {
  const HubPrimaryActionRow({super.key, required this.actions});

  final List<HubPrimaryActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(width: AppSpacing.gridGutter),
            Expanded(child: _HubPrimaryActionButton(item: actions[i])),
          ],
        ],
      ),
    );
  }
}

class _HubPrimaryActionButton extends StatelessWidget {
  const _HubPrimaryActionButton({required this.item});

  final HubPrimaryActionItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: AppRadius.lgAll,
        child: Ink(
          height: AppLayout.buttonHeight,
          decoration: BoxDecoration(
            gradient: AppGradients.action,
            borderRadius: AppRadius.lgAll,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: AppColors.onSecondary, size: 20),
                SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    item.label,
                    style: AppTypography.labelBold().copyWith(
                      color: AppColors.onSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
