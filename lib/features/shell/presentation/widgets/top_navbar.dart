import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/status_pill.dart';

class TopNavbar extends StatelessWidget {
  const TopNavbar({
    super.key,
    required this.title,
    this.onOpenMenu,
    this.trailing,
  });

  final String title;
  final VoidCallback? onOpenMenu;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (onOpenMenu != null) ...[
          IconButton(
            tooltip: 'Menu',
            onPressed: onOpenMenu,
            icon: const Icon(Icons.menu_rounded),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: const [
                  StatusPill(
                    label: 'LIVE',
                    color: AppColors.success,
                    leading: Icons.wifi_tethering_rounded,
                    dense: true,
                  ),
                  StatusPill(
                    label: 'VEHICLE: V1',
                    color: AppColors.neonCyan,
                    leading: Icons.flight_rounded,
                    dense: true,
                  ),
                  StatusPill(
                    label: 'MODE: AUTO',
                    color: AppColors.softPurple,
                    leading: Icons.auto_mode_rounded,
                    dense: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ] else ...[
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
              gradient: LinearGradient(
                colors: [
                  scheme.surfaceContainerHighest.withValues(alpha: 0.65),
                  scheme.surface.withValues(alpha: 0.35),
                ],
              ),
            ),
            child: Icon(Icons.person_rounded, color: scheme.onSurface),
          ),
        ],
      ],
    );
  }
}

