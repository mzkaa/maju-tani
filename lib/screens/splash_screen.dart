import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/latar_halaman.dart';

/// M00 Layar Pembuka (Splash). Setelah 1,8 detik pindah ke M01 Masuk,
/// sesuai pengaturan "After delay" di prototype Figma.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _jeda = Duration(milliseconds: 1800);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Hitung jeda sejak splash benar-benar tampil (setelah frame pertama).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timer = Timer(_jeda, () {
        if (mounted) context.go(Rute.masuk);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lebar = MediaQuery.sizeOf(context).width;
    final kanan = lebar - 390; // hiasan kanan menempel ke tepi kanan
    final atas = AppLayout.ekstraAtas(context);
    final bawah = AppLayout.ekstraBawah(context);
    final tengah = lebar / 2;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.splashBawah,
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.splashAtas, AppColors.splashTengah, AppColors.splashBawah],
                    stops: [0, 0.55, 1],
                  ),
                ),
              ),
            ),
            // Cahaya buram (layer blur 90).
            Positioned(
              left: -120,
              top: -80 + atas,
              child: const Gumpalan(ukuran: 340, warna: AppColors.splashGumpalanHijau, blur: 90),
            ),
            Positioned(
              left: 200 + kanan,
              bottom: -76 - bawah,
              child: const Gumpalan(ukuran: 360, warna: AppColors.splashGumpalanTua, blur: 90),
            ),
            Positioned(
              left: 240 + kanan,
              top: 120 + atas,
              child: const Gumpalan(ukuran: 200, warna: AppColors.splashGumpalanKuning, blur: 90),
            ),
            // Dua cincin tipis di belakang logo.
            Positioned(
              left: tengah - 150,
              top: 190 + atas,
              child: const _Cincin(ukuran: 300, warna: Color(0x0FFFFFFF)),
            ),
            Positioned(
              left: tengah - 110,
              top: 230 + atas,
              child: const _Cincin(ukuran: 220, warna: Color(0x1AFFFFFF)),
            ),
            Positioned(left: tengah - 64, top: 276 + atas, child: const _Logo()),
            Positioned(
              left: 0,
              right: 0,
              top: 440 + atas,
              child: Text('Mitra Maju Tani', textAlign: TextAlign.center, style: AppText.splashJudul),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 484 + atas,
              child: Text('Catat panen & penjualan', textAlign: TextAlign.center, style: AppText.splashSub),
            ),
            // Tiga titik; di Figma deretnya bergeser 1 px ke kanan dari tengah.
            Positioned(
              left: tengah - 24,
              bottom: 134 + bawah,
              child: const Row(
                children: [
                  _Titik(warna: AppColors.titikAktif),
                  SizedBox(width: 10),
                  _Titik(warna: Color(0x4DFFFFFF)),
                  SizedBox(width: 10),
                  _Titik(warna: Color(0x4DFFFFFF)),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 48 + bawah,
              child: Text('Versi 1.0', textAlign: TextAlign.center, style: AppText.splashVersi),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 128,
      child: KotakKaca(
        radius: 40,
        gradien: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.logoAwal, AppColors.logoAkhir],
          stops: [0, 0.5],
        ),
        warnaGaris: const Color(0x66FFFFFF), // putih 40%
        tebalGaris: 1.5,
        bayangan: [AppShadows.figma(const Color(0x59000000), y: 24, blur: 48, spread: -8)],
        sorotan: const Color(0x80FFFFFF), // putih 50%
        sorotanDy: 2,
        sorotanBlur: 2,
        kaburKaca: null,
        child: const Center(child: AppIcon(Ikon.leaf, size: 64, color: Color(0xFFFFFFFF), tebal: 5.333)),
      ),
    );
  }
}

class _Cincin extends StatelessWidget {
  const _Cincin({required this.ukuran, required this.warna});

  final double ukuran;
  final Color warna;

  @override
  Widget build(BuildContext context) => Container(
    width: ukuran,
    height: ukuran,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: warna),
    ),
  );
}

class _Titik extends StatelessWidget {
  const _Titik({required this.warna});

  final Color warna;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
  );
}
