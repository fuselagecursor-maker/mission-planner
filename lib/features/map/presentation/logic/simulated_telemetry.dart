import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Deterministic, physics-ish telemetry for wireframe GCS (no real FC link).
class SimulatedTelemetry {
  SimulatedTelemetry({math.Random? random}) : _r = random ?? math.Random(42);

  final math.Random _r;
  static const Distance _d = Distance();

  double _altMsl = 910;
  double _prevAlt = 910;
  double _groundSpeed = 0;
  double _climb = 0;
  double _battery = 88;
  int _sats = 12;
  double _hdop = 0.85;
  double _epoch = 0;
  int _signalPct = 92;
  int _latencyMs = 42;
  double _currentA = 6.2;
  double _voltageV = 15.0;

  double get altMsl => _altMsl;
  double get groundSpeed => _groundSpeed;
  double get climbMps => _climb;
  double get battery => _battery;
  int get sats => _sats;
  double get hdop => _hdop;
  int get signalPct => _signalPct;
  int get latencyMs => _latencyMs;
  double get currentA => _currentA;
  double get voltageV => _voltageV;
  double get batteryPct => _battery;

  void resetBattery() {
    _battery = 86 + _r.nextDouble() * 8;
  }

  /// [now] and [prev] are smoothed vehicle positions. [dt] seconds.
  void step({
    required LatLng now,
    required LatLng? prev,
    required double dt,
    required bool motionEnabled,
    required bool armed,
  }) {
    _epoch += dt;
    if (dt > 1e-6 && prev != null) {
      final m = _d(prev, now);
      _groundSpeed = (m / dt).clamp(0.0, 30.0);
    } else {
      _groundSpeed = (motionEnabled ? _groundSpeed * 0.85 : 0.0).clamp(0.0, 30.0);
    }

    // Barometric altitude: slow phugoid + noise (simulated MSL, not terrain).
    _prevAlt = _altMsl;
    _altMsl = 900 +
        32 * math.sin(_epoch * 0.45) +
        6 * math.sin(_epoch * 2.1) +
        (armed ? 8 * math.sin(_epoch * 0.9) : 0) +
        (_r.nextDouble() - 0.5) * 0.4;
    _climb = (_altMsl - _prevAlt) / (dt > 1e-6 ? dt : 0.04);

    // GNSS: HDOP wobble; sats nudge ±1.
    _hdop = (0.75 + 0.35 * (0.5 + 0.5 * math.sin(_epoch * 0.6))).clamp(0.5, 2.5);
    _sats = (12 + (3 * math.sin(_epoch * 0.2)).round()).clamp(8, 16);

    // Battery drain on motion + armed.
    if (armed && _groundSpeed > 1) {
      _battery = (_battery - dt * 0.012 * (1 + _groundSpeed * 0.04)).clamp(5, 100);
    } else {
      _battery = (_battery - dt * 0.0008).clamp(5, 100);
    }

    // Electrical: voltage + current respond to load; coarse but UI-ready.
    _currentA = (armed ? (4.5 + _groundSpeed * 0.22 + 0.8 * math.sin(_epoch * 1.1)) : 0.6).clamp(0.2, 42.0);
    _voltageV = (12.0 + (_battery / 100) * 4.2 - _currentA * 0.03).clamp(10.5, 16.8);

    // Link: simulate strength/latency drift with occasional dips.
    final dip = 0.5 + 0.5 * math.sin(_epoch * 0.18);
    _signalPct = (88 + 10 * dip - (armed ? 3 : 0) + (_r.nextDouble() - 0.5) * 2).round().clamp(0, 100);
    _latencyMs = (35 + 40 * (1 - dip) + (_r.nextDouble() * 10)).round().clamp(10, 280);
  }

  String get gpsStatusLine => '$_sats sats · 3D · HDOP ${_hdop.toStringAsFixed(1)}';
  String get batteryStatusLine {
    return '${_battery.toStringAsFixed(0)}% · ${_voltageV.toStringAsFixed(1)}V';
  }

  String get batteryCurrentLine => '${_currentA.toStringAsFixed(1)} A';

  String get batteryTimeRemainingLine {
    // Very rough estimate: scale with battery and load.
    final loadFactor = (_currentA / 10.0).clamp(0.2, 3.0);
    final minutes = ((_battery / 100) * 28 / loadFactor).clamp(1.0, 90.0);
    return '${minutes.toStringAsFixed(0)} min';
  }

  String get gpsFixTypeLine {
    if (_sats < 4) return 'NO FIX';
    if (_sats < 7) return '2D';
    return '3D';
  }

  String get gpsAccuracyLine {
    // interpret HDOP roughly; UI-only.
    final m = (_hdop * 2.2).clamp(0.8, 9.9);
    return '±${m.toStringAsFixed(1)} m';
  }
}
