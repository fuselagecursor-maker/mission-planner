import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../../../shared/widgets/skeletons/skeleton_list_tile.dart';
import '../../data/dummy_tasks_repository.dart';
import '../../domain/models/agent.dart';
import '../../domain/models/mission_task.dart';

enum _TaskSort {
  titleAsc,
  titleDesc,
  missionId,
  status,
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _repo = DummyTasksRepository();
  late final Future<List<Agent>> _agentsFuture;
  late final Future<List<MissionTask>> _tasksFuture;

  final _agentSearchController = TextEditingController();
  final _taskSearchController = TextEditingController();
  String _agentQuery = '';
  String _taskQuery = '';
  AgentStatus? _agentStatusFilter;
  TaskStatus? _taskStatusFilter;
  _TaskSort _taskSort = _TaskSort.titleAsc;

  @override
  void initState() {
    super.initState();
    _agentsFuture = _repo.listAgents();
    _tasksFuture = _repo.listTasks();
    _agentSearchController.addListener(() {
      setState(() => _agentQuery = _agentSearchController.text.trim().toLowerCase());
    });
    _taskSearchController.addListener(() {
      setState(() => _taskQuery = _taskSearchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _agentSearchController.dispose();
    _taskSearchController.dispose();
    super.dispose();
  }

  String _taskSortLabel(_TaskSort s) => switch (s) {
        _TaskSort.titleAsc => 'Title (A–Z)',
        _TaskSort.titleDesc => 'Title (Z–A)',
        _TaskSort.missionId => 'Mission ID',
        _TaskSort.status => 'Status',
      };

  int _taskStatusOrder(TaskStatus s) => switch (s) {
        TaskStatus.pending => 0,
        TaskStatus.active => 1,
        TaskStatus.completed => 2,
      };

  List<Agent> _filterAgents(List<Agent> agents) {
    var list = List<Agent>.from(agents);
    if (_agentStatusFilter != null) {
      list = list.where((a) => a.status == _agentStatusFilter).toList();
    }
    if (_agentQuery.isNotEmpty) {
      list = list
          .where(
            (a) =>
                a.name.toLowerCase().contains(_agentQuery) ||
                a.role.toLowerCase().contains(_agentQuery),
          )
          .toList();
    }
    return list;
  }

  List<MissionTask> _filterAndSortTasks(List<MissionTask> tasks) {
    var list = List<MissionTask>.from(tasks);
    if (_taskStatusFilter != null) {
      list = list.where((t) => t.status == _taskStatusFilter).toList();
    }
    if (_taskQuery.isNotEmpty) {
      list = list
          .where(
            (t) =>
                t.title.toLowerCase().contains(_taskQuery) ||
                t.missionId.toLowerCase().contains(_taskQuery) ||
                t.assigneeId.toLowerCase().contains(_taskQuery),
          )
          .toList();
    }

    switch (_taskSort) {
      case _TaskSort.titleAsc:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case _TaskSort.titleDesc:
        list.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
      case _TaskSort.missionId:
        list.sort((a, b) {
          final c = a.missionId.compareTo(b.missionId);
          return c != 0 ? c : a.title.compareTo(b.title);
        });
      case _TaskSort.status:
        list.sort((a, b) {
          final c = _taskStatusOrder(a.status).compareTo(_taskStatusOrder(b.status));
          return c != 0 ? c : a.title.compareTo(b.title);
        });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton<_TaskSort>(
            tooltip: 'Sort tasks',
            initialValue: _taskSort,
            onSelected: (v) => setState(() => _taskSort = v),
            itemBuilder: (context) => [
              for (final option in _TaskSort.values)
                CheckedPopupMenuItem(
                  value: option,
                  checked: _taskSort == option,
                  child: Text(_taskSortLabel(option)),
                ),
            ],
            icon: const Icon(Icons.sort_outlined),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: ListView(
        children: [
          const SectionHeader(title: 'Agents / operators'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _agentSearchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search agents by name or role',
                    prefixIcon: const Icon(Icons.person_search_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                    suffixIcon: _agentQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear',
                            onPressed: () => _agentSearchController.clear(),
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _agentStatusFilter == null,
                        onSelected: (_) => setState(() => _agentStatusFilter = null),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterChip(
                        label: const Text('Available'),
                        selected: _agentStatusFilter == AgentStatus.available,
                        onSelected: (_) => setState(
                          () => _agentStatusFilter =
                              _agentStatusFilter == AgentStatus.available
                                  ? null
                                  : AgentStatus.available,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterChip(
                        label: const Text('Busy'),
                        selected: _agentStatusFilter == AgentStatus.busy,
                        onSelected: (_) => setState(
                          () => _agentStatusFilter =
                              _agentStatusFilter == AgentStatus.busy ? null : AgentStatus.busy,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterChip(
                        label: const Text('Offline'),
                        selected: _agentStatusFilter == AgentStatus.offline,
                        onSelected: (_) => setState(
                          () => _agentStatusFilter =
                              _agentStatusFilter == AgentStatus.offline
                                  ? null
                                  : AgentStatus.offline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<List<Agent>>(
            future: _agentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Column(
                  children: [
                    SkeletonListTile(),
                    SkeletonListTile(),
                  ],
                );
              }
              final agents = _filterAgents(snapshot.data ?? const <Agent>[]);
              if (agents.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    'No agents match your search or filters.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Card(
                  child: Column(
                    children: [
                      for (final a in agents)
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(a.name),
                          subtitle: Text(a.role),
                          trailing: StatusPill(
                            label: _agentStatusLabel(a.status),
                            color: _agentStatusColor(context, a.status),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Open ${a.name} (placeholder)')),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SectionHeader(title: 'Assign tasks (placeholder)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assignment panel',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Future: select mission → select agent → select tasks → dispatch to backend.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.flag_outlined),
                            label: const Text('Pick mission'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.person_outline),
                            label: const Text('Pick agent'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Assign tasks (placeholder)')),
                          );
                        },
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Assign'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SectionHeader(title: 'Task list'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _taskSearchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by title, mission ID, or assignee',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                    suffixIcon: _taskQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear',
                            onPressed: () => _taskSearchController.clear(),
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _taskStatusFilter == null,
                        onSelected: (_) => setState(() => _taskStatusFilter = null),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterChip(
                        label: const Text('Pending'),
                        selected: _taskStatusFilter == TaskStatus.pending,
                        onSelected: (_) => setState(
                          () => _taskStatusFilter =
                              _taskStatusFilter == TaskStatus.pending
                                  ? null
                                  : TaskStatus.pending,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterChip(
                        label: const Text('Active'),
                        selected: _taskStatusFilter == TaskStatus.active,
                        onSelected: (_) => setState(
                          () => _taskStatusFilter =
                              _taskStatusFilter == TaskStatus.active ? null : TaskStatus.active,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterChip(
                        label: const Text('Completed'),
                        selected: _taskStatusFilter == TaskStatus.completed,
                        onSelected: (_) => setState(
                          () => _taskStatusFilter =
                              _taskStatusFilter == TaskStatus.completed
                                  ? null
                                  : TaskStatus.completed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort: ${_taskSortLabel(_taskSort)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<List<MissionTask>>(
            future: _tasksFuture,
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
              final tasks = _filterAndSortTasks(snapshot.data ?? const <MissionTask>[]);
              if (tasks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'No tasks match your search or filters.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Card(
                  child: Column(
                    children: [
                      for (final t in tasks)
                        ListTile(
                          leading: const Icon(Icons.checklist_outlined),
                          title: Text(t.title),
                          subtitle: Text('Mission: ${t.missionId} • Assignee: ${t.assigneeId}'),
                          trailing: StatusPill(
                            label: _taskStatusLabel(t.status),
                            color: _taskStatusColor(context, t.status),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
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
