import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../models/transaksi.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/bilah_tombol.dart';
import '../widgets/header_ringkas.dart';
import '../widgets/isi_formulir.dart';
import '../widgets/isian_kaca.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/layar_tambahan.dart';
import '../widgets/tombol.dart';

/// M18 Ubah Data Transaksi.
class UbahTransaksiScreen extends StatefulWidget {
  const UbahTransaksiScreen({super.key, required this.id});

  final String id;

  @override
  State<UbahTransaksiScreen> createState() => _UbahTransaksiScreenState();
}

class _UbahTransaksiScreenState extends State<UbahTransaksiScreen> {
  late final AppStore _store = context.read<AppStore>();
  late final Transaksi? _awal = _store.cariTransaksi(widget.id);
  late DateTime _tanggalPanen = _awal?.tanggalPanen ?? _store.hariIni;
  late DateTime? _tanggalJual = _awal?.tanggalJual;
  late final _beratPanen = TextEditingController(text: '${_awal?.beratPanenKg ?? ''}');
  late final _pengepul = TextEditingController(text: _awal?.pembeli ?? '');
  late final _beratJual = TextEditingController(text: '${_awal?.beratTerjualKg ?? ''}');
  late final _harga = TextEditingController(text: _awal?.hargaPerKg == null ? '' : Format.rupiah(_awal!.hargaPerKg!));
  String? _galat;

  @override
  void dispose() {
    for (final c in [_beratPanen, _pengepul, _beratJual, _harga]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<DateTime?> _pilih(DateTime awal) => showDatePicker(
    context: context,
    initialDate: awal,
    firstDate: DateTime(_store.hariIni.year - 1),
    lastDate: _store.hariIni,
  );

  void _simpan(Transaksi t) {
    final panen = Format.angka(_beratPanen.text);
    final jual = Format.angka(_beratJual.text);
    final harga = Format.angka(_harga.text);
    final salah = panen == null || panen <= 0 || (t.sudahDijual && (jual == null || jual <= 0 || harga == null));
    if (salah) {
      setState(() => _galat = 'Periksa lagi berat dan harga');
      return;
    }
    _store.ubahTransaksi(
      t.id,
      tanggalPanen: _tanggalPanen,
      beratPanenKg: panen,
      pembeli: _pengepul.text.trim().isEmpty ? null : _pengepul.text.trim(),
      tanggalJual: _tanggalJual,
      beratTerjualKg: jual,
      hargaPerKg: harga,
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = _awal;
    final kiri = const TombolKembali();
    return KerangkaHalaman(
      header: HeaderRingkas(
        judul: 'Ubah Data',
        keterangan: t == null ? '' : '${t.komoditas} · No. ${t.nomor}',
        kiri: kiri,
      ),
      bilahBawah: t == null
          ? null
          : BilahTombol(
              tombol: [
                TombolUtama(label: 'Simpan Perubahan', ikon: Ikon.check, onTap: () => _simpan(t)),
                TombolGaris(label: 'Batal', ikon: Ikon.x, onTap: () => context.pop()),
              ],
            ),
      isi: t == null
          ? const SizedBox(height: 200)
          : IsiFormulir(
              tepi: 14,
              jarak: 11,
              bawah: 158.0 + 145 - 17,
              children: [
                const JudulKecil(label: 'DATA PANEN', judul: 'Hasil panen'),
                IsianKaca(
                  label: 'Tanggal panen',
                  ikon: Ikon.calendar,
                  nilaiTetap: Format.tanggal(_tanggalPanen),
                  onTap: () async {
                    final d = await _pilih(_tanggalPanen);
                    if (d != null) setState(() => _tanggalPanen = d);
                  },
                ),
                IsianKaca(
                  label: 'Berat panen',
                  ikon: Ikon.scale,
                  controller: _beratPanen,
                  keyboardType: TextInputType.number,
                  akhiran: Text('kg', style: AppText.akhiranIsian),
                  galat: _galat,
                ),
                IsianKaca(label: 'Pengepul', ikon: Ikon.user, controller: _pengepul),
                if (t.sudahDijual) ...[
                  const JudulKecil(label: 'DATA PENJUALAN', judul: 'Hasil jual'),
                  IsianKaca(
                    label: 'Tanggal terjual',
                    ikon: Ikon.calendar,
                    nilaiTetap: Format.tanggal(_tanggalJual ?? _store.hariIni),
                    onTap: () async {
                      final d = await _pilih(_tanggalJual ?? _store.hariIni);
                      if (d != null) setState(() => _tanggalJual = d);
                    },
                  ),
                  IsianKaca(
                    label: 'Berat terjual',
                    ikon: Ikon.scale,
                    controller: _beratJual,
                    keyboardType: TextInputType.number,
                    akhiran: Text('kg', style: AppText.akhiranIsian),
                  ),
                  IsianKaca(
                    label: 'Harga jual per kg',
                    ikon: Ikon.tag,
                    controller: _harga,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [FormatRupiahInput()],
                    akhiran: Text('/kg', style: AppText.akhiranIsian),
                  ),
                ],
                const KotakKaca(
                  radius: 19,
                  padding: EdgeInsets.all(12),
                  child: BarisIkon(
                    ikon: Ikon.info,
                    warna: AppColors.biruIkonTambahan,
                    judul: 'Perubahan akan dicatat',
                    keterangan: 'Muncul di "Perjalanan transaksi" supaya jelas',
                    panah: false,
                  ),
                ),
              ],
            ),
    );
  }
}
