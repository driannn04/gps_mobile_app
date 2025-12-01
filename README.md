🛰 GPS Presensi UNBIN

Aplikasi presensi berbasis lokasi menggunakan Flutter, Flutter Map & Geolocator.
Digunakan untuk melakukan presensi otomatis saat pengguna berada pada radius tertentu dari lokasi kampus.

🚀 Fitur Aplikasi
Fitur	Status
Menampilkan map lokasi user realtime	✔
Menentukan titik koordinat kampus	✔
Notifikasi presensi berhasil dengan popup	✔
Presensi hanya aktif bila user berada dalam radius kampus	✔
Menyimpan jam masuk & jam pulang secara lokal (SharedPreferences)	✔
Akurasi GPS + tracking posisi otomatis	✔
🗺 Cara Kerja Aplikasi

Aplikasi mengambil GPS device menggunakan geolocator

Lokasi kampus dijadikan acuan (default UNBIN Bogor, bisa diganti)

Jika user berada < 100 meter dari kampus → tombol presensi aktif

Klik Presensi Sekarang → data disimpan otomatis (masuk & pulang)

Riwayat presensi tersimpan di lokal device, reset per hari

📲 Cara Instal & Jalankan
1. Clone project
git clone https://github.com/username/repository.git
cd repository

2. Install dependencies
flutter pub get

3. Jalankan aplikasi
flutter run

🔐 Permissions Android (WAJIB)

Agar GPS berjalan & map tidak diblokir, tambahkan ini di android/app/src/main/AndroidManifest.xml 👇

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET" />


Pastikan juga bagian <application> memiliki:

android:usesCleartextTraffic="true"


📍 Tanpa izin lokasi & internet, map bisa tidak muncul/blokir di Android.

📄 Struktur Folder Utama
/lib
 ├── main.dart                # Root aplikasi
 ├── pages/
 │    ├── home_page.dart      # Dashboard utama + mini map
 │    ├── gps_page.dart       # Halaman presensi & map full view
 │    └── set_campus_page.dart# Ubah lokasi kampus
 ├── providers/
 │    └── location_provider.dart
 ├── services/
 │    └── location_service.dart
 └── models/
      └── location_model.dart

🔥 Screenshot Preview (optional)

Bisa tambahkan gambar nanti agar repo lebih profesional.

🤝 Kontribusi

Pull Request terbuka untuk peningkatan fitur seperti:

✔ Export data presensi
✔ Backend Firebase/REST API
✔ Mode offline lebih kuat

📚 Teknologi
Tools	Digunakan untuk
Flutter	Main framework
Flutter Map + OSM	Menampilkan peta
Geolocator	Tracking posisi GPS
Shared Preferences	Penyimpanan lokal presensi
🧑 Author

Developer: Abdullah Andrian Saputra