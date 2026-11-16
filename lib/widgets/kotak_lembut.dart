import 'package:flutter/widgets.dart';

import 'kotak_kaca.dart';

/// Kotak putih 50% dengan garis putih 85% dan blur latar 16, tanpa bayangan.
/// Dipakai untuk catatan, bantuan, batang progres, dan isian otomatis.
class KotakLembut extends StatelessWidget {
  const KotakLembut({super.key, required this.child, this.radius = 16, this.padding = EdgeInsets.zero, this.onTap});

  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return KotakKaca(
      radius: radius,
      padding: padding,
      warna: const Color(0x80FFFFFF), // putih 50%
      warnaGaris: const Color(0xD9FFFFFF), // putih 85%
      bayangan: const [],
      sorotan: null,
      kaburKaca: 16,
      onTap: onTap,
      child: child,
    );
  }
}
