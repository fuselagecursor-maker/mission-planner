import 'package:latlong2/latlong.dart';

/// Demo NFZ rectangle (kept in sync with [MapViewport] airspace overlay).
bool isInDemoNfz(LatLng p) {
  return p.latitude >= 12.9735 &&
      p.latitude <= 12.9765 &&
      p.longitude >= 77.599 &&
      p.longitude <= 77.605;
}
