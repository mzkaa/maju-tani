import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/app_store.dart';
import 'package:maju_tani/router.dart';
import 'package:maju_tani/widgets/app_icon.dart';
import 'package:provider/provider.dart';

import 'figma_helper.dart';

void main() {
  // M00: posisi sesuai Figma, lalu pindah otomatis ke M01 setelah 1,8 detik.
  testWidgets('M00 Splash sesuai Figma dan pindah ke Masuk', (tester) async {
    await siapkanLayarFigma(tester);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStore()..keluar(),
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pump();

    cocokkanPosisi(tester, const {
      'Mitra Maju Tani': Offset(0, 440),
      'Catat panen & penjualan': Offset(0, 484),
      'Versi 1.0': Offset(0, 780),
    });
    // Ikon daun 64 × 64 di tengah logo (logo 128 di x 131, y 276).
    expect(tester.getRect(find.byType(AppIcon)), const Rect.fromLTWH(163, 308, 64, 64));

    await tester.pump(const Duration(milliseconds: 1799));
    expect(find.text('Selamat datang'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang'), findsOneWidget);
  });
}
