import 'package:flutter/material.dart';

import '../../core/ui/app_spacing.dart';

enum ConnectionStateLabel { simulated, connected, degraded, disconnected }

class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({
    super.key,
    required this.state,
    required this.onTap,
  });

  final ConnectionStateLabel state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color, icon) = switch (state) {
      ConnectionStateLabel.simulated => ('SIMULATED LINK', scheme.outline, Icons.science_outlined),
      ConnectionStateLabel.connected => ('LINK OK', scheme.tertiary, Icons.link_outlined),
      ConnectionStateLabel.degraded => ('LINK DEGRADED', scheme.primary, Icons.network_check_outlined),
      ConnectionStateLabel.disconnected => ('DISCONNECTED', scheme.error, Icons.link_off_outlined),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: scheme.onSurface),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.chevron_right, size: 16, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

