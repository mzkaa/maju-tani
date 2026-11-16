import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../models/transaksi.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/cincin_persen.dart';
import '../widgets/header_hijau.dart';
import '../widgets/judul_seksi.dart';
import '../widgets/kartu_harga.dart';
import '../widgets/kartu_tugas.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/nav_bawah.dart';

/// M02 Beranda.
class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ekstraAtas = AppLayout.ekstraAtas(context);
    return KerangkaHalaman(
      header: HeaderHijau(ekstraAtas: ekstraAtas, child: const _Sapaan()),
      isi: _Isi(ekstraAtas: ekstraAtas),
      nav: true,
      navAktif: TabUtama.beranda,
    );
  }
}

// ---------------------------------------------------------------------------
// Header: sapaan, tombol akun, tombol notifikasi

class _Sapaan extends StatelessWidget {
  const _Sapaan();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 56),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: 47,
          child: Row(
            children: [
              _TombolHeader(
                label: 'Akun & Bantuan',
                onTap: () => context.push(Rute.akun),
                child: const AppIcon(Ikon.user, size: 28, color: Color(0xFFFFFFFF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(Format.sapaan(store.hariIni), style: AppText.sapaan),
                    Text(store.namaPemilik, style: AppText.namaPengguna),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _TombolHeader(
                label: 'Notifikasi',
                onTap: () => context.push(Rute.notifikasi),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const AppIcon(Ikon.bell, size: 26, color: Color(0xFFFFFFFF)),
                    // Titik di pojok lonceng, hanya bila ada notifikasi belum dibaca.
                    if (store.notifikasi.any((n) => !n.dibaca))
                      const Positioned(
                        right: -2,
                        top: -2,
                        child: SizedBox.square(
                          dimension: 12,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.kuningTitik,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(BorderSide(color: AppColors.headerTengah, width: 2)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TombolHeader extends StatelessWidget {
  const _TombolHeader({required this.label, required this.onTap, required this.child});

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 45,
      child: KotakKaca(
        radius: 22,
        warna: const Color(0x24FFFFFF), // putih 14%
        warnaGaris: const Color(0x80FFFFFF), // putih 50%
        bayangan: const [],
        sorotan: null,
        kaburKaca: 4,
        label: label,
        onTap: onTap,
        child: Center(child: child),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Isi halaman

class _Isi extends StatelessWidget {
  const _Isi({required this.ekstraAtas});

  final double ekstraAtas;

  @override
  Widget build(BuildContext context) {
    final lebar = MediaQuery.sizeOf(context).width;
    final kanan = lebar - 390; // geser hiasan kanan pada layar lebih lebar
    final y = ekstraAtas;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Lingkaran putih samar di area atas.
        Positioned(
          left: 310 + kanan,
          top: 90 + y,
          child: const _Lingkaran(ukuran: 120, warna: Color(0x12FFFFFF)),
        ),
        Positioned(
          left: -60,
          top: 150 + y,
          child: const _Lingkaran(ukuran: 140, warna: Color(0x0DFFFFFF)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 147.5 + y),
            const Padding(padding: EdgeInsets.only(left: 24), child: _ChipTanggal()),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppLayout.tepi),
              child: _KartuSaldo(),
            ),
            const SizedBox(height: 25 + 20),
            const Padding(padding: EdgeInsets.fromLTRB(AppLayout.tepi, 0, AppLayout.tepi, 94), child: _Seksi()),
          ],
        ),
      ],
    );
  }
}

class _Lingkaran extends StatelessWidget {
  const _Lingkaran({required this.ukuran, required this.warna});

  final double ukuran;
  final Color warna;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
    ),
  );
}

class _ChipTanggal extends StatelessWidget {
  const _ChipTanggal();

  @override
  Widget build(BuildContext context) {
    final hariIni = context.select<AppStore, DateTime>((s) => s.hariIni);
    return KotakKaca(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
      warna: const Color(0xB3FFFFFF), // putih 70%
      warnaGaris: const Color(0xFFFFFFFF),
      tebalGaris: 1.5,
      bayangan: const [],
      sorotan: null,
      kaburKaca: 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(Ikon.calendar, size: 20, color: AppColors.ikonHijau),
          const SizedBox(width: 8),
          Text(Format.tanggalPanjang(hariIni), style: AppText.tanggal),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu saldo: cincin persen, uang masuk, dan dua angka ringkas

class _KartuSaldo extends StatelessWidget {
  const _KartuSaldo();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return KotakKaca(
      radius: 21,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              CincinPersen(persen: store.persenSudahMasuk),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Uang masuk bulan ini', style: AppText.labelSaldo),
                    const SizedBox(height: 6),
                    Text(Format.rupiah(store.uangMasuk), style: AppText.angkaSaldo),
                    const SizedBox(height: 6),
                    const _Legenda(warna: AppColors.hijau, teks: 'Sudah masuk'),
                    const SizedBox(height: 4),
                    const _Legenda(warna: AppColors.oranyeGaris, teks: 'Belum dibayar'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _ChipAngka(
                  warnaGaris: AppColors.oranyeGaris,
                  warnaAngka: AppColors.oranyeAngka,
                  angka: Format.rupiah(store.belumDibayar),
                  label: 'belum dibayar',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChipAngka(
                  warnaGaris: AppColors.biruGaris,
                  warnaAngka: AppColors.biruAngka,
                  angka: Format.kg(store.hasilPanenKg),
                  label: 'hasil panen',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.warna, required this.teks});

  final Color warna;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(teks, style: AppText.legenda),
      ],
    );
  }
}

class _ChipAngka extends StatelessWidget {
  const _ChipAngka({required this.warnaGaris, required this.warnaAngka, required this.angka, required this.label});

  final Color warnaGaris;
  final Color warnaAngka;
  final String angka;
  final String label;

  @override
  Widget build(BuildContext context) {
    return KotakKaca(
      radius: 14,
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      warna: const Color(0x99FFFFFF), // putih 60%
      warnaGaris: const Color(0xFFFFFFFF),
      tebalGaris: 1.5,
      bayangan: AppShadows.chip,
      sorotan: null,
      kaburKaca: null,
      child: Row(
        children: [
          Container(
            width: 5,
            height: 40,
            decoration: BoxDecoration(color: warnaGaris, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(angka, style: AppText.angkaChip.copyWith(color: warnaAngka), maxLines: 1, softWrap: false),
                Text(label, style: AppText.legenda),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seksi: menu cepat, perlu diurus, perkembangan harga

class _Seksi extends StatelessWidget {
  const _Seksi();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final tugas = store.perluDiurus.take(3).toList();

    final belumDijual = store.pertamaDenganStatus({StatusTransaksi.menungguPenjualan});
    final belumLunas = store.pertamaDenganStatus({StatusTransaksi.menungguPembayaran, StatusTransaksi.dibayarSebagian});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const JudulSeksi(ikon: Ikon.clipboard, label: 'MENU CEPAT', judul: 'Mau catat apa?', teksRataAtas: true),
        const SizedBox(height: 20),
        _MenuCepat(
          jumlahMenungguHarga: store.jumlahStatus(StatusTransaksi.menungguPenjualan),
          jumlahBelumLunas: store.jumlahBelumLunas,
          onLengkapiHarga: belumDijual == null ? null : () => context.push(Rute.lengkapiPenjualan(belumDijual.id)),
          onCatatBayaran: belumLunas == null ? null : () => context.push(Rute.catatPembayaran(belumLunas.id)),
        ),
        const SizedBox(height: 20),
        JudulSeksi(
          ikon: Ikon.clock,
          label: 'PENGINGAT',
          judul: 'Perlu diurus',
          aksi: TombolKecil(teks: 'Lihat semua', onTap: () => context.go(Rute.riwayat)),
        ),
        const SizedBox(height: 20),
        for (final (i, t) in tugas.indexed) ...[if (i > 0) const SizedBox(height: 12), _kartuTugas(context, t)],
        // Grafik harga tampil setelah ada penjualan minimal 2 bulan.
        if (store.sayurHargaBeranda case final sayur?) ...[
          const SizedBox(height: 20),
          JudulSeksi(ikon: Ikon.trendingUp, label: 'PERKEMBANGAN HARGA', judul: 'Harga $sayur per kg'),
          const SizedBox(height: 20),
          KartuHarga(riwayat: store.riwayatHarga(sayur), onTap: () => context.push(Rute.riwayatHarga)),
        ],
      ],
    );
  }

  /// Ikon, warna, teks, dan tujuan kartu tugas sesuai status catatan.
  Widget _kartuTugas(BuildContext context, Transaksi t) {
    switch (t.status) {
      case StatusTransaksi.menungguPenjualan:
        return KartuTugas(
          ikon: Ikon.clock,
          warnaIkon: AppColors.biruIkon,
          latarIkon: AppColors.biruLatar,
          judul: '${t.komoditas} ${Format.kg(t.beratPanenKg)}',
          keterangan: 'Belum ada harga jual · ${Format.tanggalPendek(t.tanggalPanen)}',
          onTap: () => context.push(Rute.tindakan(t)),
        );
      case StatusTransaksi.menungguPembayaran:
        return KartuTugas(
          ikon: Ikon.hourglass,
          warnaIkon: AppColors.kuningIkon,
          latarIkon: AppColors.kuningLatar,
          judul: '${t.komoditas} ${Format.rupiah(t.totalPenjualan)}',
          keterangan: 'Belum dibayar ${t.pembeli ?? ''}'.trim(),
          onTap: () => context.push(Rute.tindakan(t)),
        );
      case StatusTransaksi.dibayarSebagian:
      case StatusTransaksi.lunas:
        return KartuTugas(
          ikon: Ikon.pieChart,
          warnaIkon: AppColors.oranyeIkon,
          latarIkon: AppColors.oranyeLatar,
          judul: '${t.komoditas} sisa ${Format.rupiah(t.sisaTagihan)}',
          keterangan: 'Dibayar sebagian · ${t.pembeli ?? ''}',
          onTap: () => context.push(Rute.tindakan(t)),
        );
    }
  }
}

class _MenuCepat extends StatelessWidget {
  const _MenuCepat({
    required this.jumlahMenungguHarga,
    required this.jumlahBelumLunas,
    required this.onLengkapiHarga,
    required this.onCatatBayaran,
  });

  final int jumlahMenungguHarga;
  final int jumlahBelumLunas;
  final VoidCallback? onLengkapiHarga;
  final VoidCallback? onCatatBayaran;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Di Figma dua kartu kecil masing-masing 168 dari lebar 350 (sisa 4 di kanan).
        final lebarKecil = (c.maxWidth - 14) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KartuMenu(
              ikon: Ikon.tag,
              warnaIkon: AppColors.biruIkon,
              judul: 'Lengkapi Harga',
              keterangan: '$jumlahMenungguHarga menunggu',
              onTap: onLengkapiHarga,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _KartuMenu(
                  ikon: Ikon.wallet,
                  warnaIkon: AppColors.kuningIkon,
                  judul: 'Catat Bayaran',
                  keterangan: '$jumlahBelumLunas belum lunas',
                  lebar: lebarKecil,
                  onTap: onCatatBayaran,
                ),
                const SizedBox(width: 10),
                _KartuMenu(
                  ikon: Ikon.chart,
                  warnaIkon: AppColors.unguIkon,
                  judul: 'Lihat Laporan',
                  keterangan: 'Bulan ini',
                  lebar: lebarKecil,
                  onTap: () => context.go(Rute.laporan),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Kartu menu cepat. Tanpa [lebar] = kartu lebar (ikon di kiri teks),
/// dengan [lebar] = kartu kecil (ikon di atas teks).
class _KartuMenu extends StatelessWidget {
  const _KartuMenu({
    required this.ikon,
    required this.warnaIkon,
    required this.judul,
    required this.keterangan,
    required this.onTap,
    this.lebar,
  });

  final Ikon ikon;
  final Color warnaIkon;
  final String judul;
  final String keterangan;
  final VoidCallback? onTap;
  final double? lebar;

  @override
  Widget build(BuildContext context) {
    final bulat = Container(
      width: 45,
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: warnaIkon.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(22)),
      child: AppIcon(ikon, size: 28, color: warnaIkon, tebal: 2.2),
    );
    final teks = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(judul, style: AppText.judulMenu),
        const SizedBox(height: 2),
        Text(keterangan, style: AppText.keterangan),
      ],
    );

    return KotakKaca(
      radius: 19,
      width: lebar,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      onTap: onTap,
      label: '$judul, $keterangan',
      child: lebar == null
          ? Row(
              children: [
                bulat,
                const SizedBox(width: 11),
                Expanded(child: teks),
              ],
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [bulat, const SizedBox(height: 10), teks]),
    );
  }
}
