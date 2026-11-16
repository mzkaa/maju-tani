import 'package:flutter/painting.dart';

/// Bayangan dari Figma.
///
/// Figma memakai radius blur ala CSS (sigma = radius / 2), sedangkan Flutter
/// mengubah `blurRadius` menjadi sigma = r × 0,57735 + 0,5. Fungsi [figma]
/// mengonversinya supaya ukuran bayangan sama dengan di Figma.
abstract final class AppShadows {
  static BoxShadow figma(Color color, {double x = 0, double y = 0, double blur = 0, double spread = 0}) {
    final sigma = blur / 2;
    final blurRadius = sigma <= 0.5 ? 0.0 : (sigma - 0.5) / 0.57735;
    return BoxShadow(color: color, offset: Offset(x, y), blurRadius: blurRadius, spreadRadius: spread);
  }

  // Warna dasar bayangan kartu: rgb(16,47,34)
  static const _hijauGelap = Color(0xFF102F22);

  /// Bayangan kartu kaca (dua lapis).
  static final kartu = [
    figma(_hijauGelap.withValues(alpha: 0.10), y: 18, blur: 44, spread: -10),
    figma(_hijauGelap.withValues(alpha: 0.05), y: 6, blur: 16, spread: -6),
  ];

  /// Bayangan pil kaca nav bawah (sedikit lebih kuat).
  static final nav = [
    figma(_hijauGelap.withValues(alpha: 0.14), y: 18, blur: 44, spread: -10),
    figma(_hijauGelap.withValues(alpha: 0.06), y: 6, blur: 16, spread: -6),
  ];

  /// Bayangan chip kecil & tombol "Lihat semua".
  static final chip = [figma(_hijauGelap.withValues(alpha: 0.06), y: 8, blur: 20, spread: -6)];

  /// Bayangan kotak ikon judul seksi.
  static final ikonJudul = [figma(_hijauGelap.withValues(alpha: 0.10), y: 10, blur: 24, spread: -6)];

  /// Bayangan tombol bulat Catat Panen.
  static final tombolBulat = [figma(const Color(0x4711452E), y: 14, blur: 30, spread: -6)];
}
