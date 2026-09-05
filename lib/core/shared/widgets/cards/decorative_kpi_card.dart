import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../layout/hub_icon_well.dart';
import 'decorative_card_shell.dart';
import 'decorative_card_tone.dart';

/// KPI / bento tile with icon well, label, hero value, and optional footer.
class DecorativeKpiCard extends StatelessWidget {
  const DecorativeKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.tone = DecorativeCardTone.teal,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;
  final DecorativeCardTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecorativeCardShell(
        tone: tone,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.labelMd().copyWith(
                      color: tone.accent.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                HubIconWell(icon: icon, color: tone.accent),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTypography.displayLg().copyWith(
                color: tone.accent,
                height: 1.1,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTypography.labelMd().copyWith(
                  color: tone.accent.withValues(alpha: 0.72),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
