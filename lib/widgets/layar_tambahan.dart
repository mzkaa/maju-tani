import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';
import 'kotak_kaca.dart';

// Komponen yang dipakai berulang di layar tambahan M15–M30.

/// Judul bagian kecil: label kapital hijau + judul (mis. "PENGATURAN / Akun").
class JudulKecil extends StatelessWidget {
  const JudulKecil({super.key, required this.label, required this.judul, this.onTap});

  final String label;
  final String judul;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isi = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.labelBagian),
        Text(judul, style: AppText.judulBagianKecil),
      ],
    );
    if (onTap == null) return isi;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: isi);
  }
}

/// Kotak ikon 44 × 44 dengan latar warna ikon 14%.
class KotakIkon extends StatelessWidget {
  const KotakIkon({super.key, required this.ikon, required this.warna});

  final Ikon ikon;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: warna.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14.08)),
      child: AppIcon(ikon, size: 22, color: warna),
    );
  }
}

/// Baris berikon: kotak ikon, judul + keterangan, titik "belum dibaca" opsional, panah.
class BarisIkon extends StatelessWidget {
  const BarisIkon({
    super.key,
    required this.ikon,
    required this.warna,
    required this.judul,
    required this.keterangan,
    this.panah = true,
    this.titik = false,
    this.onTap,
  });

  final Ikon ikon;
  final Color warna;
  final String judul;
  final String keterangan;
  final bool panah;
  final bool titik;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final baris = Row(
      children: [
        KotakIkon(ikon: ikon, warna: warna),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(judul, style: AppText.barisJudul),
              const SizedBox(height: 2),
              Text(keterangan, style: AppText.barisKeterangan),
            ],
          ),
        ),
        if (titik) ...[
          const SizedBox(width: 10),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(color: AppColors.hijau, shape: BoxShape.circle),
          ),
        ],
        if (panah) ...[
          const SizedBox(width: 10),
          const AppIcon(Ikon.chevronRight, size: 22, color: AppColors.teksKeduaAlt),
        ],
      ],
    );
    if (onTap == null) return baris;
    return Semantics(
      button: true,
      label: '$judul, $keterangan',
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: baris),
    );
  }
}

/// Garis pemisah tipis 1 px (hitam 8%).
class GarisTipis extends StatelessWidget {
  const GarisTipis({super.key, this.warna = const Color(0x140F1F19)});

  final Color warna;

  @override
  Widget build(BuildContext context) => Container(height: 1, color: warna);
}

/// Kartu kaca berisi daftar baris yang dipisah garis tipis.
class KartuDaftar extends StatelessWidget {
  const KartuDaftar({super.key, required this.baris, this.padding = 12, this.jarak = 12});

  final List<Widget> baris;
  final double padding;
  final double jarak;

  @override
  Widget build(BuildContext context) {
    return KotakKaca(
      radius: 19,
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, b) in baris.indexed) ...[
            if (i > 0) ...[SizedBox(height: jarak), const GarisTipis(), SizedBox(height: jarak)],
            b,
          ],
        ],
      ),
    );
  }
}

/// Chip bergradien (M16, M17, M19): hijau bila aktif, kaca putih 70% bila tidak.
class ChipGradien extends StatelessWidget {
  const ChipGradien({super.key, required this.teks, required this.aktif, required this.onTap});

  final String teks;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    if (!aktif) {
      return KotakKaca(
        radius: 18,
        padding: padding,
        warna: const Color(0xB3FFFFFF), // putih 70%
        bayangan: const [],
        sorotan: null,
        kaburKaca: null,
        onTap: onTap,
        label: teks,
        child: Text(teks, style: AppText.chipGradienNonaktif),
      );
    }
    return Semantics(
      button: true,
      selected: true,
      label: teks,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(gradient: AppGradien.hijauBulat, borderRadius: BorderRadius.circular(18)),
          child: Text(teks, style: AppText.chipGradien),
        ),
      ),
    );
  }
}

/// Chip pil (M24–M30): hijau "✓ teks" bila aktif, putih 75% bila tidak.
class ChipPil extends StatelessWidget {
  const ChipPil({super.key, required this.teks, required this.aktif, this.onTap});

  final String teks;
  final bool aktif;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.all(12), // + garis 1
      decoration: BoxDecoration(
        color: aktif ? AppColors.hijauAktif : const Color(0xBFFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xE6FFFFFF)),
      ),
      child: Text(
        aktif ? '✓ $teks' : teks,
        style: AppText.tebal14.copyWith(color: aktif ? const Color(0xFFFFFFFF) : AppColors.teksUtama),
      ),
    );
    if (onTap == null) return chip;
    return Semantics(
      button: true,
      selected: aktif,
      label: teks,
      child: GestureDetector(onTap: onTap, child: chip),
    );
  }
}

/// Baris label (kiri) – nilai (kanan) untuk kartu ringkas & dokumen.
class BarisNilai extends StatelessWidget {
  const BarisNilai({
    super.key,
    required this.label,
    required this.nilai,
    required this.gayaLabel,
    required this.gayaNilai,
  });

  final String label;
  final String nilai;
  final TextStyle gayaLabel;
  final TextStyle gayaNilai;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: gayaLabel),
        const SizedBox(width: 10),
        Expanded(
          child: Text(nilai, style: gayaNilai, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
