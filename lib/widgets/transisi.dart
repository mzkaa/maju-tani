import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Arah perpindahan tab nav bawah: 1 = ke tab di kanan, -1 = ke kiri, 0 = tidak dari nav.
/// Diisi nav saat tab diketuk, lalu dipakai (dan dikosongkan) oleh layar tab yang baru terbuka.
abstract final class ArahTab {
  static int arah = 0;
}

/// Pusat lingkaran transisi Catat Panen: tengah tombol + terakhir diketuk, dalam koordinat Navigator.
/// `null` = tengah bawah layar (letak tombol +).
abstract final class AsalLingkaran {
  static Offset? pusat;
}

/// Isi layar tab yang masuk: meluncur sedikit dari arah tab yang dituju sambil memudar.
/// Nav bawah tidak ikut dibungkus, jadi nav tetap diam dan animasi karetnya menyambung.
/// Saat layar ini ditinggalkan, isinya tidak dianimasikan (layar baru sudah menutupinya).
class MasukTab extends StatefulWidget {
  const MasukTab({super.key, required this.child});

  final Widget child;

  @override
  State<MasukTab> createState() => _MasukTabState();
}

class _MasukTabState extends State<MasukTab> {
  late final int _arah;

  @override
  void initState() {
    super.initState();
    _arah = ArahTab.arah;
    ArahTab.arah = 0;
  }

  @override
  Widget build(BuildContext context) {
    final animasi = ModalRoute.of(context)?.animation;
    if (animasi == null || MediaQuery.disableAnimationsOf(context)) return widget.child;
    final a = CurvedAnimation(parent: animasi, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: a,
      child: widget.child,
      builder: (context, child) {
        if (animasi.status == AnimationStatus.reverse || a.value >= 1) return child!;
        return Opacity(
          opacity: a.value,
          child: Transform.translate(offset: Offset(_arah * 36 * (1 - a.value), 0), child: child),
        );
      },
    );
  }
}

/// Transisi lingkaran menyebar: layar baru terbuka sebagai lingkaran yang membesar dari [AsalLingkaran]
/// sampai menutupi layar; saat kembali, lingkaran menyusut ke titik itu lagi.
Widget transisiLingkaran(BuildContext context, Animation<double> animasi, Widget child) {
  if (MediaQuery.disableAnimationsOf(context)) return child;
  final a = CurvedAnimation(parent: animasi, curve: Curves.easeInOutCubic, reverseCurve: Curves.easeInCubic);
  return AnimatedBuilder(
    animation: a,
    child: child,
    builder: (context, child) {
      if (a.value >= 1) return child!;
      final ukuran = MediaQuery.sizeOf(context);
      final pusat = AsalLingkaran.pusat ?? Offset(ukuran.width / 2, ukuran.height - 60);
      // Jari-jari terjauh = jarak pusat ke sudut layar terjauh.
      final maks = [
        Offset.zero,
        Offset(ukuran.width, 0),
        Offset(0, ukuran.height),
        Offset(ukuran.width, ukuran.height),
      ].map((s) => (s - pusat).distance).reduce(math.max);
      return ClipPath(
        clipper: _PotongLingkaran(pusat, maks * a.value),
        // Isi baru sedikit memudar masuk di awal supaya tepi lingkaran terasa lembut.
        child: Opacity(opacity: Curves.easeOut.transform((a.value * 2.5).clamp(0, 1)), child: child),
      );
    },
  );
}

class _PotongLingkaran extends CustomClipper<Path> {
  const _PotongLingkaran(this.pusat, this.jari);

  final Offset pusat;
  final double jari;

  @override
  Path getClip(Size size) => Path()..addOval(Rect.fromCircle(center: pusat, radius: jari));

  @override
  bool shouldReclip(_PotongLingkaran old) => old.pusat != pusat || old.jari != jari;
}
