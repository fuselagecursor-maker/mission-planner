import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../../../shared/widgets/placeholder_panel.dart';

/// SRS FR-29 wireframe.
///
/// Future:
/// - Maintain independent connections/telemetry per vehicle slot.
/// - Vehicle selector in app bar, active-vehicle scoping for all commands.
/// - Broadcast command confirmation dialog listing affected vehicles.
class MultiVehicleScreen extends StatefulWidget {
  const MultiVehicleScreen({super.key});

  @override
  State<MultiVehicleScreen> createState() => _MultiVehicleScreenState();
}

class _MultiVehicleScreenState extends State<MultiVehicleScreen> {
  String _active = 'V1';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Vehicle'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _active,
                items: const [
                  DropdownMenuItem(value: 'V1', child: Text('Active: V1')),
                  DropdownMenuItem(value: 'V2', child: Text('Active: V2')),
                  DropdownMenuItem(value: 'V3', child: Text('Active: V3')),
                  DropdownMenuItem(value: 'V4', child: Text('Active: V4')),
                ],
                onChanged: (v) => setState(() => _active = v ?? _active),
              ),
            ),
          ),
        ],
      ),
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
                        'Vehicles',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Multiple vehicles overview and broadcast commands (FR-29)',
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
                      label: 'Active: $_active',
                      color: AppColors.neonCyan,
                      leading: Icons.directions_car_filled_outlined,
                      dense: true,
                    ),
                    StatusPill(
                      label: 'Connected: 2',
                      color: scheme.outline,
                      leading: Icons.wifi_tethering_outlined,
                      dense: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _VehicleSelectorPanel(active: _active),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 5,
                  child: _BroadcastPanel(confirm: () => _confirmBroadcast(context)),
                ),
              ],
            )
          else ...[
            _VehicleSelectorPanel(active: _active),
            const SizedBox(height: AppSpacing.lg),
            _BroadcastPanel(confirm: () => _confirmBroadcast(context)),
          ],
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shared map',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.sm),
                const PlaceholderPanel(
                  height: 240,
                  icon: Icons.map_outlined,
                  title: 'Shared map',
                  subtitle: 'Map with up to 4 vehicle icons (placeholder)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmBroadcast(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Broadcast'),
        content: const Text('Send this command to all connected vehicles? (V1, V2)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _VehicleSelectorPanel extends StatelessWidget {
  const _VehicleSelectorPanel({required this.active});

  final String active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle selector',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _VehicleMiniCard(id: 'V1', active: active == 'V1', state: 'IN_MISSION', battery: '--%'),
              _VehicleMiniCard(
                id: 'V2',
                active: active == 'V2',
                state: 'CONNECTED_DISARMED',
                battery: '--%',
              ),
              _VehicleMiniCard(id: 'V3', active: active == 'V3', state: 'DISCONNECTED', battery: '--%'),
              _VehicleMiniCard(id: 'V4', active: active == 'V4', state: 'DISCONNECTED', battery: '--%'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          StatusPill(
            label: 'Tip: use the dropdown in the app bar to switch active vehicle',
            color: scheme.outline,
            leading: Icons.tips_and_updates_outlined,
            dense: true,
          ),
        ],
      ),
    );
  }
}

class _BroadcastPanel extends StatelessWidget {
  const _BroadcastPanel({required this.confirm});

  final Future<bool?> Function() confirm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Broadcast command',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Send a command to all connected vehicles.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              GradientButton(
                icon: Icons.home_outlined,
                label: 'RTH',
                onPressed: () async {
                  final ok = await confirm();
                  if (ok != true) return;
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Broadcast RTH (placeholder)')),
                  );
                },
              ),
              GradientButton(
                icon: Icons.flight_land_outlined,
                label: 'Land',
                onPressed: () async {
                  final ok = await confirm();
                  if (ok != true) return;
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Broadcast Land (placeholder)')),
                  );
                },
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final ok = await confirm();
                  if (ok != true) return;
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Broadcast Pause (placeholder)')),
                  );
                },
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Pause'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          StatusPill(
            label: 'Conflict warnings (placeholder)',
            color: scheme.outline,
            leading: Icons.report_outlined,
          ),
        ],
      ),
    );
  }
}

class _VehicleMiniCard extends StatelessWidget {
  const _VehicleMiniCard({
    required this.id,
    required this.active,
    required this.state,
    required this.battery,
  });

  final String id;
  final bool active;
  final String state;
  final String battery;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: () {
        // Active vehicle selection is handled at screen-level for wireframe.
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? AppColors.neonCyan : scheme.outlineVariant, width: active ? 2 : 1),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surfaceContainerHighest.withValues(alpha: active ? 0.62 : 0.48),
              scheme.surface.withValues(alpha: 0.20),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              id,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('State: $state', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            Text('Battery: $battery', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

