import 'package:flutter/material.dart';

import '../../../core/gcs/gcs_status_model.dart';
import '../../../core/theme/gcs_tokens.dart';

class AlertBanner extends StatelessWidget {
  const AlertBanner({
    super.key,
    required this.alert,
    required this.onDismiss,
  });

  final GcsAlert alert;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, icon) = switch (alert.severity) {
      AlertSeverity.info => (scheme.surfaceContainerHighest, scheme.onSurface, Icons.info_outline),
      AlertSeverity.warning =>
        (GcsColors.accentWarning.withValues(alpha: 0.16), GcsColors.accentWarning, Icons.warning_amber_rounded),
      AlertSeverity.critical =>
        (GcsColors.accentDanger.withValues(alpha: 0.16), GcsColors.accentDanger, Icons.error_outline),
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: GcsLayout.panelDepth,
        ),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    alert.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w900, letterSpacing: 0.6),
                  ),
                  if (alert.message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      alert.message!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Dismiss',
              onPressed: onDismiss,
              icon: Icon(Icons.close, size: 18, color: scheme.onSurfaceVariant),
              style: IconButton.styleFrom(
                minimumSize: const Size(38, 38),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

