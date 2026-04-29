import 'package:flutter/material.dart';

import '../../../core/theme/gcs_tokens.dart';

class ManualControlPanel extends StatefulWidget {
  const ManualControlPanel({
    super.key,
    required this.open,
    required this.onToggle,
    this.maxHeight,
  });

  final bool open;
  final VoidCallback onToggle;
  final double? maxHeight;

  @override
  State<ManualControlPanel> createState() => _ManualControlPanelState();
}

class _ManualControlPanelState extends State<ManualControlPanel> {
  double _throttle = 0.0;
  double _yaw = 0.0;
  double _pitch = 0.0;
  double _roll = 0.0;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      width: 260,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GcsColors.bgPanel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GcsColors.border),
        boxShadow: GcsLayout.panelDepth,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 320),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.sports_esports_rounded, size: 18, color: GcsColors.textSecondary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'MANUAL CONTROL',
                    style: TextStyle(
                      color: GcsColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Collapse manual controls',
                  onPressed: widget.onToggle,
                  icon: const Icon(Icons.chevron_right, color: GcsColors.textSecondary),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(36, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                primary: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AxisSlider(
                      label: 'Throttle',
                      value: _throttle,
                      onChanged: (v) => setState(() => _throttle = v),
                    ),
                    const SizedBox(height: 6),
                    _AxisSlider(label: 'Yaw', value: _yaw, onChanged: (v) => setState(() => _yaw = v)),
                    const SizedBox(height: 6),
                    _AxisSlider(label: 'Pitch', value: _pitch, onChanged: (v) => setState(() => _pitch = v)),
                    const SizedBox(height: 6),
                    _AxisSlider(label: 'Roll', value: _roll, onChanged: (v) => setState(() => _roll = v)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: GcsColors.bgMain,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GcsColors.border),
                      ),
                      child: Text(
                        'T ${_throttle.toStringAsFixed(2)}  '
                        'Y ${_yaw.toStringAsFixed(2)}  '
                        'P ${_pitch.toStringAsFixed(2)}  '
                        'R ${_roll.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: GcsColors.textSecondary,
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.open) return panel;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: GcsColors.bgPanel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GcsColors.border),
        boxShadow: GcsLayout.panelDepth,
      ),
      child: IconButton(
        tooltip: 'Open manual controls',
        onPressed: widget.onToggle,
        icon: const Icon(Icons.sports_esports_rounded, color: GcsColors.textPrimary, size: 20),
      ),
    );
  }
}

class _AxisSlider extends StatelessWidget {
  const _AxisSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            style: const TextStyle(color: GcsColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: value,
              min: -1,
              max: 1,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            value.toStringAsFixed(2),
            textAlign: TextAlign.right,
            style: const TextStyle(color: GcsColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

