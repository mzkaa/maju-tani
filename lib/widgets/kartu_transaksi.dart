import 'package:flutter/widgets.dart';

import '../data/format.dart';
import '../models/transaksi.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';
import 'badge_status.dart';
import 'kotak_kaca.dart';

/// Kartu satu catatan panen (komponen "Kartu Transaksi V2" di Figma):
/// nama sayur + status, keterangan, dua angka, dan tombol "Lihat rincian".
class KartuTransaksi extends StatelessWidget {
  const KartuTransaksi({super.key, required this.transaksi, required this.onTap});

  final Transaksi transaksi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = transaksi;
    final keterangan = t.sudahDijual
        ? 'Panen ${Format.tanggal(t.tanggalPanen)} · ${t.beratTerjualKg} kg terjual'
        : 'Panen ${Format.tanggal(t.tanggalPanen)} · ${Format.kg(t.beratPanenKg)}';

    return KotakKaca(
      radius: 19,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      label: '${t.komoditas}, ${t.status.label}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                Text(t.komoditas, style: AppText.namaSayur),
                const SizedBox(width: 10),
                BadgeStatus(status: t.status),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(keterangan, style: AppText.keteranganKartu),
          const SizedBox(height: 10),
          Container(height: 1.5, color: AppColors.garisPemisah),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: t.sudahDijual
                ? [
                    Expanded(child: _Angka('Total penjualan', Format.rupiah(t.totalPenjualan))),
                    const SizedBox(width: 11),
                    Expanded(child: _Angka('Belum dibayar', Format.rupiah(t.sisaTagihan))),
                  ]
                : [
                    Expanded(child: _Angka('Berat panen', Format.kg(t.beratPanenKg))),
                    const SizedBox(width: 11),
                    const Expanded(child: _Angka('Harga jual', 'Belum ada')),
                  ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xA6FFFFFF), // putih 65%
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.garisTombolRincian),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lihat rincian', style: AppText.lihatRincian),
                const SizedBox(width: 6),
                const AppIcon(Ikon.chevronRight, size: 24, color: AppColors.hijauTuaAlt),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Angka extends StatelessWidget {
  const _Angka(this.label, this.nilai);

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.labelAngka),
        const SizedBox(height: 2),
        Text(nilai, style: AppText.nilaiAngka),
      ],
    );
  }
}
