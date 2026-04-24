import 'package:flutter/material.dart';

/// Production GCS design tokens (tactical / dark) — do not change casually.
/// Matches project brief: QGroundControl / mission-critical style.
abstract final class GcsColors {
  static const Color bgMain = Color(0xFF0B0F14);
  static const Color bgPanel = Color(0xFF121821);
  static const Color bgElevated = Color(0xFF1A2230);

  static const Color accentPrimary = Color(0xFF00C2FF);
  static const Color accentSuccess = Color(0xFF00FF9C);
  static const Color accentWarning = Color(0xFFFFC857);
  static const Color accentDanger = Color(0xFFFF4D4D);

  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8FA3B8);
  static const Color textMuted = Color(0xFF5C6B7A);

  /// ~ rgba(255,255,255,0.08)
  static const Color border = Color(0x14FFFFFF);
}

/// 8px grid, 8px corner radius, glow for hover / focus.
abstract final class GcsLayout {
  static const double radius = 8;
  static const double grid = 8;

  static final List<BoxShadow> glowCyan = [
    BoxShadow(
      color: GcsColors.accentPrimary.withValues(alpha: 0.25),
      blurRadius: 10,
    ),
  ];

  static final List<BoxShadow> glowSuccess = [
    BoxShadow(
      color: GcsColors.accentSuccess.withValues(alpha: 0.22),
      blurRadius: 10,
    ),
  ];

  static final List<BoxShadow> glowDanger = [
    BoxShadow(
      color: GcsColors.accentDanger.withValues(alpha: 0.3),
      blurRadius: 12,
    ),
  ];

  static final List<BoxShadow> panelDepth = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.45),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
