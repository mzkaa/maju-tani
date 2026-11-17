import 'package:flutter/widgets.dart';

/// Mengecilkan seluruh tampilan (teks, kotak, ikon, jarak) dengan [skala], mis. 0.9 = 10% lebih kecil.
///
/// Layar dilukis pada ukuran logis yang lebih besar ([skala] kali lebih kecil lalu diperkecil),
/// jadi semua tata letak mengikuti dan ketukan tetap tepat sasaran.
/// Padding status bar dan keyboard ikut disesuaikan agar tidak meleset.
class SkalaTampilan extends StatelessWidget {
  const SkalaTampilan({super.key, required this.skala, required this.child});

  final double skala;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (skala == 1) return child;
    final mq = MediaQuery.of(context);
    final besar = mq.size / skala;
    return FittedBox(
      fit: BoxFit.fill,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: besar.width,
        height: besar.height,
        child: MediaQuery(
          data: mq.copyWith(
            size: besar,
            padding: mq.padding / skala,
            viewPadding: mq.viewPadding / skala,
            viewInsets: mq.viewInsets / skala,
            systemGestureInsets: mq.systemGestureInsets / skala,
          ),
          child: child,
        ),
      ),
    );
  }
}
