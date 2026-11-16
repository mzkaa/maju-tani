import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../models/ringkasan.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/chip_pilihan.dart';
import '../widgets/header_ringkas.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/kotak_lembut.dart';
import '../widgets/nav_bawah.dart';
import '../widgets/tombol.dart';

/// M11 Laporan.
class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final (awal, akhir) = store.periodeLaporan;
    final r = store.ringkasan(awal, akhir);
    final persenDibayar = r.totalPenjualan == 0 ? 0 : (r.sudahDibayar / r.totalPenjualan * 100).round();
    final belumLunas = r.sayurBelumLunas;

    return KerangkaHalaman(
      header: HeaderRingkas(
        judul: 'Laporan',
        keterangan: 'Rekap penjualan usaha',
        kanan: TombolBulatHeader(
          ikon: Ikon.download,
          label: 'Cetak & unduh laporan',
          onTap: () => context.push(Rute.cetakLaporan),
        ),
      ),
      nav: true,
      navAktif: TabUtama.laporan,
      isi: Padding(
        padding: EdgeInsets.only(top: 128 + AppLayout.ekstraAtas(context), bottom: 86),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Periode
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 14, 17, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChipPilihan(
                          teks: 'Bulan ini',
                          gaya: GayaChip.polos,
                          aktif: store.pilihanPeriode == PilihanPeriode.bulanIni,
                          onTap: () => store.aturPeriode(PilihanPeriode.bulanIni),
                        ),
                        const SizedBox(width: 8),
                        ChipPilihan(
                          teks: 'Bulan lalu',
                          gaya: GayaChip.polos,
                          aktif: store.pilihanPeriode == PilihanPeriode.bulanLalu,
                          onTap: () => store.aturPeriode(PilihanPeriode.bulanLalu),
                        ),
                        const SizedBox(width: 8),
                        ChipPilihan(
                          teks: 'Pilih tanggal',
                          gaya: GayaChip.polos,
                          aktif: store.pilihanPeriode == PilihanPeriode.pilihTanggal,
                          onTap: () => context.push(Rute.pilihPeriode),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const AppIcon(Ikon.calendar, size: 24, color: AppColors.teksKedua),
                      const SizedBox(width: 8),
                      Text(Format.rentang(awal, akhir), style: AppText.labelSisa),
                    ],
                  ),
                ],
              ),
            ),
            // Kartu angka
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 0, 17, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KartuAngka(
                    warna: WarnaKartuAngka.hijau,
                    ikon: Ikon.banknote,
                    label: 'Total penjualan',
                    angka: Format.rupiah(r.totalPenjualan),
                    keterangan: 'Rata-rata ${Format.rupiah(r.rataRataPerKg)} per kg',
                  ),
                  const SizedBox(height: 12),
                  KartuAngka(
                    warna: WarnaKartuAngka.hijau,
                    ikon: Ikon.checkCircle,
                    label: 'Sudah dibayar',
                    angka: Format.rupiah(r.sudahDibayar),
                    keterangan: '$persenDibayar% dari total penjualan',
                  ),
                  const SizedBox(height: 12),
                  KartuAngka(
                    warna: WarnaKartuAngka.kuning,
                    ikon: Ikon.hourglass,
                    label: 'Belum dibayar',
                    angka: Format.rupiah(r.belumDibayar),
                    keterangan: belumLunas.isEmpty
                        ? '${100 - persenDibayar}%'
                        : '${100 - persenDibayar}% · ${_gabung(belumLunas)}',
                  ),
                  const SizedBox(height: 12),
                  KartuAngka(
                    warna: WarnaKartuAngka.biru,
                    ikon: Ikon.scale,
                    label: 'Hasil panen',
                    angka: Format.kg(r.hasilPanenKg),
                    keterangan: '${Format.kg(r.terjualKg)} terjual · ${Format.kg(r.menungguKg)} menunggu',
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(17, 8, 17, 12), child: _GrafikPerSayur(r.perSayur)),
            // Unduh & rekap
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 8, 17, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warna tombol ini mengikuti Figma: garis #15803D; ikon putih kecuali satu batang abu-abu.
                  TombolGaris(
                    label: 'Lihat Rekap per Sayur',
                    ikon: Ikon.chart,
                    warnaGaris: AppColors.garisTombolRekap,
                    warnaTeks: AppColors.teksTombolRekap,
                    warnaPerGaris: const [Colors.white, Colors.white, Colors.white, AppColors.ikonDaun],
                    onTap: () => context.push(Rute.rekapSayur),
                  ),
                  const SizedBox(height: 12),
                  TombolUtama(
                    label: 'Unduh Laporan (PDF)',
                    ikon: Ikon.download,
                    onTap: () => context.push(Rute.cetakLaporan),
                  ),
                  const SizedBox(height: 12),
                  // Di prototype tombol ini belum punya tujuan; diarahkan ke Cetak & Unduh.
                  TombolGaris(label: 'Unduh Excel', ikon: Ikon.fileText, onTap: () => context.push(Rute.cetakLaporan)),
                  const SizedBox(height: 12),
                  KotakLembut(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppIcon(Ikon.info, size: 24, color: AppColors.teksKedua),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Keuntungan belum bisa dihitung karena biaya produksi belum dicatat.',
                            style: AppText.pesanBantuan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ["Bayam", "Kangkung", "Sawi"] → "Bayam, Kangkung dan Sawi"
  static String _gabung(List<String> nama) =>
      nama.length == 1 ? nama.first : '${nama.sublist(0, nama.length - 1).join(', ')} dan ${nama.last}';
}

enum WarnaKartuAngka { hijau, kuning, biru }

/// Kartu angka ringkas (komponen "Kartu Angka V2" di Figma).
class KartuAngka extends StatelessWidget {
  const KartuAngka({
    super.key,
    required this.warna,
    required this.ikon,
    required this.label,
    required this.angka,
    required this.keterangan,
  });

  final WarnaKartuAngka warna;
  final Ikon ikon;
  final String label;
  final String angka;
  final String keterangan;

  @override
  Widget build(BuildContext context) {
    final (latar, warnaIkon) = switch (warna) {
      WarnaKartuAngka.hijau => (AppColors.lunasLatar, AppColors.hijauTuaAlt),
      WarnaKartuAngka.kuning => (AppColors.kuningLatar, AppColors.kuningTeks),
      WarnaKartuAngka.biru => (AppColors.biruLatar, AppColors.biruTeks),
    };
    return KotakKaca(
      radius: 19,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: latar, borderRadius: BorderRadius.circular(14)),
            child: AppIcon(ikon, size: 32, color: warnaIkon),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.labelSisa),
                const SizedBox(height: 2),
                Text(angka, style: AppText.angkaKartu),
                const SizedBox(height: 2),
                Text(keterangan, style: AppText.bantuanIsian),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu "Penjualan per sayur": batang hijau (sudah dibayar) + coklat (belum dibayar).
class _GrafikPerSayur extends StatelessWidget {
  const _GrafikPerSayur(this.sayur);

  final List<RingkasanSayur> sayur;

  @override
  Widget build(BuildContext context) {
    final maks = sayur.isEmpty ? 1 : sayur.map((s) => s.penjualan).reduce((a, b) => a > b ? a : b);

    return KotakKaca(
      radius: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Penjualan per sayur', style: AppText.judulBagian),
          const SizedBox(height: 13),
          const Wrap(
            spacing: 11,
            runSpacing: 8,
            children: [
              _Keterangan(warna: AppColors.headerTengah, teks: 'Sudah dibayar'),
              _Keterangan(warna: AppColors.belumBatang, teks: 'Belum dibayar'),
            ],
          ),
          LayoutBuilder(
            builder: (context, c) {
              // Batang terpanjang = lebar kartu − 64 (262 dari 326 di Figma).
              final skala = maks == 0 ? 0.0 : (c.maxWidth - 64) / maks;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final s in sayur.where((s) => s.penjualan > 0)) ...[
                    const SizedBox(height: 13),
                    _BarisBatang(sayur: s, skala: skala),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Keterangan extends StatelessWidget {
  const _Keterangan({required this.warna, required this.teks});

  final Color warna;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 122,
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: warna, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(teks, style: AppText.pesanBantuan)),
        ],
      ),
    );
  }
}

class _BarisBatang extends StatelessWidget {
  const _BarisBatang({required this.sayur, required this.skala});

  final RingkasanSayur sayur;
  final double skala;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(sayur.nama, style: AppText.nilaiAngka),
            Expanded(
              child: Text(Format.rupiahRingkas(sayur.penjualan), style: AppText.nilaiAngka, textAlign: TextAlign.right),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sayur.dibayar > 0)
                Container(width: (sayur.dibayar * skala).roundToDouble(), height: 20, color: AppColors.headerTengah),
              if (sayur.belumDibayar > 0)
                Container(
                  width: (sayur.belumDibayar * skala).roundToDouble(),
                  height: 20,
                  color: AppColors.belumBatang,
                ),
            ],
          ),
        ),
        if (sayur.belumDibayar > 0) ...[
          const SizedBox(height: 6),
          Text(
            'Belum dibayar ${Format.rupiahRingkas(sayur.belumDibayar)}',
            style: AppText.bantuanIsian.copyWith(color: AppColors.kuningTeks),
          ),
        ],
      ],
    );
  }
}
