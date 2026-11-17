import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../models/transaksi.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/bilah_tombol.dart';
import '../widgets/header_ringkas.dart';
import '../widgets/isi_formulir.dart';
import '../widgets/isian_kaca.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/lingkaran_sukses.dart';
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
  String? _galatPanen;
  String? _galatJual;
  String? _galatHarga;

  @override
  void dispose() {
    for (final c in [_beratPanen, _pengepul, _beratJual, _harga]) {
      c.dispose();
    }
    super.dispose();
  }

  /// [terawal] = batas awal kalender; catatan lama tetap bisa dibuka (tidak dibatasi tahun lalu).
  Future<DateTime?> _pilih(DateTime awal, {DateTime? terawal}) {
    final batas = terawal ?? DateTime(_store.hariIni.year - 1);
    return showDatePicker(
      context: context,
      initialDate: awal,
      firstDate: awal.isBefore(batas) ? DateUtils.dateOnly(awal) : DateUtils.dateOnly(batas),
      lastDate: _store.hariIni,
    );
  }

  Future<void> _simpan(Transaksi t) async {
    // Berat harus angka bulat: "91,5" ditolak, bukan dibaca 915.
    final panen = int.tryParse(_beratPanen.text.trim());
    final jual = int.tryParse(_beratJual.text.trim());
    final harga = Format.angka(_harga.text);
    final panenSalah = panen == null || panen <= 0;
    String? galatJual;
    String? galatHarga;
    if (t.sudahDijual) {
      final tanggalJual = _tanggalJual;
      if (jual == null || jual <= 0 || (!panenSalah && jual > panen)) {
        galatJual = panenSalah ? 'Isi berat terjual' : 'Isi berat antara 1 dan ${Format.kg(panen)}';
      } else if (tanggalJual != null && DateUtils.dateOnly(tanggalJual).isBefore(DateUtils.dateOnly(_tanggalPanen))) {
        galatJual = 'Tanggal terjual tidak boleh sebelum tanggal panen';
      }
      if (harga == null || harga <= 0) {
        galatHarga = 'Isi harga jual per kg';
      } else if (galatJual == null && jual! * harga < t.totalDibayar) {
        // Total penjualan tidak boleh di bawah uang yang sudah diterima.
        galatHarga = 'Total jadi lebih kecil dari yang sudah dibayar (${Format.rupiah(t.totalDibayar)})';
      }
    }
    setState(() {
      _galatPanen = panenSalah ? 'Isi berat panen dalam kg' : null;
      _galatJual = galatJual;
      _galatHarga = galatHarga;
    });
    if (panenSalah || galatJual != null || galatHarga != null) return;
    _store.ubahTransaksi(
      t.id,
      tanggalPanen: _tanggalPanen,
      beratPanenKg: panen,
      pembeli: _pengepul.text.trim().isEmpty ? null : _pengepul.text.trim(),
      tanggalJual: _tanggalJual,
      beratTerjualKg: jual,
      hargaPerKg: harga,
    );
    await tampilkanBerhasil(context, 'Perubahan tersimpan');
    if (mounted) context.kembali();
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
                TombolGaris(label: 'Batal', ikon: Ikon.x, onTap: () => context.kembali()),
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
                  galat: _galatPanen,
                ),
                IsianKaca(label: 'Pengepul', ikon: Ikon.user, controller: _pengepul),
                if (t.sudahDijual) ...[
                  const JudulKecil(label: 'DATA PENJUALAN', judul: 'Hasil jual'),
                  IsianKaca(
                    label: 'Tanggal terjual',
                    ikon: Ikon.calendar,
                    nilaiTetap: Format.tanggal(_tanggalJual ?? _store.hariIni),
                    onTap: () async {
                      final d = await _pilih(_tanggalJual ?? _store.hariIni, terawal: _tanggalPanen);
                      if (d != null) setState(() => _tanggalJual = d);
                    },
                  ),
                  IsianKaca(
                    label: 'Berat terjual',
                    ikon: Ikon.scale,
                    controller: _beratJual,
                    keyboardType: TextInputType.number,
                    akhiran: Text('kg', style: AppText.akhiranIsian),
                    galat: _galatJual,
                  ),
                  IsianKaca(
                    label: 'Harga jual per kg',
                    ikon: Ikon.tag,
                    controller: _harga,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [FormatRupiahInput()],
                    akhiran: Text('/kg', style: AppText.akhiranIsian),
                    galat: _galatHarga,
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
