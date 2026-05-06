import 'package:flutter/material.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/gcs_tokens.dart';
import '../../core/ui/app_spacing.dart';
import '../../shared/widgets/glass/glass_card.dart';
import '../../shared/widgets/status_pill.dart';

/// SRS v3.0: Root navigation is a persistent main drawer.
///
/// Note: We keep the bottom tabs for fast core navigation, but the drawer
/// provides access to the expanded GCS feature set (Manual Control, Camera,
/// Replay, Plugins, Multi-Vehicle, etc.).
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(color: scheme.surface),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppGradients.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.flight_takeoff, color: scheme.onPrimary, size: 18),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Drone GCS',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.2,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Mission Planner • Dashboard',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: const [
                          StatusPill(
                            label: 'LIVE',
                            color: AppColors.success,
                            leading: Icons.wifi_tethering_rounded,
                            dense: true,
                          ),
                          StatusPill(
                            label: 'V1',
                            color: AppColors.neonCyan,
                            leading: Icons.flight_rounded,
                            dense: true,
                          ),
                          StatusPill(
                            label: 'AUTO',
                            color: AppColors.softPurple,
                            leading: Icons.auto_mode_rounded,
                            dense: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: GlassCard(
                    borderRadius: 22,
                    padding: EdgeInsets.zero,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      children: const [
                        _NavSectionLabel('VEHICLE & PREFLIGHT'),
                        _NavTile(
                          icon: Icons.fact_check_outlined,
                          title: 'Vehicle & preflight (checklist)',
                          route: AppRoutes.vehicleSetup,
                        ),
                        _NavDivider(),
                        _NavSectionLabel('FLIGHT'),
                        _NavTile(icon: Icons.gamepad_outlined, title: 'Manual Control', route: AppRoutes.manualControl),
                        _NavTile(icon: Icons.videocam_outlined, title: 'Camera & Payload', route: AppRoutes.cameraPayload),
                        _NavTile(icon: Icons.speed_outlined, title: 'Telemetry Dashboard', route: AppRoutes.telemetry),
                        _NavTile(icon: Icons.battery_charging_full_outlined, title: 'Power Management', route: AppRoutes.power),
                        _NavTile(icon: Icons.public_outlined, title: 'Airspace Awareness', route: AppRoutes.airspace),
                        _NavTile(icon: Icons.replay_outlined, title: 'Mission Replay', route: AppRoutes.replay),
                        _NavTile(icon: Icons.schema_outlined, title: 'State Machine (FSM)', route: AppRoutes.fsmViewer),
                        _NavDivider(),
                        _NavSectionLabel('SYSTEM'),
                        _NavTile(icon: Icons.directions_car_outlined, title: 'Multi-Vehicle', route: AppRoutes.vehicles),
                        _NavTile(icon: Icons.system_update_alt_outlined, title: 'Firmware Flash', route: AppRoutes.firmwareFlash),
                        _NavTile(icon: Icons.extension_outlined, title: 'Plugin Manager', route: AppRoutes.plugins),
                        _NavDivider(),
                        _NavTile(icon: Icons.help_outline, title: 'Help & About', route: AppRoutes.helpAbout),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSectionLabel extends StatelessWidget {
  const _NavSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _NavDivider extends StatelessWidget {
  const _NavDivider();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Divider(height: AppSpacing.xl, color: scheme.outlineVariant.withValues(alpha: 0.65)),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, size: 20, color: scheme.onSurface),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

