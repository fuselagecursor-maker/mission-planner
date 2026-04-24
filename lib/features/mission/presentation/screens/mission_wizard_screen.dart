import 'package:flutter/material.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../domain/models/mission.dart';

/// SRS §7.1.3: Mission creation wizard (full-screen stepper dialog).
///
/// UI-only wireframe:
/// - No persistence
/// - No backend calls
/// - Emits a placeholder "Create" action
class MissionWizardScreen extends StatefulWidget {
  const MissionWizardScreen({super.key});

  @override
  State<MissionWizardScreen> createState() => _MissionWizardScreenState();
}

class _MissionWizardScreenState extends State<MissionWizardScreen> {
  int _step = 0;

  final _name = TextEditingController();
  final _desc = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  MissionPriority _priority = MissionPriority.medium;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _start : _end) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end != null && _end!.isBefore(picked)) _end = null;
      } else {
        _end = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Wizard'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _step,
        onStepTapped: (i) => setState(() => _step = i),
        controlsBuilder: (context, details) {
          final isLast = _step == 3;
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Row(
              children: [
                FilledButton(
                  onPressed: isLast
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Create Mission (placeholder)')),
                          );
                          Navigator.of(context).pushReplacementNamed(AppRoutes.missionEditor);
                        }
                      : details.onStepContinue,
                  child: Text(isLast ? 'Create' : 'Next'),
                ),
                const SizedBox(width: AppSpacing.md),
                OutlinedButton(
                  onPressed: _step == 0 ? null : details.onStepCancel,
                  child: const Text('Back'),
                ),
                const Spacer(),
                StatusPill(
                  label: 'Step ${_step + 1}/4',
                  color: scheme.outline,
                ),
              ],
            ),
          );
        },
        onStepContinue: () {
          if (_step < 3) setState(() => _step += 1);
        },
        onStepCancel: () {
          if (_step > 0) setState(() => _step -= 1);
        },
        steps: [
          Step(
            title: const Text('Basics'),
            isActive: _step >= 0,
            content: Column(
              children: [
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Mission Name',
                    hintText: 'e.g., Recon Alpha',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _desc,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Objective and constraints',
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Schedule & priority'),
            isActive: _step >= 1,
            content: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'Start Date',
                        value: _start,
                        onTap: () => _pickDate(isStart: true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _DateField(
                        label: 'End Date',
                        value: _end,
                        onTap: () => _pickDate(isStart: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<MissionPriority>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: MissionPriority.values
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(_priorityLabel(p)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _priority = v ?? _priority),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Waypoints'),
            isActive: _step >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add / reorder / configure waypoints (placeholder).'),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: const Text('Waypoint 1'),
                        subtitle: const Text('Lat: --, Lng: --, Alt: --'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Open waypoint editor (placeholder)')),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: const Text('Waypoint 2'),
                        subtitle: const Text('Lat: --, Lng: --, Alt: --'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add waypoint'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.auto_fix_high_outlined),
                      label: const Text('Survey grid (placeholder)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Review'),
            isActive: _step >= 3,
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name.text.isEmpty ? '(Mission Name)' : _name.text,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(_desc.text.isEmpty ? '(Description)' : _desc.text),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        StatusPill(
                          label: 'Priority: ${_priorityLabel(_priority)}',
                          color: scheme.primary,
                        ),
                        StatusPill(
                          label: 'Start: ${_date(_start)}',
                          color: scheme.outline,
                        ),
                        StatusPill(
                          label: 'End: ${_date(_end)}',
                          color: scheme.outline,
                        ),
                        StatusPill(
                          label: 'Waypoints: 2 (placeholder)',
                          color: scheme.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Future: validate mission, run airspace compliance check, '
                      'compute power feasibility, and persist locally.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Select'
        : '${value!.year.toString().padLeft(4, '0')}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            Expanded(child: Text(text)),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.calendar_month_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}

String _date(DateTime? d) {
  if (d == null) return '--';
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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

