import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';

/// Tombol utama hijau selebar parent (komponen "Tombol V2 / Utama" seperti
/// dipakai di frame Figma: tinggi 47, radius 14, ikon opsional di kiri label).
class TombolUtama extends StatelessWidget {
  const TombolUtama({super.key, required this.label, this.ikon, required this.onTap});

  final String label;
  final Ikon? ikon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 47,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          decoration: BoxDecoration(
            gradient: AppGradien.tombolUtama,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [AppShadows.figma(AppColors.bayanganTombol, y: 6, blur: 14)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (ikon != null) ...[
                AppIcon(ikon!, size: 24, color: const Color(0xFFFFFFFF)),
                const SizedBox(width: 10),
              ],
              Text(label, style: AppText.tombol),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol garis putih selebar parent (komponen "Tombol V2 / Garis" seperti
/// dipakai di frame Figma: tinggi 47, radius 14, garis hijau 2).
class TombolGaris extends StatelessWidget {
  const TombolGaris({
    super.key,
    required this.label,
    this.ikon,
    required this.onTap,
    this.warnaGaris = AppColors.headerTengah,
    this.warnaTeks = AppColors.hijauTuaAlt,
    this.warnaIkon = AppColors.hijauTuaAlt,
    this.warnaPerGaris,
  });

  final String label;
  final Ikon? ikon;
  final VoidCallback onTap;
  final Color warnaGaris;
  final Color warnaTeks;
  final Color warnaIkon;

  /// Warna tiap garis ikon (lihat [AppIcon.warnaPerGaris]).
  final List<Color>? warnaPerGaris;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 47,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: warnaGaris, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (ikon != null) ...[
                AppIcon(ikon!, size: 24, color: warnaIkon, warnaPerGaris: warnaPerGaris),
                const SizedBox(width: 10),
              ],
              // Tombol sempit (mis. dua tombol sejajar): teks mengecil, tidak terpotong atau meluber.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, maxLines: 1, style: AppText.tombolGaris.copyWith(color: warnaTeks)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
