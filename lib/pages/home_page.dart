import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'set_campus_page.dart';
import '../providers/location_provider.dart';
import 'gps_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String timeNow = "00:00:00";
  late Timer timer;

  bool? lastFakeGpsStatus; // ← untuk mencegah spam notif

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      setState(() {
        timeNow =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().startTracking();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LocationProvider>();

    // ======================================================
    //          FAKE GPS / MOCK LOCATION NOTIFICATION
    // ======================================================
    if (lastFakeGpsStatus != p.isFakeGps) {
      lastFakeGpsStatus = p.isFakeGps;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              p.isFakeGps
                  ? "⚠️ Fake GPS terdeteksi! Lokasi tidak valid."
                  : "GPS Aman ✔",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: p.isFakeGps ? Colors.red : Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xffe8ecff),
      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            //                     HEADER GLASS EFFECT
            // ======================================================
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff6A5AE0), Color(0xff8E44AD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SetCampusPage()),
                              );
                            },
                          ),
                        ),
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage("assets/profile.png"),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Abdullah Andrian S",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          timeNow,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          p.isWithinCampus
                              ? "Status: Dalam Area Kampus"
                              : "Status: Di Luar Area Kampus",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ======================================================
                    //                     MINI MAP GLASS
                    // ======================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            height: 260,
                            child: FlutterMap(
                              mapController: p.mapController,
                              options: MapOptions(
                                initialCenter: p.campusPoint,
                                initialZoom: 16,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  userAgentPackageName: "com.example.gps_app",
                                ),
                                if (p.lat != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(p.lat!, p.lng!),
                                        width: 55,
                                        height: 55,
                                        child: const Icon(
                                          Icons.location_on,
                                          size: 50,
                                          color: Colors.red,
                                        ),
                                      )
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ======================================================
                    //        LOKASI USER CARD GLASS
                    // ======================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _glassCard(
                        child: Text(
                          p.lat == null
                              ? "Lokasi Anda: Mengambil GPS..."
                              : "Lokasi Anda:  Lat: ${p.lat!.toStringAsFixed(6)}   |   Lng: ${p.lng!.toStringAsFixed(6)}",
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ======================================================
                    //        INFO KAMPUS GLASS
                    // ======================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _glassCard(
                        child: Column(
                          children: [
                            const Text(
                              "Kampus UNBIN Bogor",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Jarak: ${p.distanceToCampus.toStringAsFixed(2)} meter",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _JamInfo(
                                  title: "Jam Masuk",
                                  value: p.jamMasuk ?? "--:--",
                                ),
                                _JamInfo(
                                  title: "Jam Keluar",
                                  value: p.jamKeluar ?? "--:--",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ======================================================
                    //              BUTTON PRESENSI
                    // ======================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: p.isWithinCampus
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const GpsPage()),
                                )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(double.infinity, 55),
                        ),
                        child: const Text(
                          "PRESENSI",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  //              Glass Card Reusable Widget
  // ======================================================
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.28),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ======================================================
class _JamInfo extends StatelessWidget {
  final String title;
  final String value;

  const _JamInfo({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
