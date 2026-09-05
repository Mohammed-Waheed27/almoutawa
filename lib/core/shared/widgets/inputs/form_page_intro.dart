import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

/// Optional one-line hint below the app bar on add/edit forms.
///
/// Do **not** repeat the page title from [RoleDashboardScaffold] — only pass
/// copy that adds workflow context (e.g. pricing rules, permissions).
class FormPageIntro extends StatelessWidget {
  const FormPageIntro({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    if (hint.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(
          hint,
          style: AppTypography.bodyMd().copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}
