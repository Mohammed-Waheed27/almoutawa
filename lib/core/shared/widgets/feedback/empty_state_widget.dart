import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../buttons/almoutawa_button.dart';
import '../cards/almoutawa_card.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(top: AppSpacing.xxl),
        child: AlmoutawaCard(
          variant: AlmoutawaCardVariant.glass,
          child: Column(
            children: [
              Icon(icon, size: 48, color: AppColors.onSurfaceVariant),
              SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLg().copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                SizedBox(height: AppSpacing.lg),
                AlmoutawaButton(
                  label: actionLabel!,
                  variant: AlmoutawaButtonVariant.secondaryGlass,
                  size: AlmoutawaButtonSize.sm,
                  expanded: false,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
