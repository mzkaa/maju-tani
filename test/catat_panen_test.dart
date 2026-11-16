import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/router.dart';

import 'figma_helper.dart';

void main() {
  // Alur M05 → M06 → M07 → M08 dengan posisi teks dibandingkan ke Figma.
  testWidgets('Catat Panen M05–M08 sesuai Figma', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.catatPanen);

    cocokkanPosisi(tester, const {
      'Catat Hasil Panen': Offset(78, 54),
      'Isi setelah sayur ditimbang pengepul': Offset(78, 84),
      'Langkah 1 dari 3: Pilih sayur': Offset(17, 142),
      'Sayur apa yang dipanen?': Offset(17, 204),
      'Sawi': Offset(76.5, 316),
      'Dipilih': Offset(78, 356),
      'Bayam': Offset(244.5, 314),
      'Kangkung': Offset(52.5, 474),
      'Daun Bawang': Offset(36, 596),
      'Sayur tidak ada di daftar? Tambahkan dulu di menu Komoditas.': Offset(66, 667),
      'Lanjut': Offset(186.5, 786.5),
    });

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    cocokkanPosisi(tester, const {
      'Sayur dipilih: Sawi': Offset(78, 84),
      'Langkah 2 dari 3: Isi berat & tanggal': Offset(17, 142),
      'Tanggal panen': Offset(17, 205),
      'Hari ini, 5 Nov 2026': Offset(66, 259),
      'Tekan untuk mengganti tanggal': Offset(17, 313),
      'Berat hasil panen': Offset(17, 352),
      '120': Offset(66, 406),
      'kg': Offset(340, 406),
      'Lihat angka di timbangan pengepul': Offset(17, 460),
      'Nama pengepul (boleh dikosongkan)': Offset(17, 499),
      'Pak Dadang': Offset(66, 553),
      'Lanjut': Offset(186.5, 727.5),
      'Kembali': Offset(178, 786.5),
    });

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    cocokkanPosisi(tester, const {
      'Periksa sekali lagi': Offset(78, 84),
      'Langkah 3 dari 3: Periksa & simpan': Offset(17, 142),
      'Apakah data ini sudah benar?': Offset(17, 204),
      'Sayur': Offset(32, 265),
      'Tanggal panen': Offset(32, 314.5),
      'Berat': Offset(32, 364),
      'Pengepul': Offset(32, 413.5),
      'Harga jual diisi nanti, setelah pengepul menjual sayur di pasar. Status awal: Menunggu Penjualan.': Offset(
        65,
        484.5,
      ),
      'Ya, Simpan Data Panen': Offset(118, 727.5),
      'Ada yang salah, ubah': Offset(125, 786.5),
    });

    await tester.tap(find.text('Ya, Simpan Data Panen'));
    await tester.pumpAndSettle();
    cocokkanPosisi(tester, const {
      'Data panen tersimpan': Offset(17, 202),
      'Sawi 120 kg, panen Kamis 5 Nov 2026, sudah masuk ke Riwayat.': Offset(17, 253),
      'Status': Offset(36, 338),
      'Menunggu Penjualan': Offset(213, 337),
      'Kembali ke Beranda': Offset(130, 727.5),
      'Catat Panen Lagi': Offset(143, 786.5),
    });
  });
}
