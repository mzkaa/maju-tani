import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../data/prakiraan.dart';
import '../models/ringkasan.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/bilah_tombol.dart';
import '../widgets/header_ringkas.dart';
import '../widgets/isi_formulir.dart';
import '../widgets/kartu_harga.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/layar_tambahan.dart';
import '../widgets/tombol.dart';

// ---------------------------------------------------------------------------
// M19 Riwayat Harga

class RiwayatHargaScreen extends StatefulWidget {
  const RiwayatHargaScreen({super.key});

  @override
  State<RiwayatHargaScreen> createState() => _RiwayatHargaScreenState();
}

class _RiwayatHargaScreenState extends State<RiwayatHargaScreen> {
  String? _dipilih;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final pilihan = store.sayurDenganRiwayatHarga;
    final sayur = pilihan.contains(_dipilih) ? _dipilih : pilihan.firstOrNull;
    if (sayur == null) {
      return KerangkaHalaman(
        header: const HeaderRingkas(
          judul: 'Riwayat Harga Jual',
          keterangan: 'Harga per kg dari pengepul',
          kiri: TombolKembali(),
        ),
        isi: IsiFormulir(
          tepi: 14,
          jarak: 11,
          bawah: 43.0 + 145 - 17,
          children: [
            KotakKaca(
              radius: 19,
              padding: const EdgeInsets.all(14),
              child: Text('Grafik harga muncul setelah ada penjualan minimal 2 bulan.', style: AppText.barisKeterangan),
            ),
          ],
        ),
      );
    }
    final riwayat = store.riwayatHarga(sayur);
    final terbaru = riwayat.reversed.take(4).toList();
    final prakiraan = store.prakiraanHarga(sayur);

    return KerangkaHalaman(
      header: const HeaderRingkas(
        judul: 'Riwayat Harga Jual',
        keterangan: 'Harga per kg dari pengepul',
        kiri: TombolKembali(),
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: 43.0 + 145 - 17,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in pilihan)
                ChipGradien(teks: s, aktif: s == sayur, onTap: () => setState(() => _dipilih = s)),
            ],
          ),
          KartuHarga(riwayat: riwayat),
          JudulKecil(label: 'CATATAN HARGA', judul: '$sayur per bulan'),
          KotakKaca(
            radius: 19,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, h) in terbaru.indexed) ...[
                  if (i > 0) ...[const SizedBox(height: 12), const GarisTipis(), const SizedBox(height: 12)],
                  BarisNilai(
                    label: Format.bulanTahun(h.bulan),
                    nilai: '${Format.rupiah(h.hargaPerKg)}/kg',
                    gayaLabel: AppText.gaya(14, FontWeight.w600, AppColors.teksUtama),
                    gayaNilai: AppText.gaya(14, FontWeight.w800, i == 0 ? AppColors.hijauTua : AppColors.teksKeduaAlt),
                  ),
                ],
              ],
            ),
          ),
          if (prakiraan != null) ...[
            JudulKecil(
              label: 'PRAKIRAAN',
              judul: '$sayur ${Format.bulanTahun(DateTime(riwayat.last.bulan.year, riwayat.last.bulan.month + 1))}',
            ),
            _KartuPrakiraan(hasil: prakiraan, hargaTerakhir: riwayat.last.hargaPerKg),
          ],
        ],
      ),
    );
  }
}

/// Prakiraan harga bulan depan: angka utama, selisih dari bulan terakhir, metode, dan keandalannya.
class _KartuPrakiraan extends StatelessWidget {
  const _KartuPrakiraan({required this.hasil, required this.hargaTerakhir});

  final HasilPrakiraan hasil;
  final int hargaTerakhir;

  @override
  Widget build(BuildContext context) {
    final selisih = hargaTerakhir == 0 ? 0 : ((hasil.hargaPerKg - hargaTerakhir) / hargaTerakhir * 100).round();
    final naik = selisih >= 0;
    final label = AppText.gaya(14, FontWeight.w600, AppColors.teksUtama);
    final nilai = AppText.gaya(14, FontWeight.w800, AppColors.teksKeduaAlt);

    return KotakKaca(
      radius: 19,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text('${Format.rupiah(hasil.hargaPerKg)}/kg', style: AppText.harga)),
              Text(
                '${naik ? '+' : ''}$selisih%',
                style: AppText.gaya(14, FontWeight.w800, naik ? AppColors.hijauAktif : AppColors.oranyeAngka),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Perkiraan, dibanding bulan terakhir', style: AppText.sedang13Samar),
          const SizedBox(height: 12),
          const GarisTipis(),
          const SizedBox(height: 12),
          BarisNilai(label: 'Metode', nilai: hasil.metode.label, gayaLabel: label, gayaNilai: nilai),
          const SizedBox(height: 12),
          BarisNilai(label: 'Data dipakai', nilai: '${hasil.jumlahData} bulan', gayaLabel: label, gayaNilai: nilai),
          const SizedBox(height: 12),
          BarisNilai(
            label: 'Keandalan',
            nilai: hasil.mape == null
                ? 'Belum bisa diukur'
                : '${hasil.kepercayaan} (galat ${hasil.mape!.toStringAsFixed(1).replaceAll('.', ',')}%)',
            gayaLabel: label,
            gayaNilai: nilai,
          ),
          if (hasil.mape == null) ...[
            const SizedBox(height: 10),
            Text(
              'Data masih sedikit. Prakiraan makin akurat setelah ada penjualan 4 bulan atau lebih.',
              style: AppText.sedang13Samar,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M20 Rekap per Sayur

class RekapSayurScreen extends StatelessWidget {
  const RekapSayurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final (awal, akhir) = store.periodeLaporan;
    final r = store.ringkasan(awal, akhir);
    // Urutan kartu mengikuti daftar komoditas (seperti di Figma).
    final urutan = {for (final (i, k) in store.komoditas.indexed) k.nama: i};
    final sayur = r.perSayur.toList()..sort((a, b) => (urutan[a.nama] ?? 99).compareTo(urutan[b.nama] ?? 99));

    RingkasanSayur? terbesar(int Function(RingkasanSayur s) nilai) =>
        sayur.isEmpty ? null : sayur.reduce((a, b) => nilai(b) > nilai(a) ? b : a);
    final panenTerbanyak = terbesar((s) => s.panenKg);
    final hargaTertinggi = terbesar((s) => s.rataRataPerKg);
    final belumTerbanyak = terbesar((s) => s.belumDibayar);

    return KerangkaHalaman(
      header: HeaderRingkas(
        judul: 'Rekap per Sayur',
        keterangan: Format.rentang(awal, akhir),
        kiri: const TombolKembali(),
      ),
      bilahBawah: BilahTombol(
        tombol: [
          // Di prototype tombol ini belum punya tujuan; diarahkan ke Cetak & Unduh.
          TombolUtama(label: 'Unduh Tabel (Excel)', ikon: Ikon.download, onTap: () => context.push(Rute.cetakLaporan)),
        ],
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: 158.0 + 145 - 17,
        children: [
          const JudulKecil(label: 'HAL PENTING', judul: 'Periode ini'),
          KartuDaftar(
            baris: [
              BarisIkon(
                ikon: Ikon.leaf,
                warna: AppColors.hijauTua,
                judul: 'Panen terbanyak',
                keterangan: panenTerbanyak == null
                    ? '-'
                    : '${panenTerbanyak.nama} · ${Format.kg(panenTerbanyak.panenKg)} '
                          '(${r.hasilPanenKg == 0 ? 0 : (panenTerbanyak.panenKg / r.hasilPanenKg * 100).round()}%)',
                panah: false,
              ),
              BarisIkon(
                ikon: Ikon.trendingUp,
                warna: AppColors.biruIkonTambahan,
                judul: 'Harga tertinggi',
                keterangan: hargaTertinggi == null
                    ? '-'
                    : '${hargaTertinggi.nama} · ${Format.rupiah(hargaTertinggi.rataRataPerKg)}/kg',
                panah: false,
              ),
              BarisIkon(
                ikon: Ikon.hourglass,
                warna: AppColors.oranyeAngka,
                judul: 'Paling banyak belum dibayar',
                keterangan: belumTerbanyak == null || belumTerbanyak.belumDibayar == 0
                    ? 'Semua sudah dibayar'
                    : '${belumTerbanyak.nama} · ${Format.rupiah(belumTerbanyak.belumDibayar)}',
                panah: false,
              ),
            ],
          ),
          const JudulKecil(label: 'PER SAYUR', judul: 'Rincian'),
          for (final s in sayur) _KartuRekap(s),
        ],
      ),
    );
  }
}

class _KartuRekap extends StatelessWidget {
  const _KartuRekap(this.s);

  final RingkasanSayur s;

  @override
  Widget build(BuildContext context) {
    final label = AppText.gaya(13, FontWeight.w500, const Color(0xA60F1F19)); // 65%
    final nilai = AppText.gaya(14, FontWeight.w700, AppColors.teksUtama);
    final baris = [
      ('Kali panen', '${s.kaliPanen} kali', nilai),
      ('Total panen', Format.kg(s.panenKg), nilai),
      ('Terjual', Format.kg(s.terjualKg), nilai),
      ('Rata-rata/kg', Format.rupiah(s.rataRataPerKg), nilai),
      (
        'Belum dibayar',
        Format.rupiah(s.belumDibayar),
        nilai.copyWith(color: s.belumDibayar > 0 ? AppColors.oranyeAngka : AppColors.teksKeduaAlt),
      ),
    ];

    return KotakKaca(
      radius: 19,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarisNilai(
            label: s.nama,
            nilai: Format.rupiah(s.penjualan),
            gayaLabel: AppText.gaya(16, FontWeight.w800, AppColors.teksUtama),
            gayaNilai: AppText.gaya(16, FontWeight.w800, AppColors.hijauTua),
          ),
          const SizedBox(height: 10),
          for (final (i, (l, n, g)) in baris.indexed) ...[
            if (i > 0) const GarisTipis(),
            SizedBox(
              height: 34,
              child: Center(
                child: BarisNilai(label: l, nilai: n, gayaLabel: label, gayaNilai: g),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
