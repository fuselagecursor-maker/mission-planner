import 'package:flutter/material.dart';

import '../../domain/vehicle_feature_item.dart';
import '../widgets/vehicle_setup_section_scaffold.dart';

class BatteryPowerScreen extends StatelessWidget {
  const BatteryPowerScreen({super.key});

  static const _items = <VehicleFeatureItem>[
    VehicleFeatureItem(
      id: 'P01',
      title: 'Low-voltage alarm',
      subtitle: 'HUD + optional audio.',
    ),
    VehicleFeatureItem(
      id: 'P02',
      title: 'Low / critical protection + action',
      subtitle: 'RTL, land, or hover on trigger.',
    ),
    VehicleFeatureItem(
      id: 'P03',
      title: 'Cell / pack model',
      subtitle: 'S count, pack V, or smart battery.',
    ),
    VehicleFeatureItem(
      id: 'P04',
      title: 'Voltage display calibration',
      subtitle: 'Measured vs reported mV.',
    ),
    VehicleFeatureItem(
      id: 'P05',
      title: 'Discharge / over-current (as FC provides)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const VehicleSetupSectionScaffold(
      title: 'Power & battery',
      docPathHint: 'docs/FLIGHT_FEATURES_CHECKLIST.md · §3',
      items: _items,
    );
  }
}
