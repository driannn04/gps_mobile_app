import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class SetCampusPage extends StatefulWidget {
  const SetCampusPage({super.key});

  @override
  State<SetCampusPage> createState() => _SetCampusPageState();
}

class _SetCampusPageState extends State<SetCampusPage> {
  late TextEditingController latC;
  late TextEditingController lngC;

  @override
  void initState() {
    super.initState();
    final p = context.read<LocationProvider>();
    latC = TextEditingController(text: p.campusPoint.latitude.toString());
    lngC = TextEditingController(text: p.campusPoint.longitude.toString());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LocationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Atur Lokasi Kampus"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Latitude", style: TextStyle(fontSize: 16)),
            TextField(
              controller: latC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Longitude", style: TextStyle(fontSize: 16)),
            TextField(
              controller: lngC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                double? lat = double.tryParse(latC.text.trim());
                double? lng = double.tryParse(lngC.text.trim());

                if (lat == null || lng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lat/Lng tidak valid")),
                  );
                  return;
                }

                p.updateCampusLocation(lat, lng);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Lokasi kampus diperbarui")),
                );

                Navigator.pop(context);
              },
              child: const Text("SIMPAN"),
            )
          ],
        ),
      ),
    );
  }
}
