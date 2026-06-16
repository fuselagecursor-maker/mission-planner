/// Agri-style waypoint roles (JiYi K++ / Agri Assistant–inspired).
///
/// - [routeFlight]: ordered fly-through points (spray path / mission polyline).
/// - [fieldBoundary]: ordered vertices of a work field; three or more define a
///   closed outline (K++ “boundary point” flow on the map).
enum AgriWaypointKind {
  routeFlight,
  fieldBoundary,
}

extension AgriWaypointKindX on AgriWaypointKind {
  /// Short marker text on the map (fits small chips).
  String markerPrefix() => switch (this) {
        AgriWaypointKind.routeFlight => 'W',
        AgriWaypointKind.fieldBoundary => 'B',
      };

  String title() => switch (this) {
        AgriWaypointKind.routeFlight => 'Route point',
        AgriWaypointKind.fieldBoundary => 'Boundary point',
      };

  String subtitle() => switch (this) {
        AgriWaypointKind.routeFlight =>
          'Fly-through waypoint along the mission path (K++ route style).',
        AgriWaypointKind.fieldBoundary =>
          'Field corner; three or more close the work outline (K++ boundary style).',
      };
}
