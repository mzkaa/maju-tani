import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/app_store.dart';
import 'package:maju_tani/router.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:maju_tani/widgets/app_icon.dart';

/// Menyiapkan font, ikon, locale, dan layar 390 × 844 seperti frame Figma.
Future<void> siapkanLayarFigma(WidgetTester tester) async {
  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID');
  await tester.runAsync(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
      final bytes = File('assets/fonts/PlusJakartaSans-$w.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
    await AppIcon.muat();
  });
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
  addTearDown(tester.view.reset);
}

/// Membandingkan posisi kiri-atas teks dengan koordinat Figma (toleransi 1 px).
void cocokkanPosisi(WidgetTester tester, Map<String, Offset> posisiFigma) {
  final meleset = <String>[];
  posisiFigma.forEach((teks, figma) {
    final d = tester.getTopLeft(find.text(teks)) - figma;
    if (d.dx.abs() > 1 || d.dy.abs() > 1) {
      meleset.add('$teks: Δx ${d.dx.toStringAsFixed(1)}, Δy ${d.dy.toStringAsFixed(1)}');
    }
  });
  expect(meleset, isEmpty, reason: meleset.join('\n'));
}

/// Menampilkan aplikasi lengkap (router + data contoh) mulai dari [lokasi].
Future<void> tampilkan(WidgetTester tester, String lokasi, {void Function(AppStore s)? siapkan}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) {
        final s = AppStore();
        siapkan?.call(s);
        return s;
      },
      child: MaterialApp.router(routerConfig: buatRouter(awal: lokasi)),
    ),
  );
  await tester.pump();
}
