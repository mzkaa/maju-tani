import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../data/sample_data.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
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

/// Jarak bawah isi layar tambahan (padding "Konten" 158 + "Isi" 145 di Figma).
const _bawahTambahan = 158.0 + 145 - 17;

// ---------------------------------------------------------------------------
// M15 Akun & Bantuan

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final ukuran = switch (store.ukuranHuruf) {
      UkuranHuruf.sedang => 'Sedang',
      UkuranHuruf.besar => 'Besar',
      UkuranHuruf.sangatBesar => 'Sangat besar',
    };

    return KerangkaHalaman(
      header: const HeaderRingkas(judul: 'Akun Saya', keterangan: 'Profil, bantuan, dan keluar', kiri: TombolKembali()),
      bilahBawah: BilahTombol(
        tombol: [
          // Warna tombol ini mengikuti Figma: garis #15803D; ikon pintu putih, panah abu-abu.
          TombolGaris(
            label: 'Keluar dari Akun',
            ikon: Ikon.logout,
            warnaGaris: AppColors.garisTombolRekap,
            warnaTeks: AppColors.teksTombolRekap,
            warnaPerGaris: const [Colors.white, AppColors.ikonDaun, AppColors.ikonDaun],
            onTap: () {
              store.keluar();
              context.go(Rute.masuk);
            },
          ),
        ],
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: _bawahTambahan,
        children: [
          KotakKaca(
            radius: 19,
            height: 100, // tinggi tetap seperti di Figma
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 51,
                  height: 51,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: AppGradien.hijauBulat, borderRadius: BorderRadius.circular(26)),
                  child: Text(_inisial(store.namaPemilik), style: AppText.gaya(19, FontWeight.w800, Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(store.namaPemilik, style: AppText.gaya(17, FontWeight.w800, AppColors.teksUtama)),
                      const SizedBox(height: 2),
                      Text('Pemilik · Mitra Maju Tani', style: AppText.barisKeterangan),
                      const SizedBox(height: 2),
                      Text('Nama pengguna: ${store.namaPengguna}', style: AppText.barisKeterangan),
                    ],
                  ),
                ),
              ],
            ),
          ),
          JudulKecil(label: 'PENGATURAN', judul: 'Akun', onTap: () => context.push(Rute.pengaturan)),
          KartuDaftar(
            baris: [
              BarisIkon(
                ikon: Ikon.lock,
                warna: AppColors.hijauTua,
                judul: 'Ubah kata sandi',
                keterangan: 'Ganti kata sandi untuk masuk',
                onTap: () => context.push(Rute.ubahSandi),
              ),
              BarisIkon(
                ikon: Ikon.sun,
                warna: AppColors.oranyeAngka,
                judul: 'Ukuran tulisan',
                keterangan: 'Sekarang: $ukuran',
                onTap: () => context.push(Rute.pengaturan),
              ),
            ],
          ),
          const JudulKecil(label: 'BANTUAN', judul: 'Butuh bantuan?'),
          KartuDaftar(
            baris: [
              BarisIkon(
                ikon: Ikon.phone,
                warna: AppColors.hijauTua,
                judul: 'Hubungi lewat WhatsApp',
                keterangan: 'Tim pengembang siap membantu',
              ),
              BarisIkon(
                ikon: Ikon.help,
                warna: AppColors.biruIkonTambahan,
                judul: 'Cara memakai aplikasi',
                keterangan: 'Panduan singkat bergambar',
                onTap: () => _info(context, 'Cara memakai aplikasi', _panduan),
              ),
              BarisIkon(
                ikon: Ikon.info,
                warna: AppColors.teksKeduaAlt,
                judul: 'Tentang aplikasi',
                keterangan: store.dataContoh ? 'Versi 1.0 · data contoh' : 'Versi 1.0',
                onTap: () => _info(
                  context,
                  'Tentang aplikasi',
                  'Mitra Maju Tani versi 1.0\n\nPencatatan panen, penjualan, dan pembayaran untuk UMKM pertanian. '
                      'Semua data tersimpan di HP ini.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _panduan =
      '1. Tekan tombol + di bawah untuk mencatat panen.\n'
      '2. Setelah pengepul menjual, buka "Lengkapi Harga" di Beranda dan isi berat terjual serta harga per kg.\n'
      '3. Saat uang diterima, buka "Catat Bayaran". Cicilan boleh dicatat beberapa kali.\n'
      '4. Lihat ringkasan di menu Laporan, lalu cetak atau unduh sebagai PDF/Excel.\n'
      '5. Cadangkan data secara rutin dari Pengaturan.';

  static Future<void> _info(BuildContext context, String judul, String isi) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(judul),
      content: Text(isi),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
    ),
  );

  /// "Pak Pemilik" → "PP"
  static String _inisial(String nama) =>
      nama.split(' ').where((k) => k.isNotEmpty).take(2).map((k) => k[0].toUpperCase()).join();
}

// ---------------------------------------------------------------------------
// M22 Lupa Kata Sandi

class LupaSandiScreen extends StatefulWidget {
  const LupaSandiScreen({super.key});

  @override
  State<LupaSandiScreen> createState() => _LupaSandiScreenState();
}

class _LupaSandiScreenState extends State<LupaSandiScreen> {
  // Contoh isian seperti di Figma.
  final _nomor = TextEditingController(text: '0812 3456 7890');
  final _kode = TextEditingController(text: '482');
  final _fokusKode = FocusNode();
  int _sisaDetik = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _kode.addListener(() => setState(() {}));
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_sisaDetik == 0) return t.cancel();
      setState(() => _sisaDetik--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nomor.dispose();
    _kode.dispose();
    _fokusKode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kode = _kode.text;
    return KerangkaHalaman(
      header: const HeaderRingkas(judul: 'Lupa Kata Sandi', keterangan: 'Kami bantu atur ulang', kiri: TombolKembali()),
      bilahBawah: BilahTombol(
        tombol: [
          // Pengiriman kode sungguhan dikerjakan nanti; di prototype kembali ke Masuk.
          TombolUtama(label: 'Kirim Kode', onTap: () => context.go(Rute.masuk)),
          TombolGaris(label: 'Kembali ke Masuk', onTap: () => context.go(Rute.masuk)),
        ],
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: _bawahTambahan,
        children: [
          KotakKaca(
            radius: 19,
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color(0x2E2A7A52), shape: BoxShape.circle), // 18%
                  child: Text('?', style: AppText.gaya(21, FontWeight.w800, AppColors.hijauAktif, tinggi: 1.35)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Masukkan nomor HP yang terdaftar. Kode 6 angka akan dikirim lewat SMS/WhatsApp.',
                    style: AppText.gaya(14, FontWeight.w500, const Color(0xCC0F1F19), tinggi: 1.35),
                  ),
                ),
              ],
            ),
          ),
          // Ikon kalender mengikuti Figma.
          IsianKaca(label: 'Nomor HP', ikon: Ikon.calendar, controller: _nomor, keyboardType: TextInputType.phone),
          KotakKaca(
            radius: 19,
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Masukkan kode', style: AppText.tebal14),
                const SizedBox(height: 10),
                // Kotak kode: mengetuk membuka isian tersembunyi.
                GestureDetector(
                  onTap: () => _fokusKode.requestFocus(),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          for (var i = 0; i < 6; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            _KotakKode(angka: i < kode.length ? kode[i] : ''),
                          ],
                        ],
                      ),
                      Opacity(
                        opacity: 0,
                        child: SizedBox(
                          width: 1,
                          height: 1,
                          child: TextField(
                            controller: _kode,
                            focusNode: _fokusKode,
                            maxLength: 6,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _sisaDetik > 0
                      ? 'Kirim ulang kode dalam 00:${_sisaDetik.toString().padLeft(2, '0')}'
                      : 'Kirim ulang kode',
                  style: AppText.gaya(13, FontWeight.w600, AppColors.hijauAktif, tinggi: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KotakKode extends StatelessWidget {
  const _KotakKode({required this.angka});

  final String angka;

  @override
  Widget build(BuildContext context) {
    final terisi = angka.isNotEmpty;
    return Container(
      width: 46,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xE6FFFFFF), // putih 90%
        borderRadius: BorderRadius.circular(14),
        border: terisi
            ? Border.all(color: AppColors.hijauAktif, width: 2)
            : Border.all(color: const Color(0x260F1F19)), // 15%
      ),
      child: Text(angka, style: AppText.gaya(19, FontWeight.w800, AppColors.teksUtama, tinggi: 1.35)),
    );
  }
}

// ---------------------------------------------------------------------------
// M23 Ubah Kata Sandi

class UbahSandiScreen extends StatefulWidget {
  const UbahSandiScreen({super.key});

  @override
  State<UbahSandiScreen> createState() => _UbahSandiScreenState();
}

class _UbahSandiScreenState extends State<UbahSandiScreen> {
  late final AppStore _store = context.read<AppStore>();
  // Data contoh: isian seperti di Figma (kolom terakhir belum sama).
  late final _lama = TextEditingController(text: _store.dataContoh ? SampleData.kataSandi : '');
  late final _baru = TextEditingController(text: _store.dataContoh ? 'panen20261' : '');
  late final _ulang = TextEditingController(text: _store.dataContoh ? 'panen20262' : '');
  bool _sibuk = false;
  String? _galatLama;

  @override
  void initState() {
    super.initState();
    for (final c in [_baru, _ulang]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _lama.dispose();
    _baru.dispose();
    _ulang.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    setState(() => _sibuk = true);
    final berhasil = await _store.ubahSandi(_lama.text, _baru.text);
    if (!mounted) return;
    setState(() {
      _sibuk = false;
      _galatLama = berhasil ? null : 'Kata sandi lama salah';
    });
    if (!berhasil) return;
    await tampilkanBerhasil(context, 'Kata sandi diganti');
    if (mounted) context.kembali();
  }

  @override
  Widget build(BuildContext context) {
    final syarat = [
      ('Minimal 8 huruf/angka', _baru.text.length >= 8),
      ('Ada angkanya', _baru.text.contains(RegExp(r'[0-9]'))),
      ('Sama dengan kolom di atas', _baru.text.isNotEmpty && _baru.text == _ulang.text),
    ];
    final semuaTerpenuhi = syarat.every((s) => s.$2);

    return KerangkaHalaman(
      header: const HeaderRingkas(judul: 'Ubah Kata Sandi', keterangan: 'Jaga akun tetap aman', kiri: TombolKembali()),
      bilahBawah: BilahTombol(
        tombol: [
          TombolUtama(
            label: _sibuk ? 'Menyimpan…' : 'Simpan Kata Sandi',
            onTap: semuaTerpenuhi && !_sibuk ? _simpan : () {},
          ),
          TombolGaris(label: 'Batal', onTap: () => context.kembali()),
        ],
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: _bawahTambahan,
        children: [
          // Ikon kalender mengikuti Figma.
          IsianKaca(
            label: 'Kata sandi lama',
            ikon: Ikon.calendar,
            controller: _lama,
            sembunyikanTeks: true,
            galat: _galatLama,
          ),
          IsianKaca(label: 'Kata sandi baru', ikon: Ikon.calendar, controller: _baru, sembunyikanTeks: true),
          IsianKaca(label: 'Ulangi kata sandi baru', ikon: Ikon.calendar, controller: _ulang, sembunyikanTeks: true),
          KotakKaca(
            radius: 19,
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Syarat kata sandi', style: AppText.tebal14),
                for (final (teks, ok) in syarat) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${ok ? '✓' : '○'}  $teks',
                    style: AppText.gaya(
                      14,
                      FontWeight.w600,
                      ok ? AppColors.hijauAktif : const Color(0x990F1F19),
                      tinggi: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M30 Pengaturan

class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  /// Mengirim salinan file database lewat lembar bagikan (simpan ke Files/Drive atau kirim ke HP lain).
  static Future<void> _cadangkan(AppStore store) async {
    final isi = await store.dataCadangan();
    if (isi == null) return;
    final nama = 'maju-tani-cadangan-${DateTime.now().toIso8601String().substring(0, 10)}.db';
    final hasil = await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(isi, name: nama, mimeType: 'application/vnd.sqlite3')],
        fileNameOverrides: [nama],
        subject: 'Cadangan Maju Tani',
      ),
    );
    if (hasil.status != ShareResultStatus.dismissed) store.tandaiDicadangkan();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final baris = <(String, String, VoidCallback?)>[
      ('Pengingat lengkapi harga', 'Notifikasi tiap sore', null),
      (
        'Cadangkan data',
        switch (store.terakhirDicadangkan) {
          final d? => 'Terakhir: ${Format.tanggalSingkat(d)}',
          null => 'Belum pernah',
        },
        () => _cadangkan(store),
      ),
      ('Ubah kata sandi', 'Jaga akun tetap aman', () => context.push(Rute.ubahSandi)),
      ('Cetak & unduh laporan', 'PDF atau Excel', () => context.push(Rute.cetakLaporan)),
    ];

    return KerangkaHalaman(
      header: const HeaderRingkas(judul: 'Pengaturan', keterangan: 'Sesuaikan aplikasi', kiri: TombolKembali()),
      bilahBawah: BilahTombol(
        tombol: [TombolUtama(label: 'Simpan Pengaturan', onTap: () => context.kembali())],
      ),
      isi: IsiFormulir(
        tepi: 14,
        jarak: 11,
        bawah: _bawahTambahan,
        children: [
          KotakKaca(
            radius: 19,
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ukuran huruf', style: AppText.tebal14),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (u, teks) in [
                      (UkuranHuruf.sedang, 'Sedang'),
                      (UkuranHuruf.besar, 'Besar'),
                      (UkuranHuruf.sangatBesar, 'Sangat besar'),
                    ])
                      ChipPil(teks: teks, aktif: store.ukuranHuruf == u, onTap: () => store.aturUkuranHuruf(u)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Ukuran tampilan', style: AppText.tebal14),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final u in UkuranTampilan.values)
                      ChipPil(
                        teks: u.label,
                        aktif: store.ukuranTampilan == u,
                        onTap: () => store.aturUkuranTampilan(u),
                      ),
                  ],
                ),
              ],
            ),
          ),
          KotakKaca(
            radius: 19,
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, (judul, ket, aksi)) in baris.indexed) ...[
                  if (i > 0) const SizedBox(height: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: aksi,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(judul, style: AppText.tebal14),
                              Text(ket, style: AppText.sedang13Samar),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('›', style: AppText.gaya(19, FontWeight.w700, const Color(0x800F1F19), tinggi: 1.35)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
