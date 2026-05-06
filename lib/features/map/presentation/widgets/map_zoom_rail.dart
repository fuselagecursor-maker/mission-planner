import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/gcs_tokens.dart';

/// In-map +/−/recenter for users who do not use pinch or scroll wheel.
class MapZoomRail extends StatelessWidget {
  const MapZoomRail({
    super.key,
    required this.controller,
    this.recenterPoint,
  });

  final MapController controller;
  final LatLng? recenterPoint;

  void _nudgeZoom(double delta) {
    final cam = controller.camera;
    final z = (cam.zoom + delta).clamp(3.0, 19.0);
    controller.move(cam.center, z);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.92),
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapZoomButton(
            tooltip: 'Zoom in',
            icon: Icons.add,
            onPressed: () => _nudgeZoom(0.6),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          _MapZoomButton(
            tooltip: 'Zoom out',
            icon: Icons.remove,
            onPressed: () => _nudgeZoom(-0.6),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          _MapZoomButton(
            tooltip: 'Recenter on vehicle',
            icon: Icons.my_location,
            onPressed: recenterPoint == null
                ? null
                : () {
                    final cam = controller.camera;
                    final z = cam.zoom < 14 ? 14.0 : cam.zoom;
                    controller.move(recenterPoint!, z);
                  },
          ),
        ],
      ),
    );
  }
}

class _MapZoomButton extends StatelessWidget {
  const _MapZoomButton({
    required this.tooltip,
    required this.icon,
    this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: scheme.onSurface),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(6),
        minimumSize: const Size(40, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
