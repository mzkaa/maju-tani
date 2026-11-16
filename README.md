# Mitra Maju Tani

Aplikasi pencatatan **panen, penjualan, dan pembayaran** untuk UMKM pertanian, dibuat dengan Flutter.
Satu kode yang sama berjalan di **browser (web)**, **iOS**, dan **Android**.

Semua data (akun, catatan panen, penjualan, pembayaran, komoditas) disimpan di **database SQLite lokal**
di perangkat masing-masing. Belum ada server backend, jadi data di browser, iPhone, dan HP Android
**tidak saling tersambung**.

---

## 1. Persiapan (sekali saja)

### Flutter SDK

Flutter di Mac ini ada di `~/Developer/flutter`. Agar perintah `flutter` dikenal di terminal,
tambahkan ke PATH (taruh di `~/.zshrc` supaya permanen):

```bash
export PATH="$HOME/Developer/flutter/bin:$PATH"
```

Buka terminal baru, lalu cek:

```bash
flutter --version
```

### Paket proyek

Dari folder proyek:

```bash
flutter pub get
```

> File `web/sqlite3.wasm` dan `web/sqflite_sw.js` (database untuk versi web) sudah ada di repo.
> Bila hilang atau versi `sqflite_common_ffi_web` diperbarui, buat ulang dengan
> `dart run sqflite_common_ffi_web:setup`.

---

## 2. Menjalankan di browser (paling mudah)

```bash
flutter run -d web-server --web-port 8080
```

1. Tunggu sampai muncul `lib/main.dart is being served at http://localhost:8080`
   (kompilasi pertama bisa beberapa menit).
2. Buka **http://localhost:8080** di browser. Bila halaman masih putih, muat ulang (refresh) sekali.
3. Selama perintah di atas berjalan, setelah mengubah kode tekan di terminal:
   - `r` — *hot reload*: perubahan tampilan langsung terlihat.
   - `R` — *hot restart*: aplikasi dimulai ulang (perlu untuk perubahan di `main.dart`).
   - `q` — berhenti.

Alternatif dengan Chrome yang dibuka otomatis:

```bash
flutter run -d chrome
```

**Mencoba di HP lewat browser:** jalankan dengan `--web-hostname 0.0.0.0`, lalu buka
`http://<IP-Mac>:8080` dari HP yang tersambung ke Wi-Fi yang sama.

---

## 3. Menjalankan di iPhone (simulator)

Butuh **Xcode** (sudah terpasang di Mac ini).

Nyalakan simulator (daftar nama: `xcrun simctl list devices available`), lalu jalankan:

```bash
xcrun simctl boot "iPhone 18 Pro"
flutter run -d iPhone
```

`-d iPhone` memilih perangkat yang namanya diawali "iPhone". Lihat semua perangkat dengan
`flutter devices`, lalu `flutter run -d <id-perangkat>` bila perlu.

---

## 4. Menjalankan di Android

Kode sudah siap untuk Android, tetapi Mac ini **belum punya Android SDK**.
Pasang salah satu:

- **Android Studio** (https://developer.android.com/studio) — SDK & emulator dipasang lewat wizard, atau
- SDK saja (command-line tools), lalu arahkan Flutter: `flutter config --android-sdk <lokasi-sdk>`.

Cek dengan `flutter doctor`, nyalakan emulator atau colok HP Android (aktifkan *USB debugging*),
lihat id-nya dengan `flutter devices`, lalu:

```bash
flutter run -d <id-perangkat>
```

Membuat file APK untuk dipasang di HP:

```bash
flutter build apk --release
```

Hasilnya ada di `build/app/outputs/flutter-apk/app-release.apk`.

---

## 5. Pemakaian pertama

1. Saat pertama dibuka, layar **Buat Akun** muncul. Isi nama pengguna dan kata sandi
   (minimal 8 huruf/angka dan ada angkanya).
2. Satu perangkat = satu akun pemilik. Setelah akun dibuat, berikutnya cukup **Masuk**.
3. Kata sandi disimpan sebagai hash (PBKDF2-SHA256), bukan teks asli.
4. Cadangkan data dari **Akun › Pengaturan › Cadangkan data**.

Akun dan data di tiap perangkat/browser terpisah: akun yang dibuat di simulator iPhone
tidak ada di browser, dan sebaliknya.

---

## 6. Test

```bash
flutter analyze
flutter test
```

Test layar memakai **data contoh** (`lib/data/sample_data.dart`) dengan tanggal tetap
5 Nov 2026 agar posisi teks bisa dibandingkan dengan desain Figma.

Merender satu layar ke PNG untuk dibandingkan dengan Figma:

```bash
flutter test test_pratinjau/pratinjau_test.dart --dart-define=RUTE=/beranda --dart-define=KELUAR=/tmp/beranda.png
```

---

## 7. Struktur kode

| Folder / file | Isi |
|---|---|
| `lib/main.dart` | Titik awal: membuka database lalu menjalankan aplikasi |
| `lib/router.dart` | Semua rute layar (kode M00–M30 sesuai frame Figma) dan penjaga login |
| `lib/data/app_store.dart` | Sumber data aplikasi (Provider); setiap perubahan ditulis ke database |
| `lib/data/database.dart` | Tabel SQLite dan baca/tulis data |
| `lib/data/kata_sandi.dart` | Hash dan pemeriksaan kata sandi |
| `lib/data/dokumen.dart` | Pembuatan laporan PDF/Excel dan nota pembayaran |
| `lib/data/sample_data.dart` | Data contoh untuk test dan pratinjau |
| `lib/models/` | Model data (transaksi, komoditas, notifikasi, ...) |
| `lib/screens/` | Layar-layar aplikasi |
| `lib/widgets/`, `lib/theme/` | Komponen tampilan, warna, dan tipografi |

## 8. Belum tersedia

- Server backend (sinkron antar perangkat, lupa kata sandi lewat SMS/WhatsApp).
- Mengembalikan data dari file cadangan.
- Pengingat harian "lengkapi harga".
- Nomor WhatsApp tim pengembang di menu Akun.
