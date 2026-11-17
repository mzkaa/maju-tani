import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/router.dart';

import 'figma_helper.dart';

void main() {
  testWidgets('M11 Laporan sesuai Figma', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.laporan);
    cocokkanPosisi(tester, const {
      'Laporan': Offset(20, 54),
      'Rekap penjualan usaha': Offset(20, 84),
      'Bulan ini': Offset(46, 150),
      'Bulan lalu': Offset(126.8, 151),
      'Pilih tanggal': Offset(216.1, 151),
      '1 Okt – 5 Nov 2026': Offset(42, 202),
      'Total penjualan': Offset(34, 247),
      'Rp 2.025.000': Offset(34, 269),
      'Rata-rata Rp 5.400 per kg': Offset(34, 304),
      'Rp 1.491.000': Offset(34, 377),
      'Rp 534.000': Offset(201, 377),
      '500 kg': Offset(304.7, 424),
      'Penjualan per sayur': Offset(34, 489),
      'Sawi': Offset(34, 522),
      'Bayam': Offset(34, 568),
      'Selada': Offset(34, 614),
      'Daun Bawang': Offset(34, 660),
      'Kangkung': Offset(34, 706),
      'Unduh Laporan (PDF)': Offset(124.9, 781.5),
      'Unduh Excel': Offset(235.9, 838.5),
      'Keuntungan belum bisa dihitung karena biaya produksi belum dicatat.': Offset(41, 889),
    });
  });

  testWidgets('M12 Data Komoditas sesuai Figma', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.komoditas);
    // Figma: "Semua (5)" & "Aktif (4)"; data contoh juga memuat Daun Bawang (ada di M05 & M20).
    cocokkanPosisi(tester, const {
      'Komoditas': Offset(20, 54),
      'Jenis sayur yang dipanen': Offset(20, 84),
      'Semua (6)': Offset(46, 155),
      'Aktif (5)': Offset(138.6, 155),
      // Figma x 201; angka "5" sedikit lebih sempit dari "4" sehingga chip ini bergeser 1,5 px.
      'Nonaktif (1)': Offset(219.5, 155),
      'Sawi': Offset(79, 225),
      'Bayam': Offset(79, 293),
      'Kangkung': Offset(79, 361),
      'Selada': Offset(79, 429),
    });
  });

  testWidgets('M13 Tambah Komoditas sesuai Figma', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.tambahKomoditas);
    cocokkanPosisi(tester, const {
      'Tambah Komoditas': Offset(78, 54),
      'Sayur baru akan muncul di Catat Panen': Offset(78, 84),
      'Nama sayur': Offset(17, 142),
      'Tomat': Offset(66, 196),
      'Contoh: Tomat, Buncis, Terong': Offset(17, 250),
      'Satuan': Offset(17, 289),
      'Kilogram (kg)': Offset(66, 343),
      'Tampilkan saat catat panen': Offset(31, 417),
      'Pilih "Ya" agar sayur ini bisa dipilih': Offset(31, 447),
      'Ya': Offset(292, 432),
      'Simpan Komoditas': Offset(134, 727.5),
      'Batal': Offset(190.5, 786.5),
    });
  });
}
