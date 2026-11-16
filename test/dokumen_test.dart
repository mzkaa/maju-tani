import 'dart:convert';

import 'package:excel/excel.dart' as xl;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:maju_tani/data/app_store.dart';
import 'package:maju_tani/data/dokumen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting('id_ID'));

  AppStore bulanLalu() => AppStore()..aturPeriode(PilihanPeriode.bulanLalu);

  test('Laporan PDF dibuat untuk setiap jenis', () async {
    for (final jenis in JenisDokumen.values) {
      final f = await Dokumen.buatLaporan(bulanLalu(), jenis, pdf: true);
      expect(latin1.decode(f.isi.sublist(0, 5)), '%PDF-', reason: jenis.name);
      expect(f.halaman, greaterThanOrEqualTo(1));
      expect(f.nama, endsWith('-Okt-2026.pdf'));
    }
  });

  test('Laporan Excel berisi baris penjualan dan total', () async {
    final f = await Dokumen.buatLaporan(bulanLalu(), JenisDokumen.penjualan, pdf: false);
    expect(f.nama, 'Laporan-Penjualan-Okt-2026.xlsx');
    final lembar = xl.Excel.decodeBytes(f.isi)['Laporan Penjualan'];
    final teks = [for (final r in lembar.rows) r.map((c) => c?.value?.toString() ?? '').join('|')];
    expect(teks[3], 'Tanggal|Sayur|Berat|Jumlah');
    expect(teks.where((t) => t.startsWith('Total penjualan|')), hasLength(1));
  });

  test('Nota pembayaran PDF', () async {
    final t = AppStore().cariTransaksi('t3')!;
    final nota = await Dokumen.buatNota(t, 'Pak Pemilik');
    expect(latin1.decode(nota.isi.sublist(0, 5)), '%PDF-');
    expect(nota.nama, 'Nota-NP-2026-1102-PJ-009.pdf');
  });
}
