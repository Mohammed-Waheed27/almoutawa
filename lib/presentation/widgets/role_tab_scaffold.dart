import 'package:flutter/material.dart';

import '../../core/layout/adaptive_scope.dart';
import '../../core/layout/desktop_page_shell.dart';
import '../../core/shared/widgets/navigation/almoutawa_app_bar.dart';
import '../../core/theme/app_density.dart';
import '../../core/theme/desktop_ui_tokens.dart';

/// Tab root layout inside a role shell — primary app bar + scrollable body.
class RoleTabScaffold extends StatelessWidget {
  const RoleTabScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.header,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,

    /// When false on expanded, skip [DesktopPageShell] so master–detail can use full width.
    this.constrainBody = true,
    this.contentMaxWidth,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? header;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Expanded only: wrap body in [DesktopPageShell]. Disable for MasterDetail hubs.
  final bool constrainBody;

  /// Expanded max width when [constrainBody] is true (default hub 1280).
  final double? contentMaxWidth;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AlmoutawaAppBar.primary(
        title: title,
        subtitle: subtitle,
        actions: actions,
      ),
      floatingActionButton: dense ? null : floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?header,
          Expanded(
            child: AdaptiveScopeHost(
              child: SafeArea(
                top: false,
                bottom: false,
                child: dense && constrainBody
                    ? DesktopPageShell(
                        maxWidth:
                            contentMaxWidth ?? DesktopUiTokens.hubMaxWidth,
                        padding: EdgeInsets.zero,
                        child: body,
                      )
                    : body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
