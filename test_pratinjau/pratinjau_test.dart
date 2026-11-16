// Alat bantu pengembangan (bukan tes): merender layar ke PNG untuk dibandingkan dengan Figma.
// Jalankan: flutter test test_pratinjau/pratinjau_test.dart --dart-define=RUTE=/riwayat --dart-define=KELUAR=/tmp/a.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/app_store.dart';
import 'package:maju_tani/router.dart';
import 'package:provider/provider.dart';

import '../test/figma_helper.dart';

void main() {
  testWidgets('pratinjau', (tester) async {
    const rute = String.fromEnvironment('RUTE', defaultValue: Rute.beranda);
    const keluar = String.fromEnvironment('KELUAR');
    // Opsional: 'lalu' = periode laporan Bulan lalu; 'aktif' = saring komoditas aktif.
    const atur = String.fromEnvironment('ATUR');
    await siapkanLayarFigma(tester);
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(780, 1688);
    final kunci = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: kunci,
        child: ChangeNotifierProvider(
          create: (_) {
            final s = AppStore();
            if (atur == 'lalu') s.aturPeriode(PilihanPeriode.bulanLalu);
            if (atur == 'aktif') s.aturSaringKomoditas(true);
            return s;
          },
          child: MaterialApp.router(debugShowCheckedModeBanner: false, routerConfig: buatRouter(awal: rute)),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.runAsync(() async {
      final batas = kunci.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final gambar = await batas.toImage(pixelRatio: 2);
      final data = await gambar.toByteData(format: ui.ImageByteFormat.png);
      File(keluar).writeAsBytesSync(data!.buffer.asUint8List());
    });
  });
}
