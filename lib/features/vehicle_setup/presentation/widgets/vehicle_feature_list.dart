import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/vehicle_feature_item.dart';

/// Renders a scrollable list of checklist items; wireframe actions show a snackbar.
class VehicleFeatureList extends StatelessWidget {
  const VehicleFeatureList({super.key, required this.items, this.onOpenDetail});

  final List<VehicleFeatureItem> items;
  final void Function(VehicleFeatureItem item)? onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, i) {
        final item = items[i];
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            leading: Container(
              width: 40,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.35)),
              ),
              child: Text(
                item.id,
                style: text.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.neonCyan),
              ),
            ),
            title: Text(item.title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            subtitle: item.subtitle != null
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      item.subtitle!,
                      style: text.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  )
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenDetail != null
                ? () => onOpenDetail!(item)
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.id}: ${item.title} (wireframe)'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
          ),
        );
      },
    );
  }
}
