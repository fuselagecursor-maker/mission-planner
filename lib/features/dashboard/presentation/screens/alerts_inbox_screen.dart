import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';

/// Wireframe alerts / notification center (dummy rows).
class AlertsInboxScreen extends StatelessWidget {
  const AlertsInboxScreen({super.key});

  static const _items = <_AlertItem>[
    _AlertItem(
      title: 'Geofence proximity',
      subtitle: 'Vehicle V1 within 50 m of boundary',
      icon: Icons.fence_outlined,
      severity: _Severity.warning,
    ),
    _AlertItem(
      title: 'Battery estimate',
      subtitle: 'Mission leg 3 may exceed 25% reserve',
      icon: Icons.battery_alert_outlined,
      severity: _Severity.warning,
    ),
    _AlertItem(
      title: 'Link quality',
      subtitle: 'Telemetry RSSI dropped briefly (recovered)',
      icon: Icons.signal_cellular_alt_outlined,
      severity: _Severity.info,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mark all read (placeholder)')),
              );
            },
            child: const Text('Clear all'),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SectionHeader(title: 'Today'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                for (final item in _items)
                  Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      subtitle: Text(item.subtitle),
                      trailing: _SeverityDot(severity: item.severity),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Open: ${item.title} (placeholder)')),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertItem {
  const _AlertItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.severity,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _Severity severity;
}

enum _Severity { info, warning }

class _SeverityDot extends StatelessWidget {
  const _SeverityDot({required this.severity});

  final _Severity severity;

  @override
  Widget build(BuildContext context) {
    final color = switch (severity) {
      _Severity.info => Colors.blue,
      _Severity.warning => Colors.orange,
    };
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
