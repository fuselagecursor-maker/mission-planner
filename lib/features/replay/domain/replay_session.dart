import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// One telemetry sample in a replay log (FR-24).
class ReplaySample {
  const ReplaySample({
    required this.timeSec,
    required this.point,
    required this.altM,
    required this.speedMs,
    required this.headingDeg,
    required this.batteryPct,
    required this.gnssSats,
  });

  final double timeSec;
  final LatLng point;
  final double altM;
  final double speedMs;
  final double headingDeg;
  final double batteryPct;
  final int gnssSats;
}

enum ReplayEventKind { modeChange, rth, photo, batteryWarn, geofence }

/// Logged event for timeline + map (FR-24-09).
class ReplayEvent {
  const ReplayEvent({
    required this.timeSec,
    required this.kind,
    required this.label,
    this.point,
  });

  final double timeSec;
  final ReplayEventKind kind;
  final String label;
  final LatLng? point;
}

/// Loaded flight replay data.
class FlightReplayLog {
  const FlightReplayLog({
    required this.samples,
    required this.events,
    this.sourceLabel = 'Demo log',
  });

  final List<ReplaySample> samples;
  final List<ReplayEvent> events;
  final String sourceLabel;

  double get durationSec =>
      samples.isEmpty ? 0 : samples.last.timeSec - samples.first.timeSec;

  bool get isEmpty => samples.length < 2;
}

/// Synthetic figure-eight style track for wireframe replay (no file I/O).
FlightReplayLog buildDemoReplayLog() {
  const center = LatLng(12.9716, 77.5946);
  const samples = <ReplaySample>[];
  const n = 240;
  const totalSec = 120.0;
  const radius = 0.0042;

  for (var i = 0; i <= n; i++) {
    final u = i / n;
    final t = u * totalSec;
    final a = u * math.pi * 4;
    final lat = center.latitude + radius * math.sin(a);
    final lng = center.longitude + radius * 0.85 * math.sin(a * 0.5);
    final speed = 3 + 10 * (0.5 + 0.5 * math.sin(a * 1.3));
    final hdg = (a * 180 / math.pi) % 360;
    final alt = 42 + 18 * math.sin(a * 0.7);
    samples.add(
      ReplaySample(
        timeSec: t,
        point: LatLng(lat, lng),
        altM: alt,
        speedMs: speed,
        headingDeg: hdg,
        batteryPct: 88 - (u * 36),
        gnssSats: 12 + (i % 3),
      ),
    );
  }

  ReplaySample at(double timeSec) {
    final idx = (timeSec / totalSec * n).round().clamp(0, n);
    return samples[idx];
  }

  final events = <ReplayEvent>[
    ReplayEvent(
      timeSec: 12,
      kind: ReplayEventKind.modeChange,
      label: 'AUTO → LOITER',
      point: at(12).point,
    ),
    ReplayEvent(
      timeSec: 38,
      kind: ReplayEventKind.photo,
      label: 'Photo capture',
      point: at(38).point,
    ),
    ReplayEvent(
      timeSec: 64,
      kind: ReplayEventKind.batteryWarn,
      label: 'Battery warn',
      point: at(64).point,
    ),
    ReplayEvent(
      timeSec: 81,
      kind: ReplayEventKind.rth,
      label: 'RTH',
      point: at(81).point,
    ),
    ReplayEvent(
      timeSec: 99,
      kind: ReplayEventKind.geofence,
      label: 'Geofence advisory',
      point: at(99).point,
    ),
  ];

  return FlightReplayLog(samples: samples, events: events, sourceLabel: 'Demo flight (synthetic)');
}

/// Linear interpolation between samples by time (FR-24-04).
ReplaySample interpolateAt(FlightReplayLog log, double timeSec) {
  final s = log.samples;
  if (s.isEmpty) {
    throw StateError('empty log');
  }
  if (s.length == 1 || timeSec <= s.first.timeSec) return s.first;
  if (timeSec >= s.last.timeSec) return s.last;

  var i = 0;
  while (i < s.length - 1 && s[i + 1].timeSec < timeSec) {
    i++;
  }
  final a = s[i];
  final b = s[i + 1];
  final span = b.timeSec - a.timeSec;
  final t = span <= 1e-6 ? 0.0 : (timeSec - a.timeSec) / span;

  LatLng lerpLatLng(LatLng p, LatLng q, double k) {
    return LatLng(
      p.latitude + (q.latitude - p.latitude) * k,
      p.longitude + (q.longitude - p.longitude) * k,
    );
  }

  double lerpD(double p, double q, double k) => p + (q - p) * k;

  return ReplaySample(
    timeSec: timeSec,
    point: lerpLatLng(a.point, b.point, t),
    altM: lerpD(a.altM, b.altM, t),
    speedMs: lerpD(a.speedMs, b.speedMs, t),
    headingDeg: lerpD(a.headingDeg, b.headingDeg, t),
    batteryPct: lerpD(a.batteryPct, b.batteryPct, t),
    gnssSats: (lerpD(a.gnssSats.toDouble(), b.gnssSats.toDouble(), t)).round(),
  );
}

Color _speedHeatColor(double v01) {
  final c = v01.clamp(0.0, 1.0);
  if (c < 0.25) return Color.lerp(Colors.blue, Colors.cyan, c * 4)!;
  if (c < 0.5) return Color.lerp(Colors.cyan, Colors.lightGreen, (c - 0.25) * 4)!;
  if (c < 0.75) return Color.lerp(Colors.lightGreen, Colors.amber, (c - 0.5) * 4)!;
  return Color.lerp(Colors.amber, Colors.red, (c - 0.75) * 4)!;
}

/// Build per-segment polylines coloured by local speed (FR-24-03).
List<Polyline> buildSpeedColoredTrack(FlightReplayLog log) {
  final s = log.samples;
  if (s.length < 2) return const [];

  var minS = double.infinity;
  var maxS = -double.infinity;
  for (var i = 0; i < s.length; i++) {
    final v = s[i].speedMs;
    if (v < minS) minS = v;
    if (v > maxS) maxS = v;
  }
  final span = (maxS - minS).abs() < 1e-6 ? 1.0 : (maxS - minS);

  final out = <Polyline>[];
  for (var i = 0; i < s.length - 1; i++) {
    final a = s[i];
    final b = s[i + 1];
    final avg = (a.speedMs + b.speedMs) * 0.5;
    final n = (avg - minS) / span;
    out.add(
      Polyline(
        points: [a.point, b.point],
        strokeWidth: 4,
        color: _speedHeatColor(n),
      ),
    );
  }
  return out;
}

String _kmlEscape(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// Minimal KML export: track + event placemarks (FR-24-10).
String buildReplayKml(FlightReplayLog log) {
  final coords = log.samples.map((e) => '${e.point.longitude},${e.point.latitude},${e.altM}').join(' ');
  final buf = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<kml xmlns="http://www.opengis.net/kml/2.2">')
    ..writeln('<Document>')
    ..writeln('<name>${_kmlEscape(log.sourceLabel)}</name>')
    ..writeln('<Placemark><name>Track</name>')
    ..writeln('<LineString><tessellate>1</tessellate><coordinates>$coords</coordinates></LineString>')
    ..writeln('</Placemark>');

  for (final e in log.events) {
    final p = e.point ?? interpolateAt(log, e.timeSec).point;
    buf
      ..writeln('<Placemark>')
      ..writeln('<name>${_kmlEscape(e.label)}</name>')
      ..writeln(
        '<description>${_kmlEscape(e.kind.name)} @ ${e.timeSec.toStringAsFixed(1)}s</description>',
      )
      ..writeln('<Point><coordinates>${p.longitude},${p.latitude},0</coordinates></Point>')
      ..writeln('</Placemark>');
  }

  buf.writeln('</Document></kml>');
  return buf.toString();
}
