import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';

/// Lingkaran centang besar di layar "berhasil" (M08, M14, M27).
/// Saat muncul: lingkaran memantul masuk, riak menyebar, centang tergambar, dan HP bergetar halus.
class LingkaranSukses extends StatefulWidget {
  const LingkaranSukses({
    super.key,
    this.warnaDalam = AppColors.headerTengah,
    this.ukuranCentang = 45,
    this.tebalCentang = 2,
  });

  final Color warnaDalam;
  final double ukuranCentang;
  final double tebalCentang;

  @override
  State<LingkaranSukses> createState() => _LingkaranSuksesState();
}

class _LingkaranSuksesState extends State<LingkaranSukses> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  late final _luar = CurvedAnimation(
    parent: _c,
    curve: const Interval(0, 0.45, curve: Curves.easeOutBack),
  );
  late final _dalam = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.12, 0.6, curve: Curves.elasticOut),
  );
  late final _centang = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.4, 0.75, curve: Curves.easeOutCubic),
  );
  late final _riak = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.35, 1, curve: Curves.easeOut),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.isAnimating || _c.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
      return;
    }
    _c.forward();
    // Getar saat centang mulai tergambar (di web diabaikan).
    Future.delayed(const Duration(milliseconds: 480), () {
      if (mounted) HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 112,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Riak: cincin tipis yang membesar lalu hilang.
            if (_riak.value > 0 && _riak.value < 1)
              Transform.scale(
                scale: 1 + 0.55 * _riak.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.hijau.withValues(alpha: 0.45 * (1 - _riak.value)), width: 2),
                  ),
                ),
              ),
            Transform.scale(
              scale: 0.6 + 0.4 * _luar.value,
              child: Opacity(
                opacity: _luar.value.clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x739CE8BF), // 45%
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xB3FFFFFF)), // putih 70%
                  ),
                ),
              ),
            ),
            Transform.scale(
              scale: _dalam.value,
              child: Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.warnaDalam,
                  shape: BoxShape.circle,
                  boxShadow: [AppShadows.figma(const Color(0x4D0D4026), y: 10, blur: 24, spread: -6)],
                ),
                child: CustomPaint(
                  size: Size.square(widget.ukuranCentang),
                  painter: _CentangPainter(_centang.value, widget.tebalCentang),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centang (bentuk sama dengan ikon check.svg, 24 × 24) yang tergambar sebagian sesuai [progres].
class _CentangPainter extends CustomPainter {
  const _CentangPainter(this.progres, this.tebal);

  final double progres;
  final double tebal;

  @override
  void paint(Canvas canvas, Size size) {
    if (progres <= 0) return;
    final s = size.width / 24;
    final jalur = Path()
      ..moveTo(4 * s, 12 * s)
      ..lineTo(9 * s, 17 * s)
      ..lineTo(20 * s, 6 * s);
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = tebal
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final m = jalur.computeMetrics().first;
    canvas.drawPath(m.extractPath(0, m.length * progres), paint);
  }

  @override
  bool shouldRepaint(_CentangPainter old) => old.progres != progres || old.tebal != tebal;
}

/// Layar berhasil singkat untuk aktivitas pendukung (ubah data, tambah sayur, ubah kata sandi):
/// lingkaran centang beranimasi + satu kalimat, lalu tertutup sendiri. Ketuk di mana saja untuk menutup lebih cepat.
/// Selesai (Future) setelah layar tertutup, jadi pemanggil bisa lanjut pindah halaman.
Future<void> tampilkanBerhasil(BuildContext context, String judul) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: judul,
  barrierColor: const Color(0x00000000),
  transitionDuration: const Duration(milliseconds: 220),
  transitionBuilder: (context, animasi, _, child) => FadeTransition(
    opacity: CurvedAnimation(parent: animasi, curve: Curves.easeOut),
    child: child,
  ),
  pageBuilder: (context, _, _) => _LayarBerhasil(judul: judul),
);

class _LayarBerhasil extends StatefulWidget {
  const _LayarBerhasil({required this.judul});

  final String judul;

  static const lama = Duration(milliseconds: 1600);

  @override
  State<_LayarBerhasil> createState() => _LayarBerhasilState();
}

class _LayarBerhasilState extends State<_LayarBerhasil> {
  late final Timer _waktu;
  var _tertutup = false;

  @override
  void initState() {
    super.initState();
    _waktu = Timer(_LayarBerhasil.lama, _tutup);
  }

  void _tutup() {
    if (_tertutup || !mounted) return;
    _tertutup = true;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _waktu.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tutup,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: ColoredBox(
            color: const Color(0xD9EEF7F1), // hijau sangat muda 85%
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LingkaranSukses(),
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Text(widget.judul, style: AppText.judulSukses, textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
