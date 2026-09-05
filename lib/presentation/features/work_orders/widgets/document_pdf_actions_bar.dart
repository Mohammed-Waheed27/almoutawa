import 'package:flutter/material.dart';

import '../../../../core/pdf/pdf_document_action.dart';
import '../../../../core/pdf/pdf_share_service.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';

/// Save (and optional preview) actions for a commercial PDF.
class DocumentPdfActionsBar extends StatelessWidget {
  const DocumentPdfActionsBar({
    super.key,
    required this.busy,
    required this.enabled,
    required this.onAction,
  });

  final bool busy;
  final bool enabled;
  final ValueChanged<PdfDocumentAction> onAction;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !busy;
    final dense = context.density.isExpanded;
    final showPreview = !PdfShareService.isWindowsDesktop;

    if (dense) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Wrap(
          spacing: DesktopUiTokens.gapSm,
          runSpacing: DesktopUiTokens.gapSm,
          textDirection: TextDirection.rtl,
          alignment: WrapAlignment.start,
          children: [
            AlmoutawaButton(
              label: busy ? 'جاري...' : 'حفظ PDF',
              icon: Icons.save_alt_rounded,
              variant: AlmoutawaButtonVariant.secondaryGlass,
              size: AlmoutawaButtonSize.sm,
              expanded: false,
              onPressed: canTap ? () => onAction(PdfDocumentAction.save) : null,
            ),
            if (showPreview)
              AlmoutawaButton(
                label: 'معاينة',
                icon: Icons.picture_as_pdf_outlined,
                variant: AlmoutawaButtonVariant.tertiaryText,
                size: AlmoutawaButtonSize.sm,
                expanded: false,
                onPressed: canTap
                    ? () => onAction(PdfDocumentAction.preview)
                    : null,
              ),
          ],
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AlmoutawaButton(
            label: busy ? 'جاري...' : 'حفظ PDF',
            icon: Icons.save_alt_rounded,
            variant: AlmoutawaButtonVariant.secondaryGlass,
            size: AlmoutawaButtonSize.sm,
            onPressed: canTap ? () => onAction(PdfDocumentAction.save) : null,
          ),
          if (showPreview) ...[
            SizedBox(height: AppSpacing.sm),
            AlmoutawaButton(
              label: 'معاينة PDF',
              icon: Icons.picture_as_pdf_outlined,
              variant: AlmoutawaButtonVariant.tertiaryText,
              onPressed: canTap
                  ? () => onAction(PdfDocumentAction.preview)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
