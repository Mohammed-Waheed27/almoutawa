import 'package:flutter/material.dart';

import 'almoutawa_button.dart';

/// Primary CTA — delegates to [AlmoutawaButton] for design-system parity.
class PrimaryGradientButton extends StatelessWidget {
  const PrimaryGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return AlmoutawaButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      expanded: expanded,
      variant: AlmoutawaButtonVariant.primaryGradient,
    );
  }
}
