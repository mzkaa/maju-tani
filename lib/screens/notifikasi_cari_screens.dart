import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../models/notifikasi.dart';
import '../models/transaksi.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/header_ringkas.dart';
import '../widgets/isi_formulir.dart';
import '../widgets/isian_kaca.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/layar_tambahan.dart';

/// Jarak bawah isi layar tanpa bilah tombol (padding "Konten" 43 + "Isi" 145).
const _bawah = 43.0 + 145 - 17;

// ---------------------------------------------------------------------------
// M16 Notifikasi

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _hanyaBelumDibaca = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final semua = store.notifikasi;
    final belum = semua.where((n) => !n.dibaca).toList();
    final tampil = _hanyaBelumDibaca ? belum : semua;

    return KerangkaHalaman(
      header: const HeaderRingkas(
        judul: 'Pemberitahuan',
        keterangan: 'Hal yang perlu Bapak cek',
        kiri: TombolKembali(),
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: _bawah,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChipGradien(
                teks: 'Semua (${semua.length})',
                aktif: !_hanyaBelumDibaca,
                onTap: () => setState(() => _hanyaBelumDibaca = false),
              ),
              ChipGradien(
                teks: 'Belum dibaca (${belum.length})',
                aktif: _hanyaBelumDibaca,
                onTap: () => setState(() => _hanyaBelumDibaca = true),
              ),
            ],
          ),
          for (final n in tampil) _KartuNotifikasi(n),
        ],
      ),
    );
  }
}

class _KartuNotifikasi extends StatelessWidget {
  const _KartuNotifikasi(this.n);

  final Notifikasi n;

  @override
  Widget build(BuildContext context) {
    final (ikon, warna, rute) = switch (n.jenis) {
      JenisNotifikasi.belumDijual => (Ikon.clock, AppColors.biruIkonTambahan, Rute.lengkapiPenjualan(n.transaksiId)),
      JenisNotifikasi.belumDibayar => (Ikon.hourglass, AppColors.oranyeAngka, Rute.catatPembayaran(n.transaksiId)),
      JenisNotifikasi.pembayaranMasuk => (Ikon.checkCircle, AppColors.hijauTua, Rute.detail(n.transaksiId)),
    };
    final kartu = KotakKaca(
      radius: 19,
      padding: const EdgeInsets.all(12),
      child: BarisIkon(
        ikon: ikon,
        warna: warna,
        judul: n.judul,
        keterangan: n.keterangan,
        titik: !n.dibaca,
        onTap: () {
          context.read<AppStore>().tandaiDibaca(n.id);
          context.push(rute);
        },
      ),
    );
    // Yang sudah dibaca tampil sedikit samar (85%).
    return n.dibaca ? Opacity(opacity: 0.85, child: kartu) : kartu;
  }
}

// ---------------------------------------------------------------------------
// M17 Cari Catatan

enum _Saring { semua, belumDijual, belumLunas, lunas }

class CariScreen extends StatefulWidget {
  const CariScreen({super.key});

  @override
  State<CariScreen> createState() => _CariScreenState();
}

class _CariScreenState extends State<CariScreen> {
  // Data contoh: kata kunci seperti di Figma.
  late final _kata = TextEditingController(text: context.read<AppStore>().dataContoh ? 'Bayam' : '');
  final _fokus = FocusNode();
  var _saring = _Saring.semua;

  @override
  void initState() {
    super.initState();
    _kata.addListener(() => setState(() {}));
    _fokus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _kata.dispose();
    _fokus.dispose();
    super.dispose();
  }

  bool _cocok(Transaksi t) {
    final k = _kata.text.trim().toLowerCase();
    final cocokKata = k.isEmpty || t.komoditas.toLowerCase().contains(k) || (t.pembeli ?? '').toLowerCase().contains(k);
    final cocokStatus = switch (_saring) {
      _Saring.semua => true,
      _Saring.belumDijual => t.status == StatusTransaksi.menungguPenjualan,
      _Saring.belumLunas =>
        t.status == StatusTransaksi.menungguPembayaran || t.status == StatusTransaksi.dibayarSebagian,
      _Saring.lunas => t.status == StatusTransaksi.lunas,
    };
    return cocokKata && cocokStatus;
  }

  @override
  Widget build(BuildContext context) {
    final hasil = context.watch<AppStore>().riwayat.where(_cocok).toList();
    const label = {
      _Saring.semua: 'Semua',
      _Saring.belumDijual: 'Belum dijual',
      _Saring.belumLunas: 'Belum lunas',
      _Saring.lunas: 'Lunas',
    };

    return KerangkaHalaman(
      header: const HeaderRingkas(
        judul: 'Cari Catatan',
        keterangan: 'Cari nama sayur atau pengepul',
        kiri: TombolKembali(),
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: _bawah,
        children: [
          IsianKaca(
            label: 'Kata kunci',
            ikon: Ikon.search,
            controller: _kata,
            focusNode: _fokus,
            fokusBiru: _fokus.hasFocus,
            textInputAction: TextInputAction.search,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _Saring.values)
                ChipGradien(teks: label[s]!, aktif: s == _saring, onTap: () => setState(() => _saring = s)),
            ],
          ),
          Text('${hasil.length} catatan ditemukan', style: AppText.gaya(14, FontWeight.w600, AppColors.teksKeduaAlt)),
          for (final t in hasil) _KartuHasil(t),
        ],
      ),
    );
  }
}

class _KartuHasil extends StatelessWidget {
  const _KartuHasil(this.t);

  final Transaksi t;

  @override
  Widget build(BuildContext context) {
    final (ikon, warna, label, nilai) = switch (t.status) {
      StatusTransaksi.menungguPenjualan => (Ikon.clock, AppColors.biruIkonTambahan, 'Harga jual', 'Belum ada'),
      StatusTransaksi.menungguPembayaran => (
        Ikon.hourglass,
        AppColors.oranyeAngka,
        'Belum dibayar',
        Format.rupiah(t.sisaTagihan),
      ),
      StatusTransaksi.dibayarSebagian => (Ikon.pieChart, AppColors.oranyeAngka, 'Sisa', Format.rupiah(t.sisaTagihan)),
      StatusTransaksi.lunas => (Ikon.checkCircle, AppColors.hijauTua, 'Lunas', Format.rupiah(t.totalPenjualan)),
    };
    final judul = t.sudahDijual
        ? '${t.komoditas} · ${t.beratTerjualKg} kg terjual'
        : '${t.komoditas} · ${Format.kg(t.beratPanenKg)}';
    final keterangan = 'Panen ${Format.tanggal(t.tanggalPanen)}${t.pembeli == null ? '' : ' · ${t.pembeli}'}';

    return KotakKaca(
      radius: 19,
      padding: const EdgeInsets.all(13),
      onTap: () => context.push(Rute.detail(t.id)),
      label: judul,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarisIkon(ikon: ikon, warna: warna, judul: judul, keterangan: keterangan),
          const SizedBox(height: 10),
          const GarisTipis(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppText.barisKeterangan),
              Text(nilai, style: AppText.gaya(16, FontWeight.w800, warna)),
            ],
          ),
        ],
      ),
    );
  }
}
