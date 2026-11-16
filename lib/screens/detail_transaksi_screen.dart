import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../models/transaksi.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_layout.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/badge_status.dart';
import '../widgets/header_ringkas.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/kotak_lembut.dart';
import '../widgets/nav_bawah.dart';
import '../widgets/tombol.dart';

/// M04 Detail Transaksi.
class DetailTransaksiScreen extends StatelessWidget {
  const DetailTransaksiScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppStore>().cariTransaksi(id);
    final atas = AppLayout.ekstraAtas(context);

    return KerangkaHalaman(
      header: HeaderRingkas(
        judul: 'Detail Transaksi',
        keterangan: t == null ? '' : '${t.komoditas} · ${Format.tanggal(t.tanggalPanen)}',
        kiri: const TombolKembali(),
      ),
      nav: true,
      // Di Figma tab Riwayat menyala di layar ini.
      navAktif: TabUtama.riwayat,
      isi: t == null
          ? SizedBox(height: 200 + atas)
          : Padding(
              padding: EdgeInsets.only(top: 142 + atas, bottom: 86),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (t.sudahDijual)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(17, 0, 17, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _KartuSisa(t),
                          // Tombol disembunyikan bila sudah lunas (keadaan ini tidak ada di Figma).
                          if (t.status != StatusTransaksi.lunas) ...[
                            const SizedBox(height: 11),
                            TombolUtama(
                              label: 'Catat Pembayaran',
                              ikon: Ikon.wallet,
                              onTap: () => context.push(Rute.catatPembayaran(t.id)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  Padding(padding: const EdgeInsets.fromLTRB(17, 18, 17, 8), child: _Perjalanan(t)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 0, 17, 17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TombolGaris(
                          label: 'Ubah Data',
                          ikon: Ikon.pencil,
                          onTap: () => context.push(Rute.ubahTransaksi(t.id)),
                        ),
                        const SizedBox(height: 12),
                        KotakLembut(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppIcon(Ikon.info, size: 24, color: AppColors.teksKedua),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Dicatat oleh Pemilik. Setiap perubahan tersimpan waktunya.',
                                  style: AppText.bantuanIsian,
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
}

/// Kartu sisa tagihan: status, jumlah sisa, batang progres, dan rincian bayar.
class _KartuSisa extends StatelessWidget {
  const _KartuSisa(this.t);

  final Transaksi t;

  @override
  Widget build(BuildContext context) {
    final bagian = t.totalPenjualan == 0 ? 0.0 : t.totalDibayar / t.totalPenjualan;
    final persen = (bagian * 100).round();

    return KotakKaca(
      radius: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BadgeStatus(status: t.status, tinggi: 38),
          const SizedBox(height: 10),
          Text('Sisa yang belum dibayar', style: AppText.labelSisa),
          const SizedBox(height: 10),
          Text(Format.rupiah(t.sisaTagihan), style: AppText.angkaSisa.copyWith(color: t.status.warna)),
          const SizedBox(height: 10),
          // Batang progres pembayaran (lebar 300 di Figma; isi = persen bulat × 300).
          SizedBox(
            width: 300,
            height: 14,
            child: KotakLembut(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: (persen / 100 * 300).clamp(0, 298),
                  height: double.infinity,
                  child: const ColoredBox(color: AppColors.headerTengah),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sudah dibayar ${Format.rupiah(t.totalDibayar)} dari ${Format.rupiah(t.totalPenjualan)} ($persen%)',
            style: AppText.isiKartu,
          ),
        ],
      ),
    );
  }
}

/// Kartu gelap "Perjalanan transaksi": langkah panen → penjualan → pembayaran.
class _Perjalanan extends StatelessWidget {
  const _Perjalanan(this.t);

  final Transaksi t;

  @override
  Widget build(BuildContext context) {
    final langkah = <_Langkah>[
      _Langkah(
        judul: '1. Panen dicatat',
        waktu: Format.tanggalJam(t.tanggalPanen),
        isi: t.pembeli == null ? Format.kg(t.beratPanenKg) : '${Format.kg(t.beratPanenKg)}, ditimbang ${t.pembeli}',
      ),
      if (t.sudahDijual)
        _Langkah(
          judul: '2. Penjualan dilengkapi',
          waktu: t.tanggalJual == null ? '' : Format.tanggalJam(t.tanggalJual!),
          isi:
              'Terjual ${Format.kg(t.beratTerjualKg!)} × ${Format.rupiah(t.hargaPerKg!)} = ${Format.rupiah(t.totalPenjualan)}',
        ),
      if (t.pembayaran.isNotEmpty)
        _Langkah(
          judul: t.status == StatusTransaksi.lunas ? '3. Pembayaran (lunas)' : '3. Pembayaran (dicicil)',
          waktu: 'Bayar ke-${t.pembayaran.length}: ${Format.tanggal(t.pembayaran.last.tanggal)}',
          isi: t.status == StatusTransaksi.lunas
              ? 'Masuk ${Format.rupiah(t.totalDibayar)} · lunas'
              : 'Masuk ${Format.rupiah(t.totalDibayar)} · sisa ${Format.rupiah(t.sisaTagihan)}',
          sebagian: t.status == StatusTransaksi.dibayarSebagian,
        ),
    ];

    return KotakKaca(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      gradien: const GradienFigma(
        awal: Offset(0, 0),
        akhir: Offset(0.6, 0.8),
        colors: [AppColors.perjalananAwal, AppColors.perjalananAkhir],
      ),
      warnaGaris: const Color(0x2EFFFFFF), // putih 18%
      bayangan: [AppShadows.figma(const Color(0x47081F12), y: 16, blur: 36, spread: -10)],
      sorotan: null,
      kaburKaca: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Perjalanan transaksi', style: AppText.judulPerjalanan),
          for (final (i, l) in langkah.indexed) ...[
            const SizedBox(height: 16),
            _BarisLangkah(langkah: l, garis: i < langkah.length - 1),
          ],
        ],
      ),
    );
  }
}

class _Langkah {
  const _Langkah({required this.judul, required this.waktu, required this.isi, this.sebagian = false});

  final String judul;
  final String waktu;
  final String isi;

  /// Langkah belum selesai penuh (bulatan kuning + ikon pie).
  final bool sebagian;
}

class _BarisLangkah extends StatelessWidget {
  const _BarisLangkah({required this.langkah, required this.garis});

  final _Langkah langkah;

  /// Garis penyambung ke langkah berikutnya.
  final bool garis;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: langkah.sebagian ? AppColors.langkahSebagian : AppColors.langkahSelesai,
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    langkah.sebagian ? Ikon.pieChart : Ikon.check,
                    size: 16,
                    color: AppColors.ikonLangkah,
                    tebal: 1.4545,
                  ),
                ),
                if (garis) ...[
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: const Color(0x40FFFFFF), // putih 25%
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(langkah.judul, style: AppText.langkahJudul),
                  const SizedBox(height: 2),
                  Text(langkah.waktu, style: AppText.langkahWaktu),
                  const SizedBox(height: 2),
                  Text(langkah.isi, style: AppText.langkahIsi),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
