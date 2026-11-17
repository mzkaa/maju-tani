import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/app_store.dart';
import 'package:maju_tani/screens/beranda_screen.dart';
import 'package:provider/provider.dart';

import 'figma_helper.dart';

/// Posisi kiri-atas teks di frame Figma "M02 Beranda" (390 × 844, isi belum digulir).
/// Kartu saldo, Menu Cepat, dan Perlu Diurus didesain ulang (lebih ringkas), jadi posisinya tidak lagi sama dengan Figma.
const _posisiFigma = <String, Offset>{
  'Selamat pagi,': Offset(81, 56.5),
  'Pak Pemilik': Offset(81, 76.5),
  'Kamis, 5 November 2026': Offset(65.5, 157.5),
  '74%': Offset(62.5, 248.5),
  'Uang masuk bulan ini': Offset(149, 222),
  'Rp 1.491.000': Offset(149, 244),
  'Hasil panen': Offset(61, 343),
  '500 kg': Offset(301.7, 341.5),
  'Mau catat apa?': Offset(20, 420.5),
  'Perlu diurus': Offset(20, 608.5),
  'Harga Sawi per kg': Offset(20, 887.5),
  'Lengkapi Harga': Offset(29, 525.5),
  'Catat Bayaran': Offset(150.3, 525.5),
  'Lihat semua': Offset(277, 612.5),
  'Sawi 120 kg': Offset(85, 663.5),
  'Bayam Rp 414.000': Offset(85, 731.5),
  'Kangkung sisa Rp 120.000': Offset(85, 799.5),
  'Rp 5.000': Offset(35, 939),
  '+4%': Offset(310, 944.5),
  'Mei': Offset(35, 1132.5),
};

void main() {
  // Membandingkan tata letak M02 dengan koordinat Figma (toleransi 1 px).
  testWidgets('M02 Beranda sesuai posisi Figma', (tester) async {
    await siapkanLayarFigma(tester);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStore(),
        child: const MaterialApp(home: BerandaScreen()),
      ),
    );

    cocokkanPosisi(tester, _posisiFigma);
  });
}
