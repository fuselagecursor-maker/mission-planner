import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';

/// SRS FR-23-04 wireframe.
///
/// Future:
/// - Drive from autopilot-provided mode set and metadata.
/// - Add contextual tooltips in mode selector.
class FlightModeReferenceScreen extends StatelessWidget {
  const FlightModeReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flight Mode Reference')),
      body: ListView(
        children: [
          const SectionHeader(title: 'Modes'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Column(
                children: const [
                  _ModeTile(
                    icon: Icons.route_outlined,
                    name: 'AUTO',
                    desc:
                        'Executes the planned mission autonomously. Use for waypoint missions.',
                  ),
                  Divider(height: 1),
                  _ModeTile(
                    icon: Icons.adjust_outlined,
                    name: 'LOITER',
                    desc:
                        'Holds position with a loiter radius. Use for stabilised hover and observation.',
                  ),
                  Divider(height: 1),
                  _ModeTile(
                    icon: Icons.home_outlined,
                    name: 'RTH',
                    desc:
                        'Returns to the home position automatically. Use during low battery or link loss.',
                  ),
                  Divider(height: 1),
                  _ModeTile(
                    icon: Icons.flight_land_outlined,
                    name: 'LAND',
                    desc: 'Initiates landing sequence. Use for controlled descent and touchdown.',
                  ),
                  Divider(height: 1),
                  _ModeTile(
                    icon: Icons.gamepad_outlined,
                    name: 'MANUAL',
                    desc:
                        'Direct operator control. Use for fine manoeuvres and recovery situations.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.name,
    required this.desc,
  });

  final IconData icon;
  final String name;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      subtitle: Text(desc),
    );
  }
}

