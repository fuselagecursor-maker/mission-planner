import 'package:flutter/material.dart';

import '../../domain/vehicle_feature_item.dart';
import '../widgets/vehicle_setup_section_scaffold.dart';

class SensorsCalibrationScreen extends StatelessWidget {
  const SensorsCalibrationScreen({super.key});

  static const _items = <VehicleFeatureItem>[
    VehicleFeatureItem(
      id: 'S01',
      title: 'Accelerometer / IMU level calibration',
      subtitle: 'Level frame, start cal, 3–5 s (K++-style).',
    ),
    VehicleFeatureItem(
      id: 'S02',
      title: 'Magnetic compass (mag) calibration',
      subtitle: 'Outdoor; horizontal then vertical body rotations.',
    ),
    VehicleFeatureItem(
      id: 'S03',
      title: 'Gyro / additional IMU calibration',
      subtitle: 'If your FC stack exposes it.',
    ),
    VehicleFeatureItem(
      id: 'S04',
      title: 'Compass / accel quality or interference in UI',
      subtitle: 'Warnings before flight.',
    ),
    VehicleFeatureItem(
      id: 'S05',
      title: 'Level / attitude sanity in pre-arm',
      subtitle: 'Block arming on bad level.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const VehicleSetupSectionScaffold(
      title: 'Sensors & calibration',
      docPathHint: 'docs/FLIGHT_FEATURES_CHECKLIST.md · §1',
      items: _items,
    );
  }
}
