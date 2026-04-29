import 'package:flutter/material.dart';

import '../core/settings/app_settings_controller.dart';
import '../core/theme/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final settings = SettingsScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    return _TacticalPageScaffold(
      title: 'Settings',
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Text(
              'Appearance',
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            _ToggleTile(
              title: 'Dark mode',
              subtitle: 'Tactical UI (recommended)',
              value: theme.mode != ThemeMode.light,
              onChanged: (v) => theme.setMode(v ? ThemeMode.dark : ThemeMode.light),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            _ToggleTile(
              title: 'Use phone GPS',
              subtitle: 'When ON: use mobile location. When OFF: use vehicle/drone GPS.',
              value: settings.usePhoneGps,
              onChanged: (v) => settings.setUsePhoneGps(v),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            const SizedBox(height: 8),
            Text(
              'System',
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            ListTile(
              title: Text('Connection', style: TextStyle(color: scheme.onSurface)),
              subtitle: Text(
                'Simulated link (demo)',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              leading: Icon(Icons.link, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: TextStyle(color: scheme.onSurface)),
      subtitle: Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surface.withValues(alpha: 0.96),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
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

