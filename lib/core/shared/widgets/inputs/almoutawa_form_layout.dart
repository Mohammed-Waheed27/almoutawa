import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';

/// Scrollable form body with a sticky bottom action area.
class AlmoutawaFormLayout extends StatelessWidget {
  const AlmoutawaFormLayout({
    super.key,
    required this.fields,
    this.submitButton,
    this.formKey,
  });

  final GlobalKey<FormState>? formKey;
  final List<Widget> fields;
  final Widget? submitButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Form(
            key: formKey,
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.containerPadding),
              children: fields,
            ),
          ),
        ),
        if (submitButton != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.containerPadding,
                AppSpacing.sm,
                AppSpacing.containerPadding,
                AppSpacing.containerPadding,
              ),
              child: submitButton,
            ),
          ),
      ],
    );
  }
}
