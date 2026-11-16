import 'package:flutter/widgets.dart';

import '../theme/app_layout.dart';

/// Isi layar formulir di bawah "Header ringkas": jarak atas 128 + 14,
/// tepi 17, jarak antar-bagian [jarak], dan jarak bawah untuk bilah tombol.
class IsiFormulir extends StatelessWidget {
  const IsiFormulir({super.key, required this.bawah, required this.jarak, required this.children, this.tepi = 17});

  /// Jarak bawah isi (agar tidak tertutup bilah tombol).
  final double bawah;
  final double jarak;

  /// Jarak kiri-kanan: 17 di alur utama, 14 di layar tambahan (M15–M30).
  final double tepi;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tepi,
        128 + 14 + AppLayout.ekstraAtas(context),
        tepi,
        17 + bawah + AppLayout.ekstraBawah(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, c) in children.indexed) ...[if (i > 0) SizedBox(height: jarak), c],
        ],
      ),
    );
  }
}
