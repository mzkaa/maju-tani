import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// Header hijau melengkung di atas layar (tetap, tidak ikut digulir).
///
/// Lebar desain 390. Tinggi desain 127,5; bila status bar HP lebih tinggi
/// dari desain, header ikut memanjang sebesar [ekstraAtas].
class HeaderHijau extends StatelessWidget {
  const HeaderHijau({super.key, this.tinggi = 127.5, this.ekstraAtas = 0, this.bayangan = false, required this.child});

  final double tinggi;
  final double ekstraAtas;

  /// Bayangan di bawah header ("Header ringkas" M03–M30; Beranda tanpa bayangan).
  final bool bayangan;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final lebar = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: tinggi + ekstraAtas,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: _BentukHeader(ekstraAtas, bayangan))),
          // Daun hiasan (18%): di Figma tidak ikut terpotong bentuk header.
          Positioned(
            left: lebar - 390,
            top: -52 + ekstraAtas,
            child: IgnorePointer(child: SvgPicture.asset('assets/images/daun_hiasan.svg', width: 412, height: 179.5)),
          ),
          Positioned.fill(top: ekstraAtas, child: child),
        ],
      ),
    );
  }
}

class _BentukHeader extends CustomPainter {
  const _BentukHeader(this.ekstraAtas, this.bayangan);

  final double ekstraAtas;
  final bool bayangan;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final bentuk = RRect.fromRectAndCorners(
      Offset.zero & size,
      bottomLeft: const Radius.circular(36),
      bottomRight: const Radius.circular(36),
    );
    if (bayangan) {
      // Drop shadow Figma: #0D261A 18%, y 10, blur 30, spread −8.
      canvas.drawRRect(
        bentuk.deflate(8).shift(const Offset(0, 10)),
        Paint()
          ..color = const Color(0x2E0D261A)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }
    canvas.save();
    canvas.clipRRect(bentuk);

    // Gradien linear dengan titik awal & akhir persis seperti di Figma.
    final sx = w / 390;
    final gradien = Paint()
      ..shader = ui.Gradient.linear(
        Offset(27.8571 * sx, 18.7143 + ekstraAtas),
        Offset(201.11 * sx, 276.61 + ekstraAtas),
        const [AppColors.headerAwal, AppColors.headerTengah, AppColors.headerAkhir],
        const [0, 0.6, 1],
      );
    canvas.drawRRect(bentuk, gradien);

    // Lingkaran putih 8% di kanan atas.
    canvas.drawCircle(Offset(w - 40, 40 + ekstraAtas), 100, Paint()..color = const Color(0x14FFFFFF));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BentukHeader old) => old.ekstraAtas != ekstraAtas || old.bayangan != bayangan;
}
