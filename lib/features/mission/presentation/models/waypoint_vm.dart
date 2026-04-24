class WaypointVm {
  const WaypointVm({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
    required this.altMeters,
    required this.speedMps,
    required this.action,
  });

  final String id;
  final String label;
  final double? lat;
  final double? lng;
  final double? altMeters;
  final double? speedMps;
  final String action;

  WaypointVm copyWith({
    String? label,
    double? lat,
    double? lng,
    double? altMeters,
    double? speedMps,
    String? action,
  }) {
    return WaypointVm(
      id: id,
      label: label ?? this.label,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      altMeters: altMeters ?? this.altMeters,
      speedMps: speedMps ?? this.speedMps,
      action: action ?? this.action,
    );
  }
}

