import 'package:flutter/material.dart';

import '../../../../l10n/app_strings.dart';
import 'almoutawa_app_bar.dart';

/// App bar presentation modes for mobile shells.
enum AlmoutawaAppBarMode {
  /// Home hubs — no top bar.
  none,

  /// Sub-pages — back + centered title on secondary gradient.
  subpage,

  /// Brand row — legacy.
  brand,
}

/// Sub-page app bar — delegates to [AlmoutawaAppBar.secondary].
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.pageTitle,
    this.showBackButton = false,
    this.showBrand = false,
    this.leading,
    this.actions = const [],
    this.onBack,
    this.mode = AlmoutawaAppBarMode.subpage,
  });

  final String? pageTitle;
  final bool showBackButton;
  final bool showBrand;
  final Widget? leading;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final AlmoutawaAppBarMode mode;

  static const String brandTitle = AppStrings.appName;

  @override
  Size get preferredSize => mode == AlmoutawaAppBarMode.none
      ? Size.zero
      : AlmoutawaAppBar.secondary(title: pageTitle ?? '').preferredSize;

  @override
  Widget build(BuildContext context) {
    if (mode == AlmoutawaAppBarMode.none) {
      return const SizedBox.shrink();
    }

    final isBrand = mode == AlmoutawaAppBarMode.brand || showBrand;

    return AlmoutawaAppBar.secondary(
      title: isBrand ? brandTitle : pageTitle,
      showBackButton: showBackButton && !isBrand,
      onBack: onBack,
      leading: isBrand ? leading : null,
      actions: actions,
    );
  }
}

class GlassAppBarAvatar extends StatelessWidget {
  const GlassAppBarAvatar({super.key, this.imageUrl, this.icon});

  final String? imageUrl;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Icon(icon ?? Icons.person_rounded, color: Colors.white, size: 22)
          : null,
    );
  }
}
