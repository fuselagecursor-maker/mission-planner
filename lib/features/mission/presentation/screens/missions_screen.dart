import 'package:flutter/material.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/placeholder_card.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/skeletons/skeleton_list_tile.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../data/dummy_mission_repository.dart';
import '../../domain/models/mission.dart';
import '../widgets/mission_planning_form.dart';
import '../widgets/mission_storage_dialogs.dart';
import '../widgets/waypoints_placeholder.dart';

enum _MissionSort {
  nameAsc,
  nameDesc,
  startNewest,
  startOldest,
  status,
}

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  final _repo = DummyMissionRepository();
  late final Future<List<Mission>> _missionsFuture;

  final _searchController = TextEditingController();
  String _query = '';
  MissionStatus? _statusFilter;
  _MissionSort _sort = _MissionSort.nameAsc;

  @override
  void initState() {
    super.initState();
    _missionsFuture = _repo.listMissions();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Mission> _applyFiltersAndSort(List<Mission> missions) {
    var list = List<Mission>.from(missions);

    if (_statusFilter != null) {
      list = list.where((m) => m.status == _statusFilter).toList();
    }

    if (_query.isNotEmpty) {
      list = list
          .where(
            (m) =>
                m.name.toLowerCase().contains(_query) ||
                m.description.toLowerCase().contains(_query),
          )
          .toList();
    }

    int statusOrder(MissionStatus s) => switch (s) {
          MissionStatus.draft => 0,
          MissionStatus.active => 1,
          MissionStatus.completed => 2,
        };

    switch (_sort) {
      case _MissionSort.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case _MissionSort.nameDesc:
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case _MissionSort.startNewest:
        list.sort((a, b) => b.startDate.compareTo(a.startDate));
      case _MissionSort.startOldest:
        list.sort((a, b) => a.startDate.compareTo(b.startDate));
      case _MissionSort.status:
        list.sort((a, b) {
          final c = statusOrder(a.status).compareTo(statusOrder(b.status));
          return c != 0 ? c : a.name.compareTo(b.name);
        });
    }

    return list;
  }

  String _sortLabel(_MissionSort s) => switch (s) {
        _MissionSort.nameAsc => 'Name (A–Z)',
        _MissionSort.nameDesc => 'Name (Z–A)',
        _MissionSort.startNewest => 'Start date (newest)',
        _MissionSort.startOldest => 'Start date (oldest)',
        _MissionSort.status => 'Status',
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missions'),
        actions: [
          IconButton(
            onPressed: () => showLoadMissionDialog(context),
            icon: const Icon(Icons.folder_open_outlined),
            tooltip: 'Load',
          ),
          IconButton(
            onPressed: () => showSaveMissionDialog(context),
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
          ),
          PopupMenuButton<_MissionSort>(
            tooltip: 'Sort missions',
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (context) => [
              for (final option in _MissionSort.values)
                CheckedPopupMenuItem(
                  value: option,
                  checked: _sort == option,
                  child: Text(_sortLabel(option)),
                ),
            ],
            icon: const Icon(Icons.sort_outlined),
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
                          'Missions',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Create, filter, and manage mission plans.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  GradientButton(
                    label: 'Wizard',
                    icon: Icons.auto_fix_high_outlined,
                    compact: true,
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.missionWizard),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Mission planning'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: const [
                MissionPlanningForm(),
                SizedBox(height: AppSpacing.md),
                WaypointsPlaceholder(),
              ],
            ),
          ),
          const SectionHeader(title: 'Mission list'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  borderRadius: 22,
                  opacity: 0.55,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search by name or description',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      isDense: true,
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              onPressed: () {
                                _searchController.clear();
                              },
                              icon: const Icon(Icons.clear),
                            ),
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
                        selected: _statusFilter == null,
                        onSelected: (_) => setState(() => _statusFilter = null),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterChip(
                        label: const Text('Draft'),
                        selected: _statusFilter == MissionStatus.draft,
                        onSelected: (_) => setState(
                          () => _statusFilter = _statusFilter == MissionStatus.draft
                              ? null
                              : MissionStatus.draft,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterChip(
                        label: const Text('Active'),
                        selected: _statusFilter == MissionStatus.active,
                        onSelected: (_) => setState(
                          () => _statusFilter = _statusFilter == MissionStatus.active
                              ? null
                              : MissionStatus.active,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterChip(
                        label: const Text('Completed'),
                        selected: _statusFilter == MissionStatus.completed,
                        onSelected: (_) => setState(
                          () => _statusFilter =
                              _statusFilter == MissionStatus.completed
                                  ? null
                                  : MissionStatus.completed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort: ${_sortLabel(_sort)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<List<Mission>>(
            future: _missionsFuture,
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

              final missions = _applyFiltersAndSort(snapshot.data ?? const <Mission>[]);

              if (missions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'No missions match your search or filters.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                );
              }

              return Column(
                children: [
                  for (final m in missions)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: PlaceholderCard(
                        title: m.name,
                        subtitle: m.description,
                        icon: Icons.flag_outlined,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusPill(
                              label: _statusLabel(m.status),
                              color: _statusColor(scheme, m.status),
                              leading: switch (m.status) {
                                MissionStatus.draft => Icons.edit_note_outlined,
                                MissionStatus.active => Icons.play_circle_outline,
                                MissionStatus.completed => Icons.check_circle_outline,
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            IconButton(
                              tooltip: 'Edit (Plan)',
                              onPressed: () => Navigator.of(context).pushNamed(
                                AppRoutes.missionEditor,
                                arguments: m.id,
                              ),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.missionDetails,
                            arguments: m.id,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

String _statusLabel(MissionStatus s) => switch (s) {
      MissionStatus.draft => 'Draft',
      MissionStatus.active => 'Active',
      MissionStatus.completed => 'Done',
    };

Color _statusColor(ColorScheme scheme, MissionStatus s) => switch (s) {
      MissionStatus.draft => scheme.outline,
      MissionStatus.active => AppColors.neonCyan,
      MissionStatus.completed => AppColors.success,
    };
