import 'package:flutter/material.dart';

import '../core/theme/gcs_tokens.dart';

/// Canonical widths; keep in sync with [GcsShell] / map quick-action anchoring.
const double kGcsSidebarWidthCollapsed = 64;
const double kGcsSidebarWidthExpanded = 220;

double gcsSidebarWidth(bool collapsed) =>
    collapsed ? kGcsSidebarWidthCollapsed : kGcsSidebarWidthExpanded;

enum GcsNavSection { map, mission, logs, settings }

class GcsSidebar extends StatelessWidget {
  const GcsSidebar({
    super.key,
    required this.section,
    required this.onSelect,
    required this.collapsed,
    required this.onTools,
  });

  final GcsNavSection section;
  final ValueChanged<GcsNavSection> onSelect;
  final bool collapsed;
  final VoidCallback onTools;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Hard width cap to prevent any sidebar child from expanding.
    final w = gcsSidebarWidth(collapsed);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: w,
      constraints: BoxConstraints(maxWidth: w),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(GcsLayout.radius),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: GcsLayout.panelDepth,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: _SidebarHeader(
              collapsed: collapsed,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Divider(height: 12, color: scheme.outlineVariant),
          ),
          _SidebarItems(
            section: section,
            collapsed: collapsed,
            onSelect: onSelect,
            onTools: onTools,
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.collapsed,
  });

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: GcsColors.accentPrimary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GcsColors.accentPrimary.withValues(alpha: 0.28)),
                boxShadow: GcsLayout.glowCyan,
              ),
              child: const Icon(Icons.flight, color: GcsColors.accentPrimary, size: 18),
            ),
            if (!collapsed) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'GCS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SidebarItems extends StatelessWidget {
  const _SidebarItems({
    required this.section,
    required this.collapsed,
    required this.onSelect,
    required this.onTools,
  });

  final GcsNavSection section;
  final bool collapsed;
  final ValueChanged<GcsNavSection> onSelect;
  final VoidCallback onTools;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          _NavItem(
            icon: Icons.map_rounded,
            label: 'Map',
            active: section == GcsNavSection.map,
            collapsed: collapsed,
            onTap: () => onSelect(GcsNavSection.map),
          ),
          const SizedBox(height: 6),
          _NavItem(
            icon: Icons.flag_rounded,
            label: 'Mission',
            active: section == GcsNavSection.mission,
            collapsed: collapsed,
            onTap: () => onSelect(GcsNavSection.mission),
          ),
          const SizedBox(height: 6),
          _NavItem(
            icon: Icons.terminal_rounded,
            label: 'Logs',
            active: section == GcsNavSection.logs,
            collapsed: collapsed,
            onTap: () => onSelect(GcsNavSection.logs),
          ),
          const SizedBox(height: 6),
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            active: section == GcsNavSection.settings,
            collapsed: collapsed,
            onTap: () => onSelect(GcsNavSection.settings),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: scheme.outlineVariant),
          const SizedBox(height: 12),
          _NavItem(
            icon: Icons.apps_rounded,
            label: 'Tools',
            active: false,
            collapsed: collapsed,
            onTap: onTools,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.collapsed,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = active ? GcsColors.accentPrimary.withValues(alpha: 0.14) : Colors.transparent;
    final border = active
        ? GcsColors.accentPrimary.withValues(alpha: 0.30)
        : scheme.outlineVariant;
    final fg = active ? GcsColors.accentPrimary : scheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
            boxShadow: active ? GcsLayout.glowCyan : null,
          ),
          child: Row(
            mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: fg),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

