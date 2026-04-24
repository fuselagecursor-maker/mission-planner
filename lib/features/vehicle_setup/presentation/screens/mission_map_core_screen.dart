import 'package:flutter/material.dart';

import '../../domain/vehicle_feature_item.dart';
import '../widgets/vehicle_setup_section_scaffold.dart';

class MissionMapCoreScreen extends StatelessWidget {
  const MissionMapCoreScreen({super.key});

  static const _items = <VehicleFeatureItem>[
    VehicleFeatureItem(
      id: 'M01',
      title: 'Map with vehicle (live or mock)',
      subtitle: 'Open Map tab in the app shell.',
    ),
    VehicleFeatureItem(
      id: 'M02',
      title: 'Waypoint mission create / edit / send',
      subtitle: 'Missions tab · mission editor / wizard when wired.',
    ),
    VehicleFeatureItem(
      id: 'M03',
      title: 'In-mission progress (WP, distance to home, etc.)',
      subtitle: 'Map + Missions; wire to telemetry when available.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const VehicleSetupSectionScaffold(
      title: 'Map & mission (core GCS)',
      docPathHint: 'docs/FLIGHT_FEATURES_CHECKLIST.md · §7',
      items: _items,
    );
  }
}
