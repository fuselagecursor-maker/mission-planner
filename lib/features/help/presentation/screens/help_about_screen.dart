import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';

/// Wireframe help hub: shortcuts, external links (placeholders), build info.
class HelpAboutScreen extends StatelessWidget {
  const HelpAboutScreen({super.key});

  static const _appVersion = '0.1.0+1';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & About'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.airplanemode_active, size: 40, color: scheme.primary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Drone GCS — Mission Planner',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Wireframe build for UI flows and SRS alignment. '
                      'No live vehicle or cloud connection.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Version $_appVersion',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SectionHeader(title: 'Quick tips'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                _TipTile(
                  icon: Icons.map_outlined,
                  title: 'Map is the fly workspace',
                  subtitle: 'Layers, HUD, and mission controls are grouped around the map.',
                ),
                _TipTile(
                  icon: Icons.flag_outlined,
                  title: 'Plan in Missions',
                  subtitle: 'Search, filter by status, and sort the mission list.',
                ),
                _TipTile(
                  icon: Icons.menu_open_outlined,
                  title: 'Drawer for tools',
                  subtitle: 'Manual control, telemetry, airspace, replay, and more.',
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Shortcuts'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.keyboard_outlined),
                    title: const Text('Keyboard shortcuts'),
                    subtitle: const Text('Not wired in wireframe — future: search, arm, map zoom.'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Shortcut editor (placeholder)')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Resources'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.menu_book_outlined, color: scheme.primary),
                    title: const Text('Operator documentation'),
                    trailing: const Icon(Icons.open_in_new, size: 20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Open docs URL (placeholder)')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.bug_report_outlined, color: scheme.primary),
                    title: const Text('Report an issue'),
                    trailing: const Icon(Icons.open_in_new, size: 20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Issue tracker (placeholder)')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'SRS'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'UI structure follows Drone GCS SRS v3.0 concepts (navigation drawer, '
              'map-centric HUD, mission lifecycle). Replace dummy data with real '
              'services when integrating.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  const _TipTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: scheme.primary),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}
