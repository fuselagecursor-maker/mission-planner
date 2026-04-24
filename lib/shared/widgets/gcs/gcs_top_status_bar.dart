import 'package:flutter/material.dart';
import '../../../core/theme/gcs_tokens.dart';
import '../../../core/gcs/gcs_status_model.dart';

/// Thin tactical strip: link, GPS, battery, flight mode.
class GcsTopStatusBar extends StatelessWidget {
  const GcsTopStatusBar({
    super.key,
    this.onMenu,
    this.showLeadingGcs = true,
    this.connected = true,
    this.armed = false,
    this.systemState = VehicleSystemState.idle,
    this.signalPct = 0,
    this.latencyMs = 0,
    this.linkType = LinkType.unknown,
    this.gpsLabel = 'GPS: 12 sats / RTK',
    this.batteryLabel = 'BAT: 87%',
    this.modeLabel = 'AUTO',
    this.trailing,
  });

  final VoidCallback? onMenu;
  /// When false, omits the "GCS" / flight icon block (e.g. shown on the map next to the sidebar).
  final bool showLeadingGcs;
  final bool connected;
  final bool armed;
  final VehicleSystemState systemState;
  final int signalPct;
  final int latencyMs;
  final LinkType linkType;
  final String gpsLabel;
  final String batteryLabel;
  final String modeLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 860;
        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: GcsColors.bgPanel,
            border: const Border(bottom: BorderSide(color: GcsColors.border)),
            boxShadow: GcsLayout.panelDepth,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onMenu != null)
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: GcsColors.textPrimary),
                      onPressed: onMenu,
                      tooltip: 'Menu',
                    ),
                  if (showLeadingGcs) ...[
                    if (!compact)
                      const Text(
                        'GCS',
                        style: TextStyle(
                          color: GcsColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 1.2,
                        ),
                      )
                    else
                      const Icon(Icons.flight, color: GcsColors.textPrimary, size: 18),
                    SizedBox(width: compact ? 10 : 16),
                  ],
                  _StatusPill(
                    label: 'LINK',
                    value: connected ? 'OK $signalPct%' : 'LOST',
                    color: connected ? GcsColors.accentSuccess : GcsColors.accentDanger,
                    dot: true,
                    dotOn: connected,
                    maxValueWidth: compact ? 64 : 200,
                  ),
                  const SizedBox(width: 8),
                  if (!compact)
                    _StatusPill(
                      label: 'LAT',
                      value: '${latencyMs}ms · ${_linkTypeLabel(linkType)}',
                      color: latencyMs < 90 ? GcsColors.accentSuccess : GcsColors.accentWarning,
                      dot: false,
                      dotOn: false,
                      maxValueWidth: 200,
                    ),
                  if (!compact) const SizedBox(width: 8),
                  if (!compact) ...[
                    _StatusPill(
                      label: 'GPS',
                      value: gpsLabel,
                      color: GcsColors.accentPrimary,
                      dot: false,
                      dotOn: false,
                      maxValueWidth: 200,
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(
                      label: 'PWR',
                      value: batteryLabel,
                      color: GcsColors.accentSuccess,
                      dot: false,
                      dotOn: false,
                      maxValueWidth: 180,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (armed ? GcsColors.accentDanger : GcsColors.accentSuccess).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: (armed ? GcsColors.accentDanger : GcsColors.accentSuccess).withValues(alpha: 0.35),
                      ),
                      boxShadow: armed ? GcsLayout.glowDanger : GcsLayout.glowSuccess,
                    ),
                    child: Text(
                      compact ? _systemPillText(modeLabel, systemState) : _systemPillText('MODE: $modeLabel', systemState),
                      style: const TextStyle(
                        color: GcsColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.value,
    required this.color,
    required this.dot,
    required this.dotOn,
    this.maxValueWidth = 200,
  });

  final String label;
  final String value;
  final Color color;
  final bool dot;
  final bool dotOn;
  final double maxValueWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: GcsColors.bgMain,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GcsColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotOn ? GcsColors.accentSuccess : GcsColors.accentDanger,
                boxShadow: dotOn ? GcsLayout.glowSuccess : GcsLayout.glowDanger,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            '$label: ',
            style: const TextStyle(
              color: GcsColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxValueWidth),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _linkTypeLabel(LinkType t) => switch (t) {
      LinkType.wifi => 'WiFi',
      LinkType.radio => 'Radio',
      LinkType.usb => 'USB',
      LinkType.unknown => 'Link',
    };

String _systemPillText(String mode, VehicleSystemState s) {
  final state = switch (s) {
    VehicleSystemState.idle => 'IDLE',
    VehicleSystemState.armed => 'ARMED',
    VehicleSystemState.flying => 'FLYING',
    VehicleSystemState.landing => 'LANDING',
    VehicleSystemState.emergency => 'EMERGENCY',
  };
  return '$mode · $state';
}
