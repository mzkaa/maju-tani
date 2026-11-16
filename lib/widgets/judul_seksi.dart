import 'package:flutter/widgets.dart';

import '../theme/app_gradients.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';
import 'kotak_kaca.dart';

/// Judul seksi: kotak ikon kaca + label kapital + judul, dengan aksi opsional di kanan.
class JudulSeksi extends StatelessWidget {
  const JudulSeksi({
    super.key,
    required this.ikon,
    required this.label,
    required this.judul,
    this.aksi,
    this.teksRataAtas = false,
  });

  final Ikon ikon;
  final String label;
  final String judul;
  final Widget? aksi;

  /// Teks menempel ke atas kotak ikon, bukan di tengah. Di Figma hanya
  /// judul "Mau catat apa?" (M02) yang begini.
  final bool teksRataAtas;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: teksRataAtas ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: 46,
          child: KotakKaca(
            radius: 16,
            warna: const Color(0xB3FFFFFF), // putih 70%
            garis: AppGradien.garisIkonJudul,
            bayangan: AppShadows.ikonJudul,
            sorotan: const Color(0xCCFFFFFF), // putih 80%
            kaburKaca: 6,
            child: Center(child: AppIcon(ikon, size: 22, color: AppColors.ikonHijau)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppText.labelKapital),
              Text(judul, style: AppText.judulSeksi),
            ],
          ),
        ),
        if (aksi != null) ...[const SizedBox(width: 12), aksi!],
      ],
    );
  }
}

/// Tombol kecil kaca dengan panah, misalnya "Lihat semua".
class TombolKecil extends StatelessWidget {
  const TombolKecil({super.key, required this.teks, required this.onTap});

  final String teks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KotakKaca(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      warna: const Color(0xA6FFFFFF), // putih 65%
      warnaGaris: const Color(0xFFFFFFFF),
      tebalGaris: 1.2,
      bayangan: AppShadows.chip,
      sorotan: null,
      kaburKaca: null,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(teks, style: AppText.tombolKecil),
          const SizedBox(width: 4),
          const AppIcon(Ikon.chevronRight, size: 18, color: AppColors.ikonHijau),
        ],
      ),
    );
  }
}
