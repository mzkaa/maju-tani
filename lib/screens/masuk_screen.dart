import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/kata_sandi.dart';
import '../data/sample_data.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_layout.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/isian_kaca.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/latar_halaman.dart';
import '../widgets/logo_merek.dart';
import '../widgets/tombol.dart';

/// M01 Masuk.
///
/// Saat aplikasi baru dipasang (belum ada akun), layar ini dipakai untuk
/// membuat akun pemilik. Data contoh: isian terisi akun contoh seperti di Figma.
class MasukScreen extends StatefulWidget {
  const MasukScreen({super.key});

  @override
  State<MasukScreen> createState() => _MasukScreenState();
}

class _MasukScreenState extends State<MasukScreen> {
  late final AppStore _store = context.read<AppStore>();
  late final _nama = TextEditingController(text: _store.namaPengguna ?? '');
  late final _sandi = TextEditingController(text: _store.dataContoh ? SampleData.kataSandi : '');
  /// Mode Buat Akun. Bisa dipindah ke Masuk (dan sebaliknya) selama belum ada akun di perangkat ini.
  late bool _akunBaru = !_store.punyaAkun;
  bool _sandiTerlihat = false;
  bool _sibuk = false;
  String? _galatNama;
  String? _galatSandi;

  @override
  void dispose() {
    _nama.dispose();
    _sandi.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    if (_sibuk) return;
    FocusScope.of(context).unfocus();
    final nama = _nama.text.trim();
    final sandi = _sandi.text;
    setState(() {
      _galatNama = nama.isEmpty ? 'Isi nama pengguna' : null;
      _galatSandi = _akunBaru && !KataSandi.cukupKuat(sandi)
          ? 'Minimal 8 huruf/angka dan ada angkanya'
          : (sandi.isEmpty ? 'Isi kata sandi' : null);
    });
    if (_galatNama != null || _galatSandi != null) return;

    setState(() => _sibuk = true);
    var berhasil = true;
    if (_akunBaru) {
      await _store.buatAkun(nama, sandi);
    } else {
      berhasil = await _store.masuk(nama, sandi);
    }
    if (!mounted) return;
    setState(() {
      _sibuk = false;
      _galatSandi = berhasil
          ? null
          : (_store.punyaAkun ? 'Nama pengguna atau kata sandi salah' : 'Belum ada akun di perangkat ini. Buat akun dulu.');
    });
    if (berhasil) context.go(Rute.beranda);
  }

  @override
  Widget build(BuildContext context) {
    final kanan = MediaQuery.sizeOf(context).width - 390;
    final atas = AppLayout.ekstraAtas(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.latarBawah,
        body: Stack(
          children: [
            const Positioned.fill(child: LatarGradien()),
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ...gumpalanStandar(kanan: kanan, atas: atas),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Sambutan(
                        kanan: kanan,
                        atas: atas,
                        keterangan: _akunBaru
                            ? 'Buat akun dulu untuk mulai mencatat panen dan penjualan sayur.'
                            : 'Masuk untuk mencatat panen dan penjualan sayur.',
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(17, 20, 17, 17),
                        child: AutofillGroup(child: _formulir()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formulir() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IsianKaca(
          label: 'Nama pengguna',
          ikon: Ikon.user,
          controller: _nama,
          galat: _galatNama,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
        ),
        const SizedBox(height: 14),
        IsianKaca(
          label: 'Kata sandi',
          ikon: Ikon.lock,
          controller: _sandi,
          sembunyikanTeks: !_sandiTerlihat,
          galat: _galatSandi,
          textInputAction: TextInputAction.done,
          autofillHints: [_akunBaru ? AutofillHints.newPassword : AutofillHints.password],
          onSubmitted: (_) => _masuk(),
          // Teks "Sembunyikan" tidak ada di Figma (desain hanya menampilkan "Lihat").
          akhiran: AkhiranTombol(
            teks: _sandiTerlihat ? 'Sembunyikan' : 'Lihat',
            onTap: () => setState(() => _sandiTerlihat = !_sandiTerlihat),
          ),
          bantuan: _akunBaru
              ? 'Minimal 8 huruf/angka dan ada angkanya'
              : 'Tekan "Lihat" untuk menampilkan kata sandi',
        ),
        const SizedBox(height: 14),
        TombolUtama(
          label: _sibuk ? 'Memeriksa…' : (_akunBaru ? 'Buat Akun' : 'Masuk'),
          ikon: Ikon.arrowRight,
          onTap: _masuk,
        ),
        if (!_store.punyaAkun) ...[const SizedBox(height: 4), _pindahMode()],
        const SizedBox(height: 14),
        if (_akunBaru)
          _kotakInfo(
            Ikon.info,
            'Belum ada akun di perangkat ini. Akun cukup dibuat sekali; '
            'berikutnya kamu tinggal Masuk dengan nama pengguna dan kata sandi ini.',
          )
        else
          _kotakInfo(
            Ikon.phone,
            'Lupa kata sandi? Hubungi tim pengembang lewat WhatsApp.',
            onTap: _lupaSandi,
          ),
      ],
    );
  }

  /// Layar M22 (kirim kode lewat SMS) butuh server, jadi hanya dibuka untuk data contoh.
  void _lupaSandi() {
    if (_store.dataContoh) {
      context.push(Rute.lupaSandi);
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lupa kata sandi'),
        content: const Text(
          'Akun dan data tersimpan di perangkat ini, jadi kata sandi belum bisa diatur ulang lewat SMS/WhatsApp. '
          'Hubungi tim pengembang untuk bantuan.',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
      ),
    );
  }

  /// "Sudah punya akun? Masuk" / "Belum punya akun? Buat akun".
  Widget _pindahMode() {
    final (tanya, aksi) = _akunBaru ? ('Sudah punya akun?', 'Masuk') : ('Belum punya akun?', 'Buat akun');
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() {
          _akunBaru = !_akunBaru;
          _galatNama = null;
          _galatSandi = null;
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text.rich(
            TextSpan(
              text: '$tanya ',
              children: [
                TextSpan(
                  text: aksi,
                  style: AppText.pesanBantuan.copyWith(fontWeight: FontWeight.w800, color: AppColors.hijauTuaAlt),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppText.pesanBantuan,
          ),
        ),
      ),
    );
  }

  Widget _kotakInfo(Ikon ikon, String teks, {VoidCallback? onTap}) {
    return KotakKaca(
      radius: 16,
      padding: const EdgeInsets.all(12),
      warna: const Color(0x80FFFFFF), // putih 50%
      warnaGaris: const Color(0xD9FFFFFF), // putih 85%
      bayangan: const [],
      sorotan: null,
      kaburKaca: 16,
      onTap: onTap,
      child: Row(
        children: [
          AppIcon(ikon, size: 24, color: AppColors.hijauTuaAlt),
          const SizedBox(width: 10),
          Expanded(child: Text(teks, style: AppText.pesanBantuan)),
        ],
      ),
    );
  }
}

/// Header hijau "Sambutan": logo, judul, dan keterangan.
class _Sambutan extends StatelessWidget {
  const _Sambutan({required this.kanan, required this.atas, required this.keterangan});

  final double kanan;
  final double atas;
  final String keterangan;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradien.sambutan),
        child: Stack(
          children: [
            Positioned(
              left: 320 + kanan,
              top: 120 + atas,
              child: const _Lingkaran(ukuran: 120, warna: Color(0x0FFFFFFF)),
            ),
            Positioned(
              left: 250 + kanan,
              top: -60 + atas,
              child: const _Lingkaran(ukuran: 200, warna: Color(0x14FFFFFF)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(17, 58 + atas, 17, 29),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LogoMerek(),
                  const SizedBox(height: 11),
                  Text('Selamat datang', style: AppText.sambutanJudul),
                  const SizedBox(height: 11),
                  Text(keterangan, style: AppText.sambutanIsi),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Lingkaran extends StatelessWidget {
  const _Lingkaran({required this.ukuran, required this.warna});

  final double ukuran;
  final Color warna;

  @override
  Widget build(BuildContext context) => Container(
    width: ukuran,
    height: ukuran,
    decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
  );
}
