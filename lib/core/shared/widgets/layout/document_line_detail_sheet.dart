import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class DocumentLineDetailField {
  const DocumentLineDetailField({required this.label, required this.value});

  final String label;
  final String value;
}

/// Bottom sheet showing full labeled details for one document بند.
abstract final class DocumentLineDetailSheet {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<DocumentLineDetailField> fields,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.containerPadding,
                AppSpacing.xs,
                AppSpacing.containerPadding,
                AppSpacing.containerPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSm().copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMd().copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimaryFixedVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: AppSpacing.md),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(ctx).height * 0.55,
                    ),
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppRadius.lgAll,
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < fields.length; i++) ...[
                              _DetailRow(
                                label: fields[i].label,
                                value: fields[i].value,
                              ),
                              if (i != fields.length - 1)
                                const Divider(
                                  height: 1,
                                  color: AppColors.outlineVariant,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'إغلاق',
                      style: AppTypography.labelBold().copyWith(
                        color: AppColors.onPrimaryFixedVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTypography.caption().copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '—' : value,
              style: AppTypography.labelBold().copyWith(
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
