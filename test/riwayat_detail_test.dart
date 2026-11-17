import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/router.dart';

import 'package:maju_tani/widgets/kartu_transaksi.dart';

import 'figma_helper.dart';

void main() {
  testWidgets('M03 Riwayat sesuai posisi Figma', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.riwayat);
    cocokkanPosisi(tester, const {
      'Riwayat': Offset(20, 54),
      'Panen & penjualan terbaru': Offset(20, 84),
      'Semua (6)': Offset(46, 150),
      'Belum dijual (1)': Offset(139, 151),
      'Belum lunas (2)': Offset(263, 151),
      'Kangkung': Offset(84, 370),
      'Rp 320.000': Offset(251, 372),
    });
    // Saring "Belum lunas" hanya menampilkan Bayam & Kangkung.
    await tester.tap(find.text('Belum lunas (2)'));
    await tester.pump();
    expect(find.byType(KartuTransaksi), findsNWidgets(2));
  });

  testWidgets('M04 Detail Transaksi sesuai posisi Figma', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.detail('t3'));
    cocokkanPosisi(tester, const {
      'Detail Transaksi': Offset(78, 54),
      'Kangkung · 30 Okt 2026': Offset(78, 84),
      'Dibayar Sebagian': Offset(65, 164),
      'Sisa yang belum dibayar': Offset(32, 205),
      'Rp 120.000': Offset(32, 243),
      'Sudah dibayar Rp 200.000 dari Rp 320.000 (63%)': Offset(32, 321),
      'Catat Pembayaran': Offset(135, 413.5),
      'Perjalanan transaksi': Offset(36, 501),
      '1. Panen dicatat': Offset(80, 550),
      '30 Okt 2026, 16:20': Offset(80, 580),
      '80 kg, ditimbang Pak Ujang': Offset(80, 606),
      '2. Penjualan dilengkapi': Offset(80, 671),
      '01 Nov 2026, 09:10': Offset(80, 701),
      'Terjual 80 kg × Rp 4.000 = Rp 320.000': Offset(80, 727),
      '3. Pembayaran (dicicil)': Offset(80, 820),
      'Bayar ke-1: 02 Nov 2026': Offset(80, 850),
      'Masuk Rp 200.000 · sisa Rp 120.000': Offset(80, 876),
      'Ubah Data': Offset(169, 981.5),
      'Dicatat oleh Pemilik. Setiap perubahan tersimpan waktunya.': Offset(64, 1041),
    });
  });
}
