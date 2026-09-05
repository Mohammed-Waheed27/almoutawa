import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_shadows.dart';

/// Primary gradient FAB — fixed size per [AppLayout.fabSize].
class GradientFab extends StatelessWidget {
  const GradientFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        elevation: 0,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.lgAll,
          child: Ink(
            width: AppLayout.fabSize,
            height: AppLayout.fabSize,
            decoration: BoxDecoration(
              gradient: AppGradients.action,
              borderRadius: AppRadius.lgAll,
              boxShadow: AppShadows.primaryGlow,
            ),
            child: Icon(icon, color: AppColors.onSecondary, size: 28),
          ),
        ),
      ),
    );
  }
}
