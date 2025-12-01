import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';

class LocationService {

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

    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );

    await for (final pos in stream) {

      // JANGAN hitung jarak di sini
      yield LocationModel(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        distanceFromCampus: 0, // diisi nanti oleh provider
      );
    }
  }
}
