import 'package:latlong2/latlong.dart';

/// Demo NFZ was removed; real airspace checks can plug in here later.
@Deprecated('Demo NFZ removed; always false until real airspace data is wired.')
bool isInDemoNfz(LatLng p) {
  return false;
}
