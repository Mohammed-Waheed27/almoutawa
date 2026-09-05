import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class ListLoadMoreFooter extends StatelessWidget {
  const ListLoadMoreFooter({
    super.key,
    required this.isLoading,
    required this.hasMore,
    required this.itemCount,
    required this.totalCount,
  });

  final bool isLoading;
  final bool hasMore;
  final int itemCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!hasMore && itemCount > 0) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: Text(
            'عرض $itemCount من $totalCount',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    return SizedBox(height: AppSpacing.sectionMargin);
  }
}
