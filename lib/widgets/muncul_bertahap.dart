import 'package:flutter/widgets.dart';

/// Isi yang muncul pelan dari bawah (pudar + geser naik) setelah [jeda], sekali saat layar dibuka.
/// Dipakai berurutan dengan jeda bertambah supaya layar terasa hidup, bukan langsung "tertempel".
/// Bila animasi dimatikan di pengaturan perangkat, isi langsung tampil.
class MunculBertahap extends StatefulWidget {
  const MunculBertahap({super.key, required this.child, this.jeda = Duration.zero});

  final Widget child;
  final Duration jeda;

  static const durasi = Duration(milliseconds: 420);

  @override
  State<MunculBertahap> createState() => _MunculBertahapState();
}

class _MunculBertahapState extends State<MunculBertahap> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: MunculBertahap.durasi + widget.jeda);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.isAnimating || _c.isCompleted) return;
    MediaQuery.disableAnimationsOf(context) ? _c.value = 1 : _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _c.duration!.inMicroseconds;
    final mulai = total == 0 ? 0.0 : widget.jeda.inMicroseconds / total;
    final a = CurvedAnimation(
      parent: _c,
      curve: Interval(mulai, 1, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: a,
      child: AnimatedBuilder(
        animation: a,
        builder: (context, child) => Transform.translate(offset: Offset(0, 16 * (1 - a.value)), child: child),
        child: widget.child,
      ),
    );
  }
}
