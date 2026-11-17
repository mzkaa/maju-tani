import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/app_store.dart';
import 'package:maju_tani/main.dart';
import 'package:maju_tani/router.dart';
import 'package:provider/provider.dart';
import 'package:maju_tani/widgets/kotak_kaca.dart';
import 'package:maju_tani/widgets/skala_tampilan.dart';

import 'figma_helper.dart';

void main() {
  testWidgets('Mengetuk bagian kosong kotak isian (bukan baris teks) memfokuskan isian', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.catatPanenBerat);
    await tester.pumpAndSettle();

    final isian = find.byType(TextField).first;
    final kotak = tester.getRect(find.ancestor(of: isian, matching: find.byType(KotakKaca)).first);
    final baris = tester.getRect(isian);
    // Titik dekat tepi bawah kotak: di luar satu baris teks, tapi masih di dalam kotak bulat.
    final titik = Offset(kotak.center.dx, kotak.bottom - 6);
    expect(baris.contains(titik), isFalse);
    await tester.tapAt(titik);
    await tester.pump();

    final editable = tester.state<EditableTextState>(find.byType(EditableText).first);
    expect(editable.widget.focusNode.hasFocus, isTrue);
  });

  testWidgets('Bilah tombol disembunyikan saat keyboard terbuka dan muncul lagi setelah ditutup', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.catatPanenBerat);
    await tester.pumpAndSettle();
    expect(find.text('Lanjut'), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(find.text('Lanjut'), findsNothing);

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pumpAndSettle();
    expect(find.text('Lanjut'), findsOneWidget);
  });

  testWidgets('Ketuk di luar isian menutup fokus', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.catatPanenBerat);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    expect(tester.state<EditableTextState>(find.byType(EditableText).first).widget.focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(200, 140)); // area kosong di bawah header
    await tester.pump();
    expect(tester.state<EditableTextState>(find.byType(EditableText).first).widget.focusNode.hasFocus, isFalse);
  });

  testWidgets('SkalaTampilan memperkecil isi dan ketukan tetap tepat sasaran', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var diketuk = 0;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SkalaTampilan(
            skala: 0.5,
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => diketuk++,
                child: const SizedBox(key: Key('kotak'), width: 200, height: 100),
              ),
            ),
          ),
        ),
      ),
    );
    // Kotak 200 × 100 digambar menjadi 100 × 50.
    expect(tester.getRect(find.byKey(const Key('kotak'))).size, const Size(100, 50));
    await tester.tapAt(const Offset(90, 40));
    expect(diketuk, 1);
    await tester.tapAt(const Offset(150, 40)); // di luar kotak setelah diperkecil
    expect(diketuk, 1);
  });

  testWidgets('Seluruh layar menerima ukuran, padding, dan keyboard yang sudah diperkecil', (tester) async {
    await siapkanLayarFigma(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 264);
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => AppStore(), child: const MajuTaniApp()),
    );
    await tester.pump();
    final konteks = tester.element(find.byType(Scaffold).first);
    expect(MediaQuery.sizeOf(konteks).width, closeTo(390 / UkuranTampilan.sedang.skala, 0.01));
    expect(MediaQuery.sizeOf(konteks).height, closeTo(844 / UkuranTampilan.sedang.skala, 0.01));
    expect(MediaQuery.viewInsetsOf(konteks).bottom, closeTo(264 / UkuranTampilan.sedang.skala, 0.01));
    expect(MediaQuery.paddingOf(konteks).top, closeTo(47 / UkuranTampilan.sedang.skala, 0.01));
    await tester.pumpWidget(const SizedBox());
  });
}
