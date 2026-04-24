import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../../../shared/widgets/placeholder_panel.dart';

/// SRS FR-27 wireframe.
///
/// Future:
/// - Replace placeholders with a real FSM engine (Riverpod/Bloc) and transition table.
/// - Persist state; log transitions; validate transitions; drive HUD states.
class FsmViewerScreen extends StatelessWidget {
  const FsmViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('State Machine (FSM)')),
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
                        'FSM',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Vehicle state machine inspector and transition history (FR-27)',
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
                      label: 'State: IN_MISSION',
                      color: AppColors.neonCyan,
                      leading: Icons.hub_outlined,
                      dense: true,
                    ),
                    StatusPill(
                      label: 'Updated: --',
                      color: scheme.outline,
                      leading: Icons.schedule_outlined,
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
                  'Current state',
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
                      label: 'State: IN_MISSION',
                      color: AppColors.neonCyan,
                      leading: Icons.hub_outlined,
                    ),
                    StatusPill(
                      label: 'Trigger: Mission Start',
                      color: scheme.outline,
                      leading: Icons.bolt_outlined,
                    ),
                    StatusPill(
                      label: 'Updated: --',
                      color: scheme.outline,
                      leading: Icons.schedule_outlined,
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
                  'Transition diagram',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.sm),
                const PlaceholderPanel(
                  height: 260,
                  icon: Icons.account_tree_outlined,
                  title: 'State Transition Diagram Viewer',
                  subtitle: 'Diagram placeholder',
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
                  'Recent transitions',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _TransitionTile(
                  title: 'CONNECTED_DISARMED → PRE_ARM_CHECK',
                  subtitle: 'Trigger: Arm command • Time: --',
                ),
                _DividerLine(),
                const _TransitionTile(
                  title: 'PRE_ARM_CHECK → ARMED_IDLE',
                  subtitle: 'Trigger: All checks pass • Time: --',
                ),
                _DividerLine(),
                const _TransitionTile(
                  title: 'ARMED_IDLE → TAKING_OFF',
                  subtitle: 'Trigger: Start mission • Time: --',
                ),
                _DividerLine(),
                const _TransitionTile(
                  title: 'TAKING_OFF → IN_MISSION',
                  subtitle: 'Trigger: Takeoff complete • Time: --',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransitionTile extends StatelessWidget {
  const _TransitionTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.swap_horiz_outlined),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.7));
  }
}

