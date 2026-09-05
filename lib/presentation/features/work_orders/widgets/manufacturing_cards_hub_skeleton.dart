import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_spacing.dart';

class ManufacturingCardsHubSkeleton extends StatelessWidget {
  const ManufacturingCardsHubSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.containerPadding),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => AlmoutawaCard(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 14, color: Colors.grey[300]),
                          SizedBox(height: 4),
                          Container(
                            height: 11,
                            width: 120,
                            color: Colors.grey[200],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 28,
                      color: Colors.grey[200],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
