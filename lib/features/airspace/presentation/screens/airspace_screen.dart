import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/status_pill.dart';

/// SRS FR-25 wireframe.
///
/// Future:
/// - Integrate airspace provider (OpenAIP/AirMap) via AirspaceDataService.
/// - Render polygons/NOTAM markers on the map and compute compliance status.
class AirspaceScreen extends StatefulWidget {
  const AirspaceScreen({super.key});

  @override
  State<AirspaceScreen> createState() => _AirspaceScreenState();
}

class _AirspaceScreenState extends State<AirspaceScreen> {
  bool _airspaceLayer = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Airspace Awareness')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Airspace',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Compliance status and nearby restrictions (FR-25)',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.end,
                  children: [
                    StatusPill(
                      label: 'Status: CLEAR',
                      color: AppColors.success,
                      leading: Icons.verified_outlined,
                      dense: true,
                    ),
                    StatusPill(
                      label: 'Layer: ${_airspaceLayer ? 'ON' : 'OFF'}',
                      color: _airspaceLayer ? AppColors.neonCyan : scheme.outline,
                      leading: Icons.layers_outlined,
                      dense: true,
                    ),
                    Switch(
                      value: _airspaceLayer,
                      onChanged: (v) => setState(() => _airspaceLayer = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Compliance status',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    StatusPill(
                      label: 'Last updated: --',
                      color: scheme.outline,
                      leading: Icons.schedule_outlined,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StatusPill(
                      label: 'NFZ: none nearby',
                      color: scheme.outline,
                      leading: Icons.block_outlined,
                      dense: true,
                    ),
                    StatusPill(
                      label: 'NOTAMs: --',
                      color: scheme.outline,
                      leading: Icons.campaign_outlined,
                      dense: true,
                    ),
                    StatusPill(
                      label: 'Ceiling: --',
                      color: scheme.outline,
                      leading: Icons.height_outlined,
                      dense: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zones',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.block_outlined),
                  title: const Text('No-Fly Zone (NFZ)'),
                  subtitle: const Text('ZONE_NAME • Ceiling: -- • Active: --'),
                  trailing: StatusPill(
                    label: 'NFZ',
                    color: scheme.error,
                    leading: Icons.warning_amber_rounded,
                    dense: true,
                  ),
                  onTap: () {},
                ),
                Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.7)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.shield_outlined),
                  title: const Text('Controlled Airspace'),
                  subtitle: const Text('Class -- • Ceiling: --'),
                  trailing: StatusPill(
                    label: 'CTRL',
                    color: AppColors.neonCyan,
                    leading: Icons.shield_outlined,
                    dense: true,
                  ),
                  onTap: () {},
                ),
                Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.7)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.campaign_outlined),
                  title: const Text('NOTAM'),
                  subtitle: const Text('Tap to expand NOTAM text (placeholder)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

