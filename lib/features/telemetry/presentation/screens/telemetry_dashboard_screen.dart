import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_pill.dart';

/// SRS FR-07 / FR-24 wireframe.
///
/// Future:
/// - Replace placeholders with telemetry streams (live and replay-synchronised).
/// - Add expandable time-series graph panel and replay cursor integration.
class TelemetryDashboardScreen extends StatefulWidget {
  const TelemetryDashboardScreen({super.key});

  @override
  State<TelemetryDashboardScreen> createState() => _TelemetryDashboardScreenState();
}

class _TelemetryDashboardScreenState extends State<TelemetryDashboardScreen> {
  bool _graphsExpanded = false;
  bool _recording = false;
  bool _replayMode = false;
  double _replayPosition = 0.25;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemetry'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Center(
              child: StatusPill(
                label: _replayMode ? 'Mode: REPLAY' : 'Mode: LIVE',
                color: _replayMode ? scheme.tertiary : scheme.primary,
                leading: _replayMode ? Icons.replay_outlined : Icons.wifi_tethering_rounded,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                  child: GlassCard(
                    borderRadius: 26,
                    opacity: 0.58,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Telemetry Center',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.6,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _replayMode
                                    ? 'Replay-synchronised panels and cursor controls.'
                                    : 'Live flight telemetry panels (wireframe).',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        GradientButton(
                          label: _replayMode ? 'Exit Replay' : 'Replay',
                          icon: _replayMode ? Icons.close : Icons.replay_outlined,
                          compact: true,
                          onPressed: () => setState(() => _replayMode = !_replayMode),
                        ),
                      ],
                    ),
                  ),
                ),
                const SectionHeader(title: 'Attitude & heading'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      const Expanded(child: _InstrumentCard(title: 'Artificial horizon')),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(child: _InstrumentCard(title: 'Compass rose')),
                    ],
                  ),
                ),
                const SectionHeader(title: 'Key metrics'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: GlassCard(
                    borderRadius: 24,
                    opacity: 0.55,
                    child: LayoutBuilder(
                      builder: (ctx, c) {
                        final w = c.maxWidth;
                        final cols = w >= 1100 ? 4 : (w >= 720 ? 3 : 2);
                        return GridView.count(
                          crossAxisCount: cols,
                          mainAxisSpacing: AppSpacing.sm,
                          crossAxisSpacing: AppSpacing.sm,
                          childAspectRatio: cols >= 4 ? 2.9 : 2.6,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            _MetricTile(icon: Icons.height_outlined, label: 'Altitude', value: '-- m'),
                            _MetricTile(icon: Icons.speed_outlined, label: 'Speed', value: '-- m/s'),
                            _MetricTile(icon: Icons.trending_up_outlined, label: 'V-Speed', value: '-- m/s'),
                            _MetricTile(icon: Icons.explore_outlined, label: 'Heading', value: '--°'),
                            _MetricTile(icon: Icons.battery_charging_full_outlined, label: 'Battery', value: '--%'),
                            _MetricTile(icon: Icons.signal_cellular_alt_outlined, label: 'Signal', value: '--'),
                            _MetricTile(icon: Icons.straighten_outlined, label: 'Distance', value: '-- m'),
                            _MetricTile(icon: Icons.satellite_alt_outlined, label: 'GPS', value: '-- sats'),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SectionHeader(title: 'Graphs'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: GlassCard(
                    borderRadius: 24,
                    opacity: 0.55,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.show_chart_outlined),
                          title: const Text('Time-series graphs'),
                          subtitle: Text(
                            _graphsExpanded
                                ? 'Expanded (channel selector + replay cursor placeholder)'
                                : 'Collapsed',
                          ),
                          trailing: IconButton(
                            tooltip: _graphsExpanded ? 'Collapse' : 'Expand',
                            onPressed: () => setState(() => _graphsExpanded = !_graphsExpanded),
                            icon: Icon(
                              _graphsExpanded
                                  ? Icons.expand_less_outlined
                                  : Icons.expand_more_outlined,
                            ),
                          ),
                          onTap: () => setState(() => _graphsExpanded = !_graphsExpanded),
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: _graphsExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox(height: 0),
                          secondChild: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              0,
                              AppSpacing.lg,
                              AppSpacing.lg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.filter_alt_outlined),
                                      label: const Text('Channel'),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.zoom_in_outlined),
                                      label: const Text('Zoom'),
                                    ),
                                    const Spacer(),
                                    StatusPill(
                                      label: _replayMode ? 'Replay cursor' : 'Live cursor',
                                      color: _replayMode ? AppColors.softPurple : AppColors.neonCyan,
                                      leading: _replayMode ? Icons.replay_outlined : Icons.bolt_outlined,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.8)),
                                    gradient: LinearGradient(
                                      colors: [
                                        scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                                        scheme.surface.withValues(alpha: 0.25),
                                      ],
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('Graph viewport (placeholder)'),
                                ),
                                if (_replayMode) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  Row(
                                    children: [
                                      Text(
                                        'Replay',
                                        style: Theme.of(context).textTheme.labelLarge,
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Slider(
                                          value: _replayPosition,
                                          onChanged: (v) => setState(() => _replayPosition = v),
                                        ),
                                      ),
                                      Text('${(_replayPosition * 100).toStringAsFixed(0)}%'),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
          _BottomActionStrip(
            recording: _recording,
            replayMode: _replayMode,
            onToggleRecording: (v) => setState(() => _recording = v),
            onOpenLogs: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open log viewer (placeholder)')),
              );
            },
            onToggleReplayMode: () => setState(() => _replayMode = !_replayMode),
          ),
        ],
      ),
    );
  }
}

class _InstrumentCard extends StatelessWidget {
  const _InstrumentCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      borderRadius: 24,
      opacity: 0.55,
      child: SizedBox(
        height: 170,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.8)),
            gradient: LinearGradient(
              colors: [
                scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                scheme.surface.withValues(alpha: 0.25),
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$title\n(placeholder)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionStrip extends StatelessWidget {
  const _BottomActionStrip({
    required this.recording,
    required this.replayMode,
    required this.onToggleRecording,
    required this.onOpenLogs,
    required this.onToggleReplayMode,
  });

  final bool recording;
  final bool replayMode;
  final ValueChanged<bool> onToggleRecording;
  final VoidCallback onOpenLogs;
  final VoidCallback onToggleReplayMode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 6,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: onOpenLogs,
                icon: const Icon(Icons.article_outlined),
                label: const Text('Logs'),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => onToggleRecording(!recording),
                icon: Icon(recording ? Icons.stop_circle_outlined : Icons.fiber_manual_record),
                label: Text(recording ? 'Stop rec' : 'Record'),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onToggleReplayMode,
                icon: Icon(replayMode ? Icons.close : Icons.replay_outlined),
                label: Text(replayMode ? 'Exit replay' : 'Replay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
