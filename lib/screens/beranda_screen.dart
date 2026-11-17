import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../models/transaksi.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
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
// Kartu saldo: cincin persen, uang masuk, sisa tagihan, dan hasil panen

class _KartuSaldo extends StatelessWidget {
  const _KartuSaldo();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final sisa = store.belumDibayar;
    return KotakKaca(
      radius: 21,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              CincinPersen(persen: store.persenSudahMasuk),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Uang masuk bulan ini', style: AppText.labelSaldo),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(Format.rupiah(store.uangMasuk), style: AppText.angkaSaldo.copyWith(fontSize: 24)),
                    ),
                    const SizedBox(height: 10),
                    _SisaTagihan(sisa: sisa),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0x140F1F19)), // garis tipis 8%
          const SizedBox(height: 12),
          Row(
            children: [
              const AppIcon(Ikon.sprout, size: 16, color: AppColors.hijau),
              const SizedBox(width: 8),
              Text('Hasil panen', style: AppText.legenda),
              const Spacer(),
              Text(Format.kg(store.hasilPanenKg), style: AppText.gaya(15, FontWeight.w800, AppColors.teksUtama)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Satu baris sisa tagihan (warna oranye = lintasan cincin), atau tanda lunas bila tidak ada sisa.
class _SisaTagihan extends StatelessWidget {
  const _SisaTagihan({required this.sisa});

  final int sisa;

  @override
  Widget build(BuildContext context) {
    final lunas = sisa <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (lunas ? AppColors.hijau : AppColors.oranyeGaris).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: lunas
          ? Text('Semua sudah dibayar', style: AppText.gaya(12, FontWeight.w700, AppColors.hijau))
          : Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: Format.rupiah(sisa), style: AppText.gaya(12, FontWeight.w800, AppColors.oranyeAngka)),
                  TextSpan(text: ' belum dibayar', style: AppText.gaya(12, FontWeight.w500, AppColors.oranyeAngka)),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
        const JudulSeksi(judul: 'Mau catat apa?'),
        const SizedBox(height: 12),
        _MenuCepat(
          jumlahMenungguHarga: store.jumlahStatus(StatusTransaksi.menungguPenjualan),
          jumlahBelumLunas: store.jumlahBelumLunas,
          onLengkapiHarga: belumDijual == null ? null : () => context.push(Rute.lengkapiPenjualan(belumDijual.id)),
          onCatatBayaran: belumLunas == null ? null : () => context.push(Rute.catatPembayaran(belumLunas.id)),
        ),
        const SizedBox(height: 28),
        JudulSeksi(
          judul: 'Perlu diurus',
          aksi: TombolKecil(teks: 'Lihat semua', onTap: () => context.go(Rute.riwayat)),
        ),
        const SizedBox(height: 4),
        KartuTugas(tugas: [for (final t in tugas) _barisTugas(context, t)]),
        // Grafik harga tampil setelah ada penjualan minimal 2 bulan.
        if (store.sayurHargaBeranda case final sayur?) ...[
          const SizedBox(height: 28),
          JudulSeksi(judul: 'Harga $sayur per kg'),
          const SizedBox(height: 12),
          KartuHarga(riwayat: store.riwayatHarga(sayur), onTap: () => context.push(Rute.riwayatHarga)),
        ],
      ],
    );
  }

  /// Ikon, warna, teks, dan tujuan baris tugas sesuai status catatan.
  BarisTugas _barisTugas(BuildContext context, Transaksi t) {
    switch (t.status) {
      case StatusTransaksi.menungguPenjualan:
        return BarisTugas(
          ikon: Ikon.clock,
          warnaIkon: AppColors.biruIkon,
          latarIkon: AppColors.biruLatar,
          judul: '${t.komoditas} ${Format.kg(t.beratPanenKg)}',
          keterangan: 'Belum ada harga jual · ${Format.tanggalPendek(t.tanggalPanen)}',
          onTap: () => context.push(Rute.tindakan(t)),
        );
      case StatusTransaksi.menungguPembayaran:
        return BarisTugas(
          ikon: Ikon.hourglass,
          warnaIkon: AppColors.kuningIkon,
          latarIkon: AppColors.kuningLatar,
          judul: '${t.komoditas} ${Format.rupiah(t.totalPenjualan)}',
          keterangan: 'Belum dibayar ${t.pembeli ?? ''}'.trim(),
          onTap: () => context.push(Rute.tindakan(t)),
        );
      case StatusTransaksi.dibayarSebagian:
      case StatusTransaksi.lunas:
        return BarisTugas(
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _KartuMenu(
              ikon: Ikon.tag,
              warnaIkon: AppColors.biruIkon,
              judul: 'Lengkapi Harga',
              jumlah: jumlahMenungguHarga,
              artiJumlah: 'menunggu harga',
              onTap: onLengkapiHarga,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _KartuMenu(
              ikon: Ikon.wallet,
              warnaIkon: AppColors.kuningIkon,
              judul: 'Catat Bayaran',
              jumlah: jumlahBelumLunas,
              artiJumlah: 'belum lunas',
              onTap: onCatatBayaran,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _KartuMenu(
              ikon: Ikon.chart,
              warnaIkon: AppColors.unguIkon,
              judul: 'Lihat Laporan',
              onTap: () => context.go(Rute.laporan),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ubin menu cepat: ikon bulat (dengan lencana jumlah bila ada yang menunggu) dan nama menu.
class _KartuMenu extends StatelessWidget {
  const _KartuMenu({
    required this.ikon,
    required this.warnaIkon,
    required this.judul,
    required this.onTap,
    this.jumlah = 0,
    this.artiJumlah = '',
  });

  final Ikon ikon;
  final Color warnaIkon;
  final String judul;
  final VoidCallback? onTap;
  final int jumlah;
  final String artiJumlah;

  @override
  Widget build(BuildContext context) {
    return KotakKaca(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
      onTap: onTap,
      label: jumlah > 0 ? '$judul, $jumlah $artiJumlah' : judul,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: warnaIkon.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: AppIcon(ikon, size: 22, color: warnaIkon),
              ),
              if (jumlah > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.oranyeIkon,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFFFFF), width: 2),
                    ),
                    child: Text(
                      '$jumlah',
                      style: AppText.gaya(10, FontWeight.w800, const Color(0xFFFFFFFF), tinggi: 1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            judul,
            textAlign: TextAlign.center,
            style: AppText.gaya(13, FontWeight.w700, AppColors.teksUtama, tinggi: 1.25),
          ),
        ],
      ),
    );
  }
}
