import 'package:flutter/rendering.dart';

/// Bayangan dalam (inner shadow) seperti efek "Inner shadow" di Figma.
///
/// Dipakai untuk garis cahaya putih tipis di tepi atas kartu kaca
/// (y 1, blur 0) dan kilau di tombol bulat (y 2, blur 3).
class SorotanDalam extends CustomPainter {
  const SorotanDalam({required this.radius, required this.color, this.dy = 1, this.blur = 0});

  final BorderRadius radius;
  final Color color;
  final double dy;
  final double blur;

  @override
  void paint(Canvas canvas, Size size) {
    final bentuk = radius.toRRect(Offset.zero & size);
    canvas.save();
    canvas.clipRRect(bentuk);
    // Area di luar bentuk yang digeser; bagian yang masuk ke bentuk menjadi bayangan.
    final luar = Path()..addRect((Offset.zero & size).inflate(blur * 2 + dy.abs() + 4));
    final lubang = Path()..addRRect(bentuk.shift(Offset(0, dy)));
    final paint = Paint()..color = color;
    if (blur > 0) paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur / 2);
    canvas.drawPath(Path.combine(PathOperation.difference, luar, lubang), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(SorotanDalam old) =>
      old.radius != radius || old.color != color || old.dy != dy || old.blur != blur;
}
