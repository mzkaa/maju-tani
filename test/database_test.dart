import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/app_store.dart';
import 'package:maju_tani/data/database.dart';
import 'package:maju_tani/models/komoditas.dart';
import 'package:maju_tani/models/transaksi.dart';
import 'package:maju_tani/router.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'figma_helper.dart';

void main() {
  sqfliteFfiInit();

  late String lokasi;
  setUp(() => lokasi = 'file:test_${DateTime.now().microsecondsSinceEpoch}?mode=memory&cache=shared');

  /// Membuka database yang sama lagi, seperti aplikasi ditutup lalu dibuka.
  Future<AppStore> buka() async {
    final db = await Penyimpanan.buka(lokasi: lokasi, factory: databaseFactoryFfi);
    return AppStore.dariDatabase(db, await db.muat());
  }

  test('Cincin Beranda menghitung pembayaran bulan lalu atas tagihan yang masih ada', () async {
    final store = await buka();
    store.ubahDraft((d) {
      d.komoditas = 'Bayam';
      d.beratKg = 50;
      d.pengepul = 'Pak Dadang';
    });
    final id = store.simpanPanen();
    final bulanLalu = DateTime(store.hariIni.year, store.hariIni.month, 0);
    store.lengkapiPenjualan(id, tanggal: bulanLalu, beratKg: 50, hargaPerKg: 4000); // Rp200.000
    expect(store.persenSudahMasuk, 0);
    store.catatPembayaran(id, tanggal: bulanLalu, jumlah: 50000);
    expect(store.uangMasuk, 0); // belum ada uang masuk bulan ini...
    expect(store.persenSudahMasuk, 0.25); // ...tapi cincin tetap menunjukkan 25% sudah dibayar.
  });

  test('Data tetap ada setelah aplikasi dibuka ulang', () async {
    final pertama = await buka();
    expect(pertama.transaksi, isEmpty);
    expect(pertama.komoditas.map((k) => k.nama), ['Sawi', 'Bayam', 'Kangkung', 'Selada', 'Daun Bawang']);

    pertama.ubahDraft((d) {
      d.komoditas = 'Bayam';
      d.beratKg = 50;
      d.pengepul = 'Pak Dadang';
    });
    final id = pertama.simpanPanen();
    pertama.lengkapiPenjualan(id, tanggal: pertama.hariIni, beratKg: 48, hargaPerKg: 4000);
    pertama.catatPembayaran(id, tanggal: pertama.hariIni, jumlah: 100000);
    pertama.tambahKomoditas(const Komoditas(nama: 'Tomat'));
    pertama.ubahKomoditas('Bayam', const Komoditas(nama: 'Bayam Hijau'));
    pertama.aturUkuranHuruf(UkuranHuruf.sangatBesar);
    pertama.aturUkuranTampilan(UkuranTampilan.kecil);
    pertama.tandaiDibaca('bayar-$id');
    await pertama.selesaiMenyimpan;

    final kedua = await buka();
    final t = kedua.cariTransaksi(id)!;
    expect(t.nomor, 'PJ-001');
    expect(t.komoditas, 'Bayam Hijau');
    expect(t.beratPanenKg, 50);
    expect(t.pembeli, 'Pak Dadang');
    expect(t.totalPenjualan, 192000);
    expect(t.totalDibayar, 100000);
    expect(t.status, StatusTransaksi.dibayarSebagian);
    expect(kedua.komoditas.map((k) => k.nama), ['Sawi', 'Bayam Hijau', 'Kangkung', 'Selada', 'Daun Bawang', 'Tomat']);
    expect(kedua.ukuranHuruf, UkuranHuruf.sangatBesar);
    expect(kedua.ukuranTampilan, UkuranTampilan.kecil);
  });

  test('Draft Catat Panen kosong dan riwayat harga dari penjualan', () async {
    final store = await buka();
    expect(store.draftPanen.beratKg, isNull);
    expect(store.draftPanen.pengepul, '');
    expect(store.sayurHargaBeranda, isNull);
  });

  test('Buat akun, keluar, masuk, dan ubah kata sandi', () async {
    final pertama = await buka();
    expect(pertama.punyaAkun, isFalse);
    expect(pertama.sudahMasuk, isFalse);

    await pertama.buatAkun(' Pemilik ', 'panen2026');
    expect(pertama.sudahMasuk, isTrue);
    await pertama.selesaiMenyimpan;

    // Sesi tetap tersimpan saat aplikasi dibuka ulang.
    final kedua = await buka();
    expect(kedua.namaPengguna, 'pemilik');
    expect(kedua.sudahMasuk, isTrue);

    kedua.keluar();
    expect(await kedua.masuk('pemilik', 'salah123'), isFalse);
    expect(await kedua.masuk('orang lain', 'panen2026'), isFalse);
    expect(kedua.sudahMasuk, isFalse);
    expect(await kedua.masuk('PEMILIK', 'panen2026'), isTrue);

    expect(await kedua.ubahSandi('salah123', 'baru2026x'), isFalse);
    expect(await kedua.ubahSandi('panen2026', 'baru2026x'), isTrue);
    kedua.keluar();
    await kedua.selesaiMenyimpan;

    final ketiga = await buka();
    expect(ketiga.sudahMasuk, isFalse);
    expect(await ketiga.masuk('pemilik', 'panen2026'), isFalse);
    expect(await ketiga.masuk('pemilik', 'baru2026x'), isTrue);
  });

  testWidgets('Belum masuk: semua layar diarahkan ke Masuk untuk membuat akun', (tester) async {
    await siapkanLayarFigma(tester);
    final store = (await tester.runAsync(buka))!;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: store,
        child: MaterialApp.router(routerConfig: buatRouter(awal: Rute.beranda)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Buat Akun'), findsOneWidget);
    expect(find.text('Buat akun dulu untuk mulai mencatat panen dan penjualan sayur.'), findsOneWidget);

    // Kata sandi lemah ditolak.
    await tester.enterText(find.byType(TextField).first, 'pemilik');
    await tester.enterText(find.byType(TextField).last, 'pendek');
    await tester.tap(find.text('Buat Akun'));
    await tester.pump();
    expect(find.text('Minimal 8 huruf/angka dan ada angkanya'), findsOneWidget);
    expect(store.punyaAkun, isFalse);

    // Pindah ke mode Masuk, tapi belum ada akun di perangkat ini.
    await tester.tap(find.text('Sudah punya akun? Masuk'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, 'panen2026');
    await tester.tap(find.widgetWithText(Row, 'Masuk').first);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    expect(find.text('Belum ada akun di perangkat ini. Buat akun dulu.'), findsOneWidget);

    await tester.tap(find.text('Belum punya akun? Buat akun'));
    await tester.pump();
    expect(find.text('Buat Akun'), findsOneWidget);
  });

  testWidgets('Layar utama tampil tanpa galat saat database masih kosong', (tester) async {
    await siapkanLayarFigma(tester);
    final store = (await tester.runAsync(buka))!;
    await tester.runAsync(() => store.buatAkun('pemilik', 'panen2026'));
    for (final lokasi in [
      Rute.beranda,
      Rute.riwayat,
      Rute.catatPanen,
      Rute.catatPanenBerat,
      Rute.laporan,
      Rute.rekapSayur,
      Rute.riwayatHarga,
      Rute.komoditas,
      Rute.notifikasi,
      Rute.pengaturan,
    ]) {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          key: ValueKey(lokasi),
          value: store,
          child: MaterialApp.router(routerConfig: buatRouter(awal: lokasi)),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: lokasi);
    }
    expect(find.text('Belum pernah'), findsOneWidget);
  });
}
