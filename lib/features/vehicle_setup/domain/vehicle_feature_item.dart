/// One row in a vehicle / preflight checklist (matches `docs/FLIGHT_FEATURES_CHECKLIST.md` IDs).
class VehicleFeatureItem {
  const VehicleFeatureItem({
    required this.id,
    required this.title,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
}
