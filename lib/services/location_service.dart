import 'package:geolocator/geolocator.dart';
import 'package:trust_location/trust_location.dart';
import '../models/location_model.dart';

class LocationService {

  bool lastIsMock = false; // <-- untuk simpan info Mock dari trust_location

  Future<bool> _ensurePermission() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  Stream<LocationModel> streamLocation() async* {
    final ok = await _ensurePermission();
    if (!ok) return;

    // -------------------------------
    // START TRUST LOCATION (no await)
    // -------------------------------
    try {
      TrustLocation.start(5);
    } catch (_) {}

    // LISTENER UNTUK FAKE GPS
    TrustLocation.onChange.listen((values) {
      lastIsMock = values.isMockLocation ?? false;
    });

    // --------------------------------
    // STREAM GPS UTAMA GELOCATOR
    // --------------------------------
    await for (final pos in Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    )) {
      yield LocationModel(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        distanceFromCampus: 0,
        isMock: lastIsMock,  // ← ambil dari listener
      );
    }
  }
}
