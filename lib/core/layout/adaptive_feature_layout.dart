import 'package:flutter/material.dart';

import '../theme/app_density.dart';

/// Branches UI at the page entry — one Bloc above; compact vs expanded trees.
///
/// Medium widths (600–1023) keep [compact] until a dedicated medium layout exists.
class AdaptiveFeatureLayout extends StatelessWidget {
  const AdaptiveFeatureLayout({
    super.key,
    required this.compact,
    required this.expanded,
  });

  final Widget compact;
  final Widget expanded;

  @override
  Widget build(BuildContext context) {
    final d = context.density;
    return d.isExpanded ? expanded : compact;
  }
}
