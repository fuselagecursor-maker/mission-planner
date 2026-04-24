import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../../../shared/widgets/emergency_stop_button.dart';

/// SRS FR-21 wireframe.
///
/// Future:
/// - Replace joystick placeholders with a real virtual joystick widget.
/// - Sample at >=20 Hz, apply deadzone + expo curves, map to channels, emit to MAVLink.
class ManualControlScreen extends StatefulWidget {
  const ManualControlScreen({super.key});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  bool _armedOverride = false;
  String _activeVehicle = 'V1';

  Offset _leftStick = Offset.zero; // x=yaw, y=throttle
  Offset _rightStick = Offset.zero; // x=roll, y=pitch

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final joystickH = (size.height * 0.40).clamp(220.0, 340.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Control'),
        actions: [
          IconButton(
            onPressed: () {
              // SRS: mode switcher (Mode 1/2/3/4) lives in Settings.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Joystick Mode (placeholder)')),
              );
            },
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Sensitivity / mode (placeholder)',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Top centre bar (SRS §7.2.2).
          GlassCard(
            borderRadius: 24,
            opacity: 0.55,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: _ManualTopBar(
              fsmLabel: 'IN_MISSION',
              manualOverrideActive: _armedOverride,
              latencyMsLabel: '--',
              activeVehicle: _activeVehicle,
              onChangeVehicle: (v) => setState(() => _activeVehicle = v),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // HUD mini-panels (top corners).
          const Row(
            children: [
              _MiniHudPanel(title: 'ALT / SPD', lines: ['Alt: -- m', 'Spd: -- m/s']),
              Spacer(),
              _MiniHudPanel(title: 'HDG / BAT', lines: ['Hdg: --°', 'Bat: --%']),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Joysticks.
          SizedBox(
            height: joystickH,
            child: Row(
              children: [
                Expanded(
                  child: _JoystickPanel(
                    title: 'Left joystick',
                    subtitle: 'Throttle (Y) • Yaw (X)',
                    enabled: _armedOverride,
                    stick: _leftStick,
                    onChanged: (o) => setState(() => _leftStick = o),
                    axisLeftLabel: 'Yaw (X)',
                    axisRightLabel: 'Thr (Y)',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _JoystickPanel(
                    title: 'Right joystick',
                    subtitle: 'Pitch (Y) • Roll (X)',
                    enabled: _armedOverride,
                    stick: _rightStick,
                    onChanged: (o) => setState(() => _rightStick = o),
                    axisLeftLabel: 'Roll (X)',
                    axisRightLabel: 'Pitch (Y)',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Bottom centre strip (SRS §7.2.2).
          GlassCard(
            borderRadius: 22,
            opacity: 0.55,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sensitivity settings (placeholder)')),
                    );
                  },
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Sensitivity'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Joystick mode selector (placeholder)')),
                    );
                  },
                  icon: const Icon(Icons.swap_horiz_outlined),
                  label: const Text('Mode 2'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camera trigger (placeholder)')),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Trigger'),
                ),
                GradientButton(
                  label: 'Return to auto',
                  icon: Icons.route_outlined,
                  compact: true,
                  onPressed: _armedOverride
                      ? () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Return to Auto'),
                              content: const Text('Resume autonomous mission from waypoint N?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                          if (ok != true) return;
                          if (!context.mounted) return;
                          setState(() => _armedOverride = false);
                        }
                      : null,
                ),
                GradientButton(
                  label: _armedOverride ? 'Manual enabled' : 'Enable manual',
                  icon: Icons.gamepad_outlined,
                  compact: true,
                  onPressed: () async {
                    if (_armedOverride) return;
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Manual Control'),
                        content: const Text('Suspend autonomous mission and take manual control?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    if (!context.mounted) return;
                    setState(() => _armedOverride = true);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Emergency stop button (large, bottom-centre; SRS §7.2.2).
          SizedBox(
            width: double.infinity,
            child: GlassCard(
              borderRadius: 24,
              opacity: 0.50,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.55)),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.danger.withValues(alpha: 0.18),
                      scheme.surfaceContainerHighest.withValues(alpha: 0.30),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: const [
                      Text(
                        'Emergency stop',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      EmergencyStopButton(),
                    ],
                  ),
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

class _ManualTopBar extends StatelessWidget {
  const _ManualTopBar({
    required this.fsmLabel,
    required this.manualOverrideActive,
    required this.latencyMsLabel,
    required this.activeVehicle,
    required this.onChangeVehicle,
  });

  final String fsmLabel;
  final bool manualOverrideActive;
  final String latencyMsLabel;
  final String activeVehicle;
  final ValueChanged<String> onChangeVehicle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        StatusPill(label: 'FSM: $fsmLabel', color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        StatusPill(
          label: manualOverrideActive ? 'MANUAL OVERRIDE ACTIVE' : 'Override: OFF',
          color: manualOverrideActive ? scheme.tertiary : scheme.outline,
        ),
        const SizedBox(width: AppSpacing.sm),
        StatusPill(label: 'Latency: $latencyMsLabel ms', color: scheme.outline),
        const Spacer(),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: activeVehicle,
            items: const [
              DropdownMenuItem(value: 'V1', child: Text('V1')),
              DropdownMenuItem(value: 'V2', child: Text('V2')),
              DropdownMenuItem(value: 'V3', child: Text('V3')),
              DropdownMenuItem(value: 'V4', child: Text('V4')),
            ],
            onChanged: (v) {
              if (v == null) return;
              onChangeVehicle(v);
            },
          ),
        ),
      ],
    );
  }
}

class _MiniHudPanel extends StatelessWidget {
  const _MiniHudPanel({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final l in lines) Text(l, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _JoystickPanel extends StatelessWidget {
  const _JoystickPanel({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.stick,
    required this.onChanged,
    required this.axisLeftLabel,
    required this.axisRightLabel,
  });

  final String title;
  final String subtitle;
  final bool enabled;
  final Offset stick; // normalized [-1..1]
  final ValueChanged<Offset> onChanged;
  final String axisLeftLabel;
  final String axisRightLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = enabled ? AppColors.neonCyan : scheme.outlineVariant;
    return GlassCard(
      borderRadius: 26,
      opacity: 0.55,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border.withValues(alpha: enabled ? 0.50 : 0.65)),
          gradient: LinearGradient(
            colors: [
              (enabled ? AppColors.neonCyan : scheme.surfaceContainerHighest).withValues(alpha: 0.10),
              scheme.surface.withValues(alpha: 0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                    ),
                  ),
                  StatusPill(
                    label: enabled ? 'ACTIVE' : 'OFF',
                    color: enabled ? AppColors.neonCyan : scheme.outline,
                    leading: enabled ? Icons.bolt_outlined : Icons.power_settings_new_rounded,
                    dense: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Center(
                  child: _VirtualJoystick(
                    enabled: enabled,
                    value: stick,
                    onChanged: onChanged,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$axisLeftLabel: ${(stick.dx * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$axisRightLabel: ${((-stick.dy) * 100).toStringAsFixed(0)}%',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                enabled ? 'Live output (placeholder)' : 'Disabled until manual is enabled',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VirtualJoystick extends StatefulWidget {
  const _VirtualJoystick({
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  final bool enabled;
  final Offset value; // normalized [-1..1]
  final ValueChanged<Offset> onChanged;

  @override
  State<_VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<_VirtualJoystick> {
  void _update(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final delta = localPosition - center;
    final radius = size.shortestSide / 2;
    final norm = Offset(delta.dx / radius, delta.dy / radius);
    // Clamp to unit circle.
    final mag = norm.distance;
    final clamped = mag <= 1 ? norm : norm / mag;
    widget.onChanged(Offset(clamped.dx.clamp(-1, 1), clamped.dy.clamp(-1, 1)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final center = Offset(size.width / 2, size.height / 2);
          final radius = size.shortestSide / 2;
          final knob = center + Offset(widget.value.dx * radius, widget.value.dy * radius);

          return GestureDetector(
            onPanStart: widget.enabled ? (d) => _update(d.localPosition, size) : null,
            onPanUpdate: widget.enabled ? (d) => _update(d.localPosition, size) : null,
            onPanEnd: widget.enabled
                ? (_) => widget.onChanged(Offset.zero) // spring return
                : null,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Stack(
                children: [
                  // Crosshair.
                  Align(
                    alignment: Alignment.center,
                    child: Container(width: 1, height: double.infinity, color: scheme.outlineVariant),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(height: 1, width: double.infinity, color: scheme.outlineVariant),
                  ),
                  // Knob.
                  Positioned(
                    left: knob.dx - 28,
                    top: knob.dy - 28,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.enabled
                            ? scheme.surfaceContainerHighest
                            : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                        border: Border.all(color: scheme.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        widget.enabled ? Icons.open_with_outlined : Icons.lock_outline,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

