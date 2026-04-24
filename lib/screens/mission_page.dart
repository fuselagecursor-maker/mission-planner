import 'package:flutter/material.dart';

import '../core/routing/app_router.dart';
import '../core/theme/gcs_tokens.dart';
import '../features/mission/presentation/widgets/mission_storage_dialogs.dart';
import '../shared/widgets/buttons/gradient_button.dart';

class MissionPage extends StatelessWidget {
  const MissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _TacticalPageScaffold(
      title: 'Mission',
      actions: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            onPressed: () => showLoadMissionDialog(context),
            icon: const Icon(Icons.folder_open_outlined, size: 18),
            label: const Text('Load'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => showSaveMissionDialog(context),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
          GradientButton(
            label: 'New mission',
            icon: Icons.add,
            compact: true,
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.missionWizard),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: GcsColors.bgPanel.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(GcsLayout.radius),
          border: Border.all(color: GcsColors.border),
          boxShadow: GcsLayout.panelDepth,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Waypoint planning',
              style: TextStyle(
                color: GcsColors.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Use the Map screen: long-press to add waypoints and tap markers for actions.',
              style: TextStyle(color: GcsColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: GcsColors.bgMain,
                  borderRadius: BorderRadius.circular(GcsLayout.radius),
                  border: Border.all(color: GcsColors.border),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Mission list / editor panel (next)\n\n'
                  'This page is now a dedicated mission workflow,\n'
                  'separate from the always-on map.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: GcsColors.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TacticalPageScaffold extends StatelessWidget {
  const _TacticalPageScaffold({
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final Widget? actions;

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
              Row(
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
                  const Spacer(),
                  if (actions != null) actions!,
                ],
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

