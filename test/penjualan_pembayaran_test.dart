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
      'Sawi': Offset(86, 159),
      'Menunggu Penjualan': Offset(86, 182),
      'Panen 03 Nov 2026 · 120 kg · No. PJ-011': Offset(32, 209),
      'Tanggal terjual': Offset(17, 253),
      'Kamis, 5 Nov 2026': Offset(66, 307),
      'Berat yang terjual': Offset(17, 367),
      '118': Offset(66, 421),
      'kg': Offset(340.5, 421),
      'Ubah bila beda dari berat panen (120 kg)': Offset(17, 475),
      'Harga jual per kg': Offset(17, 513),
      'Rp 5.200': Offset(66, 567),
      '/kg': Offset(332.4, 567),
      'Harga yang diterima dari pengepul': Offset(17, 621),
      'Rp 613.600': Offset(233.7, 678),
      'Setelah disimpan, status menjadi Menunggu Pembayaran sampai uang dari pengepul dicatat.': Offset(45, 739),
      'Simpan Penjualan': Offset(139.5, 786.5),
    });
  });

  testWidgets('M10 Catat Pembayaran → M14 sesuai Figma', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.catatPembayaran('t3'));
    cocokkanPosisi(tester, const {
      'Catat Pembayaran': Offset(78, 54),
      'Boleh dicicil atau langsung lunas': Offset(78, 84),
      'Kangkung': Offset(85, 158),
      'Dibayar Sebagian': Offset(85, 181),
      'Sisa yang belum dibayar': Offset(31, 204),
      'Sudah dibayar Rp 200.000 dari Rp 320.000': Offset(31, 288),
      'Tanggal uang diterima': Offset(17, 372),
      'Berapa yang dibayar?': Offset(17, 486),
      'Lunas semua': Offset(56, 530.5),
      'Sebagian dulu': Offset(192.6, 530.5),
      'Jumlah uang diterima': Offset(17, 579),
      'Paling banyak Rp 120.000 (sisa tagihan)': Offset(17, 687),
      'Setelah disimpan, status jadi': Offset(30, 741),
      'Lunas': Offset(289.4, 743),
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
