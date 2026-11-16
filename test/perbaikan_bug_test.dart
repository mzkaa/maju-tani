import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/app_store.dart';
import 'package:maju_tani/data/format.dart';
import 'package:maju_tani/models/komoditas.dart';
import 'package:maju_tani/models/transaksi.dart';
import 'package:maju_tani/router.dart';
import 'package:provider/provider.dart';

import 'figma_helper.dart';

/// Membuka aplikasi langsung di [lokasi] (seperti halaman dimuat ulang di browser).
Future<AppStore> buka(WidgetTester tester, String lokasi, {void Function(AppStore s)? siapkan}) async {
  await siapkanLayarFigma(tester);
  final store = AppStore();
  siapkan?.call(store);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: store,
      child: MaterialApp.router(routerConfig: buatRouter(awal: lokasi)),
    ),
  );
  await tester.pumpAndSettle();
  return store;
}

void main() {
  group('M18 Ubah Data', () {
    // Isian: 0 berat panen, 1 pengepul, 2 berat terjual, 3 harga.
    testWidgets('menolak total di bawah uang yang sudah dibayar', (tester) async {
      final store = await buka(tester, Rute.ubahTransaksi('t3')); // Kangkung 80 kg × 4.000, dibayar 200.000
      await tester.enterText(find.byType(TextField).at(3), '1000');
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();
      expect(find.textContaining('lebih kecil dari yang sudah dibayar'), findsOneWidget);
      expect(store.cariTransaksi('t3')!.hargaPerKg, 4000);
      expect(store.cariTransaksi('t3')!.sisaTagihan, 120000);
    });

    testWidgets('menolak berat terjual melebihi panen dan harga nol', (tester) async {
      final store = await buka(tester, Rute.ubahTransaksi('t2')); // Bayam panen 95 kg
      await tester.enterText(find.byType(TextField).at(2), '500');
      await tester.enterText(find.byType(TextField).at(3), '0');
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();
      expect(find.text('Isi berat antara 1 dan 95 kg'), findsOneWidget);
      expect(find.text('Isi harga jual per kg'), findsOneWidget);
      expect(store.cariTransaksi('t2')!.beratTerjualKg, 92);
    });

    testWidgets('berat desimal ditolak, bukan dibaca sebagai ribuan', (tester) async {
      final store = await buka(tester, Rute.ubahTransaksi('t2'));
      await tester.enterText(find.byType(TextField).at(2), '91,5');
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();
      expect(find.text('Isi berat antara 1 dan 95 kg'), findsOneWidget);
      expect(store.cariTransaksi('t2')!.beratTerjualKg, 92);
    });

    testWidgets('pengepul bisa dikosongkan; Simpan tetap jalan tanpa layar sebelumnya', (tester) async {
      final store = await buka(tester, Rute.ubahTransaksi('t2'));
      await tester.enterText(find.byType(TextField).at(1), '');
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(store.cariTransaksi('t2')!.pembeli, isNull);
      expect(find.text('Mau catat apa?'), findsOneWidget); // kembali ke Beranda
    });

    testWidgets('kalender terbuka untuk catatan lama', (tester) async {
      final lama = DateTime(2024, 12, 20);
      await buka(
        tester,
        Rute.ubahTransaksi('t6'),
        siapkan: (s) => s.ubahTransaksi('t6', tanggalPanen: lama, beratPanenKg: 105, pembeli: 'Bu Imas'),
      );
      await tester.tap(find.text(Format.tanggal(lama)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });

  group('Komoditas dengan karakter khusus', () {
    for (final nama in ['Cabai/Rawit', 'Sawi #1', 'Bayam 100%', 'Kol?']) {
      testWidgets('form ubah "$nama" membuka komoditas yang benar', (tester) async {
        await siapkanLayarFigma(tester);
        final store = AppStore()..tambahKomoditas(Komoditas(nama: nama));
        final router = buatRouter(awal: Rute.komoditas);
        await tester.pumpWidget(
          ChangeNotifierProvider.value(value: store, child: MaterialApp.router(routerConfig: router)),
        );
        await tester.pumpAndSettle();
        router.push(Rute.ubahKomoditas(nama));
        await tester.pumpAndSettle();
        expect(find.text('Ubah Komoditas'), findsOneWidget);
        expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text, nama);
      });
    }
  });

  group('Catat Panen', () {
    testWidgets('tanpa komoditas aktif tidak bisa lanjut', (tester) async {
      final store = await buka(
        tester,
        Rute.catatPanen,
        siapkan: (s) {
          for (final k in s.komoditas) {
            s.ubahKomoditas(k.nama, k.copyWith(aktif: false));
          }
        },
      );
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Belum ada sayur aktif'), findsOneWidget);
      expect(find.text('Sayur apa yang dipanen?'), findsOneWidget);
      expect(store.sayurDraftSah, isFalse);
    });

    testWidgets('sayur yang namanya sudah diganti harus dipilih ulang', (tester) async {
      await buka(
        tester,
        Rute.catatPanen,
        siapkan: (s) {
          s.draftPanen; // draft: Sawi
          s.ubahKomoditas('Sawi', const Komoditas(nama: 'Sawi Hijau'));
        },
      );
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih dulu sayur yang dipanen.'), findsOneWidget);

      await tester.tap(find.text('Sawi Hijau'));
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Sayur apa yang dipanen?'), findsNothing);
    });

    testWidgets('langkah Periksa dibuka langsung tanpa berat kembali ke langkah 1', (tester) async {
      final store = await buka(tester, Rute.catatPanenPeriksa, siapkan: (s) => s.ubahDraft((d) => d.beratKg = null));
      expect(find.text('Sayur apa yang dipanen?'), findsOneWidget);
      expect(store.transaksi, hasLength(6));
    });
  });

  test('Notifikasi dua cicilan di menit yang sama punya id berbeda', () {
    final store = AppStore();
    store.catatPembayaran('t2', tanggal: store.hariIni, jumlah: 1000);
    store.catatPembayaran('t2', tanggal: store.hariIni, jumlah: 2000);
    final ids = store.notifikasi.map((n) => n.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    expect(store.cariTransaksi('t2')!.status, StatusTransaksi.dibayarSebagian);
  });

  testWidgets('Tanggal terjual tidak bisa sebelum tanggal panen (M09)', (tester) async {
    await buka(tester, Rute.lengkapiPenjualan('t1')); // panen 3 Nov 2026
    await tester.tap(find.text(Format.hariTanggal(DateTime(2026, 11, 5))));
    await tester.pumpAndSettle();
    final kalender = tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(kalender.firstDate, DateTime(2026, 11, 3));
  });
}
