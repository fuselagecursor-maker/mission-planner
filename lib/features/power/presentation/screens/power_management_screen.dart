import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../../../shared/widgets/placeholder_panel.dart';

/// SRS FR-26 wireframe.
///
/// Future:
/// - Add discharge curves, per-cell voltages, RTH requirement computations.
/// - Integrate with live telemetry and mission feasibility model.
class PowerManagementScreen extends StatelessWidget {
  const PowerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Power Management')),
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
                        'Power',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Battery health, discharge, and feasibility estimates (FR-26)',
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
                      label: 'Battery: --%',
                      color: AppColors.neonCyan,
                      leading: Icons.battery_full_outlined,
                      dense: true,
                    ),
                    StatusPill(
                      label: 'Health: --',
                      color: scheme.outline,
                      leading: Icons.health_and_safety_outlined,
                      dense: true,
                    ),
                    GradientButton(
                      compact: true,
                      icon: Icons.insights_outlined,
                      label: 'Optimize',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Power optimizer (placeholder)')),
                        );
                      },
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
                  'Battery status',
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
                    StatusPill(
                      label: 'Battery: --%',
                      color: AppColors.neonCyan,
                      leading: Icons.battery_full_outlined,
                    ),
                    StatusPill(
                      label: 'Voltage: -- V',
                      color: scheme.outline,
                      leading: Icons.flash_on_outlined,
                    ),
                    StatusPill(
                      label: 'Current: -- A',
                      color: scheme.outline,
                      leading: Icons.bolt_outlined,
                    ),
                    StatusPill(
                      label: 'Health: --',
                      color: scheme.outline,
                      leading: Icons.health_and_safety_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const PlaceholderPanel(
                  height: 170,
                  icon: Icons.show_chart_rounded,
                  title: 'Discharge curve',
                  subtitle: 'Graph placeholder',
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
                  'RTH & feasibility',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Estimated RTH requirement'),
                  subtitle: const Text('--% (includes safety margin)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.7)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fact_check_outlined),
                  title: const Text('Mission feasibility'),
                  subtitle: const Text('FEASIBLE / MARGINAL / INSUFFICIENT'),
                  trailing: StatusPill(
                    label: 'FEASIBLE',
                    color: AppColors.success,
                    leading: Icons.check_circle_outline,
                    dense: true,
                  ),
                  onTap: () {},
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
                  'Per-cell voltages',
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
                    StatusPill(label: 'Cell 1: -- V', color: scheme.outline, leading: Icons.battery_1_bar),
                    StatusPill(label: 'Cell 2: -- V', color: scheme.outline, leading: Icons.battery_2_bar),
                    StatusPill(label: 'Cell 3: -- V', color: scheme.outline, leading: Icons.battery_3_bar),
                    StatusPill(label: 'Cell 4: -- V', color: scheme.outline, leading: Icons.battery_4_bar),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

