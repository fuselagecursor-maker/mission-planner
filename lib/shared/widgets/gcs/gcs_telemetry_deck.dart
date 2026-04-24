import 'package:flutter/material.dart';
import 'gcs_metric_card.dart';
import '../../../core/theme/gcs_tokens.dart';

class GcsTelemetryDeck extends StatelessWidget {
  const GcsTelemetryDeck({
    super.key,
    required this.altitudeM,
    required this.speedMs,
    required this.batteryPct,
    this.batteryVoltageV = '—',
    this.batteryCurrentA = '—',
    this.batteryTimeRemaining = '—',
    required this.gpsSats,
    this.gpsFix = '—',
    this.gpsAccuracy = '—',
    required this.headingDeg,
    this.climbMps = '—',
    this.hdop = '—',
    this.ekf = '—',
    this.imu = '—',
    this.compass = '—',
    this.width,
    this.margin,
  });

  final String altitudeM;
  final String speedMs;
  final String batteryPct;
  final String batteryVoltageV;
  final String batteryCurrentA;
  final String batteryTimeRemaining;
  final String gpsSats;
  final String gpsFix;
  final String gpsAccuracy;
  final String headingDeg;
  final String climbMps;
  final String hdop;
  final String ekf;
  final String imu;
  final String compass;
  final double? width;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: GcsColors.bgPanel,
        borderRadius: BorderRadius.circular(GcsLayout.radius),
        border: Border.all(color: GcsColors.border),
        boxShadow: GcsLayout.panelDepth,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'TELEMETRY',
              style: TextStyle(
                color: GcsColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            GcsMetricCard(label: 'ALT MSL (m)', value: altitudeM),
            const SizedBox(height: 8),
            GcsMetricCard(label: 'Speed (m/s)', value: speedMs),
            const SizedBox(height: 8),
            GcsMetricCard(label: 'Climb (m/s)', value: climbMps, subtitle: 'Vertical rate'),
            const SizedBox(height: 8),
            GcsMetricCard(label: 'Battery', value: batteryPct),
            const SizedBox(height: 8),
            GcsMetricCard(
              label: 'Power',
              value: '${batteryVoltageV} V',
              subtitle: '${batteryCurrentA} A · Est. ${batteryTimeRemaining}',
            ),
            const SizedBox(height: 8),
            GcsMetricCard(label: 'GNSS sats', value: gpsSats, subtitle: 'HDOP $hdop · 3D'),
            const SizedBox(height: 8),
            GcsMetricCard(
              label: 'GPS quality',
              value: gpsFix,
              subtitle: '$gpsAccuracy · HDOP $hdop',
            ),
            const SizedBox(height: 8),
            GcsMetricCard(
              label: 'Health',
              value: 'EKF $ekf',
              subtitle: 'IMU $imu · COMPASS $compass',
            ),
            const SizedBox(height: 8),
            GcsMetricCard(label: 'Heading (°)', value: headingDeg),
          ],
        ),
      ),
    );
  }
}
