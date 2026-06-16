import '../../domain/agri_waypoint_kind.dart';

/// Values edited in [WaypointPropertySheet] and applied to map / mission models.
class MissionWaypointEditorValues {
  const MissionWaypointEditorValues({
    required this.latitude,
    required this.longitude,
    this.altitudeM,
    this.speedMps,
    this.holdSeconds = 0,
    this.action = 'Navigate',
    this.kind = AgriWaypointKind.routeFlight,
    this.cameraTrigger = false,
  });

  final double latitude;
  final double longitude;
  final double? altitudeM;
  final double? speedMps;
  final double holdSeconds;
  final String action;
  final AgriWaypointKind kind;
  final bool cameraTrigger;

  MissionWaypointEditorValues copyWith({
    double? latitude,
    double? longitude,
    double? altitudeM,
    double? speedMps,
    double? holdSeconds,
    String? action,
    AgriWaypointKind? kind,
    bool? cameraTrigger,
  }) {
    return MissionWaypointEditorValues(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitudeM: altitudeM ?? this.altitudeM,
      speedMps: speedMps ?? this.speedMps,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      action: action ?? this.action,
      kind: kind ?? this.kind,
      cameraTrigger: cameraTrigger ?? this.cameraTrigger,
    );
  }
}
