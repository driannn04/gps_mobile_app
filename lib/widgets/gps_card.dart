import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/location_model.dart';

class GPSCard extends StatelessWidget {
  final LocationModel loc;

  const GPSCard({super.key, required this.loc});

  @override
  Widget build(BuildContext context) {
    final bool hadir = loc.distanceFromCampus <= 100;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // ganti withOpacity() -> Color.fromRGBO
              color: Color.fromRGBO(255, 255, 255, 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                // ganti withOpacity()
                color: Color.fromRGBO(255, 255, 255, 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  // ganti withOpacity()
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hadir ? "Dalam Area Kampus" : "Di Luar Area Kampus",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: hadir ? Colors.greenAccent : Colors.redAccent,
                    shadows: [
                      Shadow(
                        // ganti withOpacity()
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                        blurRadius: 6,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Detail lokasi
                _infoRow("Latitude", loc.latitude.toStringAsFixed(6)),
                _infoRow("Longitude", loc.longitude.toStringAsFixed(6)),
                _infoRow("Akurasi GPS", "${loc.accuracy.toStringAsFixed(1)} m"),
                const SizedBox(height: 8),

                // Jarak ke kampus
                Text(
                  "Jarak ke Kampus: ${loc.distanceFromCampus.toStringAsFixed(2)} m",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        // ganti withOpacity()
                        color: Color.fromRGBO(0, 0, 0, 0.26),
                        blurRadius: 5,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title:",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
