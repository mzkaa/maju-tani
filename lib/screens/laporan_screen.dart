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
        padding: EdgeInsets.only(top: 138 + AppLayout.ekstraAtas(context), bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Periode
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChipPilihan(
                    teks: 'Bulan ini',
                    aktif: store.pilihanPeriode == PilihanPeriode.bulanIni,
                    onTap: () => store.aturPeriode(PilihanPeriode.bulanIni),
                  ),
                  const SizedBox(width: 8),
                  ChipPilihan(
                    teks: 'Bulan lalu',
                    aktif: store.pilihanPeriode == PilihanPeriode.bulanLalu,
                    onTap: () => store.aturPeriode(PilihanPeriode.bulanLalu),
                  ),
                  const SizedBox(width: 8),
                  ChipPilihan(
                    teks: 'Pilih tanggal',
                    aktif: store.pilihanPeriode == PilihanPeriode.pilihTanggal,
                    onTap: () => context.push(Rute.pilihPeriode),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 17, 12),
              child: Row(
                children: [
                  const AppIcon(Ikon.calendar, size: 16, color: AppColors.teksKedua),
                  const SizedBox(width: 6),
                  Text(Format.rentang(awal, akhir), style: AppText.gaya(13, FontWeight.w600, AppColors.teksKedua)),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 17), child: _KartuRingkasan(r)),
            if (r.perSayur.any((s) => s.penjualan > 0)) ...[
              const SizedBox(height: 12),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 17), child: _GrafikPerSayur(r.perSayur)),
            ],
            // Unduh & rekap
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 16, 17, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TombolUtama(
                    label: 'Unduh Laporan (PDF)',
                    ikon: Ikon.download,
                    onTap: () => context.push(Rute.cetakLaporan),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TombolGaris(
                          label: 'Rekap per Sayur',
                          onTap: () => context.push(Rute.rekapSayur),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Di prototype tombol ini belum punya tujuan; diarahkan ke Cetak & Unduh.
                      Expanded(
                        child: TombolGaris(
                          label: 'Unduh Excel',
                          onTap: () => context.push(Rute.cetakLaporan),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppIcon(Ikon.info, size: 16, color: AppColors.teksKedua),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Keuntungan belum bisa dihitung karena biaya produksi belum dicatat.',
                          style: AppText.gaya(12, FontWeight.w500, AppColors.teksKedua, tinggi: 1.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu kartu ringkasan: total penjualan, batang sudah/belum dibayar, dan hasil panen.
class _KartuRingkasan extends StatelessWidget {
  const _KartuRingkasan(this.r);

  final Ringkasan r;

  @override
  Widget build(BuildContext context) {
    final persen = r.totalPenjualan == 0 ? 0.0 : r.sudahDibayar / r.totalPenjualan;
    final persenBulat = (persen * 100).round();
    return KotakKaca(
      radius: 21,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total penjualan', style: AppText.labelSaldo),
          const SizedBox(height: 4),
          Text(Format.rupiah(r.totalPenjualan), style: AppText.angkaSaldo.copyWith(fontSize: 26)),
          const SizedBox(height: 2),
          Text(
            'Rata-rata ${Format.rupiah(r.rataRataPerKg)} per kg',
            style: AppText.gaya(12, FontWeight.w500, AppColors.teksKedua),
          ),
          const SizedBox(height: 16),
          _BatangBayar(persen: persen),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Bagian(
                  warna: AppColors.hijau,
                  label: 'Sudah dibayar · $persenBulat%',
                  angka: Format.rupiah(r.sudahDibayar),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Bagian(
                  warna: AppColors.oranyeGaris,
                  label: 'Belum dibayar · ${r.totalPenjualan == 0 ? 0 : 100 - persenBulat}%',
                  angka: Format.rupiah(r.belumDibayar),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0x140F1F19)),
          const SizedBox(height: 12),
          Row(
            children: [
              const AppIcon(Ikon.sprout, size: 16, color: AppColors.hijau),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hasil panen · ${Format.kg(r.terjualKg)} terjual, ${Format.kg(r.menungguKg)} menunggu',
                  style: AppText.gaya(12, FontWeight.w500, AppColors.teksKedua),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(Format.kg(r.hasilPanenKg), style: AppText.gaya(15, FontWeight.w800, AppColors.teksUtama)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Batang tebal membulat: hijau = sudah dibayar, oranye lembut = belum. Terisi pelan saat tampil.
class _BatangBayar extends StatelessWidget {
  const _BatangBayar({required this.persen});

  final double persen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: double.infinity,
        height: 12,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: AppColors.oranyeGaris.withValues(alpha: 0.25))),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: persen.clamp(0, 1)),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, p, _) => FractionallySizedBox(
                widthFactor: p,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(colors: [AppColors.hijau, AppColors.hijauTua]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bagian extends StatelessWidget {
  const _Bagian({required this.warna, required this.label, required this.angka});

  final Color warna;
  final String label;
  final String angka;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(child: Text(label, style: AppText.gaya(12, FontWeight.w500, AppColors.teksKedua), maxLines: 1)),
          ],
        ),
        const SizedBox(height: 3),
        Text(angka, style: AppText.gaya(16, FontWeight.w800, AppColors.teksUtama)),
      ],
    );
  }
}

/// Kartu "Penjualan per sayur": tiap sayur satu batang (hijau = sudah dibayar, oranye lembut = belum).
class _GrafikPerSayur extends StatelessWidget {
  const _GrafikPerSayur(this.sayur);

  final List<RingkasanSayur> sayur;

  @override
  Widget build(BuildContext context) {
    final tampil = sayur.where((s) => s.penjualan > 0).toList();
    final maks = tampil.map((s) => s.penjualan).fold(0, (a, b) => a > b ? a : b);

    return KotakKaca(
      radius: 21,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Penjualan per sayur', style: AppText.gaya(15, FontWeight.w800, AppColors.teksUtama)),
          for (final s in tampil) ...[
            const SizedBox(height: 14),
            _BarisBatang(sayur: s, bagian: maks == 0 ? 0 : s.penjualan / maks),
          ],
        ],
      ),
    );
  }
}

class _BarisBatang extends StatelessWidget {
  const _BarisBatang({required this.sayur, required this.bagian});

  final RingkasanSayur sayur;

  /// Panjang batang dibanding sayur dengan penjualan terbesar (0..1).
  final double bagian;

  @override
  Widget build(BuildContext context) {
    final dibayar = sayur.penjualan == 0 ? 0.0 : sayur.dibayar / sayur.penjualan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(sayur.nama, style: AppText.gaya(13, FontWeight.w700, AppColors.teksUtama))),
            Text(Format.rupiahRingkas(sayur.penjualan), style: AppText.gaya(13, FontWeight.w700, AppColors.teksUtama)),
          ],
        ),
        const SizedBox(height: 6),
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: bagian.clamp(0.04, 1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sayur.dibayar > 0)
                    Expanded(
                      flex: (dibayar * 1000).round(),
                      child: const ColoredBox(color: AppColors.hijau),
                    ),
                  if (sayur.belumDibayar > 0)
                    Expanded(
                      flex: ((1 - dibayar) * 1000).round(),
                      child: ColoredBox(color: AppColors.oranyeGaris.withValues(alpha: 0.45)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
