import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';
import 'kotak_kaca.dart';

/// Kartu kaca berisi ikon berwarna, judul + keterangan, dan bulatan panah.
/// Dipakai di daftar "Perlu diurus" Beranda.
class KartuTugas extends StatelessWidget {
  const KartuTugas({
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
    return KotakKaca(
      radius: 18,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      label: '$judul, $keterangan',
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: latarIkon, borderRadius: BorderRadius.circular(14)),
            child: AppIcon(ikon, size: 28, color: warnaIkon, tebal: 2.2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul, style: AppText.judulTugas),
                const SizedBox(height: 2),
                Text(keterangan, style: AppText.keterangan),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.bulatPanah, borderRadius: BorderRadius.circular(16)),
            child: const AppIcon(Ikon.chevronRight, size: 22, color: AppColors.ikonGelap, tebal: 2.4),
          ),
        ],
      ),
    );
  }
}
