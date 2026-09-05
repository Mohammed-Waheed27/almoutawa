import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../buttons/almoutawa_button.dart';
import '../layout/hub_icon_well.dart';
import 'decorative_card_shell.dart';
import 'decorative_card_tone.dart';

class DecorativeCatalogBadge {
  const DecorativeCatalogBadge({
    required this.label,
    this.tone = DecorativeCardTone.blue,
  });

  final String label;
  final DecorativeCardTone tone;
}

class DecorativeCatalogAction {
  const DecorativeCatalogAction({
    required this.label,
    required this.icon,
    this.onPressed,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool destructive;
}

/// Catalog / product list card — badges, title, detail, footer info + actions.
class DecorativeCatalogCard extends StatelessWidget {
  const DecorativeCatalogCard({
    super.key,
    required this.title,
    this.subtitle,
    this.detail,
    this.leading,
    this.icon,
    this.badges = const [],
    this.footerInfo,
    this.actions = const [],
    this.tone = DecorativeCardTone.warm,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? detail;
  final Widget? leading;
  final IconData? icon;
  final List<DecorativeCatalogBadge> badges;
  final String? footerInfo;
  final List<DecorativeCatalogAction> actions;
  final DecorativeCardTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecorativeCardShell(
        tone: tone,
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leading ??
                      (icon != null
                          ? HubIconWell(icon: icon!, color: tone.accent)
                          : null) ??
                      const SizedBox.shrink(),
                  if (leading != null || icon != null)
                    SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (badges.isNotEmpty) ...[
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            textDirection: TextDirection.rtl,
                            children: badges
                                .map((badge) => _TagChip(badge: badge))
                                .toList(),
                          ),
                          SizedBox(height: AppSpacing.xs),
                        ],
                        Text(
                          title,
                          style: AppTypography.titleMd().copyWith(
                            color: AppColors.primary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle!,
                            style: AppTypography.bodyMd().copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (detail != null) ...[
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            detail!,
                            style: AppTypography.labelMd().copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (footerInfo != null || actions.isNotEmpty) ...[
              Divider(height: 1, color: tone.border.withValues(alpha: 0.65)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (footerInfo != null)
                      Expanded(
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                footerInfo!,
                                style: AppTypography.labelMd().copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (actions.isNotEmpty) ...[
                      if (footerInfo != null) SizedBox(width: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        textDirection: TextDirection.rtl,
                        children: actions.map((action) {
                          return AlmoutawaButton(
                            label: action.label,
                            icon: action.icon,
                            variant: action.destructive
                                ? AlmoutawaButtonVariant.destructive
                                : AlmoutawaButtonVariant.tertiaryText,
                            size: AlmoutawaButtonSize.sm,
                            expanded: false,
                            onPressed: action.onPressed,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.badge});

  final DecorativeCatalogBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badge.tone.fill,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: badge.tone.border),
      ),
      child: Text(
        badge.label,
        style: AppTypography.captionBold().copyWith(color: badge.tone.accent),
      ),
    );
  }
}
