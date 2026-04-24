import 'package:flutter/material.dart';

import '../../../core/ui/app_spacing.dart';
import 'skeleton_box.dart';

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const SkeletonBox(height: 40, width: 40, radius: 12),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, width: 180, radius: 8),
                SizedBox(height: AppSpacing.sm),
                SkeletonBox(height: 12, width: 240, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

