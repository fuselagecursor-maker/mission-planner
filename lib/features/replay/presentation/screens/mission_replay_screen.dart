import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../features/map/presentation/widgets/map_viewport.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../domain/replay_session.dart';

/// SRS FR-24 — Mission replay: map track, scrubber, playback speed, synced telemetry,
/// timeline events, altitude graph cursor, KML export (demo log; .log.gz ingestion later).
class MissionReplayScreen extends StatefulWidget {
  const MissionReplayScreen({super.key});

  @override
  State<MissionReplayScreen> createState() => _MissionReplayScreenState();
}

class _MissionReplayScreenState extends State<MissionReplayScreen> {
  final MapController _mapController = MapController();

  FlightReplayLog? _log;
  /// Recomputed only when [_log] changes — rebuilding ~hundreds of polylines each frame freezes the UI (esp. web).
  List<Polyline>? _cachedTrackPolylines;
  /// Stable map seed so [FlutterMap] is not recreated with a new [MapOptions.initialCenter] every tick.
  LatLng? _mapAnchor;
  /// Event pins do not depend on playhead; keeps marker layer lighter during playback.
  List<Marker> _cachedEventMarkers = const [];
  FlightReplayLog? _lastCacheLog;
  double _playhead = 0; // 0..1
  double _speed = 1.0;
  bool _playing = false;
  Timer? _timer;
  ReplayEvent? _highlightEvent;

  Duration get _playbackTick =>
      kIsWeb ? const Duration(milliseconds: 200) : const Duration(milliseconds: 80);

  double get _playbackTickSec => _playbackTick.inMilliseconds / 1000.0;

  @override
  void initState() {
    super.initState();
    _log = buildDemoReplayLog();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setPlaying(bool v) {
    _timer?.cancel();
    _timer = null;
    if (v) {
      _timer = Timer.periodic(_playbackTick, (_) => _tickPlayback());
    }
    setState(() => _playing = v);
  }

  void _tickPlayback() {
    final log = _log;
    if (log == null || log.isEmpty) return;
    final dur = log.durationSec;
    if (dur <= 0) return;
    final dt = _playbackTickSec * _speed / dur;
    var next = _playhead + dt;
    if (next >= 1) {
      next = 1;
      _setPlaying(false);
    }
    setState(() => _playhead = next);
    _syncHighlightEvent();
  }

  void _syncHighlightEvent() {
    final log = _log;
    if (log == null || log.events.isEmpty) {
      _highlightEvent = null;
      return;
    }
    final t = _currentTimeSec;
    ReplayEvent? best;
    var bestDist = double.infinity;
    for (final e in log.events) {
      final d = (e.timeSec - t).abs();
      if (d < bestDist && d < 1.2) {
        bestDist = d;
        best = e;
      }
    }
    _highlightEvent = best;
  }

  double get _currentTimeSec {
    final log = _log;
    if (log == null || log.samples.isEmpty) return 0;
    final t0 = log.samples.first.timeSec;
    final t1 = log.samples.last.timeSec;
    return t0 + _playhead * (t1 - t0);
  }

  String _fmtTime(double sec) {
    final s = sec.floor().clamp(0, 1 << 30);
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }

  Future<void> _exportKml() async {
    final log = _log;
    if (log == null || log.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to export')),
      );
      return;
    }
    final kml = buildReplayKml(log);
    await Clipboard.setData(ClipboardData(text: kml));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('KML copied to clipboard')),
    );
  }

  Future<void> _loadPlaceholderGzip() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Load flight log'),
        content: const Text(
          'Parsing compressed .log.gz archives will be wired to a file picker and '
          'streaming reader. This wireframe uses the built-in demo track (also loaded on open).',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _rebuildLogCaches(BuildContext context, FlightReplayLog? log) {
    if (log == null || log.isEmpty) {
      _cachedTrackPolylines = null;
      _mapAnchor = null;
      _cachedEventMarkers = const [];
      _lastCacheLog = null;
      return;
    }
    if (identical(log, _lastCacheLog)) return;
    _lastCacheLog = log;
    final scheme = Theme.of(context).colorScheme;
    _cachedTrackPolylines = buildSpeedColoredTrack(log);
    _mapAnchor = log.samples.first.point;
    _cachedEventMarkers = [
      for (final e in log.events)
        Marker(
          point: e.point ?? interpolateAt(log, e.timeSec).point,
          width: 36,
          height: 36,
          child: Icon(
            _eventIcon(e.kind),
            size: 28,
            color: scheme.primary,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black45)],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final log = _log;
    _rebuildLogCaches(context, log);
    final track = _cachedTrackPolylines ?? const <Polyline>[];
    final sample = log != null && !log.isEmpty ? interpolateAt(log, _currentTimeSec) : null;
    final mapSeed = _mapAnchor ?? LatLng(12.9716, 77.5946);
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 1060;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Replay'),
        actions: [
          OutlinedButton.icon(
            onPressed: _loadPlaceholderGzip,
            icon: const Icon(Icons.folder_open_outlined),
            label: const Text('Load'),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _log = buildDemoReplayLog();
                _lastCacheLog = null;
                _playhead = 0;
                _highlightEvent = null;
              });
              _setPlaying(false);
            },
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Demo'),
          ),
          const SizedBox(width: AppSpacing.sm),
          GradientButton(
            compact: true,
            icon: Icons.ios_share_outlined,
            label: 'Export KML',
            onPressed: _exportKml,
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
        children: [
          _ReplayHeroHeader(
            sourceLabel: log?.sourceLabel,
            playing: _playing,
            speed: _speed,
            currentTime: log == null || log.isEmpty ? null : _currentTimeSec,
            duration: log == null || log.isEmpty ? null : log.durationSec,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _ReplayMapPanel(
                    height: (size.height * 0.42).clamp(300.0, 420.0),
                    mapController: _mapController,
                    log: _log,
                    mapSeed: mapSeed,
                    track: track,
                    sample: sample,
                    eventMarkers: _cachedEventMarkers,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 5,
                  child: _TimelinePanel(
                    log: log,
                    playhead: _playhead,
                    speed: _speed,
                    playing: _playing,
                    highlightEvent: _highlightEvent,
                    currentTimeSec: _currentTimeSec,
                    fmtTime: _fmtTime,
                    onTogglePlaying: log == null || log.isEmpty ? null : () => _setPlaying(!_playing),
                    onPlayheadChanged: (v) {
                      setState(() {
                        _playhead = v;
                        _syncHighlightEvent();
                      });
                    },
                    onSpeedChanged: (v) => setState(() => _speed = v),
                    onSeekToEvent: (e) {
                      if (log == null || log.isEmpty) return;
                      final t0 = log.samples.first.timeSec;
                      final t1 = log.samples.last.timeSec;
                      final span = t1 - t0;
                      setState(() {
                        _playhead = span <= 0 ? 0 : ((e.timeSec - t0) / span).clamp(0.0, 1.0);
                        _highlightEvent = e;
                        _setPlaying(false);
                      });
                    },
                  ),
                ),
              ],
            )
          else ...[
            _ReplayMapPanel(
              height: 320,
              mapController: _mapController,
              log: _log,
              mapSeed: mapSeed,
              track: track,
              sample: sample,
              eventMarkers: _cachedEventMarkers,
            ),
            const SizedBox(height: AppSpacing.lg),
            _TimelinePanel(
              log: log,
              playhead: _playhead,
              speed: _speed,
              playing: _playing,
              highlightEvent: _highlightEvent,
              currentTimeSec: _currentTimeSec,
              fmtTime: _fmtTime,
              onTogglePlaying: log == null || log.isEmpty ? null : () => _setPlaying(!_playing),
              onPlayheadChanged: (v) {
                setState(() {
                  _playhead = v;
                  _syncHighlightEvent();
                });
              },
              onSpeedChanged: (v) => setState(() => _speed = v),
              onSeekToEvent: (e) {
                if (log == null || log.isEmpty) return;
                final t0 = log.samples.first.timeSec;
                final t1 = log.samples.last.timeSec;
                final span = t1 - t0;
                setState(() {
                  _playhead = span <= 0 ? 0 : ((e.timeSec - t0) / span).clamp(0.0, 1.0);
                  _highlightEvent = e;
                  _setPlaying(false);
                });
              },
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _TelemetryAndGraphPanel(
            log: log,
            sample: sample,
            playhead: _playhead,
          ),
        ],
      ),
    );
  }
}

class _ReplayHeroHeader extends StatelessWidget {
  const _ReplayHeroHeader({
    required this.sourceLabel,
    required this.playing,
    required this.speed,
    required this.currentTime,
    required this.duration,
  });

  final String? sourceLabel;
  final bool playing;
  final double speed;
  final double? currentTime;
  final double? duration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replay',
                  style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  sourceLabel ?? 'Demo log',
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.end,
            children: [
              StatusPill(
                label: currentTime == null || duration == null
                    ? 'Time: -- / --'
                    : 'Time: ${_fmtMmSs(currentTime!)} / ${_fmtMmSs(duration!)}',
                color: scheme.outline,
                leading: Icons.schedule_outlined,
                dense: true,
              ),
              StatusPill(
                label: 'Speed: ${speed}x',
                color: AppColors.neonCyan,
                leading: Icons.speed_outlined,
                dense: true,
              ),
              StatusPill(
                label: playing ? 'PLAYING' : 'PAUSED',
                color: playing ? AppColors.success : scheme.outline,
                leading: playing ? Icons.play_arrow_rounded : Icons.pause_rounded,
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtMmSs(double sec) {
    final s = sec.floor().clamp(0, 1 << 30);
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }
}

class _ReplayMapPanel extends StatelessWidget {
  const _ReplayMapPanel({
    required this.height,
    required this.mapController,
    required this.log,
    required this.mapSeed,
    required this.track,
    required this.sample,
    required this.eventMarkers,
  });

  final double height;
  final MapController mapController;
  final FlightReplayLog? log;
  final LatLng mapSeed;
  final List<Polyline> track;
  final ReplaySample? sample;
  final List<Marker> eventMarkers;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Replay map', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              StatusPill(
                label: track.isEmpty ? 'Track: --' : 'Track: ${track.length} seg',
                color: scheme.outline,
                leading: Icons.route_outlined,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: height,
            child: RepaintBoundary(
              child: GlassCard(
                borderRadius: 18,
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: MapViewport(
                    key: ObjectKey(log),
                    controller: mapController,
                    initialCenter: mapSeed,
                    initialZoom: 13,
                    waypoints: const [],
                    path: const [],
                    trackPolylines: track,
                    vehicle: sample != null
                        ? MapVehicle(point: sample!.point, headingDeg: sample!.headingDeg)
                        : null,
                    extraMarkers: eventMarkers,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({
    required this.log,
    required this.playhead,
    required this.speed,
    required this.playing,
    required this.highlightEvent,
    required this.currentTimeSec,
    required this.fmtTime,
    required this.onTogglePlaying,
    required this.onPlayheadChanged,
    required this.onSpeedChanged,
    required this.onSeekToEvent,
  });

  final FlightReplayLog? log;
  final double playhead;
  final double speed;
  final bool playing;
  final ReplayEvent? highlightEvent;
  final double currentTimeSec;
  final String Function(double sec) fmtTime;
  final VoidCallback? onTogglePlaying;
  final ValueChanged<double> onPlayheadChanged;
  final ValueChanged<double> onSpeedChanged;
  final void Function(ReplayEvent e) onSeekToEvent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasLog = log != null && !(log?.isEmpty ?? true);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Timeline', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton.filledTonal(
                tooltip: playing ? 'Pause' : 'Play',
                onPressed: onTogglePlaying,
                icon: Icon(playing ? Icons.pause_outlined : Icons.play_arrow_outlined),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: StatusPill(
                  label: !hasLog ? 'Time: -- / --' : 'Time: ${fmtTime(currentTimeSec)} / ${fmtTime(log!.durationSec)}',
                  color: scheme.outline,
                  leading: Icons.schedule_outlined,
                  dense: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusPill(
                label: 'Speed: ${speed}x',
                color: AppColors.neonCyan,
                leading: Icons.speed_outlined,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: playhead.clamp(0.0, 1.0),
                      onChanged: !hasLog ? null : onPlayheadChanged,
                    ),
                  ),
                  if (hasLog && w > 0)
                    IgnorePointer(
                      child: SizedBox(
                        width: w,
                        height: 36,
                        child: CustomPaint(
                          painter: _EventTicksPainter(
                            events: log!.events,
                            durationSec: log!.durationSec,
                            color: scheme.secondary,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final s in const [0.25, 0.5, 1.0, 2.0, 5.0, 10.0])
                ChoiceChip(
                  label: Text('${s}x'),
                  selected: speed == s,
                  onSelected: (_) => onSpeedChanged(s),
                ),
            ],
          ),
          if (hasLog && log!.events.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Events', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final e in log!.events)
                  InputChip(
                    avatar: Icon(_eventIcon(e.kind), size: 18),
                    label: Text('${fmtTime(e.timeSec)} · ${e.label}'),
                    selected: highlightEvent == e,
                    onPressed: () => onSeekToEvent(e),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TelemetryAndGraphPanel extends StatelessWidget {
  const _TelemetryAndGraphPanel({
    required this.log,
    required this.sample,
    required this.playhead,
  });

  final FlightReplayLog? log;
  final ReplaySample? sample;
  final double playhead;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasLog = log != null && !(log?.isEmpty ?? true);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Replay-synchronised telemetry',
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              StatusPill(
                label: 'Scrub-synced',
                color: scheme.outline,
                leading: Icons.sync_rounded,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Values follow scrubber / playback (FR-24-07)',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusPill(
                label: sample != null ? 'ALT: ${sample!.altM.toStringAsFixed(1)} m' : 'ALT: --',
                color: scheme.outline,
                leading: Icons.terrain_outlined,
              ),
              StatusPill(
                label: sample != null ? 'SPD: ${sample!.speedMs.toStringAsFixed(1)} m/s' : 'SPD: --',
                color: scheme.outline,
                leading: Icons.speed_outlined,
              ),
              StatusPill(
                label: sample != null ? 'HDG: ${sample!.headingDeg.toStringAsFixed(0)}°' : 'HDG: --',
                color: scheme.outline,
                leading: Icons.explore_outlined,
              ),
              StatusPill(
                label: sample != null ? 'BAT: ${sample!.batteryPct.toStringAsFixed(0)}%' : 'BAT: --',
                color: scheme.outline,
                leading: Icons.battery_full_outlined,
              ),
              StatusPill(
                label: sample != null ? 'GNSS: ${sample!.gnssSats} sats' : 'GNSS: --',
                color: scheme.outline,
                leading: Icons.satellite_alt_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Altitude vs time', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 170,
            child: !hasLog
                ? Center(
                    child: Text(
                      'Load a log to show graphs',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                : GlassCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: _AltitudeReplayGraph(
                      samples: log!.samples,
                      playhead: playhead,
                      cursorColor: scheme.primary,
                      fillColor: scheme.primaryContainer.withValues(alpha: 0.35),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

IconData _eventIcon(ReplayEventKind k) {
  switch (k) {
    case ReplayEventKind.modeChange:
      return Icons.swap_horiz_outlined;
    case ReplayEventKind.rth:
      return Icons.home_outlined;
    case ReplayEventKind.photo:
      return Icons.photo_camera_outlined;
    case ReplayEventKind.batteryWarn:
      return Icons.battery_alert_outlined;
    case ReplayEventKind.geofence:
      return Icons.fence_outlined;
  }
}

class _EventTicksPainter extends CustomPainter {
  _EventTicksPainter({
    required this.events,
    required this.durationSec,
    required this.color,
  });

  final List<ReplayEvent> events;
  final double durationSec;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (durationSec <= 0) return;
    const pad = 12.0;
    final w = size.width - pad * 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (final e in events) {
      final x = pad + (e.timeSec / durationSec).clamp(0.0, 1.0) * w;
      canvas.drawLine(Offset(x, 4), Offset(x, size.height - 4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EventTicksPainter oldDelegate) {
    return oldDelegate.durationSec != durationSec ||
        oldDelegate.events != events ||
        oldDelegate.color != color;
  }
}


class _AltitudeReplayGraph extends StatelessWidget {
  const _AltitudeReplayGraph({
    required this.samples,
    required this.playhead,
    required this.cursorColor,
    required this.fillColor,
  });

  final List<ReplaySample> samples;
  final double playhead;
  final Color cursorColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AltitudeGraphPainter(
        samples: samples,
        playhead: playhead,
        cursorColor: cursorColor,
        fillColor: fillColor,
        axisColor: Theme.of(context).colorScheme.outlineVariant,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _AltitudeGraphPainter extends CustomPainter {
  _AltitudeGraphPainter({
    required this.samples,
    required this.playhead,
    required this.cursorColor,
    required this.fillColor,
    required this.axisColor,
  });

  final List<ReplaySample> samples;
  final double playhead;
  final Color cursorColor;
  final Color fillColor;
  final Color axisColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;
    final t0 = samples.first.timeSec;
    final t1 = samples.last.timeSec;
    var minA = samples.first.altM;
    var maxA = samples.first.altM;
    for (final s in samples) {
      if (s.altM < minA) minA = s.altM;
      if (s.altM > maxA) maxA = s.altM;
    }
    if ((maxA - minA).abs() < 1) {
      maxA = minA + 1;
    }

    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    final spanT = t1 - t0;

    Path path = Path()..moveTo(rect.left, rect.bottom);
    for (final s in samples) {
      final u = spanT <= 0 ? 0.0 : (s.timeSec - t0) / spanT;
      final x = rect.left + u * rect.width;
      final v = (s.altM - minA) / (maxA - minA);
      final y = rect.bottom - v * rect.height;
      path.lineTo(x, y);
    }
    path.lineTo(rect.right, rect.bottom);
    path.close();
    canvas.drawPath(path, Paint()..color = fillColor);

    final line = Path();
    var first = true;
    for (final s in samples) {
      final u = spanT <= 0 ? 0.0 : (s.timeSec - t0) / spanT;
      final x = rect.left + u * rect.width;
      final v = (s.altM - minA) / (maxA - minA);
      final y = rect.bottom - v * rect.height;
      if (first) {
        line.moveTo(x, y);
        first = false;
      } else {
        line.lineTo(x, y);
      }
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = cursorColor.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final cx = rect.left + playhead.clamp(0.0, 1.0) * rect.width;
    canvas.drawLine(
      Offset(cx, rect.top),
      Offset(cx, rect.bottom),
      Paint()
        ..color = cursorColor
        ..strokeWidth = 2,
    );

    canvas.drawRect(rect, Paint()..color = axisColor..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant _AltitudeGraphPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.playhead != playhead ||
        oldDelegate.cursorColor != cursorColor;
  }
}
