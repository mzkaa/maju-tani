import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Ukuran tata letak dari Figma (frame 390 × 844).
abstract final class AppLayout {
  /// Jarak tepi kiri-kanan isi halaman.
  static const tepi = 20.0;

  /// Area status bar yang sudah dihitung di desain (iPhone 390 × 844).
  static const _atasDesain = 47.0;

  /// Area indikator home yang sudah dihitung di desain.
  static const _bawahDesain = 34.0;

  /// Tambahan jarak atas bila status bar HP lebih tinggi dari desain.
  static double ekstraAtas(BuildContext context) => math.max(0, MediaQuery.paddingOf(context).top - _atasDesain);

  /// Tambahan jarak bawah bila area home HP lebih tinggi dari desain.
  static double ekstraBawah(BuildContext context) => math.max(0, MediaQuery.paddingOf(context).bottom - _bawahDesain);
}
