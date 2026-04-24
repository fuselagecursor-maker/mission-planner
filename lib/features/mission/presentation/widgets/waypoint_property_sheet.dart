import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';

/// SRS: Waypoint property editor is a modal bottom sheet (~60% height).
///
/// UI-only contract:
/// - This widget only edits display fields.
/// - Later, bind these fields to a waypoint domain model + validation + map selection.
class WaypointPropertySheet extends StatefulWidget {
  const WaypointPropertySheet({
    super.key,
    required this.waypointTitle,
    required this.onClose,
  });

  final String waypointTitle;
  final VoidCallback onClose;

  @override
  State<WaypointPropertySheet> createState() => _WaypointPropertySheetState();
}

class _WaypointPropertySheetState extends State<WaypointPropertySheet> {
  final _lat = TextEditingController(text: '--');
  final _lng = TextEditingController(text: '--');
  final _alt = TextEditingController(text: '--');
  final _speed = TextEditingController(text: '--');
  final _hold = TextEditingController(text: '0');

  bool _cameraTrigger = false;
  String _action = 'Navigate';

  @override
  void dispose() {
    _lat.dispose();
    _lng.dispose();
    _alt.dispose();
    _speed.dispose();
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.waypointTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text('Edit waypoint properties (wireframe).'),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _lat,
                        decoration: const InputDecoration(labelText: 'Latitude'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _lng,
                        decoration: const InputDecoration(labelText: 'Longitude'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _alt,
                        decoration: const InputDecoration(labelText: 'Altitude (m)'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _speed,
                        decoration: const InputDecoration(labelText: 'Speed (m/s)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _hold,
                  decoration: const InputDecoration(labelText: 'Hold time (s)'),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _action,
                  decoration: const InputDecoration(labelText: 'Action'),
                  items: const [
                    DropdownMenuItem(value: 'Navigate', child: Text('Navigate')),
                    DropdownMenuItem(value: 'Loiter', child: Text('Loiter')),
                    DropdownMenuItem(value: 'Land', child: Text('Land')),
                    DropdownMenuItem(value: 'Return to Home', child: Text('Return to Home')),
                  ],
                  onChanged: (v) => setState(() => _action = v ?? _action),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Camera trigger'),
                  subtitle: const Text('Place capture marker on path (placeholder)'),
                  value: _cameraTrigger,
                  onChanged: (v) => setState(() => _cameraTrigger = v),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Advanced fields (heading, gimbal, ROI) (placeholder)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Delete waypoint (placeholder)')),
                    );
                    widget.onClose();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Save waypoint (placeholder)')),
                    );
                    widget.onClose();
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

