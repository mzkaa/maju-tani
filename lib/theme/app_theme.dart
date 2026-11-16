import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

/// Tema aplikasi. Sebagian besar gaya ditulis langsung di komponen
/// (lib/widgets) supaya sama persis dengan Figma.
abstract final class AppTheme {
  static ThemeData get terang => ThemeData(
    useMaterial3: true,
    fontFamily: AppText.font,
    scaffoldBackgroundColor: AppColors.latarBawah,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.hijau, primary: AppColors.hijauTua),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
