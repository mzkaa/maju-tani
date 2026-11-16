import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/transaksi.dart';
import 'app_store.dart';
import 'format.dart';

/// Jenis dokumen di M25 Cetak & Unduh.
enum JenisDokumen {
  penjualan('Laporan Penjualan'),
  rekapSayur('Rekap per Sayur'),
  riwayatHarga('Riwayat Harga');

  const JenisDokumen(this.judul);
  final String judul;
}

enum _Isi { teks, tanggal, kg, rupiah }

/// Isi satu dokumen laporan; dipakai pratinjau (M26), PDF, dan Excel agar selalu sama.
class TabelDokumen {
  const TabelDokumen({required this.jenis, required this.kolom, required this.baris, required this.ringkasan});

  final JenisDokumen jenis;
  final List<(String, _Isi)> kolom;

  /// Tiap sel: String, int (kg/rupiah), atau DateTime.
  final List<List<Object>> baris;
  final List<(String, int)> ringkasan;

  /// Teks sel untuk pratinjau & PDF.
  String teks(int kolomKe, Object nilai) => switch (kolom[kolomKe].$2) {
    _Isi.teks => '$nilai',
    _Isi.tanggal => Format.tanggalAngka(nilai as DateTime),
    _Isi.kg => Format.kg(nilai as int),
    _Isi.rupiah => Format.rupiahRapat(nilai as int),
  };

  factory TabelDokumen.dari(AppStore store, JenisDokumen jenis) {
    final (awal, akhir) = store.periodeLaporan;
    final r = store.ringkasan(awal, akhir);
    switch (jenis) {
      case JenisDokumen.penjualan:
        final terjual = r.transaksi.where((t) => t.sudahDijual).toList()
          ..sort((a, b) => a.tanggalJual!.compareTo(b.tanggalJual!));
        return TabelDokumen(
          jenis: jenis,
          kolom: const [('Tanggal', _Isi.tanggal), ('Sayur', _Isi.teks), ('Berat', _Isi.kg), ('Jumlah', _Isi.rupiah)],
          baris: [
            for (final t in terjual) [t.tanggalJual!, t.komoditas, t.beratTerjualKg!, t.totalPenjualan],
          ],
          ringkasan: [
            ('Total penjualan', r.totalPenjualan),
            ('Sudah dibayar', r.sudahDibayar),
            ('Belum dibayar', r.belumDibayar),
          ],
        );
      case JenisDokumen.rekapSayur:
        final sayur = r.perSayur.toList();
        return TabelDokumen(
          jenis: jenis,
          kolom: const [('Sayur', _Isi.teks), ('Panen', _Isi.kg), ('Terjual', _Isi.kg), ('Penjualan', _Isi.rupiah)],
          baris: [
            for (final s in sayur) [s.nama, s.panenKg, s.terjualKg, s.penjualan],
          ],
          ringkasan: [
            ('Total penjualan', r.totalPenjualan),
            ('Sudah dibayar', r.sudahDibayar),
            ('Belum dibayar', r.belumDibayar),
          ],
        );
      case JenisDokumen.riwayatHarga:
        return TabelDokumen(
          jenis: jenis,
          kolom: const [('Bulan', _Isi.teks), ('Sayur', _Isi.teks), ('Harga/kg', _Isi.rupiah)],
          baris: [
            for (final k in store.komoditas)
              for (final h in store.riwayatHarga(k.nama).reversed) [Format.bulanTahun(h.bulan), k.nama, h.hargaPerKg],
          ],
          ringkasan: const [],
        );
    }
  }
}

/// File yang sudah dibuat, untuk M27 Dokumen Berhasil.
class FileDokumen {
  const FileDokumen({required this.isi, required this.nama, required this.judul, required this.halaman});

  final Uint8List isi;
  final String nama;
  final String judul;

  /// Null untuk Excel.
  final int? halaman;

  bool get pdf => nama.endsWith('.pdf');
  int get ukuran => isi.length;

  /// Lembar bagikan sistem (simpan ke Files, kirim WhatsApp, dll.); di browser file diunduh.
  Future<void> bagikan({String? teks}) => SharePlus.instance.share(
    ShareParams(
      files: [
        XFile.fromData(
          isi,
          name: nama,
          mimeType: pdf ? 'application/pdf' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      ],
      fileNameOverrides: [nama],
      text: teks,
    ),
  );
}

/// Membuat file PDF & Excel dari data aplikasi.
abstract final class Dokumen {
  static String _namaFile(JenisDokumen jenis, DateTime akhir, {required bool pdf}) =>
      '${jenis.judul.replaceAll(' ', '-')}-${DateFormat('MMM-y', 'id_ID').format(akhir)}.${pdf ? 'pdf' : 'xlsx'}';

  static Future<FileDokumen> buatLaporan(AppStore store, JenisDokumen jenis, {required bool pdf}) async {
    final tabel = TabelDokumen.dari(store, jenis);
    final (_, akhir) = store.periodeLaporan;
    int? halaman;
    final Uint8List isi;
    if (pdf) {
      final dok = await _laporanPdf(store, tabel);
      halaman = dok.document.pdfPageList.pages.length;
      isi = await dok.save();
    } else {
      isi = laporanExcel(store, tabel);
    }
    return FileDokumen(isi: isi, nama: _namaFile(jenis, akhir, pdf: pdf), judul: jenis.judul, halaman: halaman);
  }

  static Future<Uint8List> laporanPdf(AppStore store, JenisDokumen jenis) async =>
      (await _laporanPdf(store, TabelDokumen.dari(store, jenis))).save();

  static Future<pw.Document> _laporanPdf(AppStore store, TabelDokumen tabel) async {
    final (awal, akhir) = store.periodeLaporan;
    final dok = pw.Document(theme: await _tema());
    dok.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => _kepala('${tabel.jenis.judul} · ${Format.rentangPanjang(awal, akhir)}', store.namaPemilik),
        footer: (c) => pw.Text(
          'Dicetak ${Format.tanggalSingkat(store.hariIni)} · Halaman ${c.pageNumber} dari ${c.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        build: (_) => [
          if (tabel.baris.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 24),
              child: pw.Text('Belum ada data pada periode ini.'),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: [for (final k in tabel.kolom) k.$1],
              data: [
                for (final b in tabel.baris) [for (final (i, v) in b.indexed) tabel.teks(i, v)],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: _hijau),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignments: {
                for (final (i, k) in tabel.kolom.indexed)
                  i: k.$2 == _Isi.teks || k.$2 == _Isi.tanggal ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
              },
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
            ),
          if (tabel.ringkasan.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            for (final (label, nilai) in tabel.ringkasan) _barisNilai(label, Format.rupiahRapat(nilai)),
          ],
        ],
      ),
    );
    return dok;
  }

  static Uint8List laporanExcel(AppStore store, TabelDokumen tabel) {
    final (awal, akhir) = store.periodeLaporan;
    final buku = xl.Excel.createExcel();
    final namaLembar = tabel.jenis.judul;
    buku.rename(buku.getDefaultSheet()!, namaLembar);
    final lembar = buku[namaLembar];
    final tebal = xl.CellStyle(bold: true);

    lembar.appendRow([xl.TextCellValue('Mitra Maju Tani · ${tabel.jenis.judul}')]);
    lembar.appendRow([xl.TextCellValue('Periode ${Format.rentangPanjang(awal, akhir)}')]);
    final barisKepala = lembar.maxRows + 1; // satu baris kosong di atas tabel
    for (final (i, k) in tabel.kolom.indexed) {
      lembar.updateCell(
        xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: barisKepala),
        xl.TextCellValue(k.$1),
        cellStyle: tebal,
      );
    }
    for (final b in tabel.baris) {
      lembar.appendRow([
        for (final v in b)
          switch (v) {
            final int n => xl.IntCellValue(n),
            final DateTime d => xl.DateCellValue(year: d.year, month: d.month, day: d.day),
            _ => xl.TextCellValue('$v'),
          },
      ]);
    }
    final barisRingkasan = lembar.maxRows + 1;
    for (final (i, (label, nilai)) in tabel.ringkasan.indexed) {
      lembar
        ..updateCell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: barisRingkasan + i), xl.TextCellValue(label))
        ..updateCell(xl.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: barisRingkasan + i), xl.IntCellValue(nilai));
    }
    return Uint8List.fromList(buku.encode()!);
  }

  /// Baris nota pembayaran (M28): dipakai kartu di layar dan PDF.
  static List<(String, String)> barisNota(Transaksi t) {
    final terakhir = t.pembayaran.last;
    return [
      ('Pengepul', t.pembeli ?? '-'),
      ('Sayur', '${t.komoditas} · ${Format.kg(t.beratTerjualKg ?? t.beratPanenKg)}'),
      ('Total harga', Format.rupiahRapat(t.totalPenjualan)),
      ('Dibayar sebelumnya', Format.rupiahRapat(t.totalDibayar - terakhir.jumlah)),
      ('Dibayar hari ini', Format.rupiahRapat(terakhir.jumlah)),
    ];
  }

  static String nomorNota(Transaksi t) => 'NP-${DateFormat('y-MMdd').format(t.pembayaran.last.tanggal)}';

  static String statusNota(Transaksi t) => t.status == StatusTransaksi.lunas
      ? 'Status: Lunas'
      : 'Status: Dicicil · cicilan ke-${t.pembayaran.length}';

  static Future<Uint8List> notaPdf(Transaksi t, String namaPemilik) async {
    final dok = pw.Document(theme: await _tema());
    dok.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _kepala('Nota Pembayaran', namaPemilik),
            pw.Text(
              'No. ${nomorNota(t)} · ${Format.tanggalSingkat(t.pembayaran.last.tanggal)}',
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),
            for (final (l, n) in barisNota(t)) _barisNilai(l, n),
            pw.Divider(color: PdfColors.grey400),
            _barisNilai('Sisa tagihan', Format.rupiahRapat(t.sisaTagihan), tebal: true),
            pw.SizedBox(height: 12),
            pw.Text(statusNota(t), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
    return dok.save();
  }

  static Future<FileDokumen> buatNota(Transaksi t, String namaPemilik) async => FileDokumen(
    isi: await notaPdf(t, namaPemilik),
    nama: 'Nota-${nomorNota(t)}-${t.nomor}.pdf',
    judul: 'Nota Pembayaran',
    halaman: 1,
  );

  static const _hijau = PdfColor.fromInt(0xFF1C5E3D);

  static pw.Widget _kepala(String judul, String pemilik) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 12),
    padding: const pw.EdgeInsets.only(bottom: 8),
    decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('MITRA MAJU TANI', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _hijau)),
        pw.Text(judul, style: const pw.TextStyle(color: PdfColors.grey700)),
        pw.Text('Pemilik: $pemilik', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
      ],
    ),
  );

  static pw.Widget _barisNilai(String label, String nilai, {bool tebal = false}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label),
        pw.Text(nilai, style: pw.TextStyle(fontWeight: tebal ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    ),
  );

  static Future<pw.ThemeData> _tema() async {
    Future<pw.Font> font(String berat) async =>
        pw.Font.ttf(await rootBundle.load('assets/fonts/PlusJakartaSans-$berat.ttf'));
    return pw.ThemeData.withFont(base: await font('Regular'), bold: await font('Bold'));
  }
}
