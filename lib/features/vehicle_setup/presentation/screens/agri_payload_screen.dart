import 'package:flutter/material.dart';

import '../../domain/vehicle_feature_item.dart';
import '../widgets/vehicle_setup_section_scaffold.dart';

class AgriPayloadScreen extends StatelessWidget {
  const AgriPayloadScreen({super.key});

  static const _items = <VehicleFeatureItem>[
    VehicleFeatureItem(
      id: 'A01',
      title: 'Spray / pump or payload parameters',
    ),
    VehicleFeatureItem(
      id: 'A02',
      title: 'Flowmeter calibration',
    ),
    VehicleFeatureItem(
      id: 'A03',
      title: 'Obstacle / radar related limits',
      subtitle: 'e.g. cap speed/tilt when radar on.',
    ),
    VehicleFeatureItem(
      id: 'A04',
      title: 'Field-appropriate loss-of-link / resume behavior',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const VehicleSetupSectionScaffold(
      title: 'Agri & payload',
      docPathHint: 'docs/FLIGHT_FEATURES_CHECKLIST.md · §5',
      items: _items,
    );
  }
}
