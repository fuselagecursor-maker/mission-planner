import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/gcs_tokens.dart';

class GcsBottomDock extends StatelessWidget {
  const GcsBottomDock({
    super.key,
    this.logLines = const [
      r'[12:01:22] INFO  heartbeat OK · FC v4.x',
      r'[12:01:22] OK    prearm: gyro warmed',
      r'[12:01:23] WARN  geofence: 120 m margin',
    ],
    required this.missionRow,
    this.headingDeg,
    this.speedMs,
    this.altitudeMslM,
    this.homeDistanceM,
    this.climbMps,
    this.bankDeg,
    this.sats,
    this.armed,
    this.flightMode,
  });

  final List<String> logLines;
  final Widget missionRow;
  final double? headingDeg;
  final double? speedMs;
  final double? altitudeMslM;
  final double? homeDistanceM;
  final double? climbMps;
  final double? bankDeg;
  final int? sats;
  final bool? armed;
  final String? flightMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: GcsColors.bgPanel,
        borderRadius: BorderRadius.circular(GcsLayout.radius),
        border: Border.all(color: GcsColors.border),
        boxShadow: GcsLayout.panelDepth,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: missionRow,
          ),
          const Divider(color: GcsColors.border, height: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final hasHud = headingDeg != null &&
                    speedMs != null &&
                    altitudeMslM != null &&
                    homeDistanceM != null;
                final minLogW = 360.0;
                final hudW = hasHud ? 250.0 : 0.0;
                final minGraphW = 320.0;
                final dividerCount = hasHud ? 2 : 1;
                final minTotalWidth = minLogW + hudW + minGraphW + dividerCount;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: math.max(constraints.maxWidth, minTotalWidth),
                    height: constraints.maxHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _LogTerminal(logLines: logLines),
                        ),
                        if (hasHud) ...[
                          const VerticalDivider(width: 1, color: GcsColors.border),
                          SizedBox(
                            width: hudW,
                            child: _DockHudCard(
                              headingDeg: headingDeg!,
                              speedMs: speedMs!,
                              altitudeMslM: altitudeMslM!,
                              homeDistanceM: homeDistanceM!,
                              climbMps: climbMps,
                              bankDeg: bankDeg,
                              sats: sats,
                              armed: armed,
                              flightMode: flightMode,
                            ),
                          ),
                        ],
                        const VerticalDivider(width: 1, color: GcsColors.border),
                        const Expanded(
                          flex: 4,
                          child: _SparklineStub(),
                        ),
                      ],
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

class _LogTerminal extends StatelessWidget {
  const _LogTerminal({required this.logLines});

  final List<String> logLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GcsColors.bgMain,
      padding: const EdgeInsets.all(8),
      child: ListView(
        children: logLines
            .map(
              (l) => Text(
                l,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  height: 1.35,
                  color: GcsColors.accentSuccess.withValues(alpha: 0.85),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SparklineStub extends StatelessWidget {
  const _SparklineStub();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AltStubPainter(),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'ALT (m) — live graph',
              style: TextStyle(
                color: GcsColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockHudCard extends StatelessWidget {
  const _DockHudCard({
    required this.headingDeg,
    required this.speedMs,
    required this.altitudeMslM,
    required this.homeDistanceM,
    this.climbMps,
    this.bankDeg,
    this.sats,
    this.armed,
    this.flightMode,
  });

  final double headingDeg;
  final double speedMs;
  final double altitudeMslM;
  final double homeDistanceM;
  final double? climbMps;
  final double? bankDeg;
  final int? sats;
  final bool? armed;
  final String? flightMode;

  @override
  Widget build(BuildContext context) {
    final hdg = ((headingDeg % 360) + 360) % 360;
    final gs = speedMs * 3.6;
    final ias = gs * 0.98;
    final tas = gs * 1.03;
    final rollDeg = (bankDeg ?? (10 * math.sin(hdg * math.pi / 180))).clamp(-30.0, 30.0);
    final pitchDeg = ((climbMps ?? 0.0) * 4.8).clamp(-18.0, 18.0);
    final satCount = sats ?? (11 + (math.sin(hdg * math.pi / 180) * 2)).round().clamp(8, 16);
    return Container(
      color: GcsColors.bgMain.withValues(alpha: 0.35),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = c.maxWidth < 235;
          final sideGap = compact ? 6.0 : 8.0;
          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _HudTapeColumn(
                      compact: compact,
                      topLabel: 'GS, km/h',
                      topValue: gs.toStringAsFixed(1),
                      midLabel: 'IAS, km/h',
                      midValue: ias.toStringAsFixed(0),
                      bottomLabel: 'TAS, km/h',
                      bottomValue: tas.toStringAsFixed(1),
                    ),
                    SizedBox(width: sideGap),
                    Expanded(
                      child: _AttitudeDisplay(
                        compact: compact,
                        pitchDeg: pitchDeg,
                        rollDeg: rollDeg,
                        headingDeg: hdg,
                        satCount: satCount,
                        armed: armed ?? false,
                        flightMode: flightMode ?? 'STABILIZE',
                      ),
                    ),
                    SizedBox(width: sideGap),
                    _HudTapeColumn(
                      compact: compact,
                      topLabel: 'SAT, m',
                      topValue: (altitudeMslM + 170).toStringAsFixed(0),
                      midLabel: 'ALT, m',
                      midValue: altitudeMslM.toStringAsFixed(0),
                      bottomLabel: 'HOME',
                      bottomValue: _homeDistance(homeDistanceM),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _homeDistance(double m) {
    if (m >= 1000) return '${(m / 1000).toStringAsFixed(1)} km';
    return '${m.toStringAsFixed(0)} m';
  }
}

class _HudTapeColumn extends StatelessWidget {
  const _HudTapeColumn({
    required this.compact,
    required this.topLabel,
    required this.topValue,
    required this.midLabel,
    required this.midValue,
    required this.bottomLabel,
    required this.bottomValue,
  });

  final bool compact;
  final String topLabel;
  final String topValue;
  final String midLabel;
  final String midValue;
  final String bottomLabel;
  final String bottomValue;

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, String value, {bool highlight = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: GcsColors.textMuted,
            fontSize: compact ? 7 : 8,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (!highlight)
          Text(
            value,
            style: TextStyle(
              color: GcsColors.textPrimary,
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          )
        else
          Container(
            padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.65), width: 1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
      ],
    );
    return SizedBox(
      width: compact ? 48 : 52,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cell(topLabel, topValue),
          Row(
            children: [
              SizedBox(
                width: compact ? 8 : 10,
                height: compact ? 22 : 24,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TickMark(short: true),
                    const _TickMark(short: false),
                    _TickMark(short: true),
                  ],
                ),
              ),
              const SizedBox(width: 3),
              Expanded(child: cell(midLabel, midValue, highlight: true)),
            ],
          ),
          cell(bottomLabel, bottomValue),
        ],
      ),
    );
  }
}

class _TickMark extends StatelessWidget {
  const _TickMark({required this.short});
  final bool short;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: short ? 4 : 7,
        height: 1,
        color: Colors.white.withValues(alpha: 0.58),
      ),
    );
  }
}

class _AttitudeDisplay extends StatelessWidget {
  const _AttitudeDisplay({
    required this.compact,
    required this.pitchDeg,
    required this.rollDeg,
    required this.headingDeg,
    required this.satCount,
    required this.armed,
    required this.flightMode,
  });

  final bool compact;
  final double pitchDeg;
  final double rollDeg;
  final double headingDeg;
  final int satCount;
  final bool armed;
  final String flightMode;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: pitchDeg),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, pAnimated, _) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: rollDeg),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          builder: (context, rAnimated, __) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: _PfdPainter(
                    compact: compact,
                    pitchDeg: pAnimated,
                    rollDeg: rAnimated,
                    headingDeg: headingDeg,
                    satCount: satCount,
                    armed: armed,
                    flightMode: flightMode,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PfdPainter extends CustomPainter {
  _PfdPainter({
    required this.compact,
    required this.pitchDeg,
    required this.rollDeg,
    required this.headingDeg,
    required this.satCount,
    required this.armed,
    required this.flightMode,
  });

  final bool compact;
  final double pitchDeg;
  final double rollDeg;
  final double headingDeg;
  final int satCount;
  final bool armed;
  final String flightMode;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final frame = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12));
    canvas.drawRRect(
      frame,
      Paint()
        ..color = const Color(0xFF101A27)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..color = GcsColors.border
        ..style = PaintingStyle.stroke,
    );

    final clip = Path()..addRRect(frame);
    canvas.save();
    canvas.clipPath(clip);

    // top heading strip
    final headingBand = Rect.fromLTWH(0, 0, w, compact ? 16 : 18);
    canvas.drawRect(headingBand, Paint()..color = const Color(0xFF324257));
    final hdgPxStep = w / 8;
    for (int i = 0; i <= 8; i++) {
      final x = i * hdgPxStep;
      final len = i % 2 == 0 ? 6.0 : 3.5;
      canvas.drawLine(
        Offset(x, headingBand.bottom),
        Offset(x, headingBand.bottom - len),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..strokeWidth = 1,
      );
    }
    _drawText(
      canvas,
      text: 'W     ${headingDeg.toStringAsFixed(0)}     N',
      at: Offset(cx, headingBand.center.dy),
      color: const Color(0xFFE6EDF3),
      size: compact ? 7 : 8,
      alignCenter: true,
      bold: true,
    );

    // horizon block
    final horizonTop = headingBand.bottom + 2;
    final horizonRect = Rect.fromLTWH(0, horizonTop, w, h - horizonTop);

    final pitchPx = (pitchDeg * 1.55).clamp(-14.0, 14.0);
    canvas.save();
    canvas.translate(cx, horizonRect.center.dy + pitchPx);
    canvas.rotate(rollDeg * math.pi / 180.0);

    canvas.drawRect(
      Rect.fromLTWH(-w * 1.2, -h * 1.2, w * 2.4, h * 1.2),
      Paint()..color = const Color(0xFF6EC5FF),
    );
    canvas.drawRect(
      Rect.fromLTWH(-w * 1.2, 0, w * 2.4, h * 1.2),
      Paint()..color = const Color(0xFF8A6A34),
    );

    // pitch ladder
    final ladderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..strokeWidth = 1.0;
    for (final p in <double>[-20, -10, 10, 20]) {
      final y = -p * 0.95;
      canvas.drawLine(Offset(-22, y), Offset(22, y), ladderPaint);
    }

    canvas.restore();

    // center roll arc + marks
    final arcRect = Rect.fromCenter(center: Offset(cx, cy - 8), width: 84, height: 52);
    canvas.drawArc(
      arcRect,
      math.pi * 1.08,
      math.pi * 0.84,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    _drawText(
      canvas,
      text: '-30  -20  -10   0   10  20  30',
      at: Offset(cx, cy - 31),
      color: Colors.white.withValues(alpha: 0.78),
      size: 6.5,
      alignCenter: true,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - 31)
        ..lineTo(cx - 3, cy - 25)
        ..lineTo(cx + 3, cy - 25)
        ..close(),
      Paint()..color = const Color(0xFFFFA000),
    );

    // center aircraft cue
    final wing = Paint()
      ..color = const Color(0xFFD92B2B)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 14, cy + 9), Offset(cx, cy + 2), wing);
    canvas.drawLine(Offset(cx + 14, cy + 9), Offset(cx, cy + 2), wing);
    canvas.drawLine(Offset(cx, cy + 2), Offset(cx, cy + 18), wing);

    _drawText(
      canvas,
      text: armed ? flightMode : 'DISARMED',
      at: Offset(cx, cy - 5),
      color: armed ? const Color(0xFF79FF57) : const Color(0xFFFF3B3B),
      size: compact ? 10 : 11,
      bold: true,
      alignCenter: true,
    );

    // center horizon guide
    canvas.drawLine(
      Offset(cx - 18, cy + 2),
      Offset(cx + 18, cy + 2),
      Paint()
        ..color = const Color(0xFF6F00CC)
        ..strokeWidth = 1.4,
    );
    _drawText(
      canvas,
      text: pitchDeg >= 0 ? '+${pitchDeg.toStringAsFixed(0)}' : pitchDeg.toStringAsFixed(0),
      at: Offset(cx + 25, cy + 2),
      color: Colors.white.withValues(alpha: 0.85),
      size: 7,
    );

    _drawText(
      canvas,
      text: satCount >= 8 ? 'Stabilize' : 'No Fix',
      at: Offset(w - 8, h - 8),
      color: Colors.white.withValues(alpha: 0.82),
      size: compact ? 7 : 8,
      bold: false,
      alignRight: true,
    );

    canvas.restore();
  }

  static void _drawText(
    Canvas canvas, {
    required String text,
    required Offset at,
    required Color color,
    required double size,
    bool alignCenter = false,
    bool alignRight = false,
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignCenter
        ? at.dx - (tp.width / 2)
        : alignRight
            ? at.dx - tp.width
            : at.dx;
    tp.paint(canvas, Offset(dx, at.dy - (tp.height / 2)));
  }

  @override
  bool shouldRepaint(covariant _PfdPainter oldDelegate) =>
      oldDelegate.pitchDeg != pitchDeg ||
      oldDelegate.rollDeg != rollDeg ||
      oldDelegate.headingDeg != headingDeg ||
      oldDelegate.satCount != satCount ||
      oldDelegate.armed != armed ||
      oldDelegate.flightMode != flightMode ||
      oldDelegate.compact != compact;
}

class _AltStubPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = GcsColors.accentPrimary.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const pad = 12.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    final r = Rect.fromLTWH(pad, pad + 12, w, h - 12);
    canvas.drawLine(Offset(pad, r.bottom), Offset(r.right, r.bottom), p..color = GcsColors.textMuted);
    var x = r.left;
    var y = r.bottom - 8.0;
    final path = Path()..moveTo(x, y);
    for (var i = 0; i < 12; i++) {
      x += w / 12;
      y = r.bottom - (8 + (i % 4) * 6.0).clamp(4, 32);
      path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = GcsColors.accentPrimary
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
