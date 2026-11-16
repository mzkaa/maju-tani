import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

/// Gradien latar halaman (tetap, tidak ikut digulir).
class LatarGradien extends StatelessWidget {
  const LatarGradien({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.latarAtas, AppColors.latarTengah, AppColors.latarBawah],
        ),
      ),
    );
  }
}

/// Satu "gumpalan warna" buram di latar (lingkaran + layer blur di Figma).
class Gumpalan extends StatelessWidget {
  const Gumpalan({super.key, required this.ukuran, required this.warna, this.blur = 70});

  final double ukuran;
  final Color warna;

  /// Radius layer blur Figma (sigma = blur / 2).
  final double blur;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(size: Size.square(ukuran), painter: _GumpalanPainter(warna, blur / 2)),
    );
  }
}

class _GumpalanPainter extends CustomPainter {
  const _GumpalanPainter(this.warna, this.sigma);

  final Color warna;
  final double sigma;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = warna
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(_GumpalanPainter old) => old.warna != warna || old.sigma != sigma;
}

/// Lima gumpalan warna standar yang ikut digulir (posisi sama di M01, M02, dst.).
/// [kanan] = lebar layar − 390, [atas] = tambahan jarak status bar.
List<Widget> gumpalanStandar({required double kanan, required double atas}) => [
  Positioned(
    left: -80,
    top: 330 + atas,
    child: const Gumpalan(ukuran: 260, warna: AppColors.gumpalanHijau),
  ),
  Positioned(
    left: 230 + kanan,
    top: 520 + atas,
    child: const Gumpalan(ukuran: 240, warna: AppColors.gumpalanLimau),
  ),
  Positioned(
    left: -60,
    top: 860 + atas,
    child: const Gumpalan(ukuran: 280, warna: AppColors.gumpalanToska),
  ),
  Positioned(
    left: 220 + kanan,
    top: 1150 + atas,
    child: const Gumpalan(ukuran: 260, warna: AppColors.gumpalanDaun),
  ),
  Positioned(
    left: -40,
    top: 1450 + atas,
    child: const Gumpalan(ukuran: 280, warna: AppColors.gumpalanKuning),
  ),
];

/// Pudar di bawah layar, di belakang nav bawah (tinggi 220).
class PudarBawah extends StatelessWidget {
  const PudarBawah({super.key});

  static const tinggi = 220.0;

  @override
  Widget build(BuildContext context) {
    final p = AppColors.pudar;
    return IgnorePointer(
      child: Container(
        height: tinggi,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              p.withValues(alpha: 0),
              p.withValues(alpha: 0.12),
              p.withValues(alpha: 0.45),
              p.withValues(alpha: 0.80),
              p.withValues(alpha: 0.97),
            ],
          ),
        ),
      ),
    );
  }
}
