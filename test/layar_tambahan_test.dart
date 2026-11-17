import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/app_store.dart';
import 'package:maju_tani/router.dart';

import 'figma_helper.dart';

/// Menampilkan [lokasi], mencocokkan posisi dengan Figma, lalu menutup layar.
Future<void> _uji(
  WidgetTester tester,
  String lokasi,
  Map<String, Offset> posisi, {
  void Function(AppStore s)? siapkan,
  Future<void> Function()? sebelum,
}) async {
  await siapkanLayarFigma(tester);
  await tampilkan(tester, lokasi, siapkan: siapkan);
  if (sebelum != null) await sebelum();
  cocokkanPosisi(tester, posisi);
  // Lepas layar agar pengatur waktu (mis. hitung mundur M22) ikut berhenti.
  await tester.pumpWidget(const SizedBox());
}

void main() {
  testWidgets('M15 Akun & Bantuan', (t) async {
    await _uji(t, Rute.akun, const {
      'Akun Saya': Offset(78, 54),
      'PP': Offset(42, 180),
      'Pak Pemilik': Offset(90, 161.5),
      'Pemilik · Mitra Maju Tani': Offset(90, 184.5),
      'Nama pengguna: pemilik': Offset(90, 204.5),
      'PENGATURAN': Offset(14, 253),
      'Akun': Offset(14, 268),
      'Ubah kata sandi': Offset(81, 317.5),
      'Sekarang: Besar': Offset(81, 407.5),
      'BANTUAN': Offset(14, 452),
      'Hubungi lewat WhatsApp': Offset(81, 516.5),
      'Tentang aplikasi': Offset(81, 654.5),
      'Keluar dari Akun': Offset(145.5, 786.5),
    });
  });

  testWidgets('M16 Notifikasi', (t) async {
    await _uji(t, Rute.notifikasi, const {
      'Semua (3)': Offset(26, 152),
      'Belum dibaca (2)': Offset(128, 153),
      'Sawi 120 kg belum ada harga jual': Offset(81, 206),
      'Tekan untuk lengkapi penjualan · 2 hari lalu': Offset(81, 246),
      'Bayam Rp 414.000 belum dibayar': Offset(81, 319),
      'Pak Dadang · sudah 4 hari': Offset(81, 359),
      'Pembayaran Kangkung masuk': Offset(81, 416.5),
      'Rp 200.000 dari Pak Ujang · 2 Nov': Offset(81, 437.5),
    });
  });

  testWidgets('M17 Cari Catatan (isian sedang diketik)', (t) async {
    await _uji(
      t,
      Rute.cari,
      const {
        'Kata kunci': Offset(14, 142),
        'Bayam': Offset(65, 196),
        'Semua': Offset(26, 263),
        'Belum dijual': Offset(106, 264),
        'Belum lunas': Offset(222, 264),
        'Lunas': Offset(27, 312),
        '1 catatan ditemukan': Offset(14, 352),
        'Bayam · 92 kg terjual': Offset(82, 397.5),
        'Panen 01 Nov 2026 · Pak Dadang': Offset(82, 418.5),
        'Belum dibayar': Offset(28, 460),
      },
      sebelum: () async {
        await t.tap(find.text('Bayam'));
        await t.pump();
      },
    );
  });

  testWidgets('M18 Ubah Data Transaksi', (t) async {
    await _uji(t, Rute.ubahTransaksi('t3'), const {
      'Ubah Data': Offset(78, 54),
      'Kangkung · No. PJ-009': Offset(78, 84),
      'DATA PANEN': Offset(14, 142),
      'Hasil panen': Offset(14, 157),
      'Tanggal panen': Offset(14, 191),
      '30 Okt 2026': Offset(63, 245),
      'Berat panen': Offset(14, 302),
      'Pengepul': Offset(14, 413),
      'Pak Ujang': Offset(63, 467),
      'DATA PENJUALAN': Offset(14, 524),
      'Tanggal terjual': Offset(14, 573),
      '01 Nov 2026': Offset(63, 627),
      'Berat terjual': Offset(14, 684),
      'Harga jual per kg': Offset(14, 795),
      'Rp 4.000': Offset(63, 849),
      'Perubahan akan dicatat': Offset(81, 919),
      'Simpan Perubahan': Offset(134.5, 727.5),
    });
  });

  testWidgets('M19 Riwayat Harga', (t) async {
    await _uji(t, Rute.riwayatHarga, const {
      'Riwayat Harga Jual': Offset(78, 54),
      'Sawi': Offset(26, 152),
      // Figma membulatkan lebar teks chip ke atas, jadi chip berikutnya bergeser 1–2 px.
      'Bayam': Offset(92, 153),
      'Kangkung': Offset(172.4, 153),
      'Selada': Offset(274.7, 153),
      'Daun Bawang': Offset(27, 201),
      'Rp 5.000': Offset(29, 256.5),
      '+4%': Offset(315, 262),
      'Mei': Offset(29, 450),
      'CATATAN HARGA': Offset(14, 491),
      'Sawi per bulan': Offset(14, 506),
      'Oktober 2026': Offset(27, 553),
      'Juli 2026': Offset(27, 682),
    });
  });

  testWidgets('M20 Rekap per Sayur', (t) async {
    await _uji(t, Rute.rekapSayur, const {
      'HAL PENTING': Offset(14, 142),
      'Panen terbanyak': Offset(81, 206.5),
      'Sawi · 225 kg (45%)': Offset(81, 227.5),
      'Daun Bawang · Rp 9.000/kg': Offset(81, 296.5),
      'Bayam · Rp 414.000': Offset(81, 365.5),
      'PER SAYUR': Offset(14, 410),
      'Rincian': Offset(14, 425),
      'Unduh Tabel (Excel)': Offset(131, 786.5),
    });
  });

  testWidgets('M21 Ubah Komoditas', (t) async {
    await _uji(t, Rute.ubahKomoditas('Sawi'), const {
      'Ubah Komoditas': Offset(78, 54),
      'Nama sayur': Offset(14, 142),
      'Satuan': Offset(14, 253),
      'Kilogram (kg)': Offset(63, 307),
      'Tampilkan saat catat panen': Offset(28, 377),
      'Ya': Offset(295, 392),
      'Data panen lama tetap aman': Offset(81, 470.5),
      '2 kali panen · 225 kg tidak ikut berubah': Offset(81, 491.5),
      'Simpan Perubahan': Offset(134.5, 727.5),
    });
  });

  testWidgets('M22 Lupa Kata Sandi', (t) async {
    await _uji(t, Rute.lupaSandi, const {
      'Lupa Kata Sandi': Offset(78, 54),
      '?': Offset(44, 170.5),
      'Masukkan nomor HP yang terdaftar. Kode 6 angka akan dikirim lewat SMS/WhatsApp.': Offset(83, 156),
      'Nomor HP': Offset(14, 238),
      '0812 3456 7890': Offset(63, 292),
      'Masukkan kode': Offset(28, 363),
      '4': Offset(44.5, 407),
      'Kirim ulang kode dalam 00:45': Offset(28, 458),
      'Kirim Kode': Offset(150, 727.5),
      'Kembali ke Masuk': Offset(121.5, 786.5),
    });
  });

  testWidgets('M23 Ubah Kata Sandi', (t) async {
    await _uji(t, Rute.ubahSandi, const {
      'Kata sandi lama': Offset(14, 142),
      'Kata sandi baru': Offset(14, 253),
      'Ulangi kata sandi baru': Offset(14, 364),
      'Syarat kata sandi': Offset(28, 489),
      '✓  Minimal 8 huruf/angka': Offset(28, 516),
      '○  Sama dengan kolom di atas': Offset(28, 570),
      'Simpan Kata Sandi': Offset(118.5, 727.5),
    });
  });

  void bulanLalu(AppStore s) => s.aturPeriode(PilihanPeriode.bulanLalu);

  testWidgets('M24 Pilih Periode', (t) async {
    await _uji(t, Rute.pilihPeriode, siapkan: bulanLalu, const {
      'Pilihan cepat': Offset(14, 142),
      'Hari ini': Offset(27, 185),
      'Minggu ini': Offset(106, 185),
      'Bulan ini': Offset(209, 185),
      '✓ Bulan lalu': Offset(27, 238),
      // Tanda ✓ memakai font cadangan sehingga chip "Bulan lalu" sedikit lebih sempit.
      '3 bulan': Offset(136.3, 238),
      'Oktober 2026': Offset(139.5, 297),
      '1': Offset(179, 369.5),
      '31': Offset(262.5, 569.5),
      'Dari': Offset(28, 638),
      'Terapkan': Offset(157, 727.5),
    });
  });

  testWidgets('M25 Cetak & Unduh Laporan', (t) async {
    await _uji(t, Rute.cetakLaporan, siapkan: bulanLalu, const {
      'Jenis dokumen': Offset(14, 142),
      'Laporan Penjualan': Offset(80, 187),
      'Rekap per Sayur': Offset(79, 265),
      'Riwayat Harga': Offset(79, 342),
      'Format & periode': Offset(14, 405),
      '✓ PDF': Offset(27, 448),
      // Tanda ✓ memakai font cadangan sehingga chip "PDF" sedikit lebih sempit.
      'Excel': Offset(100.1, 448),
      'Periode': Offset(14, 491),
      '1 – 31 Oktober 2026': Offset(63, 545),
      'Lihat Pratinjau': Offset(136.5, 727.5),
    });
  });

  testWidgets('M26 Pratinjau Dokumen', (t) async {
    await _uji(t, Rute.pratinjauDokumen, siapkan: bulanLalu, const {
      'MITRA MAJU TANI': Offset(74, 159.5),
      'Laporan Penjualan · Oktober 2026': Offset(74, 177.5),
      'Tanggal': Offset(28, 211),
      'Jumlah': Offset(281.5, 211),
      'Total penjualan': Offset(28, 335.5),
      'Sudah dibayar': Offset(28, 363),
      'Belum dibayar': Offset(28, 390),
      'Dicetak 5 Nov 2026 · Halaman 1 dari 1': Offset(28, 417),
      '1 halaman': Offset(27, 471),
      'Cetak': Offset(169.5, 727.5),
      'Unduh PDF': Offset(149.5, 786.5),
    });
  });

  testWidgets('M27 Dokumen Berhasil', (t) async {
    // Tunggu animasi muncul selesai sebelum mengukur posisi.
    await _uji(t, Rute.dokumenBerhasil, siapkan: bulanLalu, sebelum: () => t.pump(const Duration(seconds: 2)), const {
      'Laporan berhasil diunduh': Offset(14, 306),
      'Bisa langsung dicetak atau dikirim lewat WhatsApp.': Offset(14, 344),
      'Laporan-Penjualan-Okt-2026.pdf': Offset(87, 391),
      '184 KB  ·  1 halaman  ·  baru saja': Offset(87, 430),
      'Tersimpan di': Offset(31, 474),
      'Buka File': Offset(158, 727.5),
      'Kembali ke Laporan': Offset(114, 786.5),
    });
  });

  testWidgets('M28 Nota Pembayaran', (t) async {
    await _uji(t, Rute.notaPembayaran('t3'), const {
      'NOTA PEMBAYARAN': Offset(31, 159),
      'No. NP-2026-1102 · 2 Nov 2026': Offset(31, 186),
      'Pengepul': Offset(31, 219),
      'Sayur': Offset(31, 246),
      'Total harga': Offset(31, 273),
      'Dibayar sebelumnya': Offset(31, 300),
      'Dibayar hari ini': Offset(31, 327),
      'Sisa tagihan': Offset(31, 363.5),
      'Status: Dicicil · cicilan ke-1': Offset(31, 391),
      'Cetak Nota': Offset(148, 727.5),
      'Bagikan ke WhatsApp': Offset(104.5, 786.5),
    });
  });

  testWidgets('M29 Filter Komoditas', (t) async {
    await _uji(t, Rute.filterKomoditas, siapkan: (s) => s.aturSaringKomoditas(true), const {
      'Semua': Offset(27, 155),
      '✓ Aktif': Offset(108, 155),
      // Tanda ✓ memakai font cadangan sehingga chip "Aktif" sedikit lebih sempit.
      'Nonaktif': Offset(186.5, 155),
      'Sawi': Offset(83, 223),
      'Bayam': Offset(83, 304),
      'Kangkung': Offset(83, 385),
      'Selada': Offset(83, 466),
      'Terapkan Filter': Offset(134, 727.5),
      'Atur Ulang': Offset(152, 786.5),
    });
  });

  testWidgets('M30 Pengaturan', (t) async {
    await _uji(t, Rute.pengaturan, const {
      'Ukuran huruf': Offset(28, 156),
      'Sedang': Offset(41, 198),
      '✓ Besar': Offset(128, 198),
      // Tanda ✓ memakai font cadangan sehingga chip "Besar" sedikit lebih sempit.
      'Sangat besar': Offset(211.8, 198),
      // Kartu ukuran memuat baris "Ukuran tampilan" (bukan dari Figma): tiap teks di bawahnya turun 90 px.
      'Ukuran tampilan': Offset(28, 246),
      'Pengingat lengkapi harga': Offset(28, 359),
      'Notifikasi tiap sore': Offset(28, 378),
      'Cadangkan data': Offset(28, 408),
      'Terakhir: 10 Nov 2026': Offset(28, 427),
      'Cetak & unduh laporan': Offset(28, 506),
      'Simpan Pengaturan': Offset(114.5, 786.5),
    });
  });
}
