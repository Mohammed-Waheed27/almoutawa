import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/inputs/almoutawa_search_field.dart';
import '../../../../core/theme/app_spacing.dart';

class ProductsSearchSection extends StatelessWidget {
  const ProductsSearchSection({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'بحث عن منتج...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: AlmoutawaSearchField(
        controller: controller,
        hint: hint,
        onChanged: onChanged,
      ),
    );
  }
}
