import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';
import '../buttons/almoutawa_button.dart';
import '../cards/almoutawa_card.dart';
import 'developer_credit.dart';

/// Shared settings — sheet on compact, dialog on expanded (same actions).
abstract final class AlmoutawaSettingsSheet {
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSignOut,
  }) {
    if (context.density.isExpanded) {
      return showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppColors.background,
              title: Text('الإعدادات', style: AppTypography.headlineSm()),
              content: SizedBox(
                width: DesktopUiTokens.authFormMaxWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SettingsBody(
                      onSignOut: () {
                        Navigator.pop(dialogContext);
                        onSignOut();
                      },
                    ),
                    SizedBox(height: DesktopUiTokens.gapMd),
                    const DeveloperCredit(),
                  ],
                ),
              ),
              actions: [
                AlmoutawaButton(
                  label: 'إغلاق',
                  variant: AlmoutawaButtonVariant.tertiaryText,
                  expanded: false,
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ],
            ),
          );
        },
      );
    }

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.containerPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('الإعدادات', style: AppTypography.headlineSm()),
                  SizedBox(height: AppSpacing.lg),
                  _SettingsBody(
                    onSignOut: () {
                      Navigator.pop(sheetContext);
                      onSignOut();
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  const DeveloperCredit(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return AlmoutawaCard(
      variant: AlmoutawaCardVariant.solid,
      onTap: onSignOut,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          const Icon(Icons.logout_rounded, color: AppColors.error),
          SizedBox(width: AppSpacing.md),
          Text(
            'تسجيل الخروج',
            style: AppTypography.bodyLg().copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
