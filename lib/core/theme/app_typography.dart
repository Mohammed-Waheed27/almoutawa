import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_density.dart';
import 'desktop_ui_tokens.dart';

/// Tajawal typography — single source for all text sizes in Almoutawa.
///
/// Hierarchy (mobile, Arabic-first):
/// | Token | px | Use |
/// |---|---|---|
/// | [displayLg] | 28 | Hero KPI numbers, splash emphasis |
/// | [displaySm] | 22 | Compact hub stat values |
/// | [headlineMd] | 24 | Profile / entity header names |
/// | [headlineSm] | 20 | App bar titles, major sub-page sections |
/// | [titleMd] | 16 | List row titles, settings rows, portal cards |
/// | [titleSm] | 14 | Compact row titles, form block labels |
/// | [sectionLabel] | 13 | Settings group headers, filter group labels |
/// | [bodyLg] | 16 | Primary body copy |
/// | [bodyMd] | 14 | Secondary body, row subtitles |
/// | [labelBold] | 12 | Badges, chips, button labels |
/// | [labelMd] | 12 | Field labels, meta hints |
/// | [caption] | 11 | Dense KPI labels, inactive nav labels |
/// | [captionBold] | 11 | Dense metric values in mini tiles |
///
/// Prefer these tokens over `copyWith(fontSize: …)` in feature UI.
abstract final class AppTypography {
  static const String fontFamily = 'Tajawal';

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    required double lineHeight,
    double? letterSpacing,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      height: lineHeight / fontSize,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.onSurface,
    );
  }

  // ── Display ──────────────────────────────────────────────────────────────

  static TextStyle displayLg({bool arabic = true}) =>
      _style(fontSize: 28, fontWeight: FontWeight.w700, lineHeight: 36);

  static TextStyle displaySm({bool arabic = true}) =>
      _style(fontSize: 22, fontWeight: FontWeight.w700, lineHeight: 28);

  // ── Headline ─────────────────────────────────────────────────────────────

  static TextStyle headlineMd({bool arabic = true}) => _style(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        lineHeight: 32,
        letterSpacing: arabic ? null : -0.24,
      );

  static TextStyle headlineSm({bool arabic = true}) =>
      _style(fontSize: 20, fontWeight: FontWeight.w600, lineHeight: 28);

  // ── Title ────────────────────────────────────────────────────────────────

  static TextStyle titleMd({bool arabic = true}) =>
      _style(fontSize: 16, fontWeight: FontWeight.w600, lineHeight: 22);

  static TextStyle titleSm({bool arabic = true}) =>
      _style(fontSize: 14, fontWeight: FontWeight.w600, lineHeight: 20);

  /// Upper-hierarchy group labels (settings sections, filter groups).
  static TextStyle sectionLabel({bool arabic = true}) =>
      _style(fontSize: 13, fontWeight: FontWeight.w700, lineHeight: 18);

  // ── Body ─────────────────────────────────────────────────────────────────

  static TextStyle bodyLg({bool arabic = true}) =>
      _style(fontSize: 16, fontWeight: FontWeight.w400, lineHeight: 24);

  static TextStyle bodyMd({bool arabic = true}) =>
      _style(fontSize: 14, fontWeight: FontWeight.w400, lineHeight: 20);

  // ── Label / caption ──────────────────────────────────────────────────────

  static TextStyle labelBold({bool arabic = true}) => _style(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        lineHeight: 16,
        letterSpacing: arabic ? null : 0.6,
      );

  static TextStyle labelMd({bool arabic = true}) =>
      _style(fontSize: 12, fontWeight: FontWeight.w500, lineHeight: 16);

  static TextStyle caption({bool arabic = true}) =>
      _style(fontSize: 11, fontWeight: FontWeight.w500, lineHeight: 14);

  static TextStyle captionBold({bool arabic = true}) =>
      _style(fontSize: 11, fontWeight: FontWeight.w700, lineHeight: 14);

  // ── Dashboard KPI helpers ────────────────────────────────────────────────

  static TextStyle bentoLabelMini() => caption();

  static TextStyle bentoLabelCompact() => caption();

  static TextStyle bentoLabelStandard() => labelMd();

  static TextStyle bentoValueMini({bool hero = false}) =>
      hero ? titleMd().copyWith(fontWeight: FontWeight.w700) : titleMd();

  static TextStyle bentoValueCompact({bool hero = false}) =>
      hero ? displaySm() : headlineSm().copyWith(fontWeight: FontWeight.w700);

  static TextStyle bentoValueStandard({bool hero = false}) =>
      hero ? displayLg().copyWith(fontSize: 32.sp, height: 1.1) : displayLg();

  static TextTheme textTheme({bool arabic = true}) => TextTheme(
        displayLarge: displayLg(arabic: arabic),
        displayMedium: displaySm(arabic: arabic),
        displaySmall: headlineSm(arabic: arabic),
        headlineMedium: headlineMd(arabic: arabic),
        headlineSmall: headlineSm(arabic: arabic),
        titleLarge: titleMd(arabic: arabic),
        titleMedium: titleSm(arabic: arabic),
        titleSmall: sectionLabel(arabic: arabic),
        bodyLarge: bodyLg(arabic: arabic),
        bodyMedium: bodyMd(arabic: arabic),
        bodySmall: caption(arabic: arabic),
        labelLarge: labelBold(arabic: arabic),
        labelMedium: labelMd(arabic: arabic),
        labelSmall: captionBold(arabic: arabic),
      );

  // ── Density-aware (use these in shared + feature UI) ─────────────────────
  // On expanded: force DesktopUiTokens sizes (ignore inflated ScreenUtil .sp).
  // On compact: keep mobile token sizes.

  static TextStyle pageTitleOf(BuildContext context, {bool arabic = true}) {
    final dense = context.density.isExpanded;
    return (dense ? titleMd(arabic: arabic) : headlineSm(arabic: arabic))
        .copyWith(
      fontSize: dense ? DesktopUiTokens.pageTitle : null,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle titleOf(BuildContext context, {bool arabic = true}) {
    final dense = context.density.isExpanded;
    return titleSm(arabic: arabic).copyWith(
      fontSize: dense ? DesktopUiTokens.title : null,
    );
  }

  static TextStyle bodyOf(BuildContext context, {bool arabic = true}) {
    final dense = context.density.isExpanded;
    return bodyMd(arabic: arabic).copyWith(
      fontSize: dense ? DesktopUiTokens.body : null,
    );
  }

  static TextStyle labelOf(BuildContext context, {bool arabic = true}) {
    final dense = context.density.isExpanded;
    return labelMd(arabic: arabic).copyWith(
      fontSize: dense ? DesktopUiTokens.label : null,
    );
  }

  static TextStyle captionOf(BuildContext context, {bool arabic = true}) {
    final dense = context.density.isExpanded;
    return caption(arabic: arabic).copyWith(
      fontSize: dense ? DesktopUiTokens.label : null,
    );
  }
}
