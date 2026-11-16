import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/router.dart';

import 'figma_helper.dart';

void main() {
  testWidgets('M09 Lengkapi Penjualan sesuai Figma', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.lengkapiPenjualan('t1'));
    cocokkanPosisi(tester, const {
      'Lengkapi Penjualan': Offset(78, 54),
      'Isi setelah pengepul memberi kabar hasil jual': Offset(78, 84),
      'Sawi': Offset(31, 159),
      'Menunggu Penjualan': Offset(122, 162),
      'Panen 03 Nov 2026 · 120 kg · No. PJ-011': Offset(31, 201),
      'Tanggal terjual': Offset(17, 256),
      'Kamis, 5 Nov 2026': Offset(66, 310),
      'Berat yang terjual': Offset(17, 370),
      '118': Offset(66, 424),
      'kg': Offset(340, 424),
      'Ubah bila beda dari berat panen (120 kg)': Offset(17, 478),
      'Harga jual per kg': Offset(17, 516),
      'Rp 5.200': Offset(66, 570),
      '/kg': Offset(332, 570),
      'Harga yang diterima dari pengepul': Offset(17, 624),
      'Total penjualan (dihitung sendiri)': Offset(17, 662),
      'Rp 613.600': Offset(66, 716),
      '118 kg × Rp 5.200 = Rp 613.600': Offset(17, 770),
      'Setelah disimpan, status menjadi Menunggu Pembayaran sampai uang dari pengepul dicatat.': Offset(65, 820),
      'Simpan Penjualan': Offset(139.5, 786.5),
    });
  });

  testWidgets('M10 Catat Pembayaran → M14 sesuai Figma', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.catatPembayaran('t3'));
    cocokkanPosisi(tester, const {
      'Catat Pembayaran': Offset(78, 54),
      'Boleh dicicil atau langsung lunas': Offset(78, 84),
      'Kangkung': Offset(31, 160),
      'Dibayar Sebagian': Offset(170, 163),
      'Sisa yang belum dibayar': Offset(31, 200),
      'Sudah dibayar Rp 200.000 dari Rp 320.000': Offset(31, 284),
      'Tanggal uang diterima': Offset(17, 368),
      'Berapa yang dibayar?': Offset(17, 482),
      'Lunas semua': Offset(56, 526.5),
      'Sebagian dulu': Offset(193, 526.5),
      'Jumlah uang diterima': Offset(17, 575),
      'Paling banyak Rp 120.000 (sisa tagihan)': Offset(17, 683),
      'Setelah disimpan, status jadi': Offset(30, 737),
      'Lunas': Offset(290, 739),
      'Simpan Pembayaran': Offset(127, 786.5),
    });

    await tester.tap(find.text('Simpan Pembayaran'));
    await tester.pumpAndSettle();
    cocokkanPosisi(tester, const {
      'Pembayaran tersimpan': Offset(17, 202),
      'Kangkung: uang Rp 120.000 diterima 5 Nov 2026. Semua sudah dibayar.': Offset(17, 253),
      'Status': Offset(36, 338),
      'Lunas': Offset(314, 337),
      'Riwayat pembayaran bisa dilihat di rincian transaksi.': Offset(36, 382),
      'Kembali ke Beranda': Offset(130, 668.5),
      'Lihat & Cetak Nota': Offset(118, 727.5),
      'Lihat Rincian': Offset(160, 786.5),
    });
  });
}
