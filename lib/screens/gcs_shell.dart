import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/gcs/gcs_status_model.dart';
import '../core/routing/app_router.dart';
import '../core/theme/gcs_tokens.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../widgets/gcs_right_telemetry_panel.dart';
import '../widgets/gcs_sidebar.dart';
import '../widgets/gcs_top_bar.dart';
import 'logs_page.dart';
import 'mission_page.dart';
import 'settings_page.dart';

class GcsShell extends StatefulWidget {
  const GcsShell({super.key});

  @override
  State<GcsShell> createState() => _GcsShellState();
}

class _GcsShellState extends State<GcsShell> {
  final GcsStatusModel _status = GcsStatusModel();

  GcsNavSection _section = GcsNavSection.map;
  // Sidebar is intentionally always collapsed per UX requirement.
  final bool _sidebarCollapsed = true;
  bool _telemetryOpen = true;
  bool _mapEnabled = true; // map rendering enabled

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final w = MediaQuery.sizeOf(context).width;
    final isSmall = w < 860;
    if (isSmall) {
      _telemetryOpen = false;
    }
  }

  Widget? _buildOverlayPage() {
    return switch (_section) {
      GcsNavSection.map => null,
      GcsNavSection.mission => const MissionPage(),
      GcsNavSection.logs => const LogsPage(),
      GcsNavSection.settings => const SettingsPage(),
    };
  }

  void _openToolsSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        Widget tile({
          required IconData icon,
          required String title,
          required String subtitle,
          required String route,
        }) {
          return ListTile(
            leading: Icon(icon, color: GcsColors.textSecondary),
            title: Text(title, style: const TextStyle(color: GcsColors.textPrimary)),
            subtitle: Text(subtitle, style: const TextStyle(color: GcsColors.textSecondary)),
            onTap: () {
              Navigator.of(ctx).pop();
              setState(() => _section = GcsNavSection.map);
              Navigator.of(context).pushNamed(route);
            },
          );
        }

        final h = MediaQuery.sizeOf(ctx).height;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: h * 0.78),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const ListTile(
                    title: Text(
                      'Tools',
                      style: TextStyle(color: GcsColors.textPrimary, fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      'Secondary panels / utilities',
                      style: TextStyle(color: GcsColors.textSecondary),
                    ),
                  ),
                  const Divider(height: 1, color: GcsColors.border),
                  tile(
                    icon: Icons.sensors_rounded,
                    title: 'Telemetry',
                    subtitle: 'Full telemetry dashboard',
                    route: AppRoutes.telemetry,
                  ),
                  tile(
                    icon: Icons.photo_camera_rounded,
                    title: 'Camera',
                    subtitle: 'Payload / camera control',
                    route: AppRoutes.cameraPayload,
                  ),
                  tile(
                    icon: Icons.sports_esports_rounded,
                    title: 'Manual control',
                    subtitle: 'Stick / RC-style control',
                    route: AppRoutes.manualControl,
                  ),
                  tile(
                    icon: Icons.dangerous_rounded,
                    title: 'Airspace',
                    subtitle: 'NFZ overlay & advisories',
                    route: AppRoutes.airspace,
                  ),
                  tile(
                    icon: Icons.movie_filter_rounded,
                    title: 'Replay',
                    subtitle: 'Mission replay',
                    route: AppRoutes.replay,
                  ),
                  tile(
                    icon: Icons.extension_rounded,
                    title: 'Plugins',
                    subtitle: 'Plugin manager',
                    route: AppRoutes.plugins,
                  ),
                  tile(
                    icon: Icons.directions_car_filled,
                    title: 'Vehicles',
                    subtitle: 'Multi-vehicle view',
                    route: AppRoutes.vehicles,
                  ),
                  tile(
                    icon: Icons.build_circle_rounded,
                    title: 'Vehicle setup',
                    subtitle: 'Setup hub & calibration sections',
                    route: AppRoutes.vehicleSetup,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const shellPad = 8.0;
    const gapAfterSidebar = 8.0;
    const kTelemEdge = 8.0;
    // Keep the zoom rail close to telemetry.
    const kAfterTelemStripGap = 4.0;
    final sw = gcsSidebarWidth(_sidebarCollapsed);
    final mapQuickActionLeft = shellPad + sw + gapAfterSidebar;

    final screenW = MediaQuery.sizeOf(context).width;
    const kTelemHandleW = 38.0;
    // Keep in sync with [GcsRightTelemetryPanel] sizing logic.
    const kTelemGap = 8.0;
    final maxOverlayW = (screenW - 16 - sw - 8).clamp(kTelemHandleW, 420.0);
    final maxPanelWidth = math.max(0.0, maxOverlayW - kTelemHandleW - kTelemGap);
    final desiredPanelWidth = maxPanelWidth.clamp(140.0, 320.0);
    final availableForPanel = math.max(0.0, maxOverlayW - kTelemHandleW - kTelemGap);
    final telemOpen = _telemetryOpen && _section == GcsNavSection.map;
    final panelW = telemOpen ? math.min(desiredPanelWidth, availableForPanel) : 0.0;
    final telemetryStripW = kTelemHandleW + (panelW > 0 ? kTelemGap : 0.0) + panelW;

    // [MapZoomRail] right edge sits just left of the telemetry strip.
    final mapZoomRailRight = kTelemEdge + telemetryStripW + kAfterTelemStripGap;
    // Bottom dock + map FABs only need to stay clear of the telemetry strip (not the zoom rail).
    final mapOverlayRight = kTelemEdge + telemetryStripW + kAfterTelemStripGap;

    return Scaffold(
      backgroundColor: GcsColors.bgMain,
      body: Stack(
        children: [
          // Map is always the base layer (primary).
          Positioned.fill(
            child: _mapEnabled
                ? MapScreen(
                    statusModel: _status,
                    mapQuickActionLeft: mapQuickActionLeft,
                    mapZoomRailRight: mapZoomRailRight,
                    overlayInsets: EdgeInsets.only(
                      left: mapQuickActionLeft,
                      right: mapOverlayRight,
                    ),
                  )
                : Container(
                    color: GcsColors.bgMain,
                    alignment: Alignment.center,
                    child: const Text(
                      'MAP DISABLED (performance mode)\nTell me “turn map back on” to re-enable.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: GcsColors.textMuted,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ),
          ),

          // Subpages slide over map (map remains behind, but user focus moves to page).
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _section == GcsNavSection.map,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _section == GcsNavSection.map
                    ? const SizedBox.shrink()
                    : LayoutBuilder(
                        builder: (context, c) {
                          // Inset so pages never sit under TopBar/Sidebar/Telemetry.
                          final inset = EdgeInsets.fromLTRB(
                            shellPad + sw + 12,
                            72,
                            8 + 56, // reserve room for telemetry handle even when closed
                            8,
                          );
                          return Padding(
                            padding: inset,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(GcsLayout.radius),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(color: GcsColors.border),
                                  boxShadow: GcsLayout.panelDepth,
                                ),
                                child: KeyedSubtree(
                                  key: ValueKey(_section),
                                  child: _buildOverlayPage()!,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),

          // Top bar overlay (frosted glass).
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: AnimatedBuilder(
              animation: _status,
              builder: (context, _) {
                return GcsTopBarOverlay(
                  connected: true,
                  showLeadingGcs: _section != GcsNavSection.map,
                  armed: _status.armed,
                  systemState: _status.systemState,
                  signalPct: _status.signalPct,
                  latencyMs: _status.latencyMs,
                  linkType: _status.linkType,
                  gpsLabel: _status.gpsLabel,
                  batteryLabel: _status.batteryLabel,
                  modeLabel: _status.modeLabel,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Tools',
                        onPressed: _openToolsSheet,
                        icon: const Icon(Icons.apps, color: GcsColors.textSecondary, size: 20),
                      ),
                      IconButton(
                        tooltip: 'Toggle telemetry panel',
                        onPressed: () => setState(() => _telemetryOpen = !_telemetryOpen),
                        icon: const Icon(Icons.tune, color: GcsColors.textSecondary, size: 20),
                      ),
                      IconButton(
                        tooltip: 'Close page',
                        onPressed: _section == GcsNavSection.map
                            ? null
                            : () => setState(() => _section = GcsNavSection.map),
                        icon: const Icon(Icons.close, color: GcsColors.textSecondary, size: 20),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Left navigation hub.
          Positioned(
            top: 72,
            left: 8,
            // Keep above bottom mission dock so items stay clickable.
            bottom: 80,
            child: GcsSidebar(
              section: _section,
              collapsed: _sidebarCollapsed,
              onSelect: (s) => setState(() => _section = s),
              onTools: _openToolsSheet,
            ),
          ),

          // Right telemetry panel overlay (collapsible).
          Positioned(
            top: 72,
            right: 8,
            // Keep above the bottom mission dock so it never clips on short heights.
            bottom: 80,
            child: AnimatedBuilder(
              animation: _status,
              builder: (context, _) {
                final w = MediaQuery.sizeOf(context).width;

                // Constrain the whole overlay width so it cannot overflow to the right,
                // even when window is extremely narrow.
                const handleW = 38.0;
                const gap = 8.0;
                final maxOverlayW = (w - 16 - sw - 8).clamp(handleW, 420.0);
                final maxPanelWidth = math.max(0.0, maxOverlayW - handleW - gap);

                // Constrain max width, but let the widget shrink to handle-only when closed.
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxOverlayW),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GcsRightTelemetryPanel(
                      open: _telemetryOpen && _section == GcsNavSection.map,
                      onToggle: () => setState(() => _telemetryOpen = !_telemetryOpen),
                      maxPanelWidth: maxPanelWidth,
                      altitudeM: _status.altitudeM,
                      speedMs: _status.speedMs,
                      batteryPct: _status.batteryPct,
                      batteryVoltageV: _status.batteryVoltageV,
                      batteryCurrentA: _status.batteryCurrentA,
                      batteryTimeRemaining: _status.batteryTimeRemaining,
                      gpsSats: _status.gpsSats,
                      gpsFix: _status.gpsFix,
                      gpsAccuracy: _status.gpsAccuracy,
                      headingDeg: _status.headingDeg,
                      climbMps: _status.climbMps,
                      hdop: _status.hdop,
                      ekf: _status.ekfStatus,
                      imu: _status.imuStatus,
                      compass: _status.compassStatus,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
