import 'package:flutter/material.dart';

import '../core/theme/gcs_tokens.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      r'[12:01:22] INFO  heartbeat OK · FC v4.x',
      r'[12:01:22] OK    prearm: gyro warmed',
      r'[12:01:23] WARN  geofence: 120 m margin',
      r'[12:01:25] INFO  mission: 6 waypoints loaded',
      r'[12:01:28] INFO  link: RSSI 92%',
    ];

    return _TacticalPageScaffold(
      title: 'Logs',
      child: Container(
        decoration: BoxDecoration(
          color: GcsColors.bgMain,
          borderRadius: BorderRadius.circular(GcsLayout.radius),
          border: Border.all(color: GcsColors.border),
        ),
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: lines.length,
          itemBuilder: (context, i) => Text(
            lines[i],
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.35,
              color: GcsColors.accentSuccess,
            ),
          ),
        ),
      ),
    );
  }
}

class _TacticalPageScaffold extends StatelessWidget {
  const _TacticalPageScaffold({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GcsColors.bgMain.withValues(alpha: 0.96),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: GcsColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

