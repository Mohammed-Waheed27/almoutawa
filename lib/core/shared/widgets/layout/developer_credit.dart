import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_strings.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';

/// Compact developer mark — settings footers and desktop nav rails.
class DeveloperCredit extends StatelessWidget {
  const DeveloperCredit({
    super.key,
    this.compact = false,
  });

  final bool compact;

  Future<void> _openPhone() async {
    final uri = Uri(scheme: 'tel', path: AppStrings.developerPhone);
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final muted = AppColors.onSurfaceVariant.withValues(alpha: 0.72);
    final nameStyle = (compact
            ? AppTypography.captionOf(context)
            : AppTypography.labelOf(context))
        .copyWith(
          color: muted,
          fontWeight: FontWeight.w600,
          fontSize: compact
              ? (dense ? 10 : 11)
              : (dense ? DesktopUiTokens.label : null),
          height: 1.25,
        );
    final phoneStyle = AppTypography.captionOf(context).copyWith(
      color: muted.withValues(alpha: 0.9),
      fontSize: compact ? (dense ? 9 : 10) : (dense ? 10 : 11),
      height: 1.2,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: compact
              ? DesktopUiTokens.gapXs
              : (dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.developerCredit,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: nameStyle,
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: _openPhone,
              child: Text(
                AppStrings.developerPhone,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: phoneStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
