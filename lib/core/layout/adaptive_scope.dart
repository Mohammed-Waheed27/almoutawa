import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

/// Exposes viewport width + breakpoint helpers to descendants.
/// Prefer [AppDensityScope] / `context.density` for feature branching.
class AdaptiveScope extends InheritedWidget {
  const AdaptiveScope({super.key, required this.width, required super.child});

  final double width;

  bool get isCompact => AppBreakpoints.isCompact(width);
  bool get isMedium => AppBreakpoints.isMedium(width);
  bool get isExpanded => AppBreakpoints.isExpanded(width);

  static AdaptiveScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AdaptiveScope>();
    assert(scope != null, 'AdaptiveScope not found in widget tree');
    return scope!;
  }

  static AdaptiveScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdaptiveScope>();
  }

  @override
  bool updateShouldNotify(AdaptiveScope oldWidget) => oldWidget.width != width;
}

/// Wraps [child] with [AdaptiveScope] using current [MediaQuery] width.
class AdaptiveScopeHost extends StatelessWidget {
  const AdaptiveScopeHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScope(width: MediaQuery.sizeOf(context).width, child: child);
  }
}
