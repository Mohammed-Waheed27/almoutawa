import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/manufacturing_card_form_bloc.dart';
import '../widgets/mfg_card_section_header.dart';

class ManufacturingCardMetaSection extends StatelessWidget {
  const ManufacturingCardMetaSection({
    super.key,
    required this.modelArController,
    required this.modelEnController,
    required this.widthController,
    required this.heightController,
    required this.enabled,
  });

  final TextEditingController modelArController;
  final TextEditingController modelEnController;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManufacturingCardFormBloc, ManufacturingCardFormState>(
      buildWhen: (p, c) =>
          p.detail != c.detail || p.targetCardIndex != c.targetCardIndex,
      builder: (context, state) {
        final index = state.targetCardIndex ?? 1;
        final lineDesc = state.targetLine?.description.trim() ?? '';
        final subtitle = lineDesc.isEmpty
            ? 'باب #$index'
            : '$lineDesc · باب $index';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MfgCardSectionHeader(
              title: 'الموديل والمقاسات',
              trailing: Text(
                subtitle,
                style: AppTypography.caption().copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: AlmoutawaTextField(
                    controller: modelArController,
                    label: 'الموديل (عربي)',
                    hint: 'مثال: باب ألومنيوم + كلادينج',
                    dense: true,
                    readOnly: !enabled,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'اسم الموديل مطلوب'
                        : null,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AlmoutawaTextField(
                    controller: modelEnController,
                    label: 'Model (EN)',
                    hint: 'Aluminum Door + Cladding',
                    dense: true,
                    readOnly: !enabled,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: AlmoutawaTextField(
                    controller: widthController,
                    label: 'العرض / سم',
                    hint: '117',
                    dense: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    readOnly: !enabled,
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'عرض صحيح مطلوب';
                      return null;
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AlmoutawaTextField(
                    controller: heightController,
                    label: 'الارتفاع / سم',
                    hint: '243',
                    dense: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    readOnly: !enabled,
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'ارتفاع صحيح مطلوب';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
