import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class GpsPage extends StatefulWidget {
  const GpsPage({super.key});

  @override
  State<GpsPage> createState() => _GpsPageState();
}

class _GpsPageState extends State<GpsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController markerAnim;

  @override
  void initState() {
    super.initState();
    markerAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.88,
      upperBound: 1.12,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    markerAnim.dispose();
    super.dispose();
  }

  // ================== POPUP GLOW (tanpa vibrasi) ==================
  void showSuccessPopup() async {

    // getar HP telah dihapus sesuai permintaan
    // if (await Vibration.hasVibrator() ?? false) {
    //   Vibration.vibrate(duration: 200);
    // }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.28),
                Colors.white.withOpacity(0.08),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.8),
                      blurRadius: 35,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 18),
              const Text(
                "Presensi Berhasil!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Anda berada dalam radius kampus.",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LocationProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: p.mapController,
            options: MapOptions(
              initialCenter: p.campusPoint,
              initialZoom: 17,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.gps_app",
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: p.campusPoint,
                    radius: 100,
                    color: const Color.fromRGBO(0, 122, 255, 0.25),
                    borderStrokeWidth: 2,
                    borderColor: Colors.blue,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: p.campusPoint,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_city,
                      color: Colors.lightBlueAccent,
                      size: 55,
                    ),
                  )
                ],
              ),
              if (p.lat != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        LatLng(p.lat!, p.lng!),
                        p.campusPoint,
                      ],
                      strokeWidth: 4,
                      color: Colors.yellow,
                    ),
                  ],
                ),
              if (p.lat != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(p.lat!, p.lng!),
                      width: 60,
                      height: 60,
                      child: ScaleTransition(
                        scale: Tween(begin: 1.0, end: 1.15).animate(markerAnim),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.redAccent,
                          size: 55,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 45,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 145,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          p.isWithinCampus
                              ? "Dalam Area Kampus"
                              : "Di Luar Area Kampus",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                p.isWithinCampus ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Jarak: ${p.distanceToCampus.toStringAsFixed(2)} meter",
                          style: const TextStyle(color: Colors.white),
                        ),
                        if (p.acc != null)
                          Text(
                            "Akurasi GPS: ${p.acc!.toStringAsFixed(1)} meter",
                            style: const TextStyle(color: Colors.white70),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: ElevatedButton(
              onPressed: p.isWithinCampus
                  ? () {
                      p.doPresensi(context);
                      showSuccessPopup();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    p.isWithinCampus ? Colors.deepPurple : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                "Presensi Sekarang",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
