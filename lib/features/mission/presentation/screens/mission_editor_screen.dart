import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../models/waypoint_vm.dart';
import '../widgets/mission_storage_dialogs.dart';
import '../widgets/waypoint_property_sheet.dart';

/// Mission Editor (Plan view) wireframe.
///
/// Future:
/// - Bind to mission domain model + repository.
/// - Validate with airspace/power models.
/// - Sync to map: selecting a waypoint pans/zooms to it.
class MissionEditorScreen extends StatefulWidget {
  const MissionEditorScreen({super.key, this.missionId});

  final String? missionId;

  @override
  State<MissionEditorScreen> createState() => _MissionEditorScreenState();
}

class _MissionEditorScreenState extends State<MissionEditorScreen> {
  final _name = TextEditingController(text: 'Mission (placeholder)');
  final _desc = TextEditingController(text: 'Objective / constraints (placeholder)');

  bool _airspaceViolation = true;
  bool _powerFeasible = true;

  final List<WaypointVm> _waypoints = [
    const WaypointVm(
      id: 'wp_1',
      label: 'Waypoint 1',
      lat: null,
      lng: null,
      altMeters: null,
      speedMps: null,
      action: 'Navigate',
    ),
    const WaypointVm(
      id: 'wp_2',
      label: 'Waypoint 2',
      lat: null,
      lng: null,
      altMeters: null,
      speedMps: null,
      action: 'Loiter',
    ),
    const WaypointVm(
      id: 'wp_3',
      label: 'Waypoint 3',
      lat: null,
      lng: null,
      altMeters: null,
      speedMps: null,
      action: 'Navigate',
    ),
  ];

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canExecute = !_airspaceViolation && _powerFeasible;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Editor (Plan)'),
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
        ],
      ),
      body: ListView(
        children: [
          const SectionHeader(title: 'Mission details'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Mission Name'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _desc,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SectionHeader(title: 'Validation'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        StatusPill(
                          label: _airspaceViolation ? 'Airspace: VIOLATION' : 'Airspace: CLEAR',
                          color: _airspaceViolation ? scheme.error : scheme.tertiary,
                        ),
                        StatusPill(
                          label: _powerFeasible ? 'Power: FEASIBLE' : 'Power: INSUFFICIENT',
                          color: _powerFeasible ? scheme.tertiary : scheme.error,
                        ),
                        StatusPill(
                          label: 'Waypoints: ${_waypoints.length}',
                          color: scheme.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => _airspaceViolation = !_airspaceViolation),
                            icon: const Icon(Icons.public_outlined),
                            label: const Text('Toggle airspace (demo)'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => _powerFeasible = !_powerFeasible),
                            icon: const Icon(Icons.battery_charging_full_outlined),
                            label: const Text('Toggle power (demo)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Future: this panel is driven by real airspace + power models and updates on every edit.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SectionHeader(title: 'Waypoints'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: _waypoints.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _waypoints.removeAt(oldIndex);
                    _waypoints.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, i) {
                  final w = _waypoints[i];
                  return ListTile(
                    key: ValueKey(w.id),
                    leading: ReorderableDragStartListener(
                      index: i,
                      child: const Icon(Icons.drag_indicator),
                    ),
                    title: Text(w.label),
                    subtitle: Text('Action: ${w.action} • Alt: -- • Spd: --'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          isScrollControlled: true,
                          builder: (ctx) => FractionallySizedBox(
                            heightFactor: 0.6,
                            child: WaypointPropertySheet(
                              waypointTitle: w.label,
                              onClose: () => Navigator.of(ctx).pop(),
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Focus ${w.label} on map (placeholder)')),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _waypoints.add(
                          WaypointVm(
                            id: 'wp_${_waypoints.length + 1}',
                            label: 'Waypoint ${_waypoints.length + 1}',
                            lat: null,
                            lng: null,
                            altMeters: null,
                            speedMps: null,
                            action: 'Navigate',
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add waypoint'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Survey grid generator (placeholder)')),
                      );
                    },
                    icon: const Icon(Icons.auto_fix_high_outlined),
                    label: const Text('Survey grid'),
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Execute'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fly view handoff (UI-only)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      canExecute
                          ? 'Mission is ready to execute (placeholder).'
                          : 'Resolve validation issues before executing.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: canExecute
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Switch to Map/Fly view (placeholder)'),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.flight_takeoff_outlined),
                        label: const Text('Open Fly View'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

