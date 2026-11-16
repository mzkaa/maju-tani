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
      'Bulan ini': Offset(63, 154),
      'Bulan lalu': Offset(144.5, 155.5),
      'Pilih tanggal': Offset(235.5, 155.5),
      '1 Okt – 5 Nov 2026': Offset(49, 209),
      'Total penjualan': Offset(103, 264),
      'Rp 2.025.000': Offset(103, 294),
      'Rata-rata Rp 5.400 per kg': Offset(103, 330),
      'Rp 1.491.000': Offset(103, 426),
      '74% dari total penjualan': Offset(103, 462),
      'Rp 534.000': Offset(103, 558),
      '26% · Bayam dan Kangkung': Offset(103, 594),
      'Hasil panen': Offset(103, 660),
      '500 kg': Offset(103, 690),
      '375 kg terjual · 120 kg menunggu': Offset(103, 726),
      'Penjualan per sayur': Offset(32, 800),
      'Sawi': Offset(32, 880),
      'Bayam': Offset(32, 947),
      'Belum dibayar Rp 414 rb': Offset(32, 1007),
      'Selada': Offset(32, 1044),
      'Daun Bawang': Offset(32, 1111),
      'Kangkung': Offset(32, 1178),
      'Belum dibayar Rp 120 rb': Offset(32, 1238),
      'Lihat Rekap per Sayur': Offset(123.5, 1307.5),
      'Unduh Laporan (PDF)': Offset(124.5, 1366.5),
      'Unduh Excel': Offset(161, 1425.5),
      'Keuntungan belum bisa dihitung karena biaya produksi belum dicatat.': Offset(66, 1487),
    });
  });

  testWidgets('M12 Data Komoditas sesuai Figma', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.komoditas);
    // Figma: "Semua (5)" & "Aktif (4)"; data contoh juga memuat Daun Bawang (ada di M05 & M20).
    cocokkanPosisi(tester, const {
      'Komoditas': Offset(20, 54),
      'Jenis sayur yang dipanen': Offset(20, 84),
      'Semua (6)': Offset(25, 152),
      'Aktif (5)': Offset(119, 152),
      // Figma x 201; angka "5" sedikit lebih sempit dari "4" sehingga chip ini bergeser 1,5 px.
      'Nonaktif (1)': Offset(199.5, 152),
      'Sawi': Offset(85, 201),
      'Harga terakhir Rp 5.000/kg': Offset(85, 224),
      '2 kali panen · 225 kg': Offset(85, 243),
      'Bayam': Offset(85, 292),
      'Harga terakhir Rp 4.500/kg': Offset(85, 315),
      '1 kali panen · 95 kg': Offset(85, 334),
      'Kangkung': Offset(85, 383),
      'Selada': Offset(85, 474),
      '1 kali panen · 60 kg': Offset(85, 516),
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
