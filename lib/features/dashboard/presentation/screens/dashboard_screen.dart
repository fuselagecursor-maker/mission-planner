import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/placeholder_card.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/skeletons/skeleton_list_tile.dart';
import '../../../mission/data/dummy_mission_repository.dart';
import '../../../mission/domain/models/mission.dart';
import '../../../shell/shell_tabs.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onNavigateToTab,
  });

  /// Switches the root [AppShell] bottom tab (see [ShellTabs]).
  final void Function(int tabIndex) onNavigateToTab;

  void _openMissionWizard(BuildContext context) {
    onNavigateToTab(ShellTabs.missions);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.of(context).pushNamed(AppRoutes.missionWizard);
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = DummyMissionRepository();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.alertsInbox);
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            child: GlassCard(
              borderRadius: 26,
              opacity: 0.58,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mission Control',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Plan missions, monitor status, and launch workflows from a single control surface.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            GradientButton(
                              label: 'New Mission',
                              icon: Icons.add_rounded,
                              compact: true,
                              onPressed: () => _openMissionWizard(context),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.alertsInbox),
                              icon: const Icon(Icons.notifications_outlined),
                              label: const Text('Alerts'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Container(
                    width: 140,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.neonCyan.withValues(alpha: 0.18),
                          AppColors.softPurple.withValues(alpha: 0.14),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(Icons.flight_takeoff_rounded, color: scheme.onSurface, size: 44),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Overview'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _OverviewGrid(
              repo: repo,
              onOpenAlerts: () {
                Navigator.of(context).pushNamed(AppRoutes.alertsInbox);
              },
            ),
          ),
          const SectionHeader(title: 'Quick actions'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                PlaceholderCard(
                  title: 'Create Mission',
                  subtitle: 'Start a new mission planning flow',
                  icon: Icons.add_circle_outline,
                  onTap: () => _openMissionWizard(context),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const SizedBox(height: AppSpacing.md),
                PlaceholderCard(
                  title: 'View Map',
                  subtitle: 'Open navigation and waypoints',
                  icon: Icons.map_outlined,
                  onTap: () => onNavigateToTab(ShellTabs.map),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const SizedBox(height: AppSpacing.md),
                PlaceholderCard(
                  title: 'Vehicle & preflight',
                  subtitle: 'Sensors, RC, battery, safety checklist (wireframe)',
                  icon: Icons.fact_check_outlined,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.vehicleSetup),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const SizedBox(height: AppSpacing.md),
                PlaceholderCard(
                  title: 'Assign Tasks',
                  subtitle: 'Allocate tasks to operators',
                  icon: Icons.assignment_outlined,
                  onTap: () => onNavigateToTab(ShellTabs.tasks),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Recent missions'),
          FutureBuilder<List<Mission>>(
            future: repo.listMissions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Column(
                  children: [
                    SkeletonListTile(),
                    SkeletonListTile(),
                    SkeletonListTile(),
                  ],
                );
              }

              final missions = snapshot.data ?? const <Mission>[];
              if (missions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Text('No missions yet (placeholder).'),
                );
              }

              return Column(
                children: [
                  for (final m in missions.take(5))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
                      child: PlaceholderCard(
                        title: m.name,
                        subtitle: m.description,
                        icon: Icons.flag_outlined,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.missionDetails,
                            arguments: m.id,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({
    required this.repo,
    required this.onOpenAlerts,
  });

  final DummyMissionRepository repo;
  final VoidCallback onOpenAlerts;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Mission>>(
      future: repo.listMissions(),
      builder: (context, snapshot) {
        final missions = snapshot.data ?? const <Mission>[];
        final active = missions.where((m) => m.status == MissionStatus.active).length;
        final completed =
            missions.where((m) => m.status == MissionStatus.completed).length;
        const alerts = 2; // Placeholder.

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: PlaceholderCard(
                    title: 'Active Missions',
                    subtitle: snapshot.connectionState == ConnectionState.done
                        ? '$active'
                        : '…',
                    icon: Icons.play_circle_outline,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PlaceholderCard(
                    title: 'Completed',
                    subtitle: snapshot.connectionState == ConnectionState.done
                        ? '$completed'
                        : '…',
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            PlaceholderCard(
              title: 'Alerts',
              subtitle: snapshot.connectionState == ConnectionState.done ? '$alerts' : '…',
              icon: Icons.warning_amber_outlined,
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenAlerts,
            ),
          ],
        );
      },
    );
  }
}

