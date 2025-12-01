import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
// ❌ vibration dihapus agar tidak error
// import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _gps = LocationService();
  final MapController mapController = MapController();

  LocationModel? currentPosition;

  LatLng campusPoint = const LatLng(-6.61266, 106.72618);

  double distanceToCampus = 99999;
  bool followMode = true;

  String? jamMasuk;
  String? jamKeluar;
  String? tanggalPresensi;

  double? get lat => currentPosition?.latitude;
  double? get lng => currentPosition?.longitude;
  double? get acc => currentPosition?.accuracy;

  bool get isWithinCampus => distanceToCampus < 100;

  // =======================================================
  //                  LOAD DATA LOCAL
  // =======================================================
  Future<void> loadPresensi() async {
    final sp = await SharedPreferences.getInstance();
    jamMasuk = sp.getString("jamMasuk");
    jamKeluar = sp.getString("jamKeluar");
    tanggalPresensi = sp.getString("tanggalPresensi");

    final today = DateTime.now().toString().substring(0, 10);

    // RESET PER HARI
    if (tanggalPresensi != today) {
      jamMasuk = null;
      jamKeluar = null;
      tanggalPresensi = today;
      await savePresensiLocal();
    }

    notifyListeners();
  }

  // =======================================================
  //                  SIMPAN DATA LOCAL
  // =======================================================
  Future<void> savePresensiLocal() async {
    final sp = await SharedPreferences.getInstance();
    if (jamMasuk != null) sp.setString("jamMasuk", jamMasuk!);
    if (jamKeluar != null) sp.setString("jamKeluar", jamKeluar!);

    final today = DateTime.now().toString().substring(0, 10);
    sp.setString("tanggalPresensi", today);
  }

  // =======================================================
  //                   START GPS TRACKING
  // =======================================================
  Future<void> startTracking() async {
    await loadPresensi();
    await loadCampusLocation();

    _gps.streamLocation().listen((raw) {
      double dist = Geolocator.distanceBetween(
        raw.latitude,
        raw.longitude,
        campusPoint.latitude,
        campusPoint.longitude,
      );

      currentPosition = LocationModel(
        latitude: raw.latitude,
        longitude: raw.longitude,
        accuracy: raw.accuracy,
        distanceFromCampus: dist,
      );

      distanceToCampus = dist;

      if (followMode) {
        mapController.move(
          LatLng(raw.latitude, raw.longitude),
          17.3,
        );
      }

      notifyListeners();
    });
  }

  void toggleFollow() {
    followMode = !followMode;
    notifyListeners();
  }

  // =======================================================
  //                 PRESENSI MASUK / KELUAR
  // =======================================================
  Future<void> doPresensi(BuildContext context) async {
    final now = DateTime.now();
    final jam =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    if (jamMasuk == null) {
      jamMasuk = jam;
    } else {
      jamKeluar ??= jam;
    }

    await savePresensiLocal();
    notifyListeners();

    // ❌ vibration dihilangkan sesuai permintaan
    // if (await Vibration.hasVibrator() == true) {
    //   Vibration.vibrate(duration: 200);
    // }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Presensi berhasil!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =======================================================
  //                 SETTING LOCATION
  // =======================================================
  void updateCampusLocation(double lat, double lng) async {
    campusPoint = LatLng(lat, lng);

    final sp = await SharedPreferences.getInstance();
    sp.setDouble("campusLat", lat);
    sp.setDouble("campusLng", lng);

    notifyListeners();
  }

  // =======================================================
  //                LOAD LOKASI DARI STORAGE
  // =======================================================
  Future<void> loadCampusLocation() async {
    final sp = await SharedPreferences.getInstance();

    double? lat = sp.getDouble("campusLat");
    double? lng = sp.getDouble("campusLng");

    if (lat != null && lng != null) {
      campusPoint = LatLng(lat, lng);
    }

    notifyListeners();
  }
}
