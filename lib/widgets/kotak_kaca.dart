import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import 'sorotan_dalam.dart';

/// Kotak bergaya kaca: isi putih transparan, garis tepi bergradasi, garis
/// cahaya di tepi atas, bayangan lembut, dan blur latar.
///
/// Catatan: efek "Glass" Figma juga membiaskan (refraksi) latar di tepi
/// kotak. Flutter tidak punya efek itu, jadi di sini diganti blur latar
/// dengan kekuatan yang sama ([kaburKaca] = radius frost di Figma).
class KotakKaca extends StatelessWidget {
  const KotakKaca({
    super.key,
    required this.child,
    required this.radius,
    this.sudutBawahDatar = false,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
    this.warna = const Color(0xADFFFFFF), // putih 68%
    this.gradien,
    this.garis = AppGradien.garisKaca,
    this.warnaGaris,
    this.tebalGaris = 1,
    this.bayangan,
    this.sorotan = const Color(0xB3FFFFFF), // putih 70%, y 1
    this.sorotanDy = 1,
    this.sorotanBlur = 0,
    this.kaburKaca = 10,
    this.onTap,
    this.label,
  });

  final Widget child;
  final double radius;

  /// Hanya sudut atas yang membulat (mis. bilah tombol di bawah layar).
  final bool sudutBawahDatar;

  /// Padding seperti di Figma. Garis tepi ikut dihitung dalam tata letak.
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final Color warna;
  final Gradient? gradien;

  /// Garis tepi bergradasi di bagian dalam kotak. `null` = tanpa garis.
  final Gradient? garis;

  /// Garis tepi satu warna; bila diisi, dipakai menggantikan [garis].
  final Color? warnaGaris;
  final double tebalGaris;

  /// Default: [AppShadows.kartu].
  final List<BoxShadow>? bayangan;
  final Color? sorotan;
  final double sorotanDy;
  final double sorotanBlur;

  /// Radius frost efek Glass Figma. `null` = tanpa blur latar.
  final double? kaburKaca;
  final VoidCallback? onTap;

  /// Label untuk pembaca layar bila kotak bisa diketuk.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final bulat = sudutBawahDatar ? BorderRadius.vertical(top: Radius.circular(radius)) : BorderRadius.circular(radius);
    final adaGaris = garis != null || warnaGaris != null;
    final tebal = adaGaris ? tebalGaris : 0.0;

    Widget kotak = Container(
      width: width,
      height: height,
      padding: padding + EdgeInsets.all(tebal),
      decoration: BoxDecoration(color: gradien == null ? warna : null, gradient: gradien, borderRadius: bulat),
      child: child,
    );

    if (sorotan != null || adaGaris) {
      kotak = CustomPaint(
        foregroundPainter: _TepiKotak(
          radius: bulat,
          garis: garis,
          warnaGaris: warnaGaris,
          tebalGaris: tebal,
          sorotan: sorotan == null
              ? null
              : SorotanDalam(radius: bulat, color: sorotan!, dy: sorotanDy, blur: sorotanBlur),
        ),
        child: kotak,
      );
    }

    if (kaburKaca != null) {
      final sigma = kaburKaca! / 2;
      kotak = ClipRRect(
        borderRadius: bulat,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: kotak,
        ),
      );
    }

    kotak = DecoratedBox(
      decoration: BoxDecoration(borderRadius: bulat, boxShadow: bayangan ?? AppShadows.kartu),
      child: kotak,
    );

    if (onTap == null) return kotak;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: kotak),
    );
  }
}

/// Menggambar garis cahaya dalam lalu garis tepi (di dalam bentuk, seperti stroke "Inside" Figma).
class _TepiKotak extends CustomPainter {
  const _TepiKotak({
    required this.radius,
    required this.garis,
    required this.warnaGaris,
    required this.tebalGaris,
    required this.sorotan,
  });

  final BorderRadius radius;
  final Gradient? garis;
  final Color? warnaGaris;
  final double tebalGaris;
  final SorotanDalam? sorotan;

  @override
  void paint(Canvas canvas, Size size) {
    sorotan?.paint(canvas, size);
    if ((garis == null && warnaGaris == null) || tebalGaris <= 0) return;
    final kotak = Offset.zero & size;
    final rrect = radius.toRRect(kotak).deflate(tebalGaris / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = tebalGaris;
    if (warnaGaris != null) {
      paint.color = warnaGaris!;
    } else {
      paint.shader = garis!.createShader(kotak);
    }
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_TepiKotak old) =>
      old.radius != radius ||
      old.garis != garis ||
      old.warnaGaris != warnaGaris ||
      old.tebalGaris != tebalGaris ||
      old.sorotan != sorotan;
}
