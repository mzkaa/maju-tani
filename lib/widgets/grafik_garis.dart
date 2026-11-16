import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

/// Grafik garis halus dengan area gradien dan titik di nilai terakhir.
/// Tinggi 140 seperti "Grafik" di kartu harga Figma.
class GrafikGaris extends StatelessWidget {
  const GrafikGaris({super.key, required this.nilai});

  final List<int> nilai;

  static const tinggi = 140.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: tinggi,
      width: double.infinity,
      child: CustomPaint(painter: _GrafikPainter(nilai)),
    );
  }
}

class _GrafikPainter extends CustomPainter {
  const _GrafikPainter(this.nilai);

  final List<int> nilai;

  // Posisi dari Figma (lebar grafik 320): garis bantu y 12/70/128,
  // titik data dari x 8 sampai lebar − 18.
  static const _yAtas = 12.0;
  static const _yBawah = 128.0;

  @override
  void paint(Canvas canvas, Size size) {
    _garisBantu(canvas, size);
    if (nilai.length < 2) return;

    // Skala: bawah dibulatkan ke ribuan, atas = nilai tertinggi + 3%.
    final minNilai = (nilai.reduce(math.min) ~/ 1000) * 1000;
    final maxNilai = nilai.reduce(math.max) * 1.03;
    final langkah = (size.width - 26) / (nilai.length - 1);
    final titik = [
      for (var i = 0; i < nilai.length; i++)
        Offset(8 + i * langkah, _yBawah - (nilai[i] - minNilai) / (maxNilai - minNilai) * (_yBawah - _yAtas)),
    ];

    final garis = _kurvaHalus(titik);

    // Area di bawah garis.
    final yTerendah = titik.map((p) => p.dy).reduce(math.min);
    final area = Path.from(garis)
      ..lineTo(titik.last.dx, size.height)
      ..lineTo(titik.first.dx, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, yTerendah), Offset(0, size.height), [
          const Color(0x52327C53),
          const Color(0x00327C53),
        ]),
    );

    // Garis utama.
    canvas.drawPath(
      garis,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = ui.Gradient.linear(titik.first, Offset(titik.last.dx, titik.first.dy), [
          const Color(0x99327C53),
          AppColors.hijauTua,
        ]),
    );

    // Titik nilai terakhir.
    final akhir = titik.last;
    canvas.drawCircle(akhir, 13, Paint()..color = const Color(0x33327C53));
    canvas.drawCircle(akhir, 6.5, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawCircle(akhir, 3.5, Paint()..color = AppColors.hijauTua);
  }

  /// Kurva Catmull-Rom (tegangan 1/6), sama dengan bentuk vektor di Figma.
  Path _kurvaHalus(List<Offset> p) {
    final path = Path()..moveTo(p[0].dx, p[0].dy);
    for (var i = 0; i < p.length - 1; i++) {
      final p0 = p[math.max(i - 1, 0)];
      final p1 = p[i];
      final p2 = p[i + 1];
      final p3 = p[math.min(i + 2, p.length - 1)];
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  /// Tiga garis putus-putus (4 garis, 6 celah), lebar = lebar grafik − 10.
  void _garisBantu(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.garisGrafik
      ..strokeWidth = 1;
    final lebar = size.width - 10;
    for (final y in const [11.5, 69.5, 127.5]) {
      canvas.drawLine(Offset(0, y), Offset(2, y), paint);
      for (var x = 8.0; x + 4 <= lebar - 6; x += 10) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), paint);
      }
      canvas.drawLine(Offset(lebar - 2, y), Offset(lebar, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GrafikPainter old) => old.nilai != nilai;
}
