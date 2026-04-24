import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';

class WaypointsPlaceholder extends StatelessWidget {
  const WaypointsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Waypoints (placeholder)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // Future: open waypoint picker from Map SDK.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add waypoint (placeholder)')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              dense: true,
              leading: const Icon(Icons.place_outlined),
              title: const Text('Waypoint 1'),
              subtitle: const Text('Lat: --, Lng: --'),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Waypoint menu (placeholder)')),
                  );
                },
              ),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.place_outlined),
              title: const Text('Waypoint 2'),
              subtitle: const Text('Lat: --, Lng: --'),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Future: store waypoints in domain model, validate geometry, sync to map routes.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

