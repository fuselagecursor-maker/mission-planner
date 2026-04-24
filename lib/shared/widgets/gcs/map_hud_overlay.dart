import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/gcs_tokens.dart';

class MapHudOverlay extends StatelessWidget {
  const MapHudOverlay({
    super.key,
    required this.headingDeg,
    required this.speedMs,
    required this.altitudeMslM,
    required this.homeDistanceM,
    required this.homeBearingDeg,
    this.compact = false,
  });

  final double headingDeg;
  final double speedMs;
  final double altitudeMslM;
  final double homeDistanceM;
  final double homeBearingDeg;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final card = (String label, String value) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: GcsColors.bgPanel.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GcsColors.border),
            boxShadow: GcsLayout.panelDepth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: GcsColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: GcsColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );

    final hdg = _normDeg(headingDeg);
    final arrowDeg = _normDeg(homeBearingDeg - hdg);

    return LayoutBuilder(
      builder: (context, c) {
        // Keep HUD strict: never overflow its constraints.
        // If space is tight, fall back to fewer chips.
        final tight = c.maxWidth.isFinite ? c.maxWidth < 260 : compact;
        final showAll = !compact && !tight;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CompassChip(headingDeg: hdg, homeArrowRelativeDeg: arrowDeg),
            const SizedBox(width: 8),
            if (showAll) ...[
              card('SPD', '${speedMs.toStringAsFixed(1)} m/s'),
              const SizedBox(width: 8),
              card('ALT', '${altitudeMslM.toStringAsFixed(0)} m'),
              const SizedBox(width: 8),
            ],
            card('HOME', _homeDistanceLabel(homeDistanceM)),
          ],
        );
      },
    );
  }
}

class _CompassChip extends StatelessWidget {
  const _CompassChip({
    required this.headingDeg,
    required this.homeArrowRelativeDeg,
  });

  final double headingDeg;
  final double homeArrowRelativeDeg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: GcsColors.bgPanel.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GcsColors.border),
        boxShadow: GcsLayout.panelDepth,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            headingDeg.toStringAsFixed(0),
            style: const TextStyle(
              color: GcsColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
          Transform.rotate(
            angle: homeArrowRelativeDeg * math.pi / 180.0,
            child: const Icon(Icons.navigation_rounded, size: 16, color: GcsColors.accentPrimary),
          ),
        ],
      ),
    );
  }
}

double _normDeg(double d) => (d % 360 + 360) % 360;

String _homeDistanceLabel(double m) {
  if (m >= 1000) return '${(m / 1000).toStringAsFixed(1)} km';
  return '${m.toStringAsFixed(0)} m';
}

