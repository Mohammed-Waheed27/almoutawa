import 'package:flutter/material.dart';

import '../../../theme/app_radius.dart';

/// Icon well for hub / portal list rows.
class HubIconWell extends StatelessWidget {
  const HubIconWell({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.mdAll,
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}
