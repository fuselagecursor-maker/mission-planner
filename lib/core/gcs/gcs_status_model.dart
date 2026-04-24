import 'package:flutter/foundation.dart';

enum AlertSeverity { info, warning, critical }

class GcsAlert {
  const GcsAlert({
    required this.id,
    required this.title,
    this.message,
    required this.severity,
    this.persistent = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? message;
  final AlertSeverity severity;
  final bool persistent;
  final DateTime? createdAt;
}

enum VehicleSystemState { idle, armed, flying, landing, emergency }

enum LinkType { wifi, radio, usb, unknown }

/// Shared status bus for the Map-first GCS shell overlays.
///
/// Keeps the map implementation as the source of truth for simulated telemetry,
/// while allowing TopBar / TelemetryPanel overlays to render without shrinking
/// the map or duplicating simulation loops.
class GcsStatusModel extends ChangeNotifier {
  String _gpsLabel = '—';
  String _batteryLabel = '—';
  String _modeLabel = '—';

  String _altitudeM = '—';
  String _speedMs = '—';
  String _batteryPct = '—';
  String _gpsSats = '—';
  String _headingDeg = '—';
  String _climbMps = '—';
  String _hdop = '—';

  bool _armed = false;
  VehicleSystemState _systemState = VehicleSystemState.idle;

  int _signalPct = 0;
  int _latencyMs = 0;
  LinkType _linkType = LinkType.unknown;

  String _batteryVoltageV = '—';
  String _batteryCurrentA = '—';
  String _batteryTimeRemaining = '—';

  String _gpsFix = '—';
  String _gpsAccuracy = '—';

  String _ekfStatus = '—';
  String _imuStatus = '—';
  String _compassStatus = '—';

  bool _rthActive = false;
  String _rthPhase = '—';
  String _rthDistanceM = '—';

  bool _missionActive = false;
  int _missionWpIndex = 0;
  int _missionWpTotal = 0;
  String _missionDistToNextM = '—';
  int _missionCompletionPct = 0;
  String _homeDistance = '—';

  final List<GcsAlert> _alerts = <GcsAlert>[];

  String get gpsLabel => _gpsLabel;
  String get batteryLabel => _batteryLabel;
  String get modeLabel => _modeLabel;

  String get altitudeM => _altitudeM;
  String get speedMs => _speedMs;
  String get batteryPct => _batteryPct;
  String get gpsSats => _gpsSats;
  String get headingDeg => _headingDeg;
  String get climbMps => _climbMps;
  String get hdop => _hdop;

  bool get armed => _armed;
  VehicleSystemState get systemState => _systemState;

  int get signalPct => _signalPct;
  int get latencyMs => _latencyMs;
  LinkType get linkType => _linkType;

  String get batteryVoltageV => _batteryVoltageV;
  String get batteryCurrentA => _batteryCurrentA;
  String get batteryTimeRemaining => _batteryTimeRemaining;

  String get gpsFix => _gpsFix;
  String get gpsAccuracy => _gpsAccuracy;

  String get ekfStatus => _ekfStatus;
  String get imuStatus => _imuStatus;
  String get compassStatus => _compassStatus;

  bool get rthActive => _rthActive;
  String get rthPhase => _rthPhase;
  String get rthDistanceM => _rthDistanceM;

  bool get missionActive => _missionActive;
  int get missionWpIndex => _missionWpIndex;
  int get missionWpTotal => _missionWpTotal;
  String get missionDistToNextM => _missionDistToNextM;
  int get missionCompletionPct => _missionCompletionPct;
  String get homeDistance => _homeDistance;

  List<GcsAlert> get alerts => List.unmodifiable(_alerts);

  GcsAlert? get bannerAlert {
    // Highest severity persistent first, then newest critical.
    final persistent = _alerts.where((a) => a.persistent).toList();
    persistent.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    if (persistent.isNotEmpty) return persistent.first;
    final critical = _alerts.where((a) => a.severity == AlertSeverity.critical).toList();
    critical.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    return critical.isEmpty ? null : critical.first;
  }

  void setTopBar({
    required String gpsLabel,
    required String batteryLabel,
    required String modeLabel,
  }) {
    var changed = false;
    if (_gpsLabel != gpsLabel) {
      _gpsLabel = gpsLabel;
      changed = true;
    }
    if (_batteryLabel != batteryLabel) {
      _batteryLabel = batteryLabel;
      changed = true;
    }
    if (_modeLabel != modeLabel) {
      _modeLabel = modeLabel;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setTelemetry({
    required String altitudeM,
    required String speedMs,
    required String batteryPct,
    required String gpsSats,
    required String headingDeg,
    required String climbMps,
    required String hdop,
  }) {
    var changed = false;
    if (_altitudeM != altitudeM) {
      _altitudeM = altitudeM;
      changed = true;
    }
    if (_speedMs != speedMs) {
      _speedMs = speedMs;
      changed = true;
    }
    if (_batteryPct != batteryPct) {
      _batteryPct = batteryPct;
      changed = true;
    }
    if (_gpsSats != gpsSats) {
      _gpsSats = gpsSats;
      changed = true;
    }
    if (_headingDeg != headingDeg) {
      _headingDeg = headingDeg;
      changed = true;
    }
    if (_climbMps != climbMps) {
      _climbMps = climbMps;
      changed = true;
    }
    if (_hdop != hdop) {
      _hdop = hdop;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setFlightStatus({
    required bool armed,
    required VehicleSystemState systemState,
  }) {
    var changed = false;
    if (_armed != armed) {
      _armed = armed;
      changed = true;
    }
    if (_systemState != systemState) {
      _systemState = systemState;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setLink({
    required int signalPct,
    required int latencyMs,
    required LinkType linkType,
  }) {
    var changed = false;
    if (_signalPct != signalPct) {
      _signalPct = signalPct;
      changed = true;
    }
    if (_latencyMs != latencyMs) {
      _latencyMs = latencyMs;
      changed = true;
    }
    if (_linkType != linkType) {
      _linkType = linkType;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setBatteryDetails({
    required String voltageV,
    required String currentA,
    required String timeRemaining,
  }) {
    var changed = false;
    if (_batteryVoltageV != voltageV) {
      _batteryVoltageV = voltageV;
      changed = true;
    }
    if (_batteryCurrentA != currentA) {
      _batteryCurrentA = currentA;
      changed = true;
    }
    if (_batteryTimeRemaining != timeRemaining) {
      _batteryTimeRemaining = timeRemaining;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setGpsQuality({
    required String fix,
    required String accuracy,
  }) {
    var changed = false;
    if (_gpsFix != fix) {
      _gpsFix = fix;
      changed = true;
    }
    if (_gpsAccuracy != accuracy) {
      _gpsAccuracy = accuracy;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setSensorHealth({
    required String ekf,
    required String imu,
    required String compass,
  }) {
    var changed = false;
    if (_ekfStatus != ekf) {
      _ekfStatus = ekf;
      changed = true;
    }
    if (_imuStatus != imu) {
      _imuStatus = imu;
      changed = true;
    }
    if (_compassStatus != compass) {
      _compassStatus = compass;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setRthStatus({
    required bool active,
    required String phase,
    required String distanceM,
  }) {
    var changed = false;
    if (_rthActive != active) {
      _rthActive = active;
      changed = true;
    }
    if (_rthPhase != phase) {
      _rthPhase = phase;
      changed = true;
    }
    if (_rthDistanceM != distanceM) {
      _rthDistanceM = distanceM;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setMissionProgress({
    required bool active,
    required int wpIndex,
    required int wpTotal,
    required String distToNextM,
    required int completionPct,
  }) {
    var changed = false;
    if (_missionActive != active) {
      _missionActive = active;
      changed = true;
    }
    if (_missionWpIndex != wpIndex) {
      _missionWpIndex = wpIndex;
      changed = true;
    }
    if (_missionWpTotal != wpTotal) {
      _missionWpTotal = wpTotal;
      changed = true;
    }
    if (_missionDistToNextM != distToNextM) {
      _missionDistToNextM = distToNextM;
      changed = true;
    }
    if (_missionCompletionPct != completionPct) {
      _missionCompletionPct = completionPct;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setHomeDistance(String distanceLabel) {
    if (_homeDistance == distanceLabel) return;
    _homeDistance = distanceLabel;
    notifyListeners();
  }

  void pushAlert(GcsAlert alert) {
    final idx = _alerts.indexWhere((a) => a.id == alert.id);
    if (idx >= 0) {
      _alerts[idx] = alert;
    } else {
      _alerts.add(alert);
    }
    notifyListeners();
  }

  void dismissAlert(String id) {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}

