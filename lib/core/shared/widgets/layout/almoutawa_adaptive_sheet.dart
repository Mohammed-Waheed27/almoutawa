import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/desktop_ui_tokens.dart';

/// Bottom sheet on compact; dialog on expanded — same child content.
abstract final class AlmoutawaAdaptiveSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String? title,
    bool showDragHandle = true,
  }) {
    if (context.density.isExpanded) {
      return showDialog<T>(
        context: context,
        builder: (dialogContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppColors.background,
              title: title != null ? Text(title) : null,
              content: SizedBox(
                width: DesktopUiTokens.formNarrowMaxWidth,
                child: builder(dialogContext),
              ),
            ),
          );
        },
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: showDragHandle,
      backgroundColor: AppColors.background,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(child: builder(sheetContext)),
        );
      },
    );
  }
}
