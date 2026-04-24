import 'package:flutter/material.dart';

import '../core/theme/gcs_tokens.dart';
import '../core/theme/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    return _TacticalPageScaffold(
      title: 'Settings',
      child: Container(
        decoration: BoxDecoration(
          color: GcsColors.bgPanel.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(GcsLayout.radius),
          border: Border.all(color: GcsColors.border),
          boxShadow: GcsLayout.panelDepth,
        ),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text(
              'Appearance',
              style: TextStyle(
                color: GcsColors.textPrimary,
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
            const Divider(height: 1, color: GcsColors.border),
            const SizedBox(height: 8),
            const Text(
              'System',
              style: TextStyle(
                color: GcsColors.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            const ListTile(
              title: Text('Connection', style: TextStyle(color: GcsColors.textPrimary)),
              subtitle: Text('Simulated link (demo)', style: TextStyle(color: GcsColors.textSecondary)),
              leading: Icon(Icons.link, color: GcsColors.textSecondary),
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
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(color: GcsColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(color: GcsColors.textSecondary)),
      activeColor: GcsColors.accentPrimary,
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

