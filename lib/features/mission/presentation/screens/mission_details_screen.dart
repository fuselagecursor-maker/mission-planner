import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../../../shared/widgets/skeletons/skeleton_box.dart';
import '../../../tasks/data/dummy_tasks_repository.dart';
import '../../../tasks/domain/models/agent.dart';
import '../../../tasks/domain/models/mission_task.dart';
import '../../data/dummy_mission_repository.dart';
import '../../domain/models/mission.dart';

class MissionDetailsScreen extends StatelessWidget {
  const MissionDetailsScreen({super.key, required this.missionId});

  final String? missionId;

  @override
  Widget build(BuildContext context) {
    final missionRepo = DummyMissionRepository();
    final tasksRepo = DummyTasksRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Details'),
      ),
      body: FutureBuilder<Mission?>(
        future: missionId == null ? null : missionRepo.getMissionById(missionId!),
        builder: (context, snapshot) {
          if (missionId == null) {
            return const Center(child: Text('Missing mission id.'));
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const _DetailsSkeleton();
          }

          final mission = snapshot.data;
          if (mission == null) {
            return const Center(child: Text('Mission not found (placeholder).'));
          }

          return ListView(
            children: [
              const SectionHeader(title: 'Summary'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                mission.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            StatusPill(
                              label: _statusLabel(mission.status),
                              color: _statusColor(context, mission.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(mission.description),
                        const SizedBox(height: AppSpacing.lg),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            StatusPill(
                              label: 'Priority: ${_priorityLabel(mission.priority)}',
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            StatusPill(
                              label: 'Start: ${_date(mission.startDate)}',
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            StatusPill(
                              label: 'End: ${_date(mission.endDate)}',
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SectionHeader(title: 'Timeline / steps'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Card(
                  child: Stepper(
                    physics: const NeverScrollableScrollPhysics(),
                    currentStep: 1,
                    controlsBuilder: (context, details) => const SizedBox.shrink(),
                    steps: const [
                      Step(
                        title: Text('Draft'),
                        content: Text('Define mission parameters and constraints.'),
                        isActive: true,
                      ),
                      Step(
                        title: Text('Active'),
                        content: Text('Execute mission plan and track progress.'),
                        isActive: true,
                      ),
                      Step(
                        title: Text('Complete'),
                        content: Text('Close out mission, archive logs and results.'),
                        isActive: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SectionHeader(title: 'Assigned agents'),
              FutureBuilder<List<Agent>>(
                future: tasksRepo.listAgents(),
                builder: (context, aSnap) {
                  if (aSnap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: SkeletonBox(height: 72),
                        ),
                      ),
                    );
                  }
                  final agents = aSnap.data ?? const <Agent>[];
                  final assigned = agents.take(3).toList(); // Placeholder selection.
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Card(
                      child: Column(
                        children: [
                          for (final a in assigned)
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(a.name),
                              subtitle: Text(a.role),
                              trailing: StatusPill(
                                label: _agentStatusLabel(a.status),
                                color: _agentStatusColor(context, a.status),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SectionHeader(title: 'Tasks & logs'),
              FutureBuilder<List<MissionTask>>(
                future: tasksRepo.listTasks(missionId: mission.id),
                builder: (context, tSnap) {
                  if (tSnap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: SkeletonBox(height: 120),
                        ),
                      ),
                    );
                  }
                  final tasks = tSnap.data ?? const <MissionTask>[];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Card(
                      child: Column(
                        children: [
                          for (final t in tasks)
                            ListTile(
                              leading: const Icon(Icons.checklist_outlined),
                              title: Text(t.title),
                              subtitle: Text('Assignee: ${t.assigneeId}'),
                              trailing: StatusPill(
                                label: _taskStatusLabel(t.status),
                                color: _taskStatusColor(context, t.status),
                              ),
                            ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.article_outlined),
                            title: const Text('Logs / Updates'),
                            subtitle: const Text('Placeholder event feed (API-backed later).'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Logs (placeholder)')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SectionHeader(title: 'Summary'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: SkeletonBox(height: 110),
            ),
          ),
        ),
        SectionHeader(title: 'Timeline / steps'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: SkeletonBox(height: 180),
            ),
          ),
        ),
      ],
    );
  }
}

String _date(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _statusLabel(MissionStatus s) {
  switch (s) {
    case MissionStatus.draft:
      return 'Draft';
    case MissionStatus.active:
      return 'Active';
    case MissionStatus.completed:
      return 'Completed';
  }
}

Color _statusColor(BuildContext context, MissionStatus s) {
  final scheme = Theme.of(context).colorScheme;
  switch (s) {
    case MissionStatus.draft:
      return scheme.outline;
    case MissionStatus.active:
      return scheme.primary;
    case MissionStatus.completed:
      return scheme.tertiary;
  }
}

String _priorityLabel(MissionPriority p) {
  switch (p) {
    case MissionPriority.low:
      return 'Low';
    case MissionPriority.medium:
      return 'Medium';
    case MissionPriority.high:
      return 'High';
    case MissionPriority.critical:
      return 'Critical';
  }
}

String _agentStatusLabel(AgentStatus s) {
  switch (s) {
    case AgentStatus.available:
      return 'Available';
    case AgentStatus.busy:
      return 'Busy';
    case AgentStatus.offline:
      return 'Offline';
  }
}

Color _agentStatusColor(BuildContext context, AgentStatus s) {
  final scheme = Theme.of(context).colorScheme;
  switch (s) {
    case AgentStatus.available:
      return scheme.tertiary;
    case AgentStatus.busy:
      return scheme.primary;
    case AgentStatus.offline:
      return scheme.outline;
  }
}

String _taskStatusLabel(TaskStatus s) {
  switch (s) {
    case TaskStatus.pending:
      return 'Pending';
    case TaskStatus.active:
      return 'Active';
    case TaskStatus.completed:
      return 'Completed';
  }
}

Color _taskStatusColor(BuildContext context, TaskStatus s) {
  final scheme = Theme.of(context).colorScheme;
  switch (s) {
    case TaskStatus.pending:
      return scheme.outline;
    case TaskStatus.active:
      return scheme.primary;
    case TaskStatus.completed:
      return scheme.tertiary;
  }
}

