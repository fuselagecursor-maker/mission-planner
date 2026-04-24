import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/vehicle_feature_item.dart';
import 'vehicle_feature_list.dart';

class VehicleSetupSectionScaffold extends StatelessWidget {
  const VehicleSetupSectionScaffold({
    super.key,
    required this.title,
    required this.docPathHint,
    required this.items,
  });

  final String title;
  final String docPathHint;
  final List<VehicleFeatureItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Checklist items'),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  docPathHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: VehicleFeatureList(items: items),
            ),
          ),
        ],
      ),
    );
  }
}
