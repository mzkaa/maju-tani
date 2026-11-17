import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';
import 'kotak_kaca.dart';

/// Satu kartu kaca berisi daftar tugas ("Perlu diurus" di Beranda), dipisah garis tipis.
/// Bila [tugas] kosong, tampil satu baris "semua beres".
class KartuTugas extends StatelessWidget {
  const KartuTugas({super.key, required this.tugas});

  final List<BarisTugas> tugas;

  @override
  Widget build(BuildContext context) {
    return KotakKaca(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: tugas.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  const AppIcon(Ikon.checkCircle, size: 20, color: AppColors.hijau),
                  const SizedBox(width: 10),
                  Text('Semua beres, tidak ada yang perlu diurus', style: AppText.keterangan),
                ],
              ),
            )
          : Column(
              children: [
                for (final (i, t) in tugas.indexed) ...[
                  if (i > 0) Container(height: 1, color: const Color(0x140F1F19)), // garis tipis 8%
                  t,
                ],
              ],
            ),
    );
  }
}

/// Satu baris tugas: ikon berwarna, judul + keterangan, dan panah.
class BarisTugas extends StatelessWidget {
  const BarisTugas({
    super.key,
    required this.ikon,
    required this.warnaIkon,
    required this.latarIkon,
    required this.judul,
    required this.keterangan,
    required this.onTap,
  });

  final Ikon ikon;
  final Color warnaIkon;
  final Color latarIkon;
  final String judul;
  final String keterangan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$judul, $keterangan',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: latarIkon, borderRadius: BorderRadius.circular(12)),
                child: AppIcon(ikon, size: 20, color: warnaIkon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(judul, style: AppText.judulTugas, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(keterangan, style: AppText.keterangan, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const AppIcon(Ikon.chevronRight, size: 18, color: AppColors.teksKedua),
            ],
          ),
        ),
      ),
    );
  }
}
