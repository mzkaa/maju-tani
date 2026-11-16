import 'package:flutter/widgets.dart';

import '../models/transaksi.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';

/// Tampilan tiap status transaksi (komponen "Badge Status V2" di Figma).
extension TampilanStatus on StatusTransaksi {
  String get label => switch (this) {
    StatusTransaksi.menungguPenjualan => 'Menunggu Penjualan',
    StatusTransaksi.menungguPembayaran => 'Menunggu Pembayaran',
    StatusTransaksi.dibayarSebagian => 'Dibayar Sebagian',
    StatusTransaksi.lunas => 'Lunas',
  };

  Ikon get ikon => switch (this) {
    StatusTransaksi.menungguPenjualan => Ikon.clock,
    StatusTransaksi.menungguPembayaran => Ikon.hourglass,
    StatusTransaksi.dibayarSebagian => Ikon.pieChart,
    StatusTransaksi.lunas => Ikon.checkCircle,
  };

  /// Warna teks & ikon.
  Color get warna => switch (this) {
    StatusTransaksi.menungguPenjualan => AppColors.biruTeks,
    StatusTransaksi.menungguPembayaran => AppColors.kuningTeks,
    StatusTransaksi.dibayarSebagian => AppColors.oranyeTeks,
    StatusTransaksi.lunas => AppColors.hijauTuaAlt,
  };

  Color get latar => switch (this) {
    StatusTransaksi.menungguPenjualan => AppColors.biruLatar,
    StatusTransaksi.menungguPembayaran => AppColors.kuningLatar,
    StatusTransaksi.dibayarSebagian => AppColors.oranyeLatar,
    StatusTransaksi.lunas => AppColors.lunasLatar,
  };
}

/// Lencana status berbentuk pil: ikon 20 + teks tebal 12.
class BadgeStatus extends StatelessWidget {
  const BadgeStatus({super.key, required this.status, this.tinggi = 36});

  final StatusTransaksi status;

  /// Tinggi pil (36 di Riwayat, 38 di Detail Transaksi).
  final double tinggi;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tinggi,
      padding: const EdgeInsets.fromLTRB(8, 0, 10, 0),
      decoration: BoxDecoration(color: status.latar, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(status.ikon, size: 20, color: status.warna),
          const SizedBox(width: 5),
          Text(status.label, style: AppText.badge.copyWith(color: status.warna)),
        ],
      ),
    );
  }
}
