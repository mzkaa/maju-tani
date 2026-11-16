import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Cincin persen uang masuk (hijau = sudah masuk, oranye = belum dibayar).
/// Ukuran 112, tebal cincin 12% dari ukuran, seperti di Figma.
class CincinPersen extends StatelessWidget {
  const CincinPersen({super.key, required this.persen});

  /// 0..1
  final double persen;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 112,
      child: CustomPaint(
        painter: _CincinPainter(persen.clamp(0, 1)),
        // Di Figma label persen sedikit bergeser dari tengah (4 px ke kiri, 2,5 px ke atas).
        child: Center(
          child: Transform.translate(
            offset: const Offset(-4, -2.5),
            child: Text('${(persen * 100).round()}%', style: AppText.persen),
          ),
        ),
      ),
    );
  }
}

class _CincinPainter extends CustomPainter {
  const _CincinPainter(this.persen);

  final double persen;

  // Celah antara busur hijau dan oranye (dari Figma, ±4,6°).
  static const _celah = 4.6 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final tebal = size.width * 0.12;
    final pusat = size.center(Offset.zero);
    final r = size.width / 2 - tebal / 2;
    final kotak = Rect.fromCircle(center: pusat, radius: r);

    // Lintasan putih 80% dengan bayangan dalam tipis.
    final luar = Path()..addOval(Offset.zero & size);
    final dalam = Path()..addOval(Rect.fromCircle(center: pusat, radius: size.width / 2 - tebal));
    final cincin = Path.combine(PathOperation.difference, luar, dalam);
    canvas.drawPath(cincin, Paint()..color = const Color(0xCCFFFFFF));
    canvas.save();
    canvas.clipPath(cincin);
    final bayanganDalam = Path.combine(
      PathOperation.difference,
      Path()..addRect((Offset.zero & size).inflate(8)),
      cincin.shift(const Offset(0, 1)),
    );
    canvas.drawPath(
      bayanganDalam,
      Paint()
        ..color =
            const Color(0x1F0B291A) // 12%
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    canvas.restore();

    const mulai = -math.pi / 2;
    final sapuanHijau = persen * 2 * math.pi;
    final garis = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = tebal
      ..strokeCap = StrokeCap.butt;

    // Busur oranye: sisa lingkaran dikurangi celah di kedua ujung.
    final sapuanOranye = 2 * math.pi - sapuanHijau - 2 * _celah;
    if (sapuanOranye > 0) {
      canvas.drawArc(
        kotak,
        mulai + sapuanHijau + _celah,
        sapuanOranye,
        false,
        Paint.from(garis)..color = AppColors.oranyeGaris,
      );
    }

    if (sapuanHijau > 0) {
      // Bayangan busur hijau (y 3, blur 8, hijau 35%).
      canvas.drawArc(
        kotak.shift(const Offset(0, 3)),
        mulai,
        sapuanHijau,
        false,
        Paint.from(garis)
          ..color = const Color(0x59327C53)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      final s = size.width / 112;
      canvas.drawArc(
        kotak,
        mulai,
        sapuanHijau,
        false,
        Paint.from(garis)
          ..shader = ui.Gradient.linear(Offset(8 * s, 8 * s), Offset(88 * s, 88 * s), const [
            AppColors.hijau,
            AppColors.hijauTua,
          ]),
      );
    }
  }

  @override
  bool shouldRepaint(_CincinPainter old) => old.persen != persen;
}
