import 'package:flutter/material.dart';
import '../../../core/theme/gcs_tokens.dart';

class GcsLeftControlRail extends StatelessWidget {
  const GcsLeftControlRail({
    super.key,
    required this.armed,
    this.compact = false,
    this.onArm,
    this.onDisarm,
    this.onUploadMission,
    this.onEmergencyStop,
    this.onModeMenu,
  });

  final bool armed;
  final bool compact;
  final VoidCallback? onArm;
  final VoidCallback? onDisarm;
  final VoidCallback? onUploadMission;
  final VoidCallback? onEmergencyStop;
  final VoidCallback? onModeMenu;

  @override
  Widget build(BuildContext context) {
    final w = compact ? 64.0 : 192.0;
    return Container(
      width: w,
      margin: const EdgeInsets.only(left: 8, right: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: GcsColors.bgPanel,
        borderRadius: BorderRadius.circular(GcsLayout.radius),
        border: Border.all(color: GcsColors.border),
        boxShadow: GcsLayout.panelDepth,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GcsPillButton(
            label: compact ? '' : 'ARM',
            icon: Icons.verified_user_outlined,
            glow: GcsLayout.glowSuccess,
            color: GcsColors.accentSuccess,
            onPressed: onArm,
          ),
          const SizedBox(height: 8),
          _GcsPillButton(
            label: compact ? '' : 'DISARM',
            icon: Icons.gpp_bad_outlined,
            glow: GcsLayout.glowDanger,
            color: GcsColors.accentDanger,
            onPressed: onDisarm,
          ),
          const SizedBox(height: 8),
          _GcsOutlineButton(
            label: compact ? '' : 'Mode',
            icon: Icons.tune,
            onPressed: onModeMenu,
          ),
          const SizedBox(height: 8),
          _GcsOutlineButton(
            label: compact ? '' : 'Upload mission',
            icon: Icons.upload_file_outlined,
            onPressed: onUploadMission,
          ),
          const Spacer(),
          _EmergencyStop(
            onPressed: onEmergencyStop,
            compact: compact,
            pulse: armed,
          ),
        ],
      ),
    );
  }
}

class _GcsPillButton extends StatefulWidget {
  const _GcsPillButton({
    required this.label,
    required this.icon,
    required this.glow,
    required this.color,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final List<BoxShadow> glow;
  final Color color;
  final VoidCallback? onPressed;

  @override
  State<_GcsPillButton> createState() => _GcsPillButtonState();
}

class _GcsPillButtonState extends State<_GcsPillButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GcsLayout.radius),
          border: Border.all(color: widget.color.withValues(alpha: 0.5)),
          boxShadow: _hover ? widget.glow : null,
        ),
        child: Material(
          color: GcsColors.bgElevated,
          borderRadius: BorderRadius.circular(GcsLayout.radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(GcsLayout.radius),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: widget.label.isEmpty
                  ? Icon(widget.icon, color: widget.color, size: 22)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.icon, color: widget.color, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: widget.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GcsOutlineButton extends StatefulWidget {
  const _GcsOutlineButton({required this.label, required this.icon, this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  State<_GcsOutlineButton> createState() => _GcsOutlineButtonState();
}

class _GcsOutlineButtonState extends State<_GcsOutlineButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GcsLayout.radius),
          border: Border.all(color: GcsColors.border),
          boxShadow: _hover ? GcsLayout.glowCyan : null,
        ),
        child: Material(
          color: GcsColors.bgMain,
          borderRadius: BorderRadius.circular(GcsLayout.radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(GcsLayout.radius),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: widget.label.isEmpty
                  ? Icon(widget.icon, color: GcsColors.textPrimary, size: 20)
                  : Row(
                      children: [
                        Icon(widget.icon, color: GcsColors.textSecondary, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.label,
                            style: const TextStyle(
                              color: GcsColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyStop extends StatefulWidget {
  const _EmergencyStop({this.onPressed, this.compact = false, this.pulse = false});

  final VoidCallback? onPressed;
  final bool compact;
  final bool pulse;

  @override
  State<_EmergencyStop> createState() => _EmergencyStopState();
}

class _EmergencyStopState extends State<_EmergencyStop> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.pulse ? 0.55 + 0.45 * _c.value : 0.0;
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GcsLayout.radius),
            boxShadow: [
              if (widget.pulse)
                BoxShadow(
                  color: GcsColors.accentDanger.withValues(alpha: 0.25 + 0.25 * t),
                  blurRadius: 8 + 10 * t,
                ),
            ],
          ),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GcsColors.accentDanger,
              foregroundColor: GcsColors.bgMain,
              padding: EdgeInsets.symmetric(vertical: widget.compact ? 10 : 14, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GcsLayout.radius)),
            ),
            onPressed: widget.onPressed,
            child: widget.compact
                ? const Icon(Icons.emergency, size: 24)
                : const FittedBox(
                    child: Text(
                      'E-STOP',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
