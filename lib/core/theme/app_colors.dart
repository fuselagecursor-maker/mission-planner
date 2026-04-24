import 'package:flutter/material.dart';
import 'gcs_tokens.dart';

/// App-wide color aliases. Tactical GCS palette — see [GcsColors] for source tokens.
abstract final class AppColors {
  // Aliased to GCS spec (QGroundControl / mission-critical style)
  static const Color navy = GcsColors.bgPanel;
  static const Color neonCyan = GcsColors.accentPrimary;
  static const Color softPurple = Color(0xFF2A3F55); // secondary UI chrome only
  static const Color teal = GcsColors.accentSuccess;
  static const Color black = GcsColors.bgMain;

  static const Color bgTop = GcsColors.bgPanel;
  static const Color bgBottom = GcsColors.bgMain;

  static const Color surfaceDark = GcsColors.bgMain;
  static const Color surfaceLight = Color(0xFFF6F8FB);

  static const Color outlineDark = GcsColors.border;
  static const Color outlineLight = Color(0xFFD7DEE8);

  static const Color success = GcsColors.accentSuccess;
  static const Color warning = GcsColors.accentWarning;
  static const Color danger = GcsColors.accentDanger;
}

/// Prefer flat surfaces. Avoid large gradients in GCS layout.
abstract final class AppGradients {
  /// Legacy hook: solid tactical background (use [GcsColors.bgMain] in widgets).
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [GcsColors.bgMain, GcsColors.bgMain],
  );

  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [GcsColors.accentPrimary, GcsColors.accentPrimary],
  );
}
