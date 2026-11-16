import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/app_store.dart';
import 'package:maju_tani/screens/masuk_screen.dart';
import 'package:provider/provider.dart';

import 'figma_helper.dart';

/// Posisi kiri-atas teks di frame Figma "M01 Masuk" (390 × 844).
const _posisiFigma = <String, Offset>{
  'Mitra Maju Tani': Offset(77, 58),
  'Catatan panen & penjualan': Offset(77, 86),
  'Selamat datang': Offset(17, 121),
  'Masuk untuk mencatat panen dan penjualan sayur.': Offset(17, 172),
  'Nama pengguna': Offset(17, 277),
  'pemilik': Offset(66, 331),
  'Kata sandi': Offset(17, 391),
  'Lihat': Offset(322, 445),
  'Tekan "Lihat" untuk menampilkan kata sandi': Offset(17, 499),
  'Masuk': Offset(185, 547.5),
  'Lupa kata sandi? Hubungi tim pengembang lewat WhatsApp.': Offset(64, 611),
};

void main() {
  testWidgets('M01 Masuk sesuai posisi Figma', (tester) async {
    await siapkanLayarFigma(tester);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStore(),
        child: const MaterialApp(home: MasukScreen()),
      ),
    );
    cocokkanPosisi(tester, _posisiFigma);

    // Tombol "Lihat" menampilkan kata sandi.
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, isTrue);
    await tester.tap(find.text('Lihat'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, isFalse);
  });
}
