import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/status_pill.dart';

/// SRS FR-28 wireframe.
///
/// Future:
/// - Implement module discovery + installation flow for .gcsmodule bundles.
/// - Enforce sandbox rules, permissions, dependency checks, lifecycle logging.
class PluginManagerScreen extends StatefulWidget {
  const PluginManagerScreen({super.key});

  @override
  State<PluginManagerScreen> createState() => _PluginManagerScreenState();
}

class _PluginManagerScreenState extends State<PluginManagerScreen> {
  bool _enabledAnalytics = true;
  bool _enabledSurvey = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Manager'),
        actions: [
          GradientButton(
            compact: true,
            onPressed: () {
              // Future: pick and validate .gcsmodule bundle.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Install module (placeholder)')),
              );
            },
            icon: Icons.add,
            label: 'Install',
          ),
          const SizedBox(width: AppSpacing.lg),
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
                        'Plugins',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Installed modules, permissions, and health (FR-28)',
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
                      label: 'Sandbox: ON',
                      color: AppColors.neonCyan,
                      leading: Icons.security_outlined,
                      dense: true,
                    ),
                    StatusPill(
                      label: 'Installed: 4',
                      color: scheme.outline,
                      leading: Icons.extension_outlined,
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
                  'Installed modules',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ModuleTile(
                  name: 'Core: Map',
                  meta: 'v3.0 • Built-in • Required',
                  enabled: true,
                  canDisable: false,
                  health: StatusPill(
                    label: 'Running',
                    color: AppColors.success,
                    leading: Icons.check_circle_outline,
                    dense: true,
                  ),
                  onChanged: null,
                ),
                _DividerLine(),
                _ModuleTile(
                  name: 'Core: Telemetry',
                  meta: 'v3.0 • Built-in • Required',
                  enabled: true,
                  canDisable: false,
                  health: StatusPill(
                    label: 'Running',
                    color: AppColors.success,
                    leading: Icons.check_circle_outline,
                    dense: true,
                  ),
                  onChanged: null,
                ),
                _DividerLine(),
                _ModuleTile(
                  name: 'Analytics Pack',
                  meta: 'v1.2 • Third-party • Permissions: Storage',
                  enabled: _enabledAnalytics,
                  canDisable: true,
                  health: StatusPill(
                    label: 'Idle',
                    color: scheme.outline,
                    leading: Icons.pause_circle_outline,
                    dense: true,
                  ),
                  onChanged: (v) => setState(() => _enabledAnalytics = v),
                ),
                _DividerLine(),
                _ModuleTile(
                  name: 'Survey Planner',
                  meta: 'v0.9 • Third-party • Permissions: Location',
                  enabled: _enabledSurvey,
                  canDisable: true,
                  health: StatusPill(
                    label: 'Running',
                    color: AppColors.success,
                    leading: Icons.check_circle_outline,
                    dense: true,
                  ),
                  onChanged: (v) => setState(() => _enabledSurvey = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Future: disabling a module takes effect on next restart. '
              'If a module is a dependency of another, show a dependency warning.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.name,
    required this.meta,
    required this.enabled,
    required this.canDisable,
    required this.health,
    required this.onChanged,
  });

  final String name;
  final String meta;
  final bool enabled;
  final bool canDisable;
  final Widget health;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.extension_outlined),
      title: Text(name),
      subtitle: Text(meta),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          health,
          const SizedBox(width: AppSpacing.sm),
          Switch(
            value: enabled,
            onChanged: canDisable ? onChanged : null,
          ),
        ],
      ),
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

