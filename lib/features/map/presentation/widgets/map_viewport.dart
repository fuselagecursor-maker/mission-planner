import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Tile URL templates for wireframe basemap switching (obey each provider’s terms in production).
abstract final class MapTileTemplates {
  static const osm = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  /// Dark tactical basemap (Carto) — GCS default when not in satellite.
  static const cartoDark =
      'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
  static const esriWorldImagery =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
}

/// Map viewport adapter (FlutterMap implementation).
///
/// Production notes:
/// - Keep map SDK types contained here (do not leak FlutterMap objects to other features).
/// - Later, feed this widget domain models (waypoints, track, airspace polygons) from state management.
class MapViewport extends StatelessWidget {
  const MapViewport({
    super.key,
    required this.waypoints,
    required this.path,
    this.vehicle,
    this.vehicleListenable,
    this.controller,
    this.initialCenter = const LatLng(20, 0),
    this.initialZoom = 3,
    this.tileUrlTemplate = MapTileTemplates.osm,
    this.enhanceTiles = true,
    this.trackPolylines,
    this.landPolygons = const [],
    this.extraPolylines = const [],
    this.extraCircles = const [],
    this.extraMarkers = const [],
    this.onMapTap,
    this.onMapLongPress,
    this.onWaypointTap,
  });

  final List<MapWaypoint> waypoints;
  final List<LatLng> path;
  final MapVehicle? vehicle;
  /// If provided, only the vehicle marker layer rebuilds when the value changes.
  /// This avoids rebuilding the whole [FlutterMap] tree at high Hz (important on web).
  final ValueListenable<MapVehicle?>? vehicleListenable;
  final MapController? controller;
  final LatLng initialCenter;
  final double initialZoom;
  final String tileUrlTemplate;
  final bool enhanceTiles;

  /// When non-empty, drawn as the primary GPS track (e.g. speed-coloured replay segments).
  /// If null/empty, falls back to a single-stroke [path] polyline.
  final List<Polyline>? trackPolylines;
  /// Filled regions (e.g. land plot from boundary waypoints).
  final List<Polygon> landPolygons;
  final List<Polyline> extraPolylines;
  final List<CircleMarker> extraCircles;
  final List<Marker> extraMarkers;
  final void Function(TapPosition position, LatLng point)? onMapTap;
  final void Function(TapPosition position, LatLng point)? onMapLongPress;
  final void Function(String waypointId, LatLng point)? onWaypointTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // On web (and during hot reload / window resizes), we can briefly get a
        // zero-size or unconstrained layout. That can trigger repeated hit-test
        // assertions inside gesture handling, making the map feel \"frozen\".
        //
        // We force a concrete size for FlutterMap and avoid building a 0x0 box.
        final media = MediaQuery.sizeOf(context);
        final w =
            constraints.hasBoundedWidth ? constraints.maxWidth : media.width;
        final h =
            constraints.hasBoundedHeight ? constraints.maxHeight : media.height;
        if (w <= 1 || h <= 1) {
          return const SizedBox(width: 1, height: 1);
        }

        final scheme = Theme.of(context).colorScheme;
        final isSatellite = tileUrlTemplate == MapTileTemplates.esriWorldImagery;
        final tileBuilder = enhanceTiles ? _tileEnhancer(scheme, isSatellite) : null;

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: w,
            height: h,
            child: FlutterMap(
              mapController: controller,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: initialZoom,
                minZoom: 3,
                maxZoom: 19,
                onTap: onMapTap,
                onLongPress: onMapLongPress,
                // Improve web interaction (scroll wheel + pinch + drag).
                // NOTE: we intentionally disable rotate for a simpler GCS UX.
                interactionOptions: const InteractionOptions(
                  // Use all flags except rotate for full map interaction.
                  // Without pinchMove and flingAnimation, the map feels frozen or unresponsive.
                  flags: InteractiveFlag.drag |
                      InteractiveFlag.flingAnimation |
                      InteractiveFlag.pinchMove |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.scrollWheelZoom,
                  scrollWheelVelocity: 0.02,
                ),
              ),
              children: [
                // IMPORTANT: obey tile provider terms. OSM public tiles are rate-limited.
                // For production, use your own tile server or a paid provider.
                TileLayer(
                  urlTemplate: tileUrlTemplate,
                  userAgentPackageName: 'com.example.mission_planner_wireframe',
                  minZoom: 3,
                  maxZoom: 19,
                  maxNativeZoom: 19,
                  tileBuilder: tileBuilder,
                ),
                // Subtle vignette to make tiles feel “premium” and improve HUD legibility.
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.15,
                        colors: [
                          Colors.transparent,
                          scheme.surface.withValues(alpha: scheme.brightness == Brightness.dark ? 0.18 : 0.10),
                        ],
                        stops: const [0.58, 1.0],
                      ),
                    ),
                  ),
                ),
                if (landPolygons.isNotEmpty)
                  PolygonLayer(
                    polygons: landPolygons,
                  ),
                if (trackPolylines != null && trackPolylines!.isNotEmpty)
                  PolylineLayer(
                    polylines: trackPolylines!,
                  )
                else if (path.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: path,
                        strokeWidth: 3,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                if (extraPolylines.isNotEmpty)
                  PolylineLayer(
                    polylines: extraPolylines,
                  ),
                if (extraCircles.isNotEmpty)
                  CircleLayer(
                    circles: extraCircles,
                  ),
                if (vehicle != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: vehicle!.point,
                        width: 56,
                        height: 56,
                        child: _VehicleMarker(headingDeg: vehicle!.headingDeg),
                      ),
                    ],
                  )
                else if (vehicleListenable != null)
                  ValueListenableBuilder<MapVehicle?>(
                    valueListenable: vehicleListenable!,
                    builder: (context, v, _) {
                      if (v == null) return const SizedBox.shrink();
                      return MarkerLayer(
                        markers: [
                          Marker(
                            point: v.point,
                            width: 56,
                            height: 56,
                            child: _VehicleMarker(headingDeg: v.headingDeg),
                          ),
                        ],
                      );
                    },
                  ),
                if (extraMarkers.isNotEmpty)
                  MarkerLayer(
                    markers: extraMarkers,
                  ),
                if (waypoints.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      for (final wp in waypoints)
                        Marker(
                          point: wp.point,
                          width: 56,
                          height: 56,
                          child: _WaypointMarker(
                            id: wp.id,
                            point: wp.point,
                            label: wp.label,
                            isViolation: wp.isViolation,
                            selected: wp.selected,
                            onPanUpdate: wp.onPanUpdate,
                            onTap: onWaypointTap == null
                                ? null
                                : () => onWaypointTap!(wp.id, wp.point),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

TileBuilder _tileEnhancer(ColorScheme scheme, bool isSatellite) {
  // A gentle contrast + saturation boost that makes both OSM and satellite tiles
  // more legible under dark-glass overlays.
  //
  // Matrix roughly: contrast (c) and brightness (b):
  // out = in * c + b
  final c = scheme.brightness == Brightness.dark ? 1.12 : 1.06;
  final b = scheme.brightness == Brightness.dark ? 6.0 : 4.0;
  final sat = scheme.brightness == Brightness.dark ? (isSatellite ? 1.10 : 1.05) : 1.03;

  // Saturation matrix (approx).
  final invSat = 1 - sat;
  final r = 0.2126 * invSat;
  final g = 0.7152 * invSat;
  final bl = 0.0722 * invSat;

  final m = <double>[
    c * (r + sat), c * g, c * bl, 0, b,
    c * r, c * (g + sat), c * bl, 0, b,
    c * r, c * g, c * (bl + sat), 0, b,
    0, 0, 0, 1, 0,
  ];

  return (ctx, tileWidget, tile) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(m),
      child: tileWidget,
    );
  };
}

class MapWaypoint {
  const MapWaypoint({
    required this.id,
    required this.label,
    required this.point,
    this.isViolation = false,
    this.selected = false,
    this.onPanUpdate,
  });

  final String id;
  final String label;
  final LatLng point;
  final bool isViolation;
  final bool selected;
  /// Drag the marker on the map to reposition (screen delta → lat/lng in parent).
  final void Function(DragUpdateDetails details)? onPanUpdate;
}

class MapVehicle {
  const MapVehicle({
    required this.point,
    required this.headingDeg,
  });

  final LatLng point;
  final double headingDeg;
}

class _VehicleMarker extends StatefulWidget {
  const _VehicleMarker({required this.headingDeg});

  final double headingDeg;

  @override
  State<_VehicleMarker> createState() => _VehicleMarkerState();
}

class _VehicleMarkerState extends State<_VehicleMarker> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = 0.65 + 0.35 * (1.0 - (_pulse.value * 2 - 1).abs());
          return Transform.rotate(
            angle: (widget.headingDeg) * 3.1415926535 / 180.0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.2 + 0.2 * t),
                    blurRadius: 6 + 8 * t,
                    spreadRadius: 1.5 * t,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.navigation, color: scheme.primary, size: 20),
            ),
          );
        },
      ),
    );
  }
}

class _WaypointMarker extends StatefulWidget {
  const _WaypointMarker({
    required this.id,
    required this.point,
    required this.label,
    required this.isViolation,
    required this.selected,
    this.onPanUpdate,
    this.onTap,
  });

  final String id;
  final LatLng point;
  final String label;
  final bool isViolation;
  final bool selected;
  final void Function(DragUpdateDetails details)? onPanUpdate;
  final VoidCallback? onTap;

  @override
  State<_WaypointMarker> createState() => _WaypointMarkerState();
}

class _WaypointMarkerState extends State<_WaypointMarker> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = widget.isViolation ? scheme.errorContainer : scheme.primaryContainer;
    final fg = widget.isViolation ? scheme.onErrorContainer : scheme.onPrimaryContainer;
    final border = widget.isViolation ? scheme.error : scheme.primary;
    final scale = widget.selected || _hover ? 1.08 : 1.0;

    final inner = AnimatedScale(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      scale: scale,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onTap,
          child: Ink(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.selected ? scheme.primary : border,
                width: widget.selected ? 2.4 : 1.2,
              ),
              boxShadow: [
                if (widget.selected)
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: fg,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final withPan = widget.onPanUpdate != null
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: widget.onPanUpdate,
            child: inner,
          )
        : inner;

    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: withPan,
      ),
    );
  }
}
