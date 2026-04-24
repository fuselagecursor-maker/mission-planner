import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_pill.dart';

/// SRS §7.1.3: Firmware flash progress is a full-screen blocking overlay.
///
/// Future:
/// - Real progress from firmware service.
/// - Failure handling use case UC-13.
class FirmwareFlashScreen extends StatelessWidget {
  const FirmwareFlashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Firmware Flash')),
      body: ListView(
        children: [
          const SectionHeader(title: 'Progress (blocking overlay wireframe)'),
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
                        StatusPill(label: 'Device: Active Vehicle', color: scheme.outline),
                        StatusPill(label: 'Firmware: v--', color: scheme.outline),
                        StatusPill(label: 'Stage: Uploading', color: scheme.primary),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const LinearProgressIndicator(value: 0.35),
                    const SizedBox(height: AppSpacing.md),
                    const Text('35% • Do not disconnect power or link (placeholder).'),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Console output / steps (placeholder)'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cancel flash (placeholder)')),
                          );
                        },
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('Cancel (placeholder)'),
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

