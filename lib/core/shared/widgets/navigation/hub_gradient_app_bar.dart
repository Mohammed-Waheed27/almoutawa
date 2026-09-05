import 'package:flutter/material.dart';

import 'almoutawa_app_bar.dart';
import 'app_bar_icon_button.dart';

export 'app_bar_icon_button.dart';

/// Primary shell-tab app bar — delegates to [AlmoutawaAppBar.primary].
class HubGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HubGradientAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Size get preferredSize =>
      AlmoutawaAppBar.primary(title: title, subtitle: subtitle).preferredSize;

  @override
  Widget build(BuildContext context) {
    return AlmoutawaAppBar.primary(
      title: title,
      subtitle: subtitle,
      actions: actions,
    );
  }
}

/// White icon button for gradient app bars — alias of [AppBarHeaderIconButton].
typedef HubHeaderIconButton = AppBarHeaderIconButton;
