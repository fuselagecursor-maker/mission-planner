import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../domain/agri_waypoint_kind.dart';
import '../models/mission_waypoint_editor_values.dart';

/// Waypoint / boundary editor (K++ Agri Assistant–style fields at basic level).
///
/// Binds lat/lng/alt/speed/hold/action/kind; [onApply] receives parsed values.
class WaypointPropertySheet extends StatefulWidget {
  const WaypointPropertySheet({
    super.key,
    required this.waypointTitle,
    required this.initial,
    required this.onApply,
    required this.onClose,
    this.onDelete,
    this.showKindPicker = true,
    this.onPickLocationOnMap,
  });

  final String waypointTitle;
  final MissionWaypointEditorValues initial;
  final ValueChanged<MissionWaypointEditorValues> onApply;
  final VoidCallback onClose;
  final VoidCallback? onDelete;
  final bool showKindPicker;
  /// Close the sheet and let the map handle the next tap as a position update.
  final VoidCallback? onPickLocationOnMap;

  @override
  State<WaypointPropertySheet> createState() => _WaypointPropertySheetState();
}

class _WaypointPropertySheetState extends State<WaypointPropertySheet> {
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late final TextEditingController _alt;
  late final TextEditingController _speed;
  late final TextEditingController _hold;
  late AgriWaypointKind _kind;
  late String _action;
  bool _cameraTrigger = false;

  static String _fmt(double? v, {int digits = 6}) {
    if (v == null) return '';
    return v.toStringAsFixed(digits);
  }

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _lat = TextEditingController(text: _fmt(i.latitude, digits: 6));
    _lng = TextEditingController(text: _fmt(i.longitude, digits: 6));
    _alt = TextEditingController(text: i.altitudeM != null ? _fmt(i.altitudeM, digits: 1) : '');
    _speed = TextEditingController(text: i.speedMps != null ? _fmt(i.speedMps, digits: 1) : '');
    _hold = TextEditingController(text: i.holdSeconds > 0 ? _fmt(i.holdSeconds, digits: 1) : '0');
    _kind = i.kind;
    _action = i.action;
    _cameraTrigger = i.cameraTrigger;
  }

  @override
  void dispose() {
    _lat.dispose();
    _lng.dispose();
    _alt.dispose();
    _speed.dispose();
    _hold.dispose();
    super.dispose();
  }

  double? _parseDouble(String raw) {
    final t = raw.trim();
    if (t.isEmpty || t == '--') return null;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  String? _validate(MissionWaypointEditorValues v) {
    if (v.latitude < -90 || v.latitude > 90) return 'Latitude must be between -90 and 90.';
    if (v.longitude < -180 || v.longitude > 180) return 'Longitude must be between -180 and 180.';
    return null;
  }

  void _save() {
    final lat = double.tryParse(_lat.text.trim().replaceAll(',', '.'));
    final lng = double.tryParse(_lng.text.trim().replaceAll(',', '.'));
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid latitude and longitude.')),
      );
      return;
    }
    final next = MissionWaypointEditorValues(
      latitude: lat,
      longitude: lng,
      altitudeM: _parseDouble(_alt.text),
      speedMps: _parseDouble(_speed.text),
      holdSeconds: double.tryParse(_hold.text.trim().replaceAll(',', '.')) ?? 0,
      action: _action,
      kind: _kind,
      cameraTrigger: _cameraTrigger,
    );
    final err = _validate(next);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    widget.onApply(next);
    widget.onClose();
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
              Expanded(
                child: Text(
                  widget.waypointTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Boundary points connect in order: two points draw an edge, three or more fill a land plot. '
            'Route points are for a separate fly path. Use “Tap map to move” to drag a corner by tapping the map.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (widget.showKindPicker) ...[
            Text('Point type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<AgriWaypointKind>(
              segments: [
                ButtonSegment(
                  value: AgriWaypointKind.routeFlight,
                  label: Text(AgriWaypointKind.routeFlight.title()),
                  icon: const Icon(Icons.timeline, size: 18),
                ),
                ButtonSegment(
                  value: AgriWaypointKind.fieldBoundary,
                  label: Text(AgriWaypointKind.fieldBoundary.title()),
                  icon: const Icon(Icons.format_shapes_outlined, size: 18),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Expanded(
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _lat,
                        decoration: const InputDecoration(labelText: 'Latitude'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _lng,
                        decoration: const InputDecoration(labelText: 'Longitude'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
                        ],
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
                        decoration: const InputDecoration(
                          labelText: 'Altitude (m)',
                          hintText: 'Optional',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _speed,
                        decoration: const InputDecoration(
                          labelText: 'Speed (m/s)',
                          hintText: 'Optional',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _hold,
                  decoration: const InputDecoration(labelText: 'Hold time (s)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: AppSpacing.md),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Action',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _action,
                      items: const [
                        DropdownMenuItem(value: 'Navigate', child: Text('Navigate')),
                        DropdownMenuItem(value: 'Loiter', child: Text('Loiter (fixed point)')),
                        DropdownMenuItem(value: 'Land', child: Text('Land')),
                        DropdownMenuItem(value: 'Return to Home', child: Text('Return to Home')),
                      ],
                      onChanged: (v) => setState(() => _action = v ?? _action),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Camera trigger'),
                  subtitle: const Text('Optional payload flag (placeholder)'),
                  value: _cameraTrigger,
                  onChanged: (v) => setState(() => _cameraTrigger = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (widget.onPickLocationOnMap != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    widget.onPickLocationOnMap!();
                    widget.onClose();
                  },
                  icon: const Icon(Icons.touch_app_outlined),
                  label: const Text('Tap map to move this point'),
                ),
              ),
            ),
          Row(
            children: [
              if (widget.onDelete != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.onDelete!();
                      widget.onClose();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ),
              if (widget.onDelete != null) const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
