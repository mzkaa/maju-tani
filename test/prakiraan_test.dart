import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/prakiraan.dart';
import 'package:maju_tani/router.dart';

import 'figma_helper.dart';

void main() {
  group('Metode perhitungan', () {
    test('rata-rata bergerak 3 bulan memakai tiga bulan terakhir', () {
      expect(Prakiraan.rataRataBergerak([10, 20, 30, 40]), 30); // (20 + 30 + 40) / 3
      expect(Prakiraan.rataRataBergerak([10, 20]), 15); // data kurang dari 3: rata-rata semuanya
    });

    test('pemulusan eksponensial α = 0,5', () {
      expect(Prakiraan.pemulusanEksponensial([10, 20]), 15); // 0,5·20 + 0,5·10
      expect(Prakiraan.pemulusanEksponensial([10, 20, 30]), 22.5); // 0,5·30 + 0,5·15
      expect(Prakiraan.pemulusanEksponensial([7]), 7);
    });

    test('tren linear kuadrat terkecil meneruskan garis lurus', () {
      expect(Prakiraan.trenLinear([100, 200, 300]), closeTo(400, 1e-9));
      expect(Prakiraan.trenLinear([500, 400, 300]), closeTo(200, 1e-9));
      expect(Prakiraan.trenLinear([300, 300, 300]), closeTo(300, 1e-9));
    });

    test('MAPE uji mundur dihitung dari ramalan tiap bulan', () {
      // t = 2: ramal dari [100, 110] → tren 120, aktual 120 → galat 0
      // t = 3: ramal dari [100, 110, 120] → tren 130, aktual 130 → galat 0
      expect(Prakiraan.mape(MetodePrakiraan.trenLinear, [100, 110, 120, 130]), closeTo(0, 1e-9));
      // Data kurang dari 4 bulan: belum bisa diuji.
      expect(Prakiraan.mape(MetodePrakiraan.trenLinear, [100, 110, 120]), isNull);
    });
  });

  group('Memilih prakiraan', () {
    test('kurang dari 2 bulan: tidak ada prakiraan', () {
      expect(Prakiraan.hitung([]), isNull);
      expect(Prakiraan.hitung([5000]), isNull);
    });

    test('2–3 bulan: tren linear tanpa MAPE', () {
      final h = Prakiraan.hitung([4000, 4200])!;
      expect(h.hargaPerKg, 4400);
      expect(h.metode, MetodePrakiraan.trenLinear);
      expect(h.mape, isNull);
      expect(h.kepercayaan, isNull);
    });

    test('data lurus naik: tren linear dipilih dan akurat', () {
      final h = Prakiraan.hitung([4000, 4100, 4200, 4300, 4400])!;
      expect(h.hargaPerKg, 4500);
      expect(h.metode, MetodePrakiraan.trenLinear);
      expect(h.mape, closeTo(0, 1e-6));
      expect(h.kepercayaan, 'Tinggi');
    });

    test('data bergelombang: metode dengan galat terkecil yang dipilih', () {
      final y = [5000, 6000, 5000, 6000, 5000, 6000];
      final h = Prakiraan.hitung(y)!;
      final semua = {
        for (final m in MetodePrakiraan.values) m: Prakiraan.mape(m, [for (final v in y) v.toDouble()])!,
      };
      final terkecil = semua.values.reduce((a, b) => a < b ? a : b);
      expect(h.mape, closeTo(terkecil, 1e-9));
      expect(semua[h.metode], closeTo(terkecil, 1e-9));
    });

    test('harga tidak pernah negatif', () {
      expect(Prakiraan.hitung([300, 200, 100])!.hargaPerKg, 0);
    });
  });

  testWidgets('Riwayat Harga menampilkan kartu prakiraan bulan depan', (tester) async {
    await siapkanLayarFigma(tester);
    await tampilkan(tester, Rute.riwayatHarga);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('PRAKIRAAN'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('PRAKIRAAN'), findsOneWidget);
    expect(find.text('Sawi November 2026'), findsOneWidget); // riwayat sampai Oktober 2026
    expect(find.text('Metode'), findsOneWidget);
    expect(find.text('Keandalan'), findsOneWidget);
    expect(find.textContaining('/kg'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });
}
