import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresensiProvider extends ChangeNotifier {
  bool sudahPresensi = false;
  String? lastPresensiDate;

  List<String> history = [];

  PresensiProvider() {
    loadData();
  }

  Future<void> loadData() async {
    final pref = await SharedPreferences.getInstance();

    sudahPresensi = pref.getBool("sudahPresensi") ?? false;
    lastPresensiDate = pref.getString("lastPresensiDate");

    history = pref.getStringList("history") ?? [];

    _cekResetHarian();
    notifyListeners();
  }

  Future<void> _cekResetHarian() async {
    final sekarang = DateTime.now().toString().split(" ")[0];

    if (lastPresensiDate != sekarang) {
      final pref = await SharedPreferences.getInstance();
      sudahPresensi = false;
      pref.setBool("sudahPresensi", false);
      pref.setString("lastPresensiDate", sekarang);

      notifyListeners();
    }
  }

  Future<void> simpanPresensi() async {
    final pref = await SharedPreferences.getInstance();
    final now = DateTime.now();

    sudahPresensi = true;
    lastPresensiDate = now.toString().split(" ")[0];

    String record =
        "Presensi: ${now.hour}:${now.minute.toString().padLeft(2, '0')} — ${lastPresensiDate!}";

    history.add(record);

    await pref.setBool("sudahPresensi", true);
    await pref.setString("lastPresensiDate", lastPresensiDate!);
    await pref.setStringList("history", history);

    notifyListeners();
  }
}
