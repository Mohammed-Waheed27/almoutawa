import 'package:flutter/material.dart';

/// Sapphire Blueprint palette — single source for raw brand colors.
/// See `assets/DESIGN.md` for semantic mapping.
abstract final class AppColors {
  // Surfaces
  static const Color background = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color surfaceVariant = Color(0xFFD3E4FE);

  // Content
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF44464F);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);

  // Borders
  static const Color outline = Color(0xFF757680);
  static const Color outlineVariant = Color(0xFFC5C6D0);

  // Primary — Deep Sapphire
  static const Color primary = Color(0xFF001038);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF0F2557);
  static const Color onPrimaryContainer = Color(0xFF7B8DC6);
  static const Color inversePrimary = Color(0xFFB3C5FF);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color primaryFixedDim = Color(0xFFB3C5FF);
  static const Color onPrimaryFixed = Color(0xFF001849);
  static const Color onPrimaryFixedVariant = Color(0xFF324578);

  // Secondary — Electric Blue
  static const Color secondary = Color(0xFF0040E0);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF2E5BFF);
  static const Color onSecondaryContainer = Color(0xFFEFEFFF);
  static const Color secondaryFixed = Color(0xFFDDE1FF);

  // Tertiary — Cyan accent
  static const Color tertiary = Color(0xFF00171A);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF002D33);
  static const Color onTertiaryContainer = Color(0xFF009EB0);
  static const Color tertiaryFixed = Color(0xFF9CF0FF);
  static const Color tertiaryFixedDim = Color(0xFF00DAF3);
  static const Color onTertiaryFixed = Color(0xFF001F24);
  static const Color onTertiaryFixedVariant = Color(0xFF004F58);

  // Status
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color success = Color(0xFF009EB0);
  static const Color warning = Color(0xFFD97706);

  // Input
  static const Color inputFill = Color(0xFFF1F5F9);

  // Utility
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  // Mesh gradient blobs (5% opacity per design spec)
  static const Color meshSecondary = Color(0x0D0040E0);
  static const Color meshTertiary = Color(0x0D009EB0);
  static const Color meshPrimary = Color(0x0D0F2557);

  // App bar reference gradient anchors (teal-blue → electric blue)
  static const Color appBarPrimaryStart = Color(0xFF2B709E);
  static const Color appBarPrimaryEnd = Color(0xFF4A90E2);
  static const Color appBarSecondaryStart = Color(0xFF2569A8);
  static const Color appBarSecondaryEnd = Color(0xFF3D85DC);
}
