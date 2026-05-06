import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/gcs_tokens.dart';
import '../shared/widgets/gcs/gcs_telemetry_deck.dart';

class GcsRightTelemetryPanel extends StatelessWidget {
  const GcsRightTelemetryPanel({
    super.key,
    required this.open,
    required this.onToggle,
    this.maxPanelWidth = 260,
    required this.altitudeM,
    required this.speedMs,
    required this.batteryPct,
    required this.gpsSats,
    required this.headingDeg,
    required this.climbMps,
    required this.hdop,
    this.batteryVoltageV = '—',
    this.batteryCurrentA = '—',
    this.batteryTimeRemaining = '—',
    this.gpsFix = '—',
    this.gpsAccuracy = '—',
    this.ekf = '—',
    this.imu = '—',
    this.compass = '—',
  });

  final bool open;
  final VoidCallback onToggle;
  final double maxPanelWidth;

  final String altitudeM;
  final String speedMs;
  final String batteryPct;
  final String gpsSats;
  final String headingDeg;
  final String climbMps;
  final String hdop;
  final String batteryVoltageV;
  final String batteryCurrentA;
  final String batteryTimeRemaining;
  final String gpsFix;
  final String gpsAccuracy;
  final String ekf;
  final String imu;
  final String compass;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Keep map visible: panel is narrow and semi-transparent.
    // On very small windows, clamp so we never trigger a Flex overflow.
    final desiredPanelWidth = maxPanelWidth.clamp(140.0, 320.0);
    const handleW = 38.0;
    const gap = 8.0;

    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth.isFinite ? c.maxWidth : (handleW + gap + desiredPanelWidth);
        final availableForPanel = math.max(0.0, maxW - handleW - gap);
        final panelW = open ? math.min(desiredPanelWidth, availableForPanel) : 0.0;
        final totalW = handleW + (panelW > 0 ? gap : 0) + panelW;

        return SizedBox(
          width: totalW.clamp(0.0, maxW),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: _HandleButton(open: open, onToggle: onToggle),
              ),
              if (panelW > 0)
                Positioned(
                  right: handleW + gap,
                  top: 0,
                  bottom: 0,
                  width: panelW,
                  child: ClipRect(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      width: panelW,
                      child: IgnorePointer(
                        ignoring: !open,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: open ? 1 : 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(GcsLayout.radius),
                              border: Border.all(color: scheme.outlineVariant),
                              boxShadow: GcsLayout.panelDepth,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: GcsTelemetryDeck(
                                width: double.infinity,
                                margin: EdgeInsets.zero,
                                altitudeM: altitudeM,
                                speedMs: speedMs,
                                batteryPct: batteryPct,
                                batteryVoltageV: batteryVoltageV,
                                batteryCurrentA: batteryCurrentA,
                                batteryTimeRemaining: batteryTimeRemaining,
                                gpsSats: gpsSats,
                                gpsFix: gpsFix,
                                gpsAccuracy: gpsAccuracy,
                                headingDeg: headingDeg,
                                climbMps: climbMps,
                                hdop: hdop,
                                ekf: ekf,
                                imu: imu,
                                compass: compass,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HandleButton extends StatelessWidget {
  const _HandleButton({required this.open, required this.onToggle});

  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Large, reliable hitbox (same interaction approach as sidebar chevron).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.outlineVariant),
              boxShadow: open ? GcsLayout.glowCyan : null,
            ),
            child: Icon(
              open ? Icons.chevron_right : Icons.chevron_left,
              color: scheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

