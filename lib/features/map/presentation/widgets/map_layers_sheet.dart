import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';

/// Bottom sheet: basemap + overlay toggles (wireframe; drives [MapViewport] props).
class MapLayersSheet extends StatelessWidget {
  const MapLayersSheet({
    super.key,
    required this.useSatelliteBasemap,
    required this.onUseSatelliteBasemapChanged,
    required this.missionGeometryEnabled,
    required this.onMissionGeometryChanged,
    required this.vehicleOnMapEnabled,
    required this.onVehicleOnMapChanged,
    required this.flightTrailEnabled,
    required this.onFlightTrailEnabledChanged,
    required this.mapHudEnabled,
    required this.onMapHudEnabledChanged,
    required this.manualControlEnabled,
    required this.onManualControlEnabledChanged,
  });

  final bool useSatelliteBasemap;
  final ValueChanged<bool> onUseSatelliteBasemapChanged;
  final bool missionGeometryEnabled;
  final ValueChanged<bool> onMissionGeometryChanged;
  final bool vehicleOnMapEnabled;
  final ValueChanged<bool> onVehicleOnMapChanged;
  final bool flightTrailEnabled;
  final ValueChanged<bool> onFlightTrailEnabledChanged;
  final bool mapHudEnabled;
  final ValueChanged<bool> onMapHudEnabledChanged;
  final bool manualControlEnabled;
  final ValueChanged<bool> onManualControlEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sectionStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Map layers',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Basemap', style: sectionStyle),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Streets'),
                    icon: Icon(Icons.map_outlined),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Satellite'),
                    icon: Icon(Icons.satellite_alt_outlined),
                  ),
                ],
                selected: {useSatelliteBasemap},
                onSelectionChanged: (Set<bool> next) {
                  if (next.isEmpty) return;
                  onUseSatelliteBasemapChanged(next.first);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Overlays', style: sectionStyle),
              const SizedBox(height: AppSpacing.xs),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: missionGeometryEnabled,
                onChanged: onMissionGeometryChanged,
                secondary: Icon(Icons.timeline_outlined, color: scheme.primary),
                title: const Text('Land plot & waypoints'),
                subtitle: const Text('Field polygon, route path, and vertex markers'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: vehicleOnMapEnabled,
                onChanged: onVehicleOnMapChanged,
                secondary: Icon(Icons.navigation_outlined, color: scheme.primary),
                title: const Text('Vehicle position'),
                subtitle: const Text('Heading marker on the map'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: flightTrailEnabled,
                onChanged: onFlightTrailEnabledChanged,
                secondary: Icon(Icons.route_outlined, color: scheme.primary),
                title: const Text('Flight path trail'),
                subtitle: const Text('Draw recent vehicle movement track'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: mapHudEnabled,
                onChanged: onMapHudEnabledChanged,
                secondary: Icon(Icons.dashboard_outlined, color: scheme.primary),
                title: const Text('Map HUD'),
                subtitle: const Text('Compass, speed/alt, home distance'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: manualControlEnabled,
                onChanged: onManualControlEnabledChanged,
                secondary: Icon(Icons.sports_esports_rounded, color: scheme.primary),
                title: const Text('Manual control panel'),
                subtitle: const Text('Show collapsible control panel overlay'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
