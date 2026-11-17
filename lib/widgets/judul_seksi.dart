import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';

/// Judul seksi: satu baris judul, dengan aksi opsional di kanan (mis. [TombolKecil]).
class JudulSeksi extends StatelessWidget {
  const JudulSeksi({super.key, required this.judul, this.aksi});

  final String judul;
  final Widget? aksi;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(header: true, child: Text(judul, style: AppText.judulSeksi.copyWith(fontSize: 18))),
        ),
        if (aksi != null) ...[const SizedBox(width: 12), aksi!],
      ],
    );
  }
}

/// Tautan teks kecil dengan panah, misalnya "Lihat semua". Area ketuk minimal 44 px tinggi.
class TombolKecil extends StatelessWidget {
  const TombolKecil({super.key, required this.teks, required this.onTap});

  final String teks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: teks,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(teks, style: AppText.gaya(13, FontWeight.w700, AppColors.hijau)),
              const SizedBox(width: 2),
              const AppIcon(Ikon.chevronRight, size: 16, color: AppColors.hijau),
            ],
          ),
        ),
      ),
    );
  }
}
