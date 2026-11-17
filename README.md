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

## 3. Menjalankan di simulator iPhone

Butuh **Xcode** (sudah terpasang di Mac ini).

Nyalakan simulator (daftar nama: `xcrun simctl list devices available`), lalu jalankan:

```bash
xcrun simctl boot "iPhone 18 Pro"
flutter run -d iPhone
```

`-d iPhone` memilih perangkat yang namanya diawali "iPhone". Lihat semua perangkat dengan
`flutter devices`, lalu `flutter run -d <id-perangkat>` bila perlu.

---

## 4. Menjalankan di iPhone asli

Butuh **Xcode**, **Apple ID** (akun gratis cukup), dan iPhone dengan iOS 15 atau lebih baru.
Kabel USB diperlukan **sekali** di awal; setelah itu bisa lewat Wi-Fi.

### A. Siapkan signing di Xcode (sekali saja)

1. Buka proyek di Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. **Xcode → Settings → Accounts** → **+** → **Apple ID**, lalu login. Tanpa langkah ini Xcode menulis
   **"No Accounts"** dan terminal menolak dengan `could not code sign the application` /
   `No profiles for 'com.majutani.majuTani' were found`.
3. Klik **Runner** (ikon biru) → target **Runner** → tab **Signing & Capabilities**.
4. Centang **Automatically manage signing**, lalu pilih akunmu di **Team** (mis. "Nama (Personal Team)").
5. Bila muncul **"Failed to register bundle identifier"**, ganti **Bundle Identifier** dengan yang unik,
   mis. `com.namamu.majutani`.

> **Untuk kontributor lain:** pengaturan Team dan Bundle Identifier ini khusus akun Apple masing-masing.
> Cukup ubah di Xcode di komputermu sendiri dan **jangan ikut di-commit** ke `main`
> (`ios/Runner.xcodeproj/project.pbxproj`).

### B. Siapkan iPhone

1. **Pengaturan → Privasi & Keamanan → Mode Pengembang** → hidupkan, iPhone restart lalu konfirmasi.
2. Colok iPhone ke Mac dengan kabel, buka kunci layarnya, lalu pilih **Percayai** (*Trust*).
3. (Opsional, supaya kabel bisa dicabut) di Xcode: **Window → Devices and Simulators** → pilih iPhone →
   centang **Connect via network**. Mac dan iPhone harus di Wi-Fi yang sama.

### C. Jalankan

```bash
flutter devices
flutter run -d <id-iPhone>
```

Ambil `<id-iPhone>` dari daftar `flutter devices` (contoh: `00008130-0011793E3C0A001C`).
Biarkan perintah ini yang membuka aplikasi di iPhone, lalu tekan `r` (hot reload), `R` (restart), `q` (berhenti).

> **Penting:** aplikasi versi *debug* di iOS 14+ **tidak bisa dibuka dengan mengetuk ikonnya** di layar utama
> (layar hitam bertuliskan "In iOS 14+, debug mode Flutter apps can only be launched from Flutter tooling…").
> Buka lewat `flutter run`, atau pakai versi release di bawah.

### D. Pasang versi release (bisa diketuk dari layar utama, tanpa Mac)

```bash
flutter run --release -d <id-iPhone>
```

Tidak ada hot reload; setiap perubahan kode harus dipasang ulang dengan perintah yang sama.
Data (akun dan catatan) tetap tersimpan di iPhone.

### E. Percayai developer (sekali saja)

Bila iPhone menampilkan **"Untrusted Developer"**: **Pengaturan → Umum → VPN & Manajemen Perangkat** →
pilih profil **Apple Development: email-kamu** → **Percayai**.

### Masalah umum

| Pesan / gejala | Penyebab dan jalan keluar |
|---|---|
| `could not code sign the application`, Xcode: **No Accounts** | Apple ID belum ditambahkan di Xcode. Ikuti langkah A. |
| `No profiles for '…' were found` | Profil belum dibuat. Pilih Team (langkah A), lalu jalankan sekali dari Xcode dengan **Cmd+R**. |
| `Failed to register bundle identifier` | Bundle Identifier sudah dipakai orang lain. Ganti dengan yang unik. |
| Layar hitam "debug mode Flutter apps can only be launched from Flutter tooling" | Jangan ketuk ikonnya. Jalankan lewat `flutter run`, atau pakai versi release (langkah D). |
| `The Dart VM Service was not discovered after 60 seconds` | (1) macOS: **Pengaturan Sistem → Privasi & Keamanan → Otomasi**, izinkan terminal/VS Code mengontrol **Xcode**, dan klik **Izinkan** bila muncul dialog. (2) iPhone: **Privasi & Keamanan → Jaringan Lokal**, hidupkan untuk aplikasi ini. (3) Pakai kabel, bukan Wi-Fi: Wi-Fi di iOS 26 lebih lambat. (4) Atau pakai versi release. |
| iPhone menolak membuka aplikasi: "Untrusted Developer" | Langkah E. |
| Aplikasi tidak mau terbuka setelah seminggu | Akun Apple gratis hanya berlaku **7 hari**. Pasang ulang dengan `flutter run`. |

---

## 5. Menjalankan di Android

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

## 6. Pemakaian pertama

1. Saat pertama dibuka, layar **Buat Akun** muncul. Isi nama pengguna dan kata sandi
   (minimal 8 huruf/angka dan ada angkanya).
2. Satu perangkat = satu akun pemilik. Setelah akun dibuat, berikutnya cukup **Masuk**.
3. Kata sandi disimpan sebagai hash (PBKDF2-SHA256), bukan teks asli.
4. Cadangkan data dari **Akun › Pengaturan › Cadangkan data**.

Akun dan data di tiap perangkat/browser terpisah: akun yang dibuat di simulator iPhone
tidak ada di browser, dan sebaliknya.

---

## 7. Prakiraan harga

Layar **Riwayat Harga** menampilkan prakiraan harga per kg untuk **bulan depan** tiap sayur.
Datanya dari **rata-rata harga jual per bulan** (jumlah penjualan ÷ jumlah kg terjual), maksimal 6 bulan terakhir
yang ada penjualannya. Kodenya di `lib/data/prakiraan.dart`.

Misalkan deret harga bulanan `y₁ … yₙ` (lama → baru). Tiga metode dihitung:

| Metode | Rumus prakiraan bulan depan |
|---|---|
| **Rata-rata bergerak 3 bulan** | `ŷ = (yₙ₋₂ + yₙ₋₁ + yₙ) / 3` |
| **Pemulusan eksponensial** (α = 0,5) | `S₁ = y₁`, `Sₜ = α·yₜ + (1 − α)·Sₜ₋₁`, `ŷ = Sₙ` |
| **Tren linear** (kuadrat terkecil) | `b = Σ(x − x̄)(y − ȳ) / Σ(x − x̄)²`, `a = ȳ − b·x̄`, `ŷ = a + b·n` dengan `x = 0, 1, …, n−1` |

**Memilih metode.** Tiap metode diuji mundur: meramal harga bulan ke-`t` dari bulan-bulan sebelumnya (`t ≥ 3`),
lalu dibandingkan dengan harga sebenarnya memakai **MAPE** (rata-rata galat persentase mutlak):

```
MAPE = (100% / m) · Σ |yₜ − ŷₜ| / yₜ
```

Metode dengan MAPE terkecil yang dipakai. Keandalan: MAPE < 5% **Tinggi**, 5–10% **Cukup**, ≥ 10% **Rendah**.

**Aturan data**

| Bulan yang punya penjualan | Yang ditampilkan |
|---|---|
| 0–1 | Tidak ada prakiraan |
| 2–3 | Tren linear saja, keandalan "Belum bisa diukur" (data terlalu sedikit untuk diuji) |
| ≥ 4 | Metode terbaik menurut MAPE, lengkap dengan keandalannya |

**Contoh** (data contoh Sawi, Mei–Okt 2026: 4.200, 4.500, 4.300, 4.600, 4.800, 5.000):

| Metode | Prakiraan | MAPE |
|---|---|---|
| Rata-rata bergerak 3 bulan | Rp 4.800 | 5,64% |
| Pemulusan eksponensial | Rp 4.816 | 5,39% |
| **Tren linear** (dipilih) | **Rp 5.087** | **5,24%** |

Batasan: prakiraan hanya memakai harga masa lalu, tidak memperhitungkan musim, cuaca, atau harga pasar,
dan dengan data bulanan yang sedikit hasilnya kasar. Anggap sebagai pegangan, bukan kepastian.

---

## 8. Test

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

## 9. Struktur kode

| Folder / file | Isi |
|---|---|
| `lib/main.dart` | Titik awal: membuka database lalu menjalankan aplikasi |
| `lib/router.dart` | Semua rute layar (kode M00–M30 sesuai frame Figma) dan penjaga login |
| `lib/data/app_store.dart` | Sumber data aplikasi (Provider); setiap perubahan ditulis ke database |
| `lib/data/database.dart` | Tabel SQLite dan baca/tulis data |
| `lib/data/kata_sandi.dart` | Hash dan pemeriksaan kata sandi |
| `lib/data/dokumen.dart` | Pembuatan laporan PDF/Excel dan nota pembayaran |
| `lib/data/prakiraan.dart` | Perhitungan prakiraan harga bulan depan (tiga metode + uji mundur MAPE) |
| `lib/data/sample_data.dart` | Data contoh untuk test dan pratinjau |
| `lib/models/` | Model data (transaksi, komoditas, notifikasi, ...) |
| `lib/screens/` | Layar-layar aplikasi |
| `lib/widgets/`, `lib/theme/` | Komponen tampilan, warna, dan tipografi |

## 10. Belum tersedia

- Server backend (sinkron antar perangkat, lupa kata sandi lewat SMS/WhatsApp).
- Mengembalikan data dari file cadangan.
- Pengingat harian "lengkapi harga".
- Nomor WhatsApp tim pengembang di menu Akun.
