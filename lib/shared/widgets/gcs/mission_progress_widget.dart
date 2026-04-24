import 'package:flutter/material.dart';

import '../../../core/theme/gcs_tokens.dart';

class MissionProgressWidget extends StatelessWidget {
  const MissionProgressWidget({
    super.key,
    required this.active,
    required this.wpIndex,
    required this.wpTotal,
    required this.distToNextM,
    required this.completionPct,
  });

  final bool active;
  final int wpIndex;
  final int wpTotal;
  final String distToNextM;
  final int completionPct;

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: GcsColors.bgPanel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GcsColors.border),
        boxShadow: GcsLayout.panelDepth,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'MISSION',
            style: TextStyle(
              color: GcsColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flag_rounded, size: 18, color: GcsColors.accentPrimary),
              const SizedBox(width: 8),
              Text(
                'WP $wpIndex / $wpTotal',
                style: const TextStyle(color: GcsColors.textPrimary, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 10),
              Text(
                '$distToNextM m',
                style: const TextStyle(color: GcsColors.textSecondary, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: (completionPct.clamp(0, 100)) / 100.0,
              backgroundColor: GcsColors.bgMain,
              color: GcsColors.accentPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$completionPct% complete',
            style: const TextStyle(color: GcsColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

