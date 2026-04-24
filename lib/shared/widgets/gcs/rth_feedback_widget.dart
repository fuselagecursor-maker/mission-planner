import 'package:flutter/material.dart';

import '../../../core/theme/gcs_tokens.dart';

class RthFeedbackWidget extends StatelessWidget {
  const RthFeedbackWidget({
    super.key,
    required this.active,
    required this.phase,
    required this.distanceM,
  });

  final bool active;
  final String phase;
  final String distanceM;

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: GcsColors.accentWarning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GcsColors.accentWarning.withValues(alpha: 0.38)),
        boxShadow: GcsLayout.panelDepth,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.home_filled, color: GcsColors.accentWarning, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RETURNING TO HOME',
                style: TextStyle(
                  color: GcsColors.accentWarning,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$phase · $distanceM m',
                style: const TextStyle(
                  color: GcsColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

