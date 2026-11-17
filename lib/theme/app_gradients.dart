import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Gradien linear seperti di Figma.
///
/// Figma menyimpan gradien dalam ruang kotak ternormalisasi (0..1), lalu
/// meregangkannya ke ukuran kotak. Pada kotak yang tidak persegi, hasilnya
/// berbeda dari [LinearGradient] Flutter, jadi kelas ini meniru cara Figma.
class GradienFigma extends Gradient {
  const GradienFigma({required this.awal, required this.akhir, required super.colors, super.stops});

  /// Titik awal & akhir dalam ruang kotak (0..1), dari handle gradien Figma.
  final Offset awal;
  final Offset akhir;

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    final regang = Matrix4.identity()
      ..setEntry(0, 0, rect.width)
      ..setEntry(1, 1, rect.height)
      ..setEntry(0, 3, rect.left)
      ..setEntry(1, 3, rect.top);
    return ui.Gradient.linear(awal, akhir, colors, stops, TileMode.clamp, regang.storage);
  }

  @override
  GradienFigma scale(double factor) => withOpacity(factor);

  @override
  GradienFigma withOpacity(double opacity) => GradienFigma(
    awal: awal,
    akhir: akhir,
    colors: [for (final c in colors) c.withValues(alpha: c.a * opacity)],
    stops: stops,
  );
}

abstract final class AppGradien {
  // Handle diagonal yang paling sering dipakai di Figma: (0,071; 0,071) → (0,786; 0,786).
  static const _awal = Offset(0.0714, 0.0714);
  static const _akhir = Offset(0.7857, 0.7857);

  /// Garis tepi kartu kaca: putih 95% di atas → 35% di bawah.
  static const garisKaca = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xF2FFFFFF), Color(0x59FFFFFF)],
  );

  /// Garis tepi kotak ikon judul: putih 100% → 40%.
  /// Tombol utama (M01 dan layar formulir lain).
  static const tombolUtama = GradienFigma(
    awal: _awal,
    akhir: _akhir,
    colors: [AppColors.tombolAwal, AppColors.tombolAkhir],
  );

  /// Tombol bulat Catat Panen & lencana perubahan harga.
  static const hijauBulat = GradienFigma(awal: _awal, akhir: _akhir, colors: [AppColors.hijau, AppColors.hijauTua]);

  /// Header "Sambutan" di M01.
  static const sambutan = GradienFigma(
    awal: _awal,
    akhir: _akhir,
    colors: [AppColors.headerAwal, AppColors.headerTengah, AppColors.headerAkhir],
    stops: [0, 0.6, 1],
  );
}
