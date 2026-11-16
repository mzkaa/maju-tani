import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../data/sample_data.dart';
import '../models/transaksi.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/badge_status.dart';
import '../widgets/bilah_tombol.dart';
import '../widgets/header_ringkas.dart';
import '../widgets/isi_formulir.dart';
import '../widgets/isian_kaca.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/kotak_lembut.dart';
import '../widgets/tombol.dart';
import 'catat_panen_screens.dart';

/// Baris nama sayur + lencana status (bagian atas kartu info M09/M10).
class _NamaDanStatus extends StatelessWidget {
  const _NamaDanStatus(this.t);

  final Transaksi t;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(t.komoditas, style: AppText.judulBagian),
        BadgeStatus(status: t.status, tinggi: 38),
      ],
    );
  }
}

/// Kotak catatan biru dengan ikon info (M07, M09).
class CatatanBiru extends StatelessWidget {
  const CatatanBiru(this.teks, {super.key});

  final String teks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.biruLatar, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppIcon(Ikon.info, size: 24, color: AppColors.biruTeks),
          const SizedBox(width: 12),
          Expanded(child: Text(teks, style: AppText.pesanBantuan)),
        ],
      ),
    );
  }
}

Future<DateTime?> _pilihTanggal(BuildContext context, DateTime awal, DateTime hariIni) =>
    showDatePicker(context: context, initialDate: awal, firstDate: DateTime(hariIni.year - 1), lastDate: hariIni);

// ---------------------------------------------------------------------------
// M09 Lengkapi Penjualan

class LengkapiPenjualanScreen extends StatefulWidget {
  const LengkapiPenjualanScreen({super.key, required this.id});

  final String id;

  @override
  State<LengkapiPenjualanScreen> createState() => _LengkapiPenjualanScreenState();
}

class _LengkapiPenjualanScreenState extends State<LengkapiPenjualanScreen> {
  late final AppStore _store = context.read<AppStore>();
  late DateTime _tanggal = _store.hariIni;
  // Data contoh: isian awal seperti di Figma.
  late final _berat = TextEditingController(text: _store.dataContoh ? '${SampleData.contohBeratTerjual}' : '');
  late final _harga = TextEditingController(
    text: _store.dataContoh ? Format.rupiah(SampleData.contohHargaJual) : '',
  );
  String? _galatBerat;
  String? _galatHarga;

  @override
  void initState() {
    super.initState();
    _berat.addListener(_ulang);
    _harga.addListener(_ulang);
  }

  void _ulang() => setState(() {});

  @override
  void dispose() {
    _berat.dispose();
    _harga.dispose();
    super.dispose();
  }

  void _simpan(Transaksi t) {
    final berat = Format.angka(_berat.text);
    final harga = Format.angka(_harga.text);
    setState(() {
      _galatBerat = (berat == null || berat <= 0 || berat > t.beratPanenKg)
          ? 'Isi berat antara 1 dan ${Format.kg(t.beratPanenKg)}'
          : null;
      _galatHarga = (harga == null || harga <= 0) ? 'Isi harga jual per kg' : null;
    });
    if (_galatBerat != null || _galatHarga != null) return;
    _store.lengkapiPenjualan(t.id, tanggal: _tanggal, beratKg: berat!, hargaPerKg: harga!);
    context.go(Rute.riwayat);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppStore>().cariTransaksi(widget.id);
    final berat = Format.angka(_berat.text) ?? 0;
    final harga = Format.angka(_harga.text) ?? 0;
    final total = berat * harga;

    return KerangkaHalaman(
      header: const HeaderRingkas(
        judul: 'Lengkapi Penjualan',
        keterangan: 'Isi setelah pengepul memberi kabar hasil jual',
        kiri: TombolKembali(),
      ),
      bilahBawah: t == null
          ? null
          : BilahTombol(
              tombol: [TombolUtama(label: 'Simpan Penjualan', ikon: Ikon.check, onTap: () => _simpan(t))],
            ),
      isi: t == null
          ? const SizedBox(height: 200)
          : IsiFormulir(
              bawah: 94 - 17,
              jarak: 14,
              children: [
                KotakKaca(
                  radius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _NamaDanStatus(t),
                      const SizedBox(height: 8),
                      Text(
                        'Panen ${Format.tanggal(t.tanggalPanen)} · ${Format.kg(t.beratPanenKg)} · No. ${t.nomor}',
                        style: AppText.keteranganKartu,
                      ),
                    ],
                  ),
                ),
                IsianKaca(
                  label: 'Tanggal terjual',
                  ikon: Ikon.calendar,
                  nilaiTetap: Format.hariTanggal(_tanggal),
                  onTap: () async {
                    final d = await _pilihTanggal(context, _tanggal, _store.hariIni);
                    if (d != null) setState(() => _tanggal = d);
                  },
                  akhiran: const AppIcon(Ikon.chevronDown, size: 24, color: AppColors.teksKedua),
                ),
                IsianKaca(
                  label: 'Berat yang terjual',
                  ikon: Ikon.scale,
                  controller: _berat,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  akhiran: Text('kg', style: AppText.akhiranIsian),
                  bantuan: 'Ubah bila beda dari berat panen (${Format.kg(t.beratPanenKg)})',
                  galat: _galatBerat,
                ),
                IsianKaca(
                  label: 'Harga jual per kg',
                  ikon: Ikon.tag,
                  controller: _harga,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [FormatRupiahInput()],
                  akhiran: Text('/kg', style: AppText.akhiranIsian),
                  bantuan: 'Harga yang diterima dari pengepul',
                  galat: _galatHarga,
                ),
                IsianKaca(
                  label: 'Total penjualan (dihitung sendiri)',
                  ikon: Ikon.banknote,
                  otomatis: true,
                  nilaiTetap: Format.rupiah(total),
                  bantuan: '${Format.kg(berat)} × ${Format.rupiah(harga)} = ${Format.rupiah(total)}',
                ),
                const CatatanBiru(
                  'Setelah disimpan, status menjadi Menunggu Pembayaran sampai uang dari pengepul dicatat.',
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// M10 Catat Pembayaran

class CatatPembayaranScreen extends StatefulWidget {
  const CatatPembayaranScreen({super.key, required this.id});

  final String id;

  @override
  State<CatatPembayaranScreen> createState() => _CatatPembayaranScreenState();
}

class _CatatPembayaranScreenState extends State<CatatPembayaranScreen> {
  late final AppStore _store = context.read<AppStore>();
  late DateTime _tanggal = _store.hariIni;
  // Awalnya "Lunas semua": jumlah = sisa tagihan.
  late final _jumlah = TextEditingController(text: Format.rupiah(_store.cariTransaksi(widget.id)?.sisaTagihan ?? 0))
    ..addListener(() => setState(() {}));
  String? _galat;

  @override
  void dispose() {
    _jumlah.dispose();
    super.dispose();
  }

  void _simpan(Transaksi t) {
    final jumlah = Format.angka(_jumlah.text);
    if (jumlah == null || jumlah <= 0 || jumlah > t.sisaTagihan) {
      setState(() => _galat = 'Isi antara Rp 1 dan ${Format.rupiah(t.sisaTagihan)}');
      return;
    }
    _store.catatPembayaran(t.id, tanggal: _tanggal, jumlah: jumlah);
    context.pushReplacement(Rute.pembayaranTersimpan(t.id));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppStore>().cariTransaksi(widget.id);
    final jumlah = Format.angka(_jumlah.text) ?? 0;
    final lunasSemua = t != null && jumlah == t.sisaTagihan;
    final statusNanti = lunasSemua ? StatusTransaksi.lunas : StatusTransaksi.dibayarSebagian;

    return KerangkaHalaman(
      header: const HeaderRingkas(
        judul: 'Catat Pembayaran',
        keterangan: 'Boleh dicicil atau langsung lunas',
        kiri: TombolKembali(),
      ),
      bilahBawah: t == null
          ? null
          : BilahTombol(
              tombol: [TombolUtama(label: 'Simpan Pembayaran', ikon: Ikon.check, onTap: () => _simpan(t))],
            ),
      isi: t == null
          ? const SizedBox(height: 200)
          : IsiFormulir(
              bawah: 94 - 17,
              jarak: 14,
              children: [
                KotakKaca(
                  radius: 14,
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _NamaDanStatus(t),
                      const SizedBox(height: 6),
                      Text('Sisa yang belum dibayar', style: AppText.labelSisa),
                      const SizedBox(height: 6),
                      Text(Format.rupiah(t.sisaTagihan), style: AppText.angkaSisa.copyWith(color: t.status.warna)),
                      const SizedBox(height: 6),
                      Text(
                        'Sudah dibayar ${Format.rupiah(t.totalDibayar)} dari ${Format.rupiah(t.totalPenjualan)}',
                        style: AppText.isiKartu,
                      ),
                    ],
                  ),
                ),
                IsianKaca(
                  label: 'Tanggal uang diterima',
                  ikon: Ikon.calendar,
                  nilaiTetap: Format.hariTanggal(_tanggal),
                  onTap: () async {
                    final d = await _pilihTanggal(context, _tanggal, _store.hariIni);
                    if (d != null) setState(() => _tanggal = d);
                  },
                  akhiran: const AppIcon(Ikon.chevronDown, size: 24, color: AppColors.teksKedua),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Berapa yang dibayar?', style: AppText.labelIsian),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _PilihanCepat(
                          teks: 'Lunas semua',
                          aktif: lunasSemua,
                          onTap: () => _jumlah.text = Format.rupiah(t.sisaTagihan),
                        ),
                        _PilihanCepat(teks: 'Sebagian dulu', aktif: !lunasSemua, onTap: () => _jumlah.clear()),
                      ],
                    ),
                  ],
                ),
                IsianKaca(
                  label: 'Jumlah uang diterima',
                  ikon: Ikon.banknote,
                  controller: _jumlah,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [FormatRupiahInput()],
                  bantuan: 'Paling banyak ${Format.rupiah(t.sisaTagihan)} (sisa tagihan)',
                  galat: _galat,
                ),
                KotakLembut(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Setelah disimpan, status jadi', style: AppText.isiKartu),
                      BadgeStatus(status: statusNanti, tinggi: 38),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Chip pilihan cepat jumlah bayar (tinggi 41): hijau tua bila aktif, kaca bila tidak.
class _PilihanCepat extends StatelessWidget {
  const _PilihanCepat({required this.teks, required this.aktif, required this.onTap});

  final String teks;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!aktif) {
      return KotakKaca(
        radius: 21,
        height: 41,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        onTap: onTap,
        label: teks,
        child: Center(widthFactor: 1, child: Text(teks, style: AppText.labelIsian)),
      );
    }
    return Semantics(
      button: true,
      selected: true,
      label: teks,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 41,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(color: AppColors.headerTengah, borderRadius: BorderRadius.circular(21)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(Ikon.check, size: 20, color: Color(0xFFFFFFFF)),
              const SizedBox(width: 6),
              Text(teks, style: AppText.labelIsian.copyWith(color: const Color(0xFFFFFFFF))),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M14 Pembayaran Tersimpan

class PembayaranTersimpanScreen extends StatelessWidget {
  const PembayaranTersimpanScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppStore>().cariTransaksi(id);
    final bayar = t == null || t.pembayaran.isEmpty ? null : t.pembayaran.last;

    return KerangkaHalaman(
      statusBarGelap: true,
      bilahBawah: BilahTombol(
        tombol: [
          TombolUtama(label: 'Kembali ke Beranda', ikon: Ikon.home, onTap: () => context.go(Rute.beranda)),
          TombolGaris(label: 'Lihat & Cetak Nota', onTap: () => context.push(Rute.notaPembayaran(id))),
          TombolGaris(label: 'Lihat Rincian', ikon: Ikon.fileText, onTap: () => context.push(Rute.detail(id))),
        ],
      ),
      isi: Padding(
        padding: EdgeInsets.fromLTRB(17, 79 + AppLayout.ekstraAtas(context), 17, 199 + AppLayout.ekstraBawah(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: LingkaranSukses()),
            const SizedBox(height: 11),
            Text('Pembayaran tersimpan', style: AppText.judulSukses, textAlign: TextAlign.center),
            if (t != null && bayar != null) ...[
              const SizedBox(height: 11),
              Text(
                '${t.komoditas}: uang ${Format.rupiah(bayar.jumlah)} diterima ${Format.tanggalSingkat(bayar.tanggal)}. '
                '${t.status == StatusTransaksi.lunas ? 'Semua sudah dibayar.' : 'Sisa ${Format.rupiah(t.sisaTagihan)}.'}',
                style: AppText.keteranganKartu,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 11),
              KartuStatusGelap(status: t.status, catatan: 'Riwayat pembayaran bisa dilihat di rincian transaksi.'),
            ],
          ],
        ),
      ),
    );
  }
}
