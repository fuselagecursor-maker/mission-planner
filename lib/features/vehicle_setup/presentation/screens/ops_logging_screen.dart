import 'package:flutter/material.dart';

import '../../domain/vehicle_feature_item.dart';
import '../widgets/vehicle_setup_section_scaffold.dart';

class OpsLoggingScreen extends StatelessWidget {
  const OpsLoggingScreen({super.key});

  static const _items = <VehicleFeatureItem>[
    VehicleFeatureItem(
      id: 'O01',
      title: 'Log download / list / viewer path',
    ),
    VehicleFeatureItem(
      id: 'O02',
      title: 'Parameter review and tuning (read/change as allowed)',
    ),
    VehicleFeatureItem(
      id: 'O03',
      title: 'KML / export or replay in app scope',
      subtitle: 'See also: Mission Replay in drawer.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const VehicleSetupSectionScaffold(
      title: 'Ops & data',
      docPathHint: 'docs/FLIGHT_FEATURES_CHECKLIST.md · §6',
      items: _items,
    );
  }
}
