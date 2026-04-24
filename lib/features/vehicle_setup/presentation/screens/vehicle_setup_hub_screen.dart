import 'package:flutter/material.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/connection_status_banner.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/section_header.dart';

class _SectionLink {
  const _SectionLink({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

/// Central hub for [docs/FLIGHT_FEATURES_CHECKLIST.md] — sensors, RC, battery, etc.
class VehicleSetupHubScreen extends StatelessWidget {
  const VehicleSetupHubScreen({super.key});

  static const _sections = <_SectionLink>[
    _SectionLink(
      title: '1. Sensors & calibration',
      subtitle: 'S01–S05 · Accel, mag, gyro, interference, pre-arm',
      icon: Icons.compass_calibration_outlined,
      route: AppRoutes.vehicleSetupSensors,
    ),
    _SectionLink(
      title: '2. Radio / RC',
      subtitle: 'R01–R06 · RC cal, channels, stick mode, failsafe, RSSI',
      icon: Icons.gamepad_outlined,
      route: AppRoutes.vehicleSetupRadio,
    ),
    _SectionLink(
      title: '3. Power & battery',
      subtitle: 'P01–P05 · Alarms, protection, cell model, voltage cal',
      icon: Icons.battery_charging_full_outlined,
      route: AppRoutes.vehicleSetupBattery,
    ),
    _SectionLink(
      title: '4. Navigation, arming & safety',
      subtitle: 'N01–N06 · Pre-arm, GPS, RTL, geofence, E-stop, modes',
      icon: Icons.shield_outlined,
      route: AppRoutes.vehicleSetupNavSafety,
    ),
    _SectionLink(
      title: '5. Agri & payload',
      subtitle: 'A01–A04 · Spray, flowmeter, radar limits, field failsafe',
      icon: Icons.agriculture_outlined,
      route: AppRoutes.vehicleSetupAgri,
    ),
    _SectionLink(
      title: '6. Ops & data',
      subtitle: 'O01–O03 · Logs, parameters, export / replay',
      icon: Icons.insert_drive_file_outlined,
      route: AppRoutes.vehicleSetupOps,
    ),
    _SectionLink(
      title: '7. Map & mission (core GCS)',
      subtitle: 'M01–M03 · Map, waypoints, mission state',
      icon: Icons.map_outlined,
      route: AppRoutes.vehicleSetupMission,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle & preflight'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          ConnectionStatusBanner(
            state: ConnectionStateLabel.simulated,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link settings: open Settings tab (connection profile).'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Feature checklist (wireframe)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Matches docs/FLIGHT_FEATURES_CHECKLIST.md — open a section, then tap a row (IDs S01, R01, …).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._sections.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  leading: Icon(s.icon, color: scheme.onSurface),
                  title: Text(s.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                    s.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, s.route),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
