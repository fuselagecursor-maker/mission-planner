import 'package:flutter/material.dart';

import '../../domain/vehicle_feature_item.dart';
import '../widgets/vehicle_setup_section_scaffold.dart';

class RadioRcScreen extends StatelessWidget {
  const RadioRcScreen({super.key});

  static const _items = <VehicleFeatureItem>[
    VehicleFeatureItem(
      id: 'R01',
      title: 'RC / stick calibration wizard',
      subtitle: 'After new build, new RX, or new radio.',
    ),
    VehicleFeatureItem(
      id: 'R02',
      title: 'Channel mapping',
      subtitle: 'Arm, mode, E-stop, mode switch (e.g. ch5), etc.',
    ),
    VehicleFeatureItem(
      id: 'R03',
      title: 'Stick / transmitter mode (mode 1–4)',
    ),
    VehicleFeatureItem(
      id: 'R04',
      title: 'Failsafe: loss of RC',
      subtitle: 'RTL / land / hover — match FC.',
    ),
    VehicleFeatureItem(
      id: 'R05',
      title: '“Continue on link loss” (optional)',
      subtitle: 'Usually off; strong warnings if on.',
    ),
    VehicleFeatureItem(
      id: 'R06',
      title: 'Link quality / RSSI in HUD',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const VehicleSetupSectionScaffold(
      title: 'Radio / RC',
      docPathHint: 'docs/FLIGHT_FEATURES_CHECKLIST.md · §2',
      items: _items,
    );
  }
}
