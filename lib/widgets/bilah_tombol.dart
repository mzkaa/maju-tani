import 'package:flutter/widgets.dart';

import '../theme/app_layout.dart';
import '../theme/app_shadows.dart';
import 'kotak_kaca.dart';

/// Bilah kaca tetap di bawah layar berisi satu atau dua tombol.
class BilahTombol extends StatelessWidget {
  const BilahTombol({super.key, required this.tombol});

  final List<Widget> tombol;

  /// Tinggi bilah di Figma: 81 untuk satu tombol, 140 untuk dua tombol.
  static double tinggi(int jumlahTombol) => jumlahTombol == 1 ? 81 : 140;

  @override
  Widget build(BuildContext context) {
    return KotakKaca(
      radius: 24,
      sudutBawahDatar: true,
      padding: EdgeInsets.fromLTRB(17, 12, 17, 20 + AppLayout.ekstraBawah(context)),
      warna: const Color(0x99FFFFFF), // putih 60%
      bayangan: [AppShadows.figma(const Color(0x1A0D3824), y: -10, blur: 30, spread: -6)],
      sorotan: null,
      kaburKaca: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, t) in tombol.indexed) ...[if (i > 0) const SizedBox(height: 12), t],
        ],
      ),
    );
  }
}
