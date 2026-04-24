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
  });

  final List<String> logLines;
  final Widget missionRow;

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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _LogTerminal(logLines: logLines),
                ),
                const VerticalDivider(width: 1, color: GcsColors.border),
                const Expanded(
                  child: _SparklineStub(),
                ),
              ],
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
