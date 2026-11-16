import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Penanda langkah formulir (komponen "Langkah V2" di Figma):
/// teks langkah + tiga ruas batang, ruas yang sudah dilewati berwarna hijau.
class IndikatorLangkah extends StatelessWidget {
  const IndikatorLangkah({super.key, required this.langkah, required this.teks, this.jumlah = 3});

  final int langkah;
  final int jumlah;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(teks, style: AppText.langkahTeks),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 1; i <= jumlah; i++) ...[
              if (i > 1) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: i <= langkah ? AppColors.headerTengah : AppColors.garisPemisah,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
