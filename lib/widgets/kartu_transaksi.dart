import 'package:flutter/widgets.dart';

import '../data/format.dart';
import '../models/transaksi.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';
import 'badge_status.dart';
import 'kotak_kaca.dart';

/// Kartu ringkas satu catatan panen di Riwayat: ikon status, nama sayur + status · tanggal,
/// dan satu angka utama di kanan. Seluruh kartu bisa diketuk untuk membuka rincian.
class KartuTransaksi extends StatelessWidget {
  const KartuTransaksi({super.key, required this.transaksi, required this.onTap});

  final Transaksi transaksi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = transaksi;
    final (angka, keteranganAngka) = switch (t.status) {
      StatusTransaksi.menungguPenjualan => (Format.kg(t.beratPanenKg), 'belum ada harga'),
      StatusTransaksi.menungguPembayaran => (Format.rupiah(t.totalPenjualan), 'belum dibayar'),
      StatusTransaksi.dibayarSebagian => (Format.rupiah(t.totalPenjualan), 'sisa ${Format.rupiah(t.sisaTagihan)}'),
      StatusTransaksi.lunas => (Format.rupiah(t.totalPenjualan), 'lunas'),
    };

    return KotakKaca(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      onTap: onTap,
      label: '${t.komoditas}, ${t.status.label}, $angka, $keteranganAngka',
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: t.status.latar, borderRadius: BorderRadius.circular(13)),
            child: AppIcon(t.status.ikon, size: 21, color: t.status.warna),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.komoditas, style: AppText.judulTugas, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(
                  '${t.status.label} · ${Format.tanggalPendekTanpaNol(t.tanggalPanen)}',
                  style: AppText.gaya(12, FontWeight.w600, t.status.warna),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(angka, style: AppText.gaya(15, FontWeight.w800, AppColors.teksUtama)),
              const SizedBox(height: 3),
              Text(keteranganAngka, style: AppText.gaya(11, FontWeight.w500, AppColors.teksKedua)),
            ],
          ),
          const SizedBox(width: 4),
          const AppIcon(Ikon.chevronRight, size: 18, color: AppColors.teksKedua),
        ],
      ),
    );
  }
}
