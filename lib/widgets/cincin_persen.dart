import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Cincin persen uang yang sudah dibayar: busur hijau di atas lintasan oranye lembut (= belum dibayar).
/// Busur terisi pelan saat tampil dan saat nilainya berubah; angka di tengah selalu nilai akhir.
class CincinPersen extends StatelessWidget {
  const CincinPersen({super.key, required this.persen, this.ukuran = 96});

  /// 0..1
  final double persen;
  final double ukuran;

  @override
  Widget build(BuildContext context) {
    final p = persen.clamp(0.0, 1.0);
    final animasiMati = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      label: '${(p * 100).round()} persen sudah dibayar',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: ukuran,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: p),
          duration: animasiMati ? Duration.zero : const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, nilai, child) => CustomPaint(painter: _CincinPainter(nilai), child: child),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(p * 100).round()}%', style: AppText.persen),
                Text('dibayar', style: AppText.gaya(11, FontWeight.w600, AppColors.teksKeduaAlt, tinggi: 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CincinPainter extends CustomPainter {
  const _CincinPainter(this.persen);

  final double persen;

  @override
  void paint(Canvas canvas, Size size) {
    final tebal = size.width * 0.1;
    final pusat = size.center(Offset.zero);
    final kotak = Rect.fromCircle(center: pusat, radius: size.width / 2 - tebal / 2);
    final garis = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = tebal
      ..strokeCap = StrokeCap.round;

    // Lintasan: sisa yang belum dibayar, oranye lembut.
    canvas.drawArc(
      kotak,
      0,
      2 * math.pi,
      false,
      Paint.from(garis)..color = AppColors.oranyeGaris.withValues(alpha: 0.22),
    );

    if (persen <= 0) return;
    // Putar supaya busur mulai dari atas (jam 12) dan gradien sapu mengikuti busur.
    canvas.save();
    canvas.translate(pusat.dx, pusat.dy);
    canvas.rotate(-math.pi / 2);
    canvas.translate(-pusat.dx, -pusat.dy);
    final sapuan = persen * 2 * math.pi;
    // Bayangan lembut di bawah busur hijau.
    canvas.drawArc(
      kotak,
      0,
      sapuan,
      false,
      Paint.from(garis)
        ..color = const Color(0x40327C53)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawArc(
      kotak,
      0,
      sapuan,
      false,
      Paint.from(garis)
        ..shader = ui.Gradient.sweep(
          pusat,
          const [AppColors.hijau, AppColors.hijauTua],
          null,
          TileMode.clamp,
          0,
          math.max(sapuan, 0.01),
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CincinPainter old) => old.persen != persen;
}
