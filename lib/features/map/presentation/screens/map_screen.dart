import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/gcs/gcs_status_model.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../../../shared/widgets/emergency_stop_button.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../mission/presentation/widgets/waypoint_property_sheet.dart';
import '../../../mission/presentation/widgets/mission_storage_dialogs.dart';
import '../../../../shared/widgets/gcs/alert_banner.dart';
import '../../../../shared/widgets/gcs/manual_control_panel.dart';
import '../../../../shared/widgets/gcs/map_hud_overlay.dart';
import '../../../../shared/widgets/gcs/rth_feedback_widget.dart';
import '../../../../shared/widgets/gcs/mission_progress_widget.dart';
import '../logic/airspace_map.dart';
import '../logic/simulated_telemetry.dart';
import '../widgets/map_layers_sheet.dart';
import '../widgets/map_viewport.dart';
import '../widgets/map_zoom_rail.dart';
import '../../../../core/theme/gcs_tokens.dart';
import '../../../../shared/widgets/gcs/gcs_bottom_dock.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.statusModel,
    this.overlayInsets = EdgeInsets.zero,
    /// When set, the GCS map quick-action rail (waypoint + more) is anchored to
    /// the [left] of the map and tracks the shell sidebar; otherwise FABs sit bottom-left.
    this.mapQuickActionLeft,
    /// When set (GCS [GcsShell]), distance from the **right** of the map to the
    /// right edge of [MapZoomRail] so zoom stays just left of the telemetry strip
    /// and animates with the same [sw] / strip width as the shell.
    this.mapZoomRailRight,
  });

  final GcsStatusModel? statusModel;
  /// Space reserved by outer overlays (sidebar/telemetry handle) so in-map UI
  /// (bottom dock, FABs) stays reachable.
  final EdgeInsets overlayInsets;

  /// Pixels from the **left of the map** to the **map** quick-action column (GCS + FABs).
  final double? mapQuickActionLeft;

  /// Pixels from the **right** of the map to the **right** edge of the zoom rail (GCS only).
  final double? mapZoomRailRight;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _airspaceLayer = true;
  bool _satelliteBasemap = false;
  bool _showMissionGeometry = true;
  bool _showVehicleOnMap = true;
  bool _preArmAllPass = false;
  String _flightMode = 'AUTO';
  bool _showModeTransition = false;
  bool _tracking = false;
  bool _armed = false;
  final _mapController = MapController();
  final LatLng _homePoint = const LatLng(12.9716, 77.5946); // placeholder home
  Timer? _simTimer;
  final Distance _geoDistance = const Distance();
  DateTime? _lastCameraFollowAt;
  LatLng? _lastCameraCenter;
  DateTime _lastFrame = DateTime.now();
  LatLng? _lastTelemPos;
  final SimulatedTelemetry _telemetry = SimulatedTelemetry();
  double _vehiclePhase = 0;
  LatLng _targetVehicle = const LatLng(12.9722, 77.5952);
  LatLng _smoothedVehicle = const LatLng(12.9722, 77.5952);
  double _vehicleHeading = 0;
  late final ValueNotifier<MapVehicle?> _vehicleVn;
  DateTime _lastUiRebuildAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _dockOpen = true;
  String? _selectedWaypointId;
  bool _flightTrail = true;
  bool _mapHud = true;
  bool _manualControl = false;
  final List<LatLng> _trail = <LatLng>[];
  final List<_MissionWp> _missionWps = [
    _MissionWp(id: 'wp-1', index: 1, point: const LatLng(12.9716, 77.5946)),
    _MissionWp(id: 'wp-2', index: 2, point: const LatLng(12.975, 77.602)),
  ];

  int get _waypointCount => _showMissionGeometry ? _missionWps.length : 0;

  bool get _hasAirspaceViolation =>
      _airspaceLayer && _missionWps.any((w) => w.isNfzViolation);

  bool get _canStartMission => !_hasAirspaceViolation && _preArmAllPass;

  @override
  void initState() {
    super.initState();
    _lastFrame = DateTime.now();
    _lastTelemPos = _smoothedVehicle;
    _targetVehicle = _smoothedVehicle;
    _vehicleVn = ValueNotifier<MapVehicle?>(MapVehicle(point: _smoothedVehicle, headingDeg: _vehicleHeading));
    // Web perf: rebuilding FlutterMap too frequently tanks FPS on some GPUs/browsers.
    // Keep motion smooth but reduce rebuild cadence.
    final tick = kIsWeb ? const Duration(milliseconds: 100) : const Duration(milliseconds: 50);
    _simTimer = Timer.periodic(tick, (_) => _onSimTick());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final w = MediaQuery.sizeOf(context).width;
    // Keep the map dominant on narrower windows.
    if (w < 980 && _dockOpen) _dockOpen = false;
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _vehicleVn.dispose();
    super.dispose();
  }

  Widget _mapPrimaryFab() {
    return _MapFab(
      onAddWaypoint: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Long-press the map to add a waypoint.'),
          ),
        );
      },
      onNewMission: () => Navigator.of(context).pushNamed(AppRoutes.missionWizard),
      onSurveyGrid: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Survey grid (placeholder)')),
        );
      },
      onImportMission: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import mission (placeholder)')),
        );
      },
      onMapLayers: _showMapLayersSheet,
      armed: _armed,
      onToggleArm: () => setState(() => _armed = !_armed),
      flightMode: _flightMode,
      onSetFlightMode: _setFlightMode,
    );
  }

  void _toggleTracking() {
    setState(() {
      _tracking = !_tracking;
      if (_tracking) {
        _lastCameraFollowAt = null;
        _lastCameraCenter = null;
        _syncOrbitPhaseToVehicle();
      }
    });
  }

  void _syncOrbitPhaseToVehicle() {
    const baseLat = 12.9722;
    const baseLng = 77.5952;
    const r = 0.0035;
    final x = (_smoothedVehicle.latitude - baseLat) / r;
    final y = (_smoothedVehicle.longitude - baseLng) / r;
    _vehiclePhase = math.atan2(y, x);
  }

  void _onSimTick() {
    if (!mounted) return;
    final now = DateTime.now();
    var dt = now.difference(_lastFrame).inMicroseconds / 1e6;
    _lastFrame = now;
    if (dt > 0.2) {
      dt = 0.05;
    } else if (dt < 0.001) {
      return;
    }

    if (_tracking) {
      // ~0.1 rad / s matches the old 500ms demo roughly but feels smoother at 20 Hz.
      _vehiclePhase += 0.12 * dt * (2 * math.pi);
      const baseLat = 12.9722;
      const baseLng = 77.5952;
      const r = 0.0035;
      _targetVehicle = LatLng(
        baseLat + r * math.cos(_vehiclePhase),
        baseLng + r * math.sin(_vehiclePhase),
      );
    } else {
      _targetVehicle = _smoothedVehicle;
    }

    const t = 0.28; // lerp per tick toward physics target (50ms)
    _smoothedVehicle = _lerpLatLng(_smoothedVehicle, _targetVehicle, t);

    final movedM = _geoDistance(_lastTelemPos ?? _smoothedVehicle, _smoothedVehicle);
    if (movedM > 0.15) {
      _vehicleHeading = _bearingBetween(_lastTelemPos ?? _smoothedVehicle, _smoothedVehicle);
    }

    _telemetry.step(
      now: _smoothedVehicle,
      prev: _lastTelemPos,
      dt: dt,
      motionEnabled: _tracking,
      armed: _armed,
    );
    _lastTelemPos = _smoothedVehicle;

    // Flight trail (UI-only). Keep bounded for web performance.
    if (_flightTrail) {
      if (_trail.isEmpty || _geoDistance(_trail.last, _smoothedVehicle) > 2.5) {
        _trail.add(_smoothedVehicle);
        if (_trail.length > 220) _trail.removeAt(0);
      }
    } else if (_trail.isNotEmpty) {
      _trail.clear();
    }

    // High-Hz marker updates without rebuilding the whole map widget tree.
    _vehicleVn.value = _showVehicleOnMap
        ? MapVehicle(point: _smoothedVehicle, headingDeg: _vehicleHeading)
        : null;

    if (_tracking) {
      final clock = DateTime.now();
      final lastAt = _lastCameraFollowAt;
      final lastCenter = _lastCameraCenter;
      final minInterval = kIsWeb ? const Duration(milliseconds: 900) : const Duration(milliseconds: 450);
      final minMoveMeters = kIsWeb ? 18.0 : 10.0;
      final movedEnough =
          lastCenter == null || _geoDistance(lastCenter, _smoothedVehicle) >= minMoveMeters;
      final intervalOk = lastAt == null || clock.difference(lastAt) >= minInterval;
      if (movedEnough && intervalOk) {
        _mapController.move(_smoothedVehicle, _mapController.camera.zoom);
        _lastCameraFollowAt = clock;
        _lastCameraCenter = _smoothedVehicle;
      }
    }

    // Publish status for shell overlays (top bar + right telemetry panel).
    widget.statusModel?.setTopBar(
      gpsLabel: _telemetry.gpsStatusLine,
      batteryLabel: _telemetry.batteryStatusLine,
      modeLabel: _flightMode,
    );
    widget.statusModel?.setTelemetry(
      altitudeM: _telemetry.altMsl.toStringAsFixed(0),
      speedMs: _telemetry.groundSpeed.toStringAsFixed(1),
      batteryPct: '${_telemetry.battery.toStringAsFixed(0)}%',
      gpsSats: '${_telemetry.sats}',
      headingDeg: _vehicleHeading.toStringAsFixed(0),
      climbMps: _telemetry.climbMps.toStringAsFixed(1),
      hdop: _telemetry.hdop.toStringAsFixed(2),
    );

    widget.statusModel?.setFlightStatus(
      armed: _armed,
      systemState: _armed
          ? (_flightMode == 'LAND' ? VehicleSystemState.landing : VehicleSystemState.flying)
          : VehicleSystemState.idle,
    );

    widget.statusModel?.setLink(
      signalPct: _telemetry.signalPct,
      latencyMs: _telemetry.latencyMs,
      linkType: LinkType.radio,
    );

    widget.statusModel?.setBatteryDetails(
      voltageV: _telemetry.voltageV.toStringAsFixed(1),
      currentA: _telemetry.currentA.toStringAsFixed(1),
      timeRemaining: _telemetry.batteryTimeRemainingLine,
    );

    widget.statusModel?.setGpsQuality(
      fix: _telemetry.gpsFixTypeLine,
      accuracy: _telemetry.gpsAccuracyLine,
    );

    widget.statusModel?.setSensorHealth(
      ekf: _telemetry.hdop < 1.8 ? 'OK' : 'BAD',
      imu: _armed ? 'OK' : 'OK',
      compass: _telemetry.hdop < 2.2 ? 'OK' : 'WARN',
    );

    // Alerts (UI-only; dynamic-ready)
    if (_telemetry.batteryPct < 20) {
      widget.statusModel?.pushAlert(
        GcsAlert(
          id: 'low_battery',
          title: 'LOW BATTERY',
          message: 'Battery below 20%',
          severity: AlertSeverity.warning,
          persistent: true,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      widget.statusModel?.dismissAlert('low_battery');
    }

    if (_telemetry.sats < 6) {
      widget.statusModel?.pushAlert(
        GcsAlert(
          id: 'gps_lost',
          title: 'GPS LOST',
          message: 'Insufficient satellites',
          severity: AlertSeverity.critical,
          persistent: true,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      widget.statusModel?.dismissAlert('gps_lost');
    }

    // Signal lost / EKF / compass (UI-only; dynamic-ready)
    if (_telemetry.signalPct < 18 || _telemetry.latencyMs > 220) {
      widget.statusModel?.pushAlert(
        GcsAlert(
          id: 'signal_lost',
          title: 'SIGNAL LOST',
          message: 'Link degraded: ${_telemetry.signalPct}% · ${_telemetry.latencyMs}ms',
          severity: AlertSeverity.critical,
          persistent: true,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      widget.statusModel?.dismissAlert('signal_lost');
    }

    if (_telemetry.hdop > 2.0) {
      widget.statusModel?.pushAlert(
        GcsAlert(
          id: 'ekf_error',
          title: 'EKF ERROR',
          message: 'Navigation accuracy degraded (HDOP ${_telemetry.hdop.toStringAsFixed(2)})',
          severity: AlertSeverity.warning,
          persistent: false,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      widget.statusModel?.dismissAlert('ekf_error');
    }

    if (_telemetry.hdop > 2.2) {
      widget.statusModel?.pushAlert(
        GcsAlert(
          id: 'compass_error',
          title: 'COMPASS ERROR',
          message: 'Mag / heading may be unreliable',
          severity: AlertSeverity.warning,
          persistent: false,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      widget.statusModel?.dismissAlert('compass_error');
    }

    // RTH / mission progress (UI-only; dynamic-ready)
    final homeDistM = _geoDistance(_homePoint, _smoothedVehicle);
    widget.statusModel?.setHomeDistance(
      homeDistM >= 1000 ? '${(homeDistM / 1000).toStringAsFixed(1)} km' : '${homeDistM.toStringAsFixed(0)} m',
    );
    if (_flightMode == 'RTH' && _armed) {
      final phase = homeDistM > 200 ? 'Travel' : (homeDistM > 40 ? 'Descend' : 'Land');
      widget.statusModel?.setRthStatus(
        active: true,
        phase: phase,
        distanceM: homeDistM.toStringAsFixed(0),
      );
    } else {
      widget.statusModel?.setRthStatus(active: false, phase: '—', distanceM: '—');
    }

    final missionActive = _armed && _flightMode == 'AUTO' && _missionWps.length >= 2;
    if (missionActive) {
      final nearest = _missionWps
          .map((w) => (w, _geoDistance(w.point, _smoothedVehicle)))
          .reduce((a, b) => a.$2 < b.$2 ? a : b)
          .$1;
      final wpIndex = nearest.index;
      final wpTotal = _missionWps.length;
      final distToNext = _geoDistance(nearest.point, _smoothedVehicle);
      final completion = ((wpIndex / math.max(1, wpTotal)) * 100).round().clamp(0, 100);
      widget.statusModel?.setMissionProgress(
        active: true,
        wpIndex: wpIndex,
        wpTotal: wpTotal,
        distToNextM: distToNext.toStringAsFixed(0),
        completionPct: completion,
      );
    } else {
      widget.statusModel?.setMissionProgress(
        active: false,
        wpIndex: 0,
        wpTotal: _missionWps.length,
        distToNextM: '—',
        completionPct: 0,
      );
    }

    // Throttle expensive rebuilds (bottom dock, non-marker overlays) for web smoothness.
    final uiEvery = kIsWeb ? const Duration(milliseconds: 250) : const Duration(milliseconds: 120);
    if (now.difference(_lastUiRebuildAt) >= uiEvery) {
      _lastUiRebuildAt = now;
      setState(() {});
    }
  }

  static LatLng _lerpLatLng(LatLng a, LatLng b, double t) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  static double _bearingBetween(LatLng a, LatLng b) {
    const mDist = Distance();
    if (mDist(a, b) < 0.2) return 0;
    final lat1 = a.latitude * math.pi / 180.0;
    final lat2 = b.latitude * math.pi / 180.0;
    final dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final brng = math.atan2(y, x) * 180.0 / math.pi;
    return (brng + 360.0) % 360.0;
  }

  void _renumberWaypoints() {
    for (var i = 0; i < _missionWps.length; i++) {
      _missionWps[i] = _missionWps[i].copyWith(index: i + 1);
    }
  }

  List<MapWaypoint> get _mapWaypoints => _missionWps
      .map(
        (w) => MapWaypoint(
          id: w.id,
          label: w.label,
          point: w.point,
          isViolation: w.isNfzViolation,
          selected: w.id == _selectedWaypointId,
        ),
      )
      .toList();

  List<LatLng> get _missionPathPoints => _missionWps.map((w) => w.point).toList();

  List<String> _buildLogLines() {
    final h = DateTime.now();
    final ts =
        '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}:${h.second.toString().padLeft(2, '0')}'
        '.${(h.millisecond ~/ 100)}';
    return [
      '[$ts] TEL  ${_telemetry.groundSpeed.toStringAsFixed(1)} m/s  '
      'VSI ${_telemetry.climbMps.toStringAsFixed(1)}  '
      'alt ${_telemetry.altMsl.toStringAsFixed(0)} m  '
      'HDOP ${_telemetry.hdop.toStringAsFixed(2)}',
      r'[12:01:22] INFO  heartbeat OK · FC v4.x',
      r'[12:01:22] OK    prearm: gyro warmed',
    ];
  }

  void _onMapTap(TapPosition tap, LatLng point) {
    setState(() => _selectedWaypointId = null);
  }

  void _onMapLongPress(TapPosition tap, LatLng point) {
    setState(() {
      final w = _MissionWp(
        id: 'wp-${DateTime.now().microsecondsSinceEpoch}',
        index: 0,
        point: point,
      );
      _missionWps.add(w);
      _renumberWaypoints();
      _selectedWaypointId = w.id;
    });
    if (isInDemoNfz(point)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added waypoint inside demo NFZ — mission is blocked until moved.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${_missionWps.last.label}')),
      );
    }
  }

  void _onWaypointTap(String id, LatLng point) {
    setState(() => _selectedWaypointId = id);
    _showWaypointActions(id, point);
  }

  void _showWaypointActions(String id, LatLng point) {
    final idx = _missionWps.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final wp = _missionWps[idx];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text('${wp.label} ${wp.isNfzViolation ? "(NFZ)" : ""}'),
              subtitle: Text(
                '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.center_focus_strong_outlined),
              title: const Text('Focus on map'),
              onTap: () {
                Navigator.of(ctx).pop();
                final cam = _mapController.camera;
                final z = cam.zoom < 15 ? 15.0 : cam.zoom;
                _mapController.move(point, z);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Remove'),
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _missionWps.removeWhere((e) => e.id == id);
                  _renumberWaypoints();
                  if (_selectedWaypointId == id) _selectedWaypointId = null;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Properties (wireframe)'),
              onTap: () {
                Navigator.of(ctx).pop();
                showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (c2) => FractionallySizedBox(
                    heightFactor: 0.6,
                    child: WaypointPropertySheet(
                      waypointTitle: 'Waypoint ${wp.index} (placeholder)',
                      onClose: () => Navigator.of(c2).pop(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setFlightMode(String mode) async {
    final prev = _flightMode;
    setState(() {
      _flightMode = mode;
      _showModeTransition = true;
    });
    if (prev != mode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switched to $mode')),
      );
    }
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    if (_flightMode == mode && prev != mode) {
      setState(() => _showModeTransition = false);
    }
  }

  Future<void> _attemptStartMission() async {
    // SRS §7.5 / FR-25-05: mission start is blocked if any waypoint is in NFZ.
    if (_hasAirspaceViolation) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Airspace Violation'),
          content: const Text(
            'This mission contains waypoints inside a No-Fly Zone (NFZ). '
            'Move or edit the violating waypoint(s) before starting.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // SRS FR-27-05: disable mission start when pre-arm checks fail.
    if (!_preArmAllPass) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (ctx) => FractionallySizedBox(
          heightFactor: 0.6,
          child: _PreArmCheckSheet(
            allPass: _preArmAllPass,
            gpsLock: _telemetry.sats >= 8,
            batteryOk: _telemetry.batteryPct >= 25,
            sensorsCalibrated: _telemetry.hdop < 2.2,
            ekfHealthy: _telemetry.hdop < 1.8,
            rcSignalOk: _telemetry.signalPct >= 30,
            onSetAllPass: (v) => setState(() => _preArmAllPass = v),
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Start Mission (placeholder)')),
    );
  }

  void _showMapLayersSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => MapLayersSheet(
        useSatelliteBasemap: _satelliteBasemap,
        onUseSatelliteBasemapChanged: (v) => setState(() => _satelliteBasemap = v),
        airspaceOverlayEnabled: _airspaceLayer,
        onAirspaceOverlayChanged: (v) => setState(() => _airspaceLayer = v),
        missionGeometryEnabled: _showMissionGeometry,
        onMissionGeometryChanged: (v) => setState(() => _showMissionGeometry = v),
        vehicleOnMapEnabled: _showVehicleOnMap,
        onVehicleOnMapChanged: (v) => setState(() => _showVehicleOnMap = v),
        flightTrailEnabled: _flightTrail,
        onFlightTrailEnabledChanged: (v) => setState(() => _flightTrail = v),
        mapHudEnabled: _mapHud,
        onMapHudEnabledChanged: (v) => setState(() => _mapHud = v),
        manualControlEnabled: _manualControl,
        onManualControlEnabledChanged: (v) => setState(() => _manualControl = v),
      ),
    );
  }

  void _showMissionSummarySheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.5,
        child: _MissionSummarySheet(
          waypointCount: _waypointCount,
          hasAirspaceViolation: _hasAirspaceViolation,
          preArmAllPass: _preArmAllPass,
          canStartMission: _canStartMission,
          onOpenWaypointEditor: () {
            Navigator.of(ctx).pop();
            showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (ctx2) => FractionallySizedBox(
                heightFactor: 0.6,
                child: WaypointPropertySheet(
                  waypointTitle: 'Waypoint Properties (placeholder)',
                  onClose: () => Navigator.of(ctx2).pop(),
                ),
              ),
            );
          },
          onLoadMission: () {
            Navigator.of(ctx).pop();
            showLoadMissionDialog(context);
          },
          onSaveMission: () {
            Navigator.of(ctx).pop();
            showSaveMissionDialog(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final modeAccent = _modeAccent(scheme, _flightMode);
    final modeOverlayColor = modeAccent.withValues(alpha: 0.65);

    final bool hasVehicle = _showVehicleOnMap;
    final LatLng? vehiclePoint = hasVehicle ? _smoothedVehicle : null;

    final extraPolylines = <Polyline>[];
    final extraCircles = <CircleMarker>[];
    final extraMarkers = <Marker>[];

    if (vehiclePoint != null) {
      switch (_flightMode) {
        case 'LOITER':
          extraCircles.add(
            CircleMarker(
              point: vehiclePoint,
              radius: 120, // meters (approx visual)
              useRadiusInMeter: true,
              color: modeAccent.withValues(alpha: 0.14),
              borderColor: modeOverlayColor,
              borderStrokeWidth: 2,
            ),
          );
          break;
        case 'AUTO':
          break;
        case 'RTH':
          extraPolylines.add(
            Polyline(
              points: [vehiclePoint, _homePoint],
              strokeWidth: 4,
              color: scheme.tertiary.withValues(alpha: 0.8),
            ),
          );
          break;
        case 'LAND':
          extraPolylines.add(
            Polyline(
              points: [vehiclePoint, vehiclePoint],
              strokeWidth: 6,
              color: scheme.error.withValues(alpha: 0.45),
            ),
          );
          extraMarkers.add(
            Marker(
              point: vehiclePoint,
              width: 90,
              height: 24,
              child: _ModeTag(label: 'LANDING', color: scheme.error),
            ),
          );
          break;
        default:
          break;
      }
    }

    if (_flightTrail && _trail.length >= 2) {
      extraPolylines.add(
        Polyline(
          points: List<LatLng>.of(_trail),
          strokeWidth: 3,
          color: GcsColors.accentPrimary.withValues(alpha: 0.65),
        ),
      );
    }

    extraMarkers.add(
      Marker(
        point: _homePoint,
        width: 84,
        height: 34,
        child: _HomeMarker(
          distanceM: vehiclePoint == null ? null : _geoDistance(_homePoint, vehiclePoint),
        ),
      ),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: MapViewport(
              controller: _mapController,
              tileUrlTemplate: _satelliteBasemap
                  ? MapTileTemplates.esriWorldImagery
                  : MapTileTemplates.cartoDark,
              enhanceTiles: !kIsWeb,
              showAirspaceOverlay: _airspaceLayer,
              extraPolylines: extraPolylines,
              extraCircles: extraCircles,
              extraMarkers: extraMarkers,
              waypoints: _showMissionGeometry ? _mapWaypoints : const [],
              path: _showMissionGeometry ? _missionPathPoints : const [],
              onMapTap: _onMapTap,
              onMapLongPress: _onMapLongPress,
              onWaypointTap: _onWaypointTap,
              vehicleListenable: _vehicleVn,
            ),
          ),
        ),
        // Global alert banner (critical/persistent), inset away from side overlays.
        if (widget.statusModel?.bannerAlert != null)
          Positioned(
            top: 72,
            left: widget.overlayInsets.left + 8,
            right: widget.overlayInsets.right + 8,
            child: AlertBanner(
              alert: widget.statusModel!.bannerAlert!,
              onDismiss: () => widget.statusModel!.dismissAlert(widget.statusModel!.bannerAlert!.id),
            ),
          ),
        // Right-side status stack (just left of telemetry strip/zoom).
        if (widget.statusModel != null)
          Positioned(
            top: 72 + 132,
            right: widget.overlayInsets.right + 8,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RthFeedbackWidget(
                    active: widget.statusModel!.rthActive,
                    phase: widget.statusModel!.rthPhase,
                    distanceM: widget.statusModel!.rthDistanceM,
                  ),
                  if (widget.statusModel!.rthActive) const SizedBox(height: 8),
                  MissionProgressWidget(
                    active: widget.statusModel!.missionActive,
                    wpIndex: widget.statusModel!.missionWpIndex,
                    wpTotal: widget.statusModel!.missionWpTotal,
                    distToNextM: widget.statusModel!.missionDistToNextM,
                    completionPct: widget.statusModel!.missionCompletionPct,
                  ),
                ],
              ),
            ),
          ),
        if (_mapHud && vehiclePoint != null)
          Positioned(
            top: 72,
            left: widget.overlayInsets.left + 8,
            child: MapHudOverlay(
              headingDeg: _vehicleHeading,
              speedMs: _telemetry.groundSpeed,
              altitudeMslM: _telemetry.altMsl,
              homeDistanceM: _geoDistance(_homePoint, vehiclePoint),
              homeBearingDeg: _bearingBetween(vehiclePoint, _homePoint),
              compact: MediaQuery.sizeOf(context).width < 980,
            ),
          ),
        Positioned(
          right: widget.overlayInsets.right + 8,
          bottom: (_dockOpen ? 200.0 : 68.0) + 16,
          child: ManualControlPanel(
            open: _manualControl,
            onToggle: () => setState(() => _manualControl = !_manualControl),
          ),
        ),
        if (widget.mapZoomRailRight != null)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            right: widget.mapZoomRailRight!,
            top: 72,
            child: MapZoomRail(
              controller: _mapController,
              recenterPoint: _showVehicleOnMap ? _smoothedVehicle : null,
            ),
          )
        else
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: MapZoomRail(
              controller: _mapController,
              recenterPoint: _showVehicleOnMap ? _smoothedVehicle : null,
            ),
          ),
        if (_showModeTransition)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 72 + AppSpacing.lg,
                left: AppSpacing.md,
                right: AppSpacing.md,
              ),
              child: _FlightModeTransitionBanner(mode: _flightMode),
            ),
          ),
        if (widget.mapQuickActionLeft != null)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            left: widget.mapQuickActionLeft!,
            top: 72 + 56,
            child: _MapGcsQuickRail(
              child: _mapPrimaryFab(),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, c) {
              // Keep quick actions visible:
              // - Never under the left sidebar (use overlayInsets.left)
              // - Never under the bottom dock (raise when dock is open)
              final left = (AppSpacing.lg + widget.overlayInsets.left)
                  .clamp(8.0, (c.maxWidth - 72).clamp(8.0, 9999.0));
              final bottom = (_dockOpen ? 200.0 : 68.0) + AppSpacing.lg;
              return Positioned(
                left: left,
                bottom: bottom,
                child: _mapPrimaryFab(),
              );
            },
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            minimum: const EdgeInsets.all(8),
            child: Padding(
              padding: widget.overlayInsets,
              child: _BottomDockOverlay(
                open: _dockOpen,
                onToggle: () => setState(() => _dockOpen = !_dockOpen),
                compactRow: _GcsBottomMissionRow(
                  onStart: _attemptStartMission,
                  onLoad: () => showLoadMissionDialog(context),
                  onSave: () => showSaveMissionDialog(context),
                  onMissionSummary: _showMissionSummarySheet,
                  onToggleTracking: _toggleTracking,
                  tracking: _tracking,
                  onWaypoints: () {
                    showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (ctx) => FractionallySizedBox(
                        heightFactor: 0.6,
                        child: WaypointPropertySheet(
                          waypointTitle: 'Waypoint Properties (placeholder)',
                          onClose: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                    );
                  },
                ),
                expanded: GcsBottomDock(
                  logLines: _buildLogLines(),
                  missionRow: _GcsBottomMissionRow(
                    onStart: _attemptStartMission,
                    onLoad: () => showLoadMissionDialog(context),
                    onSave: () => showSaveMissionDialog(context),
                    onMissionSummary: _showMissionSummarySheet,
                    onToggleTracking: _toggleTracking,
                    tracking: _tracking,
                    onWaypoints: () {
                      showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        isScrollControlled: true,
                        builder: (ctx) => FractionallySizedBox(
                          heightFactor: 0.6,
                          child: WaypointPropertySheet(
                            waypointTitle: 'Waypoint Properties (placeholder)',
                            onClose: () => Navigator.of(ctx).pop(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomDockOverlay extends StatelessWidget {
  const _BottomDockOverlay({
    required this.open,
    required this.onToggle,
    required this.compactRow,
    required this.expanded,
  });

  final bool open;
  final VoidCallback onToggle;
  final Widget compactRow;
  final Widget expanded;

  @override
  Widget build(BuildContext context) {
    // Reserve space so the expand/collapse chevron never covers toolbar buttons.
    const reservedRight = 44.0;
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: open
              ? KeyedSubtree(
                  key: const ValueKey('expanded'),
                  child: Padding(
                    padding: const EdgeInsets.only(right: reservedRight),
                    child: expanded,
                  ),
                )
              : KeyedSubtree(
                  key: const ValueKey('compact'),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: GcsColors.bgPanel.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(GcsLayout.radius),
                      border: Border.all(color: GcsColors.border),
                      boxShadow: GcsLayout.panelDepth,
                    ),
                    padding: const EdgeInsets.fromLTRB(8, 0, 8 + reservedRight, 0),
                    alignment: Alignment.centerLeft,
                    child: compactRow,
                  ),
                ),
        ),
        Positioned(
          right: 10,
          top: 8,
          child: Material(
            color: GcsColors.bgElevated.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onToggle,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: GcsColors.border),
                ),
                child: Icon(
                  open ? Icons.expand_more : Icons.expand_less,
                  color: GcsColors.textPrimary,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GcsBottomMissionRow extends StatelessWidget {
  const _GcsBottomMissionRow({
    required this.onStart,
    required this.onLoad,
    required this.onSave,
    required this.onWaypoints,
    required this.onMissionSummary,
    required this.onToggleTracking,
    required this.tracking,
  });

  final Future<void> Function() onStart;
  final VoidCallback onLoad;
  final VoidCallback onSave;
  final VoidCallback onWaypoints;
  final VoidCallback onMissionSummary;
  final VoidCallback onToggleTracking;
  final bool tracking;

  @override
  Widget build(BuildContext context) {
    final outline = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: GcsColors.border),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GradientButton(
            label: 'Start Mission',
            icon: Icons.play_arrow_rounded,
            onPressed: () => onStart(),
            compact: true,
          ),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            style: outline,
            onPressed: onLoad,
            icon: const Icon(Icons.folder_open_outlined, size: 16),
            label: const Text('Load', style: TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 2),
          OutlinedButton.icon(
            style: outline,
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined, size: 16),
            label: const Text('Save', style: TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 2),
          OutlinedButton.icon(
            style: outline,
            onPressed: () {},
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('Pause', style: TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 2),
          OutlinedButton.icon(
            style: outline,
            onPressed: () {},
            icon: const Icon(Icons.home_outlined, size: 16),
            label: const Text('RTH', style: TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 2),
          OutlinedButton.icon(
            style: outline,
            onPressed: onWaypoints,
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Waypoints', style: TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 2),
          OutlinedButton.icon(
            style: outline,
            onPressed: onMissionSummary,
            icon: const Icon(Icons.summarize_outlined, size: 16),
            label: const Text('Summary', style: TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 2),
          FilledButton.tonalIcon(
            onPressed: onToggleTracking,
            icon: Icon(tracking ? Icons.gps_fixed : Icons.gps_not_fixed, size: 16),
            label: Text(tracking ? 'Track ON' : 'Track', style: const TextStyle(fontSize: 11)),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              visualDensity: VisualDensity.compact,
              backgroundColor: tracking ? GcsColors.accentPrimary.withValues(alpha: 0.2) : GcsColors.bgElevated,
              foregroundColor: GcsColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          const EmergencyStopButton(),
        ],
      ),
    );
  }
}

Color _modeAccent(ColorScheme scheme, String mode) {
  return switch (mode) {
    'AUTO' || 'LOITER' => GcsColors.accentPrimary,
    'MANUAL' => GcsColors.accentSuccess,
    'RTH' || 'LAND' => scheme.secondary,
    _ => GcsColors.textMuted,
  };
}

class _ModeTag extends StatelessWidget {
  const _ModeTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _HomeMarker extends StatelessWidget {
  const _HomeMarker({this.distanceM});

  final double? distanceM;

  @override
  Widget build(BuildContext context) {
    final dist = distanceM;
    final label = dist == null
        ? 'HOME'
        : (dist >= 1000 ? 'HOME ${(dist / 1000).toStringAsFixed(1)} km' : 'HOME ${dist.toStringAsFixed(0)} m');
    // IMPORTANT: this widget is rendered inside a fixed-size FlutterMap Marker.
    // Always constrain width so text can ellipsize without causing RenderFlex overflow.
    return SizedBox(
      width: 84,
      height: 34,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: GcsColors.bgPanel.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GcsColors.border),
          boxShadow: GcsLayout.panelDepth,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(Icons.home_rounded, size: 16, color: GcsColors.accentPrimary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  color: GcsColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// GCS label + map FABs, intended just outside the left shell sidebar (map section).
class _MapGcsQuickRail extends StatelessWidget {
  const _MapGcsQuickRail({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: GcsColors.accentPrimary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GcsColors.accentPrimary.withValues(alpha: 0.28)),
                boxShadow: GcsLayout.glowCyan,
              ),
              child: const Icon(Icons.flight, color: GcsColors.accentPrimary, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'GCS',
              style: TextStyle(
                color: GcsColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({
    required this.onAddWaypoint,
    required this.onNewMission,
    required this.onSurveyGrid,
    required this.onImportMission,
    required this.onMapLayers,
    required this.armed,
    required this.onToggleArm,
    required this.flightMode,
    required this.onSetFlightMode,
  });

  final VoidCallback onAddWaypoint;
  final VoidCallback onNewMission;
  final VoidCallback onSurveyGrid;
  final VoidCallback onImportMission;
  final VoidCallback onMapLayers;
  final bool armed;
  final VoidCallback onToggleArm;
  final String flightMode;
  final Future<void> Function(String mode) onSetFlightMode;

  void _openMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => _FabMenuSheet(
        onAddWaypoint: () {
          Navigator.of(ctx).pop();
          onAddWaypoint();
        },
        onNewMission: () {
          Navigator.of(ctx).pop();
          onNewMission();
        },
        onSurveyGrid: () {
          Navigator.of(ctx).pop();
          onSurveyGrid();
        },
        onImportMission: () {
          Navigator.of(ctx).pop();
          onImportMission();
        },
        onMapLayers: () {
          Navigator.of(ctx).pop();
          onMapLayers();
        },
        armed: armed,
        onToggleArm: () {
          Navigator.of(ctx).pop();
          onToggleArm();
        },
        flightMode: flightMode,
        onSetFlightMode: (m) async {
          Navigator.of(ctx).pop();
          await onSetFlightMode(m);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FloatingActionButton(
          heroTag: 'map_fab_add_waypoint',
          onPressed: onAddWaypoint,
          tooltip: 'Add waypoint',
          elevation: 2,
          child: const Icon(Icons.add_location_alt_outlined),
        ),
        const SizedBox(height: AppSpacing.lg),
        FloatingActionButton.small(
          heroTag: 'map_fab_menu',
          onPressed: () => _openMenu(context),
          tooltip: 'More actions',
          elevation: 2,
          child: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}

class _FabMenuSheet extends StatelessWidget {
  const _FabMenuSheet({
    required this.onAddWaypoint,
    required this.onNewMission,
    required this.onSurveyGrid,
    required this.onImportMission,
    required this.onMapLayers,
    required this.armed,
    required this.onToggleArm,
    required this.flightMode,
    required this.onSetFlightMode,
  });

  final VoidCallback onAddWaypoint;
  final VoidCallback onNewMission;
  final VoidCallback onSurveyGrid;
  final VoidCallback onImportMission;
  final VoidCallback onMapLayers;
  final bool armed;
  final VoidCallback onToggleArm;
  final String flightMode;
  final Future<void> Function(String) onSetFlightMode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Map actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.add_location_alt_outlined),
                title: const Text('Add waypoint'),
                subtitle: const Text('Long-press map to place'),
                onTap: onAddWaypoint,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.layers_outlined),
                title: const Text('Map layers'),
                subtitle: const Text('Basemap, overlays, vehicle'),
                onTap: onMapLayers,
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  armed ? Icons.shield : Icons.shield_outlined,
                  color: armed ? GcsColors.accentWarning : null,
                ),
                title: Text(armed ? 'Disarm (demo)' : 'Arm (demo)'),
                subtitle: const Text('Simulated only'),
                onTap: onToggleArm,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.swap_vert),
                title: Text('Flight mode: $flightMode'),
                subtitle: const Text('AUTO / LOITER / RTH / LAND / MANUAL'),
                onTap: () async {
                  final next = await showDialog<String>(
                    context: context,
                    builder: (c) => SimpleDialog(
                      title: const Text('Set flight mode'),
                      children: [
                        for (final m in const ['AUTO', 'LOITER', 'RTH', 'LAND', 'MANUAL'])
                          SimpleDialogOption(
                            onPressed: () => Navigator.of(c).pop(m),
                            child: Text(m),
                          ),
                      ],
                    ),
                  );
                  if (next != null) await onSetFlightMode(next);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('New mission'),
                subtitle: const Text('Open mission wizard'),
                onTap: onNewMission,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.grid_on_outlined),
                title: const Text('Survey grid'),
                subtitle: const Text('Generate survey waypoints'),
                onTap: onSurveyGrid,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.file_upload_outlined),
                title: const Text('Import mission'),
                subtitle: const Text('Import .plan / .waypoints / JSON'),
                onTap: onImportMission,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionSummarySheet extends StatelessWidget {
  const _MissionSummarySheet({
    required this.waypointCount,
    required this.hasAirspaceViolation,
    required this.preArmAllPass,
    required this.canStartMission,
    required this.onOpenWaypointEditor,
    required this.onLoadMission,
    required this.onSaveMission,
  });

  final int waypointCount;
  final bool hasAirspaceViolation;
  final bool preArmAllPass;
  final bool canStartMission;
  final VoidCallback onOpenWaypointEditor;
  final VoidCallback onLoadMission;
  final VoidCallback onSaveMission;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mission summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      StatusPill(label: 'Waypoints: $waypointCount', color: scheme.outline),
                      StatusPill(
                        label: preArmAllPass ? 'Pre-arm: PASS' : 'Pre-arm: CHECK',
                        color: preArmAllPass ? scheme.tertiary : scheme.outline,
                      ),
                      StatusPill(
                        label: hasAirspaceViolation ? 'Airspace: VIOLATION' : 'Airspace: CLEAR',
                        color: hasAirspaceViolation ? scheme.error : scheme.tertiary,
                      ),
                      StatusPill(
                        label: canStartMission ? 'Ready' : 'Blocked',
                        color: canStartMission ? scheme.primary : scheme.outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryMetric(
                          label: 'Distance',
                          value: '-- km',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _SummaryMetric(
                          label: 'Est. time',
                          value: '-- min',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    height: 88,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Altitude profile (placeholder)'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onLoadMission,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Load'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSaveMission,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onOpenWaypointEditor,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Open waypoint editor'),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _FlightModeTransitionBanner extends StatelessWidget {
  const _FlightModeTransitionBanner({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.swap_horiz_outlined),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Flight mode transition → $mode (placeholder)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// `_MiniTelemetryPanel` was previously used as an extra map overlay.
// Layout spec now keeps overlays to: map fill, left dock, right dock, bottom telemetry.
// Keeping this removed avoids unused-element warnings and reduces overlay clutter.

class _MissionWp {
  const _MissionWp({
    required this.id,
    required this.index,
    required this.point,
  });

  final String id;
  final int index;
  final LatLng point;

  bool get isNfzViolation => isInDemoNfz(point);

  String get label => 'WP$index';

  _MissionWp copyWith({
    String? id,
    int? index,
    LatLng? point,
  }) {
    return _MissionWp(
      id: id ?? this.id,
      index: index ?? this.index,
      point: point ?? this.point,
    );
  }
}

class _PreArmCheckSheet extends StatefulWidget {
  const _PreArmCheckSheet({
    required this.allPass,
    required this.onSetAllPass,
    required this.onClose,
    this.gpsLock,
    this.batteryOk,
    this.sensorsCalibrated,
    this.ekfHealthy,
    this.rcSignalOk,
  });

  final bool allPass;
  final ValueChanged<bool> onSetAllPass;
  final VoidCallback onClose;
  final bool? gpsLock;
  final bool? batteryOk;
  final bool? sensorsCalibrated;
  final bool? ekfHealthy;
  final bool? rcSignalOk;

  @override
  State<_PreArmCheckSheet> createState() => _PreArmCheckSheetState();
}

class _PreArmCheckSheetState extends State<_PreArmCheckSheet> {
  late bool _sensorCal;
  late bool _gpsLock;
  late bool _batteryOk;
  late bool _rcSignal;
  late bool _firmwareOk;
  late bool _geofenceActive;
  late bool _ekfHealthy;

  bool get _allPass =>
      _sensorCal &&
      _gpsLock &&
      _batteryOk &&
      _rcSignal &&
      _firmwareOk &&
      _geofenceActive &&
      _ekfHealthy;

  @override
  void initState() {
    super.initState();
    // Dynamic-ready defaults (from live values when provided), with manual override still possible.
    _sensorCal = widget.sensorsCalibrated ?? widget.allPass;
    _gpsLock = widget.gpsLock ?? widget.allPass;
    _batteryOk = widget.batteryOk ?? true;
    _rcSignal = widget.rcSignalOk ?? true;
    _firmwareOk = widget.allPass;
    _geofenceActive = true;
    _ekfHealthy = widget.ekfHealthy ?? true;
  }

  void _syncToParent() {
    widget.onSetAllPass(_allPass);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pre-Arm Check (placeholder)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusPill(
                label: _allPass ? 'ALL CHECKS PASS' : 'CHECKS FAIL',
                color: _allPass ? scheme.tertiary : scheme.error,
              ),
              StatusPill(label: 'State: PRE_ARM_CHECK', color: scheme.outline),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Card(
              child: ListView(
                children: [
                  _CheckTile(
                    label: 'Sensor calibration',
                    value: _sensorCal,
                    onChanged: (v) => setState(() {
                      _sensorCal = v;
                      _syncToParent();
                    }),
                  ),
                  const Divider(height: 1),
                  _CheckTile(
                    label: 'GPS lock',
                    value: _gpsLock,
                    onChanged: (v) => setState(() {
                      _gpsLock = v;
                      _syncToParent();
                    }),
                  ),
                  const Divider(height: 1),
                  _CheckTile(
                    label: 'EKF healthy',
                    value: _ekfHealthy,
                    onChanged: (v) => setState(() {
                      _ekfHealthy = v;
                      _syncToParent();
                    }),
                  ),
                  const Divider(height: 1),
                  _CheckTile(
                    label: 'Battery OK',
                    value: _batteryOk,
                    onChanged: (v) => setState(() {
                      _batteryOk = v;
                      _syncToParent();
                    }),
                  ),
                  const Divider(height: 1),
                  _CheckTile(
                    label: 'RC signal / link',
                    value: _rcSignal,
                    onChanged: (v) => setState(() {
                      _rcSignal = v;
                      _syncToParent();
                    }),
                  ),
                  const Divider(height: 1),
                  _CheckTile(
                    label: 'Firmware version OK',
                    value: _firmwareOk,
                    onChanged: (v) => setState(() {
                      _firmwareOk = v;
                      _syncToParent();
                    }),
                  ),
                  const Divider(height: 1),
                  _CheckTile(
                    label: 'Geofence active',
                    value: _geofenceActive,
                    onChanged: (v) => setState(() {
                      _geofenceActive = v;
                      _syncToParent();
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _allPass
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pre-arm checks passed (placeholder)')),
                      );
                      widget.onClose();
                    }
                  : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      title: Text(label),
      subtitle: Text(value ? 'PASS' : 'FAIL'),
      secondary: Icon(
        value ? Icons.check_circle_outline : Icons.error_outline,
        color: value ? scheme.tertiary : scheme.error,
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

