import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';
import 'almoutawa_app_bar_background.dart';
import 'app_bar_icon_button.dart';

/// Unified app bar — [AlmoutawaAppBarVariant.primary] for shell tabs,
/// [AlmoutawaAppBarVariant.secondary] for pushed sub-pages.
class AlmoutawaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AlmoutawaAppBar.primary({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  }) : variant = AlmoutawaAppBarVariant.primary,
       showBackButton = false,
       onBack = null,
       leading = null;

  const AlmoutawaAppBar.secondary({
    super.key,
    this.title,
    this.showBackButton = true,
    this.onBack,
    this.leading,
    this.actions = const [],
  }) : variant = AlmoutawaAppBarVariant.secondary,
       subtitle = null;

  final AlmoutawaAppBarVariant variant;
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? leading;
  final List<Widget> actions;

  bool get _isPrimary => variant == AlmoutawaAppBarVariant.primary;

  double _contentHeight(BuildContext context) {
    if (_isPrimary && subtitle != null) {
      return AppLayout.appBarHeightOf(context) +
          AppLayout.hubAppBarSubtitleExtraOf(context);
    }
    return AppLayout.appBarHeightOf(context);
  }

  static double _statusBarHeight(BuildContext context) =>
      MediaQuery.paddingOf(context).top;

  static double _fallbackStatusBarHeight() {
    final view = PlatformDispatcher.instance.views.first;
    return view.padding.top / view.devicePixelRatio;
  }

  @override
  Size get preferredSize {
    // PreferSize has no BuildContext — infer density from the window width.
    final view = PlatformDispatcher.instance.views.first;
    final width = view.physicalSize.width / view.devicePixelRatio;
    final dense = width >= 1024;
    final bar = dense ? DesktopUiTokens.toolbarHeight : AppLayout.appBarHeight;
    final extra = (_isPrimary && subtitle != null)
        ? (dense ? 22.0 : AppLayout.hubAppBarSubtitleExtra)
        : 0.0;
    return Size.fromHeight(_fallbackStatusBarHeight() + bar + extra);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = _statusBarHeight(context);
    final contentHeight = _contentHeight(context);
    final totalHeight = topInset + contentHeight;
    final dense = context.density.isExpanded;
    final hPad = dense
        ? DesktopUiTokens.pagePadding
        : AppSpacing.containerPadding;

    return SizedBox(
      height: totalHeight,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: AlmoutawaAppBarBackground(
          variant: variant,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              hPad,
              topInset + (_isPrimary ? (dense ? 4.0 : AppSpacing.xs) : 0),
              hPad,
              _isPrimary ? (dense ? 6.0 : AppSpacing.sm) : 0,
            ),
            child: SizedBox(
              height:
                  contentHeight -
                  (_isPrimary
                      ? (dense ? 10.0 : AppSpacing.xs + AppSpacing.sm)
                      : 0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: _isPrimary
                    ? _PrimaryBarContent(
                        title: title ?? '',
                        subtitle: subtitle,
                        actions: actions,
                        dense: dense,
                      )
                    : _SecondaryBarContent(
                        title: title,
                        showBackButton: showBackButton,
                        onBack: onBack,
                        leading: leading,
                        actions: actions,
                        dense: dense,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryBarContent extends StatelessWidget {
  const _PrimaryBarContent({
    required this.title,
    this.subtitle,
    required this.actions,
    required this.dense,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTypography.headlineSm().copyWith(
      color: AppColors.white,
      fontWeight: FontWeight.w700,
      fontSize: dense ? DesktopUiTokens.pageTitle : null,
      height: dense ? 1.2 : null,
    );
    final subtitleStyle = AppTypography.bodyMd().copyWith(
      color: AppColors.white.withValues(alpha: 0.88),
      fontSize: dense ? DesktopUiTokens.body : null,
      height: dense ? 1.25 : 1.25,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                title,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                SizedBox(height: dense ? 2 : AppSpacing.xs),
                Text(
                  subtitle!,
                  style: subtitleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          SizedBox(width: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
          Row(mainAxisSize: MainAxisSize.min, children: actions),
        ],
      ],
    );
  }
}

class _SecondaryBarContent extends StatelessWidget {
  const _SecondaryBarContent({
    this.title,
    required this.showBackButton,
    this.onBack,
    this.leading,
    required this.actions,
    required this.dense,
  });

  final String? title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? leading;
  final List<Widget> actions;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final side = AppLayout.iconButtonSizeOf(context);
    final titleStyle = AppTypography.headlineSm().copyWith(
      color: AppColors.white,
      fontWeight: FontWeight.w700,
      fontSize: dense ? DesktopUiTokens.pageTitle : null,
    );

    // Row layout (not Stack) — avoids “floating” title over controls / overflow.
    return Row(
      children: [
        SizedBox(
          width: side,
          child: showBackButton
              ? AppBarBackButton(onPressed: onBack)
              : (leading ?? const SizedBox.shrink()),
        ),
        Expanded(
          child: title != null && title!.isNotEmpty
              ? Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : const SizedBox.shrink(),
        ),
        SizedBox(
          width: actions.isEmpty ? side : null,
          child: actions.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
