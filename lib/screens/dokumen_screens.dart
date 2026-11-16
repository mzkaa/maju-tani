import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/dokumen.dart';
import '../data/format.dart';
import '../models/transaksi.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/bilah_tombol.dart';
import '../widgets/header_ringkas.dart';
import '../widgets/isi_formulir.dart';
import '../widgets/isian_kaca.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/layar_tambahan.dart';
import '../widgets/tombol.dart';
import 'catat_panen_screens.dart';

const _bawah = 158.0 + 145 - 17;

/// Label periode laporan, mis. "Oktober 2026" atau "1 Okt – 5 Nov 2026".
String _labelPeriode(DateTime awal, DateTime akhir, {bool singkat = false}) {
  final satuBulan =
      awal.day == 1 && DateTime(akhir.year, akhir.month + 1, 0).day == akhir.day && awal.month == akhir.month;
  if (!satuBulan) return Format.rentang(awal, akhir);
  return DateFormat(singkat ? 'MMM y' : 'MMMM y', 'id_ID').format(awal);
}

// ---------------------------------------------------------------------------
// M24 Pilih Periode

enum _Cepat { hariIni, mingguIni, bulanIni, bulanLalu, tigaBulan }

class PilihPeriodeScreen extends StatefulWidget {
  const PilihPeriodeScreen({super.key});

  @override
  State<PilihPeriodeScreen> createState() => _PilihPeriodeScreenState();
}

class _PilihPeriodeScreenState extends State<PilihPeriodeScreen> {
  late final AppStore _store = context.read<AppStore>();
  late DateTime _awal = _store.periodeLaporan.$1;
  late DateTime? _akhir = _store.periodeLaporan.$2;
  late DateTime _bulan = DateTime(_awal.year, _awal.month);
  late _Cepat? _cepat = switch (_store.pilihanPeriode) {
    PilihanPeriode.bulanIni => _Cepat.bulanIni,
    PilihanPeriode.bulanLalu => _Cepat.bulanLalu,
    PilihanPeriode.pilihTanggal => null,
  };

  (DateTime, DateTime) _rentangCepat(_Cepat c) {
    final h = DateUtils.dateOnly(_store.hariIni);
    return switch (c) {
      _Cepat.hariIni => (h, h),
      _Cepat.mingguIni => (h.subtract(Duration(days: h.weekday - 1)), h),
      _Cepat.bulanIni => (_store.periodeAwal, h),
      _Cepat.bulanLalu => (DateTime(h.year, h.month - 1, 1), DateTime(h.year, h.month, 0)),
      _Cepat.tigaBulan => (DateTime(h.year, h.month - 2, 1), h),
    };
  }

  void _pilihCepat(_Cepat c) {
    final (a, b) = _rentangCepat(c);
    setState(() {
      _cepat = c;
      _awal = a;
      _akhir = b;
      _bulan = DateTime(a.year, a.month);
    });
  }

  /// Ketukan pertama = tanggal awal, ketukan kedua = tanggal akhir.
  void _ketukTanggal(DateTime d) {
    setState(() {
      _cepat = null;
      if (_akhir != null || d.isBefore(_awal)) {
        _awal = d;
        _akhir = null;
      } else {
        _akhir = d;
      }
    });
  }

  void _terapkan() {
    final akhir = _akhir ?? _awal;
    switch (_cepat) {
      case _Cepat.bulanIni:
        _store.aturPeriode(PilihanPeriode.bulanIni);
      case _Cepat.bulanLalu:
        _store.aturPeriode(PilihanPeriode.bulanLalu);
      default:
        _store.aturPeriode(PilihanPeriode.pilihTanggal, awal: _awal, akhir: akhir);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    const label = {
      _Cepat.hariIni: 'Hari ini',
      _Cepat.mingguIni: 'Minggu ini',
      _Cepat.bulanIni: 'Bulan ini',
      _Cepat.bulanLalu: 'Bulan lalu',
      _Cepat.tigaBulan: '3 bulan',
    };
    final akhir = _akhir;

    return KerangkaHalaman(
      header: const HeaderRingkas(judul: 'Pilih Periode', keterangan: 'Untuk laporan & riwayat', kiri: TombolKembali()),
      bilahBawah: BilahTombol(
        tombol: [
          TombolUtama(label: 'Terapkan', onTap: _terapkan),
          TombolGaris(label: 'Batal', onTap: () => context.pop()),
        ],
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: _bawah,
        children: [
          Text('Pilihan cepat', style: AppText.tebal14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in _Cepat.values) ChipPil(teks: label[c]!, aktif: c == _cepat, onTap: () => _pilihCepat(c)),
            ],
          ),
          KotakKaca(
            radius: 19,
            padding: const EdgeInsets.all(13),
            child: _Kalender(
              bulan: _bulan,
              awal: _awal,
              akhir: akhir,
              onGeser: (n) => setState(() => _bulan = DateTime(_bulan.year, _bulan.month + n)),
              onKetuk: _ketukTanggal,
            ),
          ),
          KotakKaca(
            radius: 19,
            padding: const EdgeInsets.all(13),
            child: Column(
              children: [
                BarisNilai(
                  label: 'Dari',
                  nilai: Format.tanggalSingkat(_awal),
                  gayaLabel: AppText.sedang14Samar,
                  gayaNilai: AppText.tebal14,
                ),
                const SizedBox(height: 6),
                BarisNilai(
                  label: 'Sampai',
                  nilai: akhir == null ? '-' : Format.tanggalSingkat(akhir),
                  gayaLabel: AppText.sedang14Samar,
                  gayaNilai: AppText.tebal14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kalender satu bulan (Senin di kiri) dengan rentang tanggal yang disorot.
class _Kalender extends StatelessWidget {
  const _Kalender({
    required this.bulan,
    required this.awal,
    required this.akhir,
    required this.onGeser,
    required this.onKetuk,
  });

  final DateTime bulan;
  final DateTime awal;
  final DateTime? akhir;
  final ValueChanged<int> onGeser;
  final ValueChanged<DateTime> onKetuk;

  @override
  Widget build(BuildContext context) {
    final jumlahHari = DateTime(bulan.year, bulan.month + 1, 0).day;
    final kosongAwal = DateTime(bulan.year, bulan.month).weekday - 1;
    final sel = <DateTime?>[
      for (var i = 0; i < kosongAwal; i++) null,
      for (var d = 1; d <= jumlahHari; d++) DateTime(bulan.year, bulan.month, d),
    ];
    while (sel.length % 7 != 0) {
      sel.add(null);
    }
    final panah = AppText.gaya(19, FontWeight.w700, AppColors.teksUtama, tinggi: 1.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => onGeser(-1),
              child: Text('‹', style: panah),
            ),
            Text(Format.bulanTahun(bulan), style: AppText.gaya(16, FontWeight.w800, AppColors.teksUtama, tinggi: 1.35)),
            GestureDetector(
              onTap: () => onGeser(1),
              child: Text('›', style: panah),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final h in const ['S', 'S', 'R', 'K', 'J', 'S', 'M'])
              SizedBox(
                width: 44,
                child: Text(
                  h,
                  textAlign: TextAlign.center,
                  style: AppText.gaya(13, FontWeight.w700, const Color(0x800F1F19), tinggi: 1.35),
                ),
              ),
          ],
        ),
        for (var r = 0; r < sel.length; r += 7) ...[
          const SizedBox(height: 10),
          Row(children: [for (final d in sel.sublist(r, r + 7)) _SelTanggal(d, awal, akhir, onKetuk)]),
        ],
      ],
    );
  }
}

class _SelTanggal extends StatelessWidget {
  const _SelTanggal(this.d, this.awal, this.akhir, this.onKetuk);

  final DateTime? d;
  final DateTime awal;
  final DateTime? akhir;
  final ValueChanged<DateTime> onKetuk;

  @override
  Widget build(BuildContext context) {
    final tanggal = d;
    if (tanggal == null) return const SizedBox(width: 44, height: 40);
    final ujung = DateUtils.isSameDay(tanggal, awal) || (akhir != null && DateUtils.isSameDay(tanggal, akhir));
    final dalam = akhir != null && tanggal.isAfter(awal) && tanggal.isBefore(akhir!);
    return GestureDetector(
      onTap: () => onKetuk(tanggal),
      child: Container(
        width: 44,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ujung ? AppColors.hijauAktif : (dalam ? const Color(0x1F2A7A52) : null), // 12%
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${tanggal.day}',
          style: AppText.gaya(
            14,
            ujung ? FontWeight.w800 : FontWeight.w600,
            ujung ? Colors.white : AppColors.teksUtama,
            tinggi: 1.35,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M25 Cetak & Unduh Laporan

class CetakLaporanScreen extends StatefulWidget {
  const CetakLaporanScreen({super.key});

  @override
  State<CetakLaporanScreen> createState() => _CetakLaporanScreenState();
}

class _CetakLaporanScreenState extends State<CetakLaporanScreen> {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final (awal, akhir) = store.periodeLaporan;
    const jenis = [
      (JenisDokumen.penjualan, 'Pemasukan & pembayaran'),
      (JenisDokumen.rekapSayur, 'Berat & harga tiap komoditas'),
      (JenisDokumen.riwayatHarga, 'Naik-turun harga'),
    ];

    return KerangkaHalaman(
      header: const HeaderRingkas(judul: 'Cetak & Unduh', keterangan: 'Atur isi dokumen', kiri: TombolKembali()),
      bilahBawah: BilahTombol(
        tombol: [
          TombolUtama(label: 'Lihat Pratinjau', onTap: () => context.push(Rute.pratinjauDokumen)),
          TombolGaris(label: 'Batal', onTap: () => context.pop()),
        ],
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: _bawah,
        children: [
          Text('Jenis dokumen', style: AppText.tebal14),
          for (final (j, ket) in jenis)
            _PilihanDokumen(
              judul: j.judul,
              keterangan: ket,
              dipilih: j == store.jenisDokumen,
              onTap: () => store.aturDokumen(jenis: j),
            ),
          Text('Format & periode', style: AppText.tebal14),
          Row(
            children: [
              ChipPil(teks: 'PDF', aktif: store.formatPdf, onTap: () => store.aturDokumen(pdf: true)),
              const SizedBox(width: 8),
              ChipPil(teks: 'Excel', aktif: !store.formatPdf, onTap: () => store.aturDokumen(pdf: false)),
            ],
          ),
          IsianKaca(
            label: 'Periode',
            ikon: Ikon.calendar,
            nilaiTetap: Format.rentangPanjang(awal, akhir),
            onTap: () => context.push(Rute.pilihPeriode),
          ),
        ],
      ),
    );
  }
}

class _PilihanDokumen extends StatelessWidget {
  const _PilihanDokumen({required this.judul, required this.keterangan, required this.dipilih, required this.onTap});

  final String judul;
  final String keterangan;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KotakKaca(
      radius: 19,
      padding: const EdgeInsets.all(12),
      warnaGaris: dipilih ? AppColors.hijauAktif : null,
      tebalGaris: dipilih ? 2 : 1,
      onTap: onTap,
      label: judul,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0x2E2A7A52), shape: BoxShape.circle), // 18%
            child: Text(
              dipilih ? '✓' : '○',
              style: AppText.gaya(16, FontWeight.w800, AppColors.hijauAktif, tinggi: 1.35),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul, style: AppText.gaya(15, FontWeight.w700, AppColors.teksUtama, tinggi: 1.35)),
                Text(keterangan, style: AppText.gaya(13, FontWeight.w500, const Color(0xA60F1F19), tinggi: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M26 Pratinjau Dokumen

class PratinjauDokumenScreen extends StatefulWidget {
  const PratinjauDokumenScreen({super.key});

  @override
  State<PratinjauDokumenScreen> createState() => _PratinjauDokumenScreenState();
}

class _PratinjauDokumenScreenState extends State<PratinjauDokumenScreen> {
  late final AppStore _store = context.read<AppStore>();
  bool _sibuk = false;

  Future<void> _cetak() => Printing.layoutPdf(
    name: _store.jenisDokumen.judul,
    onLayout: (_) => Dokumen.laporanPdf(_store, _store.jenisDokumen),
  );

  Future<void> _unduh() async {
    setState(() => _sibuk = true);
    try {
      final file = await Dokumen.buatLaporan(_store, _store.jenisDokumen, pdf: _store.formatPdf);
      await file.bagikan();
      if (mounted) await context.push(Rute.dokumenBerhasil, extra: file);
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final (awal, akhir) = store.periodeLaporan;
    final tabel = TabelDokumen.dari(store, store.jenisDokumen);
    final kepala = AppText.gaya(11, FontWeight.w700, const Color(0x990F1F19), tinggi: 1.35);
    final isi = AppText.gaya(11, FontWeight.w500, const Color(0xE60F1F19), tinggi: 1.35);

    Widget baris(List<String> sel, TextStyle gaya) => Row(
      children: [
        for (final (i, s) in sel.indexed) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(child: Text(s, style: gaya)),
        ],
      ],
    );

    return KerangkaHalaman(
      header: HeaderRingkas(
        judul: 'Pratinjau Dokumen',
        keterangan: '${tabel.jenis.judul} · ${_labelPeriode(awal, akhir, singkat: true)}',
        kiri: const TombolKembali(),
      ),
      bilahBawah: BilahTombol(
        tombol: [
          TombolUtama(label: 'Cetak', onTap: _cetak),
          TombolGaris(
            label: _sibuk ? 'Menyimpan…' : (store.formatPdf ? 'Unduh PDF' : 'Unduh Excel'),
            onTap: _sibuk ? () {} : _unduh,
          ),
        ],
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: _bawah,
        children: [
          // Kertas putih pratinjau.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [AppShadows.figma(const Color(0x2E000000), y: 12, blur: 30, spread: -6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Color(0x2E2A7A52), shape: BoxShape.circle),
                      child: Text('🌱', style: AppText.gaya(14.2, FontWeight.w800, AppColors.hijauAktif, tinggi: 1.35)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MITRA MAJU TANI',
                          style: AppText.gaya(13, FontWeight.w800, AppColors.teksUtama, tinggi: 1.35),
                        ),
                        Text(
                          '${tabel.jenis.judul} · ${_labelPeriode(awal, akhir)}',
                          style: AppText.gaya(11, FontWeight.w500, const Color(0x990F1F19), tinggi: 1.35),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const GarisTipis(warna: Color(0x1A0F1F19)),
                const SizedBox(height: 8),
                baris([for (final k in tabel.kolom) k.$1], kepala),
                for (final b in tabel.baris) ...[
                  const SizedBox(height: 8),
                  baris([for (final (i, v) in b.indexed) tabel.teks(i, v)], isi),
                ],
                if (tabel.baris.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Belum ada data pada periode ini.', style: isi),
                ],
                const SizedBox(height: 8),
                const GarisTipis(warna: Color(0x1A0F1F19)),
                for (final (i, (label, nilai)) in tabel.ringkasan.indexed) ...[
                  const SizedBox(height: 8),
                  BarisNilai(
                    label: label,
                    nilai: Format.rupiahRapat(nilai),
                    gayaLabel: AppText.sedang14Samar,
                    gayaNilai: i == 0
                        ? AppText.gaya(15, FontWeight.w800, AppColors.teksUtama, tinggi: 1.35)
                        : AppText.tebal14,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Dicetak ${Format.tanggalSingkat(store.hariIni)} · Halaman 1 dari 1',
                  style: AppText.gaya(10, FontWeight.w500, const Color(0x730F1F19), tinggi: 1.35),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const ChipPil(teks: '1 halaman', aktif: false),
              const SizedBox(width: 8),
              const ChipPil(teks: 'A4', aktif: false),
              const SizedBox(width: 8),
              // Membuka lembar bagikan (WhatsApp, Files, dll.) untuk PDF laporan.
              ChipPil(
                teks: 'Bagikan',
                aktif: false,
                onTap: () async => Printing.sharePdf(
                  bytes: await Dokumen.laporanPdf(_store, _store.jenisDokumen),
                  filename: '${_store.jenisDokumen.judul}.pdf',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M27 Dokumen Berhasil

class DokumenBerhasilScreen extends StatelessWidget {
  const DokumenBerhasilScreen({super.key, required this.file});

  /// File yang baru dibuat di M26; null bila layar dibuka langsung (pratinjau desain).
  final FileDokumen? file;

  static String _ukuran(int byte) =>
      byte < 1024 * 1024 ? '${(byte / 1024).ceil()} KB' : '${(byte / 1024 / 1024).toStringAsFixed(1)} MB';

  @override
  Widget build(BuildContext context) {
    final (awal, akhir) = context.watch<AppStore>().periodeLaporan;
    final f = file;
    final judul = f?.judul ?? JenisDokumen.penjualan.judul;
    final namaFile = f?.nama ?? 'Laporan-Penjualan-${DateFormat('MMM-y', 'id_ID').format(akhir)}.pdf';
    final pdf = f?.pdf ?? true;
    final keterangan = f == null
        ? '184 KB  ·  1 halaman  ·  baru saja'
        : [_ukuran(f.ukuran), if (f.halaman case final h?) '$h halaman', 'baru saja'].join('  ·  ');

    return KerangkaHalaman(
      header: HeaderRingkas(
        judul: 'Berhasil',
        keterangan: '$judul · ${_labelPeriode(awal, akhir, singkat: true)}',
        kiri: const TombolKembali(),
      ),
      bilahBawah: BilahTombol(
        tombol: [
          // Lembar bagikan: buka di aplikasi lain, simpan ke Files, atau kirim lewat WhatsApp.
          TombolUtama(
            label: 'Buka File',
            onTap: f == null ? () {} : f.bagikan,
          ),
          TombolGaris(label: 'Kembali ke Laporan', onTap: () => context.go(Rute.laporan)),
        ],
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: _bawah,
        children: [
          const SizedBox(height: 30),
          const Center(child: LingkaranSukses(warnaDalam: Color(0xFF1C5E3D), ukuranCentang: 36, tebalCentang: 3)),
          Text(
            'Laporan berhasil diunduh',
            textAlign: TextAlign.center,
            style: AppText.gaya(20, FontWeight.w800, AppColors.teksUtama, tinggi: 1.35),
          ),
          Text(
            'Bisa langsung dicetak atau dikirim lewat WhatsApp.',
            textAlign: TextAlign.center,
            style: AppText.gaya(14, FontWeight.w500, const Color(0x7D0F1F19), tinggi: 1.35), // 70% × 70%
          ),
          KotakKaca(
            radius: 20,
            padding: const EdgeInsets.all(16),
            gradien: const GradienFigma(
              awal: Offset(0, 0),
              akhir: Offset(0.6, 0.8),
              colors: [Color(0xF217422E), Color(0xF20D291C)],
            ),
            warnaGaris: const Color(0x2EFFFFFF),
            bayangan: [AppShadows.figma(const Color(0x40081F12), y: 14, blur: 32, spread: -10)],
            sorotan: null,
            kaburKaca: null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.pdfAwal, AppColors.pdfAkhir],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppIcon(Ikon.fileText, size: 18, color: Colors.white, tebal: 1.5),
                          const SizedBox(height: 1),
                          Text(pdf ? 'PDF' : 'XLS', style: AppText.gaya(9, FontWeight.w800, Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(namaFile, style: AppText.gaya(14, FontWeight.w700, Colors.white)),
                          const SizedBox(height: 3),
                          Text(keterangan, style: AppText.gaya(12, FontWeight.w500, const Color(0x99FFFFFF))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: AppColors.langkahSelesai, shape: BoxShape.circle),
                      child: const AppIcon(Ikon.check, size: 14, color: AppColors.ikonLangkah, tebal: 1.1667),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const GarisTipis(warna: Color(0x24FFFFFF)),
                const SizedBox(height: 14),
                BarisNilai(
                  label: 'Tersimpan di',
                  nilai: 'Sesuai pilihan saat dibagikan',
                  gayaLabel: AppText.gaya(12, FontWeight.w500, const Color(0x99FFFFFF)),
                  gayaNilai: AppText.gaya(12, FontWeight.w700, const Color(0xE6FFFFFF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M28 Nota Pembayaran

class NotaPembayaranScreen extends StatelessWidget {
  const NotaPembayaranScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final t = store.cariTransaksi(id);
    final adaNota = t != null && t.pembayaran.isNotEmpty;
    return KerangkaHalaman(
      header: const HeaderRingkas(
        judul: 'Nota Pembayaran',
        keterangan: 'Bukti uang dari pengepul',
        kiri: TombolKembali(),
      ),
      bilahBawah: BilahTombol(
        tombol: [
          TombolUtama(
            label: 'Cetak Nota',
            onTap: !adaNota
                ? () {}
                : () => Printing.layoutPdf(
                    name: 'Nota ${Dokumen.nomorNota(t)}',
                    onLayout: (_) => Dokumen.notaPdf(t, store.namaPemilik),
                  ),
          ),
          // Lembar bagikan sistem; pilih WhatsApp di sana.
          TombolGaris(
            label: 'Bagikan ke WhatsApp',
            onTap: !adaNota
                ? () {}
                : () async {
                    final nota = await Dokumen.buatNota(t, store.namaPemilik);
                    await nota.bagikan(teks: 'Nota pembayaran ${t.komoditas} - Mitra Maju Tani');
                  },
          ),
        ],
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: _bawah,
        children: [if (adaNota) _KartuNota(t)],
      ),
    );
  }
}

class _KartuNota extends StatelessWidget {
  const _KartuNota(this.t);

  final Transaksi t;

  @override
  Widget build(BuildContext context) {
    final terakhir = t.pembayaran.last;
    final lunas = t.status == StatusTransaksi.lunas;
    final nomor = Dokumen.nomorNota(t);
    final label = AppText.sedang14Samar;
    final nilai = AppText.tebal14;
    final baris = Dokumen.barisNota(t);

    return KotakKaca(
      radius: 19,
      padding: const EdgeInsets.all(16),
      warna: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'NOTA PEMBAYARAN',
            textAlign: TextAlign.center,
            style: AppText.gaya(14, FontWeight.w800, AppColors.teksUtama, tinggi: 1.35),
          ),
          const SizedBox(height: 8),
          Text(
            'No. $nomor · ${Format.tanggalSingkat(terakhir.tanggal)}',
            textAlign: TextAlign.center,
            style: AppText.gaya(12, FontWeight.w500, const Color(0x990F1F19), tinggi: 1.35),
          ),
          const SizedBox(height: 8),
          const GarisTipis(warna: Color(0x1A0F1F19)),
          for (final (l, n) in baris) ...[
            const SizedBox(height: 8),
            BarisNilai(label: l, nilai: n, gayaLabel: label, gayaNilai: nilai),
          ],
          const SizedBox(height: 8),
          const GarisTipis(warna: Color(0x1A0F1F19)),
          const SizedBox(height: 8),
          BarisNilai(
            label: 'Sisa tagihan',
            nilai: Format.rupiahRapat(t.sisaTagihan),
            gayaLabel: label,
            gayaNilai: AppText.gaya(15, FontWeight.w800, AppColors.teksUtama, tinggi: 1.35),
          ),
          const SizedBox(height: 8),
          Text(
            Dokumen.statusNota(t),
            textAlign: TextAlign.center,
            style: AppText.gaya(
              13,
              FontWeight.w700,
              lunas ? AppColors.hijauAktif : AppColors.statusDicicil,
              tinggi: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
