import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/mfg_card_section_header.dart';

class ManufacturingCardNotesSection extends StatelessWidget {
  const ManufacturingCardNotesSection({
    super.key,
    required this.alertController,
    required this.notesController,
    required this.enabled,
  });

  final TextEditingController alertController;
  final TextEditingController notesController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MfgCardSectionHeader(title: 'تنبيه وملاحظات'),
        SizedBox(height: AppSpacing.sm),
        AlmoutawaTextField(
          controller: alertController,
          label: 'تنبيه مهم',
          hint: 'الباب لا يشمل دفاش',
          dense: true,
          maxLines: 2,
          readOnly: !enabled,
        ),
        SizedBox(height: AppSpacing.sm),
        AlmoutawaTextField(
          controller: notesController,
          label: 'ملاحظات (اختياري)',
          hint: 'أي تعليمات خاصة للمصنع...',
          dense: true,
          maxLines: 4,
          readOnly: !enabled,
        ),
      ],
    );
  }
}
