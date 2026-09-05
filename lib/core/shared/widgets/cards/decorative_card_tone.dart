import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Semantic color families for decorative blob cards (KPI, summary, catalog).
enum DecorativeCardTone {
  /// General catalog / products — soft blue wash.
  blue,

  /// Production / operational teal KPIs.
  teal,

  /// Delivery / logistics green KPIs.
  green,

  /// Materials / warm catalog rows — beige-tan wash.
  warm,

  /// Neutral dense panels.
  neutral,
}

extension DecorativeCardToneX on DecorativeCardTone {
  Color get fill => switch (this) {
    DecorativeCardTone.blue => AppColors.surfaceContainerLow,
    DecorativeCardTone.teal => AppColors.tertiaryFixed.withValues(alpha: 0.22),
    DecorativeCardTone.green => AppColors.success.withValues(alpha: 0.1),
    DecorativeCardTone.warm => AppColors.warning.withValues(alpha: 0.08),
    DecorativeCardTone.neutral => AppColors.surfaceContainerLowest,
  };

  Color get border => switch (this) {
    DecorativeCardTone.blue =>
      AppColors.secondaryFixed.withValues(alpha: 0.55),
    DecorativeCardTone.teal =>
      AppColors.onTertiaryContainer.withValues(alpha: 0.35),
    DecorativeCardTone.green => AppColors.success.withValues(alpha: 0.35),
    DecorativeCardTone.warm => AppColors.warning.withValues(alpha: 0.38),
    DecorativeCardTone.neutral => AppColors.outlineVariant.withValues(alpha: 0.65),
  };

  Color get accent => switch (this) {
    DecorativeCardTone.blue => AppColors.onPrimaryFixedVariant,
    DecorativeCardTone.teal => AppColors.onTertiaryContainer,
    DecorativeCardTone.green => AppColors.success,
    DecorativeCardTone.warm => AppColors.warning,
    DecorativeCardTone.neutral => AppColors.onSurfaceVariant,
  };

  Color get blobPrimary => accent.withValues(alpha: 0.14);

  Color get blobSecondary => accent.withValues(alpha: 0.08);

  Color get iconWellFill => accent.withValues(alpha: 0.14);
}
