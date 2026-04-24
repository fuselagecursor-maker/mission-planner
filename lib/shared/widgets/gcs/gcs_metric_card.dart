import 'package:flutter/material.dart';
import '../../../core/theme/gcs_tokens.dart';

class GcsMetricCard extends StatefulWidget {
  const GcsMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;

  @override
  State<GcsMetricCard> createState() => _GcsMetricCardState();
}

class _GcsMetricCardState extends State<GcsMetricCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(
          _hover ? 1.02 : 1.0,
          _hover ? 1.02 : 1.0,
          1.0,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GcsColors.bgElevated,
            borderRadius: BorderRadius.circular(GcsLayout.radius),
            border: Border.all(color: GcsColors.border),
            boxShadow: _hover
                ? [...GcsLayout.panelDepth, ...GcsLayout.glowCyan]
                : GcsLayout.panelDepth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: GcsColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: GcsColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: GcsColors.textMuted,
                        fontSize: 10,
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
