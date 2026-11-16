import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/app_store.dart';
import 'package:maju_tani/screens/beranda_screen.dart';
import 'package:provider/provider.dart';

import 'figma_helper.dart';

/// Posisi kiri-atas teks di frame Figma "M02 Beranda" (390 × 844, isi belum digulir).
const _posisiFigma = <String, Offset>{
  'Selamat pagi,': Offset(81, 56.5),
  'Pak Pemilik': Offset(81, 76.5),
  'Kamis, 5 November 2026': Offset(65.5, 157.5),
  '74%': Offset(64.5, 257.5),
  'Uang masuk bulan ini': Offset(160, 225.5),
  'Rp 1.491.000': Offset(160, 249.5),
  'Sudah masuk': Offset(178, 283.5),
  'Rp 534.000': Offset(63.5, 355),
  'MENU CEPAT': Offset(78, 464.5),
  'Mau catat apa?': Offset(78, 479.5),
  'Lengkapi Harga': Offset(89, 546),
  'Catat Bayaran': Offset(33, 686.5),
  'PENGINGAT': Offset(78, 765),
  'Lihat semua': Offset(255.8, 776),
  'Sawi 120 kg': Offset(88, 842.5),
  'Bayam Rp 414.000': Offset(88, 925.5),
  'Kangkung sisa Rp 120.000': Offset(88, 1008.5),
  'PERKEMBANGAN HARGA': Offset(78, 1088),
  'Rp 5.000': Offset(35, 1167),
  '+4%': Offset(309, 1172.5),
  'Mei': Offset(35, 1360.5),
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
