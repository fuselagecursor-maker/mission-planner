import 'package:flutter/material.dart';

import '../../domain/vehicle_feature_item.dart';
import '../widgets/vehicle_setup_section_scaffold.dart';

class NavigationArmingSafetyScreen extends StatelessWidget {
  const NavigationArmingSafetyScreen({super.key});

  static const _items = <VehicleFeatureItem>[
    VehicleFeatureItem(
      id: 'N01',
      title: 'Pre-arm / pre-flight check list',
      subtitle: 'Sensors, RC, battery, EKF, GPS, props.',
    ),
    VehicleFeatureItem(
      id: 'N02',
      title: 'GPS / position fix + quality',
    ),
    VehicleFeatureItem(
      id: 'N03',
      title: 'Home + RTL height & speed',
    ),
    VehicleFeatureItem(
      id: 'N04',
      title: 'Geofence and/or max alt / distance',
    ),
    VehicleFeatureItem(
      id: 'N05',
      title: 'Disarm, motor interlock, emergency stop',
    ),
    VehicleFeatureItem(
      id: 'N06',
      title: 'Flight mode display + commanded mode',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const VehicleSetupSectionScaffold(
      title: 'Navigation, arming & safety',
      docPathHint: 'docs/FLIGHT_FEATURES_CHECKLIST.md · §4',
      items: _items,
    );
  }
}
