import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';
import 'kotak_kaca.dart';

/// Gaya chip yang tidak aktif. Di Figma ada dua: kaca (M03) dan putih bergaris (M11).
enum GayaChip { kaca, polos }

/// Chip pilihan (saring / periode): hijau tua dengan centang bila aktif.
class ChipPilihan extends StatelessWidget {
  const ChipPilihan({
    super.key,
    required this.teks,
    required this.aktif,
    required this.onTap,
    this.gaya = GayaChip.kaca,
  });

  final String teks;
  final bool aktif;
  final VoidCallback onTap;
  final GayaChip gaya;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    if (aktif) {
      return Semantics(
        button: true,
        selected: true,
        label: teks,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: AppColors.headerTengah, borderRadius: BorderRadius.circular(21)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppIcon(Ikon.check, size: 16, color: Color(0xFFFFFFFF), tebal: 1.6),
                const SizedBox(width: 6),
                Text(teks, style: AppText.chip.copyWith(color: const Color(0xFFFFFFFF))),
              ],
            ),
          ),
        ),
      );
    }
    if (gaya == GayaChip.polos) {
      return Semantics(
        button: true,
        label: teks,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            // Container sudah menambahkan tebal garis (1,5) ke padding.
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: AppColors.garisChip, width: 1.5),
            ),
            child: Text(teks, style: AppText.chip),
          ),
        ),
      );
    }
    return KotakKaca(
      radius: 21,
      padding: padding,
      onTap: onTap,
      label: teks,
      child: Text(teks, style: AppText.chip),
    );
  }
}
