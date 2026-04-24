import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/ui/app_spacing.dart';

/// SRS: Emergency stop requires a deliberate gesture (e.g., long-press).
///
/// This is a wireframe-safe implementation:
/// - long-press triggers a blocking countdown dialog (3..2..1)
/// - confirm action is still placeholder (no real drone actuation)
class EmergencyStopButton extends StatefulWidget {
  const EmergencyStopButton({
    super.key,
    this.requireConfirmDialog = true,
  });

  final bool requireConfirmDialog;

  @override
  State<EmergencyStopButton> createState() => _EmergencyStopButtonState();
}

class _EmergencyStopButtonState extends State<EmergencyStopButton> {
  bool _armed = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        minimumSize: const Size(160, 56),
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Long-press to confirm KILL / EMERGENCY STOP (placeholder)')),
        );
      },
      onLongPress: () async {
        setState(() => _armed = true);
        try {
          final ok = widget.requireConfirmDialog ? await _showCountdown(context) : true;
          if (ok != true) return;
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('KILL / EMERGENCY STOP (placeholder)')),
          );
        } finally {
          if (mounted) setState(() => _armed = false);
        }
      },
      icon: Icon(_armed ? Icons.warning_amber_outlined : Icons.emergency),
      label: const Text('KILL / EMERGENCY STOP'),
    );
  }
}

Future<bool?> _showCountdown(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _CountdownDialog(
      onCancel: () => Navigator.of(ctx).pop(false),
      onConfirm: () => Navigator.of(ctx).pop(true),
    ),
  );
}

class _CountdownDialog extends StatefulWidget {
  const _CountdownDialog({
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _seconds = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 1) {
        t.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Emergency Stop'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will immediately transition the vehicle into EMERGENCY state.',
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: scheme.errorContainer,
              border: Border.all(color: scheme.error),
            ),
            child: Text(
              _seconds == 0 ? 'READY' : 'CONFIRMING IN $_seconds…',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
        FilledButton(
          onPressed: _seconds == 0 ? widget.onConfirm : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

