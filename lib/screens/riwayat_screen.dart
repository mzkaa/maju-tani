import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../models/transaksi.dart';
import '../router.dart';
import '../theme/app_layout.dart';
import '../widgets/app_icon.dart';
import '../widgets/chip_pilihan.dart';
import '../widgets/header_ringkas.dart';
import '../widgets/kartu_transaksi.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/nav_bawah.dart';

/// Pilihan saring di Riwayat.
enum _Saring { semua, belumDijual, belumLunas, lunas }

/// M03 Riwayat.
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  var _saring = _Saring.semua;

  bool _cocok(Transaksi t, _Saring s) => switch (s) {
    _Saring.semua => true,
    _Saring.belumDijual => t.status == StatusTransaksi.menungguPenjualan,
    _Saring.belumLunas => t.status == StatusTransaksi.menungguPembayaran || t.status == StatusTransaksi.dibayarSebagian,
    _Saring.lunas => t.status == StatusTransaksi.lunas,
  };

  @override
  Widget build(BuildContext context) {
    final semua = context.watch<AppStore>().riwayat;
    final tampil = semua.where((t) => _cocok(t, _saring)).toList();
    int jumlah(_Saring s) => semua.where((t) => _cocok(t, s)).length;
    final label = {
      _Saring.semua: 'Semua (${jumlah(_Saring.semua)})',
      _Saring.belumDijual: 'Belum dijual (${jumlah(_Saring.belumDijual)})',
      _Saring.belumLunas: 'Belum lunas (${jumlah(_Saring.belumLunas)})',
      _Saring.lunas: 'Lunas (${jumlah(_Saring.lunas)})',
    };

    return KerangkaHalaman(
      header: HeaderRingkas(
        judul: 'Riwayat',
        keterangan: 'Panen & penjualan terbaru',
        kanan: TombolBulatHeader(ikon: Ikon.search, label: 'Cari catatan', onTap: () => context.push(Rute.cari)),
      ),
      nav: true,
      navAktif: TabUtama.riwayat,
      isi: Padding(
        padding: EdgeInsets.only(top: 138 + AppLayout.ekstraAtas(context), bottom: 86),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Deret pilihan saring bisa digeser ke samping.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (i, s) in _Saring.values.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    ChipPilihan(teks: label[s]!, aktif: s == _saring, onTap: () => setState(() => _saring = s)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 0, 17, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, t) in tampil.indexed) ...[
                    if (i > 0) const SizedBox(height: 10),
                    KartuTransaksi(transaksi: t, onTap: () => context.push(Rute.tindakan(t))),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
