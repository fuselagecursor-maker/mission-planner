import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';

/// K++-style micro-joystick: nudge a map vertex north/south/east/west (and diagonals).
class WaypointNudgePad extends StatelessWidget {
  const WaypointNudgePad({
    super.key,
    required this.stepFineM,
    required this.stepCoarseM,
    required this.coarse,
    required this.onToggleCoarse,
    required this.onNudge,
  });

  final double stepFineM;
  final double stepCoarseM;
  final bool coarse;
  final VoidCallback onToggleCoarse;
  final void Function(double northM, double eastM) onNudge;

  double get _step => coarse ? stepCoarseM : stepFineM;

  void _cardinal(double n, double e) => onNudge(n * _step, e * _step);

  void _diag(double n, double e) {
    const inv = 0.70710678118;
    onNudge(n * _step * inv, e * _step * inv);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sz = 40.0;
    Widget pad(IconData icon, VoidCallback onTap) => SizedBox(
          width: sz,
          height: sz,
          child: Material(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Icon(icon, size: 20, color: scheme.primary),
            ),
          ),
        );

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      color: scheme.surface.withValues(alpha: 0.94),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Move waypoint',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              coarse ? 'Step ${_step.toStringAsFixed(0)} m (coarse)' : 'Step ${_step.toStringAsFixed(1)} m (fine)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                pad(Icons.north_west, () => _diag(1, -1)),
                pad(Icons.arrow_upward, () => _cardinal(1, 0)),
                pad(Icons.north_east, () => _diag(1, 1)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                pad(Icons.arrow_back, () => _cardinal(0, -1)),
                SizedBox(
                  width: sz,
                  height: sz,
                  child: Tooltip(
                    message: coarse ? 'Switch to fine steps' : 'Switch to coarse steps',
                    child: Material(
                      color: scheme.primaryContainer.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: onToggleCoarse,
                        borderRadius: BorderRadius.circular(8),
                        child: Icon(
                          coarse ? Icons.unfold_more : Icons.unfold_less,
                          size: 22,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
                pad(Icons.arrow_forward, () => _cardinal(0, 1)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                pad(Icons.south_west, () => _diag(-1, -1)),
                pad(Icons.arrow_downward, () => _cardinal(-1, 0)),
                pad(Icons.south_east, () => _diag(-1, 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
