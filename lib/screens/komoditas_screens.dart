import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../models/komoditas.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/bilah_tombol.dart';
import '../widgets/header_ringkas.dart';
import '../widgets/isi_formulir.dart';
import '../widgets/isian_kaca.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/layar_tambahan.dart';
import '../widgets/nav_bawah.dart';
import '../widgets/tombol.dart';

// ---------------------------------------------------------------------------
// M12 Data Komoditas

class DataKomoditasScreen extends StatelessWidget {
  const DataKomoditasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final semua = store.komoditas;
    final saring = store.saringKomoditas;
    final tampil = semua.where((k) => saring == null || k.aktif == saring).toList();
    final jumlahAktif = semua.where((k) => k.aktif).length;

    return KerangkaHalaman(
      header: HeaderRingkas(
        judul: 'Komoditas',
        keterangan: 'Jenis sayur yang dipanen',
        kanan: TombolBulatHeader(
          ikon: Ikon.plus,
          label: 'Tambah komoditas',
          onTap: () => context.push(Rute.tambahKomoditas),
        ),
      ),
      nav: true,
      navAktif: TabUtama.komoditas,
      isi: Padding(
        padding: EdgeInsets.fromLTRB(14, 142 + AppLayout.ekstraAtas(context), 14, 101),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Di prototype, chip saring membuka layar Filter Komoditas (M29).
            Row(
              children: [
                _ChipKomoditas(
                  teks: 'Semua (${semua.length})',
                  aktif: saring == null,
                  onTap: () => context.push(Rute.filterKomoditas),
                ),
                const SizedBox(width: 8),
                _ChipKomoditas(
                  teks: 'Aktif ($jumlahAktif)',
                  aktif: saring == true,
                  onTap: () => context.push(Rute.filterKomoditas),
                ),
                const SizedBox(width: 8),
                _ChipKomoditas(
                  teks: 'Nonaktif (${semua.length - jumlahAktif})',
                  aktif: saring == false,
                  onTap: () => context.push(Rute.filterKomoditas),
                ),
              ],
            ),
            for (final k in tampil) ...[
              const SizedBox(height: 12),
              _KartuKomoditas(
                komoditas: k,
                harga: store.hargaTerakhir(k.nama),
                kaliPanen: store.kaliPanen(k.nama),
                totalKg: store.totalPanenKg(k.nama),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChipKomoditas extends StatelessWidget {
  const _ChipKomoditas({required this.teks, required this.aktif, required this.onTap});

  final String teks;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: aktif,
      label: teks,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10), // + garis 1 = 11
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: aktif ? AppColors.hijauAktif : const Color(0xBFFFFFFF), // putih 75%
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xE6FFFFFF)), // putih 90%
          ),
          child: Text(
            teks,
            style: AppText.chipKecil.copyWith(color: aktif ? const Color(0xFFFFFFFF) : AppColors.teksUtama),
          ),
        ),
      ),
    );
  }
}

class _KartuKomoditas extends StatelessWidget {
  const _KartuKomoditas({required this.komoditas, required this.harga, required this.kaliPanen, required this.totalKg});

  final Komoditas komoditas;
  final int? harga;
  final int kaliPanen;
  final int totalKg;

  @override
  Widget build(BuildContext context) {
    final k = komoditas;
    final kartu = KotakKaca(
      radius: 16,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.daunLatar, borderRadius: BorderRadius.circular(14)),
            child: const AppIcon(Ikon.leaf, size: 24, color: AppColors.ikonDaun),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(k.nama, style: AppText.namaKomoditas),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: k.aktif ? AppColors.daunLatar : const Color(0x1F0F1F19), // 12%
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        k.aktif ? 'Aktif' : 'Nonaktif',
                        style: AppText.lencanaKecil.copyWith(
                          color: k.aktif ? AppColors.hijauAktif : const Color(0xB30F1F19), // 70%
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  harga == null ? 'Harga terakhir belum ada' : 'Harga terakhir ${Format.rupiah(harga!)}/kg',
                  style: AppText.hargaKomoditas,
                ),
                const SizedBox(height: 3),
                Text(
                  kaliPanen == 0 ? 'Belum pernah dipanen' : '$kaliPanen kali panen · ${Format.kg(totalKg)}',
                  style: AppText.panenKomoditas,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: 'Ubah ${k.nama}',
            child: GestureDetector(
              onTap: () => context.push(Rute.ubahKomoditas(k.nama)),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10), // + garis 1 = 11
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xB3FFFFFF), // putih 70%
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x330F1F19)), // 20%
                ),
                child: Text('Ubah', style: AppText.chipKecil.copyWith(color: AppColors.hijauAktif)),
              ),
            ),
          ),
        ],
      ),
    );
    // Komoditas nonaktif tampil samar (65%).
    return k.aktif ? kartu : Opacity(opacity: 0.65, child: kartu);
  }
}

// ---------------------------------------------------------------------------
// M13 Tambah Komoditas & M21 Ubah Komoditas (formulir yang sama)

class FormKomoditasScreen extends StatefulWidget {
  const FormKomoditasScreen({super.key, this.namaLama});

  /// Null = tambah baru (M13); berisi nama = ubah (M21).
  final String? namaLama;

  @override
  State<FormKomoditasScreen> createState() => _FormKomoditasScreenState();
}

class _FormKomoditasScreenState extends State<FormKomoditasScreen> {
  late final AppStore _store = context.read<AppStore>();
  late final Komoditas? _lama = widget.namaLama == null
      ? null
      : _store.komoditas.where((k) => k.nama == widget.namaLama).firstOrNull;
  // Tambah baru: data contoh terisi "Tomat" seperti di Figma.
  late final _nama = TextEditingController(text: _lama?.nama ?? (_store.dataContoh ? 'Tomat' : ''));
  late bool _aktif = _lama?.aktif ?? true;
  String? _galat;

  bool get _ubah => widget.namaLama != null;

  @override
  void dispose() {
    _nama.dispose();
    super.dispose();
  }

  void _simpan() {
    final nama = _nama.text.trim();
    final dipakai = _store.komoditas.any(
      (k) => k.nama.toLowerCase() == nama.toLowerCase() && k.nama != widget.namaLama,
    );
    if (nama.isEmpty || dipakai) {
      setState(() => _galat = nama.isEmpty ? 'Isi nama sayur' : 'Nama ini sudah ada di daftar');
      return;
    }
    if (_ubah) {
      _store.ubahKomoditas(widget.namaLama!, (_lama ?? Komoditas(nama: nama)).copyWith(nama: nama, aktif: _aktif));
    } else {
      _store.tambahKomoditas(Komoditas(nama: nama, aktif: _aktif));
    }
    context.kembali();
  }

  @override
  Widget build(BuildContext context) {
    final kali = _ubah ? _store.kaliPanen(widget.namaLama!) : 0;
    final kg = _ubah ? _store.totalPanenKg(widget.namaLama!) : 0;

    return KerangkaHalaman(
      header: HeaderRingkas(
        judul: _ubah ? 'Ubah Komoditas' : 'Tambah Komoditas',
        keterangan: _ubah ? widget.namaLama! : 'Sayur baru akan muncul di Catat Panen',
        kiri: const TombolKembali(),
      ),
      bilahBawah: BilahTombol(
        tombol: [
          TombolUtama(label: _ubah ? 'Simpan Perubahan' : 'Simpan Komoditas', ikon: Ikon.check, onTap: _simpan),
          TombolGaris(label: 'Batal', ikon: Ikon.x, onTap: () => context.kembali()),
        ],
      ),
      isi: IsiFormulir(
        // M13 memakai tepi 17 & jarak 15; M21 (layar tambahan) tepi 14 & jarak 11.
        tepi: _ubah ? 14 : 17,
        bawah: _ubah ? 158.0 + 145 - 17 : 145 - 17,
        jarak: _ubah ? 11 : 15,
        children: [
          IsianKaca(
            label: 'Nama sayur',
            ikon: Ikon.leaf,
            controller: _nama,
            textInputAction: TextInputAction.done,
            bantuan: _ubah ? null : 'Contoh: Tomat, Buncis, Terong',
            galat: _galat,
          ),
          IsianKaca(
            label: 'Satuan',
            ikon: Ikon.scale,
            nilaiTetap: _lama?.satuan ?? 'Kilogram (kg)',
            akhiran: const AppIcon(Ikon.chevronDown, size: 24, color: AppColors.teksKedua),
          ),
          KotakKaca(
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tampilkan saat catat panen', style: AppText.labelIsian),
                      const SizedBox(height: 2),
                      Text('Pilih "Ya" agar sayur ini bisa dipilih', style: AppText.bantuanIsian),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Saklar(nyala: _aktif, onTap: () => setState(() => _aktif = !_aktif)),
              ],
            ),
          ),
          if (_ubah)
            KotakKaca(
              radius: 19,
              padding: const EdgeInsets.all(12),
              child: BarisIkon(
                ikon: Ikon.info,
                warna: AppColors.biruIkonTambahan,
                judul: 'Data panen lama tetap aman',
                keterangan: '$kali kali panen · ${Format.kg(kg)} tidak ikut berubah',
                panah: false,
              ),
            ),
        ],
      ),
    );
  }
}

/// Saklar Ya/Tidak (84 × 48). Keadaan "Tidak" tidak ada di Figma.
class Saklar extends StatelessWidget {
  const Saklar({super.key, required this.nyala, required this.onTap});

  final bool nyala;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bulat = Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(color: Color(0xFFFFFFFF), shape: BoxShape.circle),
    );
    final teks = Text(
      nyala ? 'Ya' : 'Tidak',
      style: AppText.dipilih.copyWith(color: nyala ? const Color(0xFFFFFFFF) : AppColors.teksJudul),
    );
    return Semantics(
      toggled: nyala,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 84,
          height: 48,
          padding: nyala ? const EdgeInsets.fromLTRB(10, 4, 4, 4) : const EdgeInsets.fromLTRB(4, 4, 10, 4),
          decoration: BoxDecoration(
            color: nyala ? AppColors.headerTengah : AppColors.garisPemisah,
            borderRadius: BorderRadius.circular(19),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: nyala
                ? [teks, const SizedBox(width: 6), bulat]
                : [bulat, const SizedBox(width: 6), Expanded(child: Center(child: teks))],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M29 Filter Komoditas

class FilterKomoditasScreen extends StatefulWidget {
  const FilterKomoditasScreen({super.key});

  @override
  State<FilterKomoditasScreen> createState() => _FilterKomoditasScreenState();
}

class _FilterKomoditasScreenState extends State<FilterKomoditasScreen> {
  late final AppStore _store = context.read<AppStore>();
  late bool? _saring = _store.saringKomoditas;
  // Saklar di tiap kartu mengubah status aktif komoditas (diterapkan saat "Terapkan Filter").
  late final Map<String, bool> _aktif = {for (final k in _store.komoditas) k.nama: k.aktif};

  void _terapkan() {
    for (final k in _store.komoditas) {
      if (_aktif[k.nama] != k.aktif) _store.ubahKomoditas(k.nama, k.copyWith(aktif: _aktif[k.nama]));
    }
    _store.aturSaringKomoditas(_saring);
    context.kembali();
  }

  void _aturUlang() => setState(() {
    _saring = null;
    for (final k in _store.komoditas) {
      _aktif[k.nama] = k.aktif;
    }
  });

  @override
  Widget build(BuildContext context) {
    return KerangkaHalaman(
      header: const HeaderRingkas(judul: 'Daftar Komoditas', keterangan: 'Saring sayur aktif', kiri: TombolKembali()),
      bilahBawah: BilahTombol(
        tombol: [
          TombolUtama(label: 'Terapkan Filter', onTap: _terapkan),
          TombolGaris(label: 'Atur Ulang', onTap: _aturUlang),
        ],
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: 158.0 + 145 - 17,
        children: [
          Row(
            children: [
              ChipPil(teks: 'Semua', aktif: _saring == null, onTap: () => setState(() => _saring = null)),
              const SizedBox(width: 8),
              ChipPil(teks: 'Aktif', aktif: _saring == true, onTap: () => setState(() => _saring = true)),
              const SizedBox(width: 8),
              ChipPil(teks: 'Nonaktif', aktif: _saring == false, onTap: () => setState(() => _saring = false)),
            ],
          ),
          for (final k in _store.komoditas)
            _KartuSaklar(
              nama: k.nama,
              aktif: _aktif[k.nama]!,
              onTap: () => setState(() => _aktif[k.nama] = !_aktif[k.nama]!),
            ),
        ],
      ),
    );
  }
}

class _KartuSaklar extends StatelessWidget {
  const _KartuSaklar({required this.nama, required this.aktif, required this.onTap});

  final String nama;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kartu = KotakKaca(
      radius: 19,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0x2E2A7A52), shape: BoxShape.circle), // 18%
            child: Text('🥬', style: AppText.gaya(17.8, FontWeight.w800, AppColors.hijauAktif, tinggi: 1.35)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(nama, style: AppText.gaya(15, FontWeight.w700, AppColors.teksUtama, tinggi: 1.35))),
          const SizedBox(width: 12),
          Semantics(
            toggled: aktif,
            label: nama,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 56,
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: aktif ? Alignment.centerRight : Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: aktif ? AppColors.hijauAktif : const Color(0x330F1F19), // 20%
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    // Komoditas nonaktif tampil samar (60%).
    return aktif ? kartu : Opacity(opacity: 0.6, child: kartu);
  }
}
