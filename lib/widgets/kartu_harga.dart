import 'package:flutter/widgets.dart';

import '../data/format.dart';
import '../models/harga_bulanan.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';
import 'grafik_garis.dart';
import 'kotak_kaca.dart';

/// Kartu harga per kg: harga terakhir, lencana perubahan, grafik 6 bulan,
/// dan nama bulan ("Kartu harga" di M02 & M19).
class KartuHarga extends StatelessWidget {
  const KartuHarga({super.key, required this.riwayat, this.onTap});

  final List<HargaBulanan> riwayat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final nilai = [for (final h in riwayat) h.hargaPerKg];
    final sekarang = nilai.last;
    final sebelum = nilai[nilai.length - 2];
    final perubahan = ((sekarang - sebelum) / sebelum * 100).round();

    return KotakKaca(
      radius: 19,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
      onTap: onTap,
      label: onTap == null ? null : 'Harga ${Format.rupiah(sekarang)} per kg',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Format.rupiah(sekarang), style: AppText.harga),
                    const SizedBox(width: 4),
                    Text('/kg', style: AppText.satuan),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _LencanaPerubahan(persen: perubahan),
            ],
          ),
          const SizedBox(height: 12),
          GrafikGaris(nilai: nilai),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (i, h) in riwayat.indexed)
                Text(
                  Format.bulanPendek(h.bulan),
                  style: i == riwayat.length - 1 ? AppText.bulanGrafikAktif : AppText.bulanGrafik,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LencanaPerubahan extends StatelessWidget {
  const _LencanaPerubahan({required this.persen});

  final int persen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: AppGradien.hijauBulat),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(Ikon.trendingUp, size: 16, color: Color(0xFFFFFFFF)),
          const SizedBox(width: 4),
          Text('${persen >= 0 ? '+' : ''}$persen%', style: AppText.lencana),
        ],
      ),
    );
  }
}
