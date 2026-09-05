import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class HexColorField extends StatelessWidget {
  const HexColorField({
    super.key,
    required this.controller,
    this.onChanged,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  Color? get _previewColor {
    final value = controller.text.trim();
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value)) return null;
    final hex = value.substring(1);
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final preview = _previewColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'كود اللون (اختياري)',
            style: AppTypography.labelBold().copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: preview ?? AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.65),
                  ),
                ),
                child: preview == null
                    ? const Icon(
                        Icons.palette_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 20,
                      )
                    : null,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  readOnly: readOnly,
                  onChanged: onChanged,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[#0-9A-Fa-f]')),
                    LengthLimitingTextInputFormatter(7),
                  ],
                  style: AppTypography.bodyMd(),
                  decoration: InputDecoration(
                    hintText: '#FFFFFF',
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.inputAll,
                      borderSide: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.65),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.inputAll,
                      borderSide: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.65),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.inputAll,
                      borderSide: BorderSide(
                        color: AppColors.secondary.withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
