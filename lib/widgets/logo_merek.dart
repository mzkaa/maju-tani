import 'package:flutter/widgets.dart';

import '../theme/app_text.dart';
import 'app_icon.dart';

/// Logo usaha di atas latar hijau (komponen "Logo V2" di Figma):
/// kotak putih transparan berisi ikon tunas + nama usaha dan slogan.
class LogoMerek extends StatelessWidget {
  const LogoMerek({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0x2EFFFFFF), borderRadius: BorderRadius.circular(14)),
          child: const AppIcon(Ikon.sprout, size: 28, color: Color(0xFFFFFFFF)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mitra Maju Tani', style: AppText.namaUsaha),
            Text('Catatan panen & penjualan', style: AppText.slogan),
          ],
        ),
      ],
    );
  }
}
