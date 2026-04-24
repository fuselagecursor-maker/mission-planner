import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/gcs_tokens.dart';
import '../core/gcs/gcs_status_model.dart';
import '../shared/widgets/gcs/gcs_top_status_bar.dart';

class GcsTopBarOverlay extends StatelessWidget {
  const GcsTopBarOverlay({
    super.key,
    required this.gpsLabel,
    required this.batteryLabel,
    required this.modeLabel,
    this.armed = false,
    this.systemState = VehicleSystemState.idle,
    this.signalPct = 0,
    this.latencyMs = 0,
    this.linkType = LinkType.unknown,
    this.connected = true,
    this.onMenu,
    this.showLeadingGcs = true,
    this.trailing,
  });

  final String gpsLabel;
  final String batteryLabel;
  final String modeLabel;
  final bool armed;
  final VehicleSystemState systemState;
  final int signalPct;
  final int latencyMs;
  final LinkType linkType;
  final bool connected;
  final VoidCallback? onMenu;
  final bool showLeadingGcs;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(GcsLayout.radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: GcsColors.bgPanel.withValues(alpha: 0.78),
            border: Border.all(color: GcsColors.border),
            boxShadow: GcsLayout.panelDepth,
          ),
          child: GcsTopStatusBar(
            onMenu: onMenu,
            showLeadingGcs: showLeadingGcs,
            connected: connected,
            gpsLabel: gpsLabel,
            batteryLabel: batteryLabel,
            modeLabel: modeLabel,
            armed: armed,
            systemState: systemState,
            signalPct: signalPct,
            latencyMs: latencyMs,
            linkType: linkType,
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}

