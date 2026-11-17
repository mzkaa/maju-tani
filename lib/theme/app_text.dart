import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Gaya teks dari Figma. Semua memakai Plus Jakarta Sans.
///
/// `height` = tinggi baris Figma dibagi ukuran huruf. Tinggi baris "auto"
/// di Figma dibiarkan `null` agar memakai metrik bawaan font.
abstract final class AppText {
  static const font = 'PlusJakartaSans';

  // inherit: false agar tidak ikut gaya bawaan Material (jarak huruf 0,25 & tinggi baris 1,43).
  static const _dasar = TextStyle(
    inherit: false,
    fontFamily: font,
    leadingDistribution: TextLeadingDistribution.even,
    textBaseline: TextBaseline.alphabetic,
  );

  // Header
  static final sapaan = _dasar.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: const Color(0xD9FFFFFF),
  );
  static final namaPengguna = _dasar.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: const Color(0xFFFFFFFF),
  );

  // Judul seksi: label kapital + judul
  static final judulSeksi = _dasar.copyWith(
    fontSize: 19,
    fontWeight: FontWeight.w800,
    height: 1.35,
    letterSpacing: -0.38,
    color: AppColors.teksJudul,
  );

  // Kartu
  static final judulTugas = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 1.35,
    color: AppColors.teksJudul,
  );
  static final keterangan = _dasar.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.teksKedua,
  );

  // Kartu saldo
  static final labelSaldo = _dasar.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teksKeduaAlt);
  static final angkaSaldo = _dasar.copyWith(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.teksUtama);
  static final persen = _dasar.copyWith(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.hijauTua);
  static final legenda = _dasar.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teksKeduaAlt);

  // Chip tanggal & tombol kecil
  static final tanggal = _dasar.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.hijauTua,
  );

  // Kartu harga
  static final harga = _dasar.copyWith(fontSize: 23, fontWeight: FontWeight.w800, color: AppColors.teksUtama);
  static final satuan = _dasar.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teksSamar);
  static final lencana = _dasar.copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFFFFFFF));
  static final bulanGrafik = _dasar.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teksSamar);
  static final bulanGrafikAktif = _dasar.copyWith(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.hijauTua);

  // M00 Layar Pembuka
  static final splashJudul = _dasar.copyWith(fontSize: 25, fontWeight: FontWeight.w800, color: const Color(0xFFFFFFFF));
  static final splashSub = _dasar.copyWith(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xB3FFFFFF));
  static final splashVersi = _dasar.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0x73FFFFFF));

  // M01 Masuk: sambutan & logo
  static final namaUsaha = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 28 / 16,
    color: const Color(0xFFFFFFFF),
  );
  static final slogan = _dasar.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 24 / 14,
    color: const Color(0xCCFFFFFF),
  );
  static final sambutanJudul = _dasar.copyWith(
    fontSize: 25,
    fontWeight: FontWeight.w800,
    height: 40 / 25,
    letterSpacing: -0.375,
    color: const Color(0xFFFFFFFF),
  );
  static final sambutanIsi = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 28 / 16,
    color: const Color(0xFFFFFFFF),
  );

  // Isian (Input V2 versi kaca)
  static final labelIsian = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 28 / 16,
    color: AppColors.teksJudul,
  );
  static final nilaiIsian = _dasar.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 28 / 17,
    color: AppColors.teksJudul,
  );
  static final akhiranIsian = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 28 / 16,
    color: AppColors.teksKedua,
  );
  static final bantuanIsian = _dasar.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 24 / 14,
    color: AppColors.teksKedua,
  );

  // Tombol utama & kotak bantuan
  static final tombol = _dasar.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 26 / 17,
    color: const Color(0xFFFFFFFF),
  );
  static final pesanBantuan = _dasar.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 24 / 14,
    color: AppColors.teksJudul,
  );

  // Header ringkas, kartu transaksi, detail transaksi
  static final judulHeader = _dasar.copyWith(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFFFFFFFF));
  static final keteranganHeader = _dasar.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: const Color(0xC7FFFFFF),
  );
  static final badge = _dasar.copyWith(fontSize: 12, fontWeight: FontWeight.w700, height: 24 / 12);
  static final chip = _dasar.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 28 / 13,
    color: AppColors.teksJudul,
  );
  static final keteranganKartu = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 28 / 16,
    color: AppColors.teksKedua,
  );
  static final nilaiAngka = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 28 / 16,
    color: AppColors.teksJudul,
  );
  static final tombolGaris = _dasar.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 26 / 17,
    color: AppColors.hijauTuaAlt,
  );
  static final labelSisa = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 28 / 16,
    color: AppColors.teksKedua,
  );
  static final angkaSisa = _dasar.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 44 / 28,
    letterSpacing: -0.42,
  );
  static final isiKartu = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 28 / 16,
    color: AppColors.teksJudul,
  );
  static final judulPerjalanan = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 30 / 16,
    letterSpacing: -0.08,
    color: const Color(0xFFFFFFFF),
  );
  static final langkahJudul = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 28 / 16,
    color: const Color(0xFFFFFFFF),
  );
  static final langkahWaktu = _dasar.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 24 / 14,
    color: const Color(0x99FFFFFF),
  );
  static final langkahIsi = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 28 / 16,
    color: const Color(0xE0FFFFFF),
  );

  // Catat Panen (M05–M08)
  static final langkahTeks = _dasar.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 28 / 16,
    color: AppColors.hijauTuaAlt,
  );
  static final judulBagian = _dasar.copyWith(
    fontSize: 19,
    fontWeight: FontWeight.w800,
    height: 30 / 19,
    letterSpacing: -0.095,
    color: AppColors.teksJudul,
  );
  static final dipilih = _dasar.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 24 / 14,
    color: AppColors.hijauTuaAlt,
  );
  static final judulSukses = _dasar.copyWith(
    fontSize: 25,
    fontWeight: FontWeight.w800,
    height: 40 / 25,
    letterSpacing: -0.375,
    color: AppColors.teksJudul,
  );
  static final labelGelap = _dasar.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: const Color(0xA6FFFFFF),
  );
  static final nilaiGelap = _dasar.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: const Color(0xFFFFFFFF),
  );
  static final catatanGelap = _dasar.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: const Color(0xD1FFFFFF),
  );

  // Laporan & Komoditas (M11–M13)

  // Layar tambahan (M15–M30)

  /// Pembuat gaya untuk teks yang hanya muncul sekali.
  static TextStyle gaya(double ukuran, FontWeight tebal, Color warna, {double? tinggi, double? jarak}) =>
      _dasar.copyWith(fontSize: ukuran, fontWeight: tebal, color: warna, height: tinggi, letterSpacing: jarak);

  static final labelBagian = gaya(12, FontWeight.w700, AppColors.hijau, jarak: 1.44);
  static final judulBagianKecil = gaya(18, FontWeight.w800, AppColors.teksUtama, jarak: -0.36);
  static final barisJudul = gaya(15, FontWeight.w700, AppColors.teksUtama);
  static final barisKeterangan = gaya(14, FontWeight.w500, AppColors.teksKeduaAlt);
  static final chipGradien = gaya(14, FontWeight.w700, const Color(0xFFFFFFFF));
  static final chipGradienNonaktif = gaya(14, FontWeight.w600, AppColors.teksUtama);
  static final tebal14 = gaya(14, FontWeight.w700, AppColors.teksUtama, tinggi: 1.35);
  static final sedang14Samar = gaya(14, FontWeight.w500, const Color(0xB30F1F19), tinggi: 1.35); // 70%
  static final sedang13Samar = gaya(13, FontWeight.w500, const Color(0x990F1F19), tinggi: 1.35); // 60%
}
