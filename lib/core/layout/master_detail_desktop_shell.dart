import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/desktop_ui_tokens.dart';

/// List + inline detail for expanded hubs (customers, products, work orders).
class MasterDetailDesktopShell extends StatelessWidget {
  const MasterDetailDesktopShell({
    super.key,
    required this.master,
    required this.detail,
    this.sidebar,
    this.masterWidth = DesktopUiTokens.masterListMaxWidth,
    this.sidebarWidth = DesktopUiTokens.filterSidebarWidth,
    this.emptyDetailMessage = 'اختر عنصراً من القائمة',
  });

  /// Filter / period panel on the RTL start (right).
  final Widget? sidebar;

  /// Scrollable master list.
  final Widget master;

  /// Selected entity content — or null to show empty placeholder.
  final Widget? detail;

  final double masterWidth;
  final double sidebarWidth;
  final String emptyDetailMessage;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (sidebar != null) ...[
            SizedBox(
              width: sidebarWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border(
                    left: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                child: sidebar,
              ),
            ),
          ],
          SizedBox(
            width: masterWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow.withValues(alpha: 0.45),
                border: Border(
                  left: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
              child: master,
            ),
          ),
          Expanded(
            child: detail ??
                Center(
                  child: Text(
                    emptyDetailMessage,
                    style: AppTypography.bodyMd().copyWith(
                      fontSize: DesktopUiTokens.body,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
