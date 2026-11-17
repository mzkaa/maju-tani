import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../theme/app_gradients.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';
import 'kotak_kaca.dart';
import 'transisi.dart';

/// Tab di nav bawah.
enum TabUtama { beranda, riwayat, laporan, komoditas }

/// Nav bawah melayang: dua pil kaca + tombol bulat Catat Panen di tengah.
///
/// Tab yang aktif melebar dan menampilkan namanya. Saat pindah tab, tab lama mengecil dan tab baru
/// melebar dengan efek karet (memantul). Tiap layar punya nav sendiri, jadi tab terakhir diingat di
/// [_terakhir] supaya nav di layar baru bisa mulai dari keadaan nav di layar sebelumnya.
class NavBawah extends StatefulWidget {
  const NavBawah({super.key, required this.aktif});

  /// Tab yang sedang terbuka; `null` bila layar bukan tab (misalnya M04).
  final TabUtama? aktif;

  static TabUtama? _terakhir;

  @override
  State<NavBawah> createState() => _NavBawahState();
}

class _NavBawahState extends State<NavBawah> with SingleTickerProviderStateMixin {
  late final TabUtama? _dari;
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  late final _melebar = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
  late final _mengecil = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    _dari = NavBawah._terakhir;
    // Layar tanpa tab aktif (mis. rincian) tidak mengubah ingatan tab.
    if (widget.aktif != null) NavBawah._terakhir = widget.aktif;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.isAnimating || _c.isCompleted) return;
    final perluAnimasi = _dari != widget.aktif && !MediaQuery.disableAnimationsOf(context);
    perluAnimasi ? _c.forward() : _c.value = 1;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Seberapa lebar tab [tab] saat ini: 0 = hanya ikon, 1 = ikon + nama (boleh sedikit >1 saat memantul).
  double _lebar(TabUtama tab) {
    final jadi = tab == widget.aktif;
    final tadi = tab == _dari;
    if (jadi && tadi) return 1;
    if (jadi) return _melebar.value;
    if (tadi) return 1 - _mengecil.value;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final maks = MediaQuery.sizeOf(context).width - 24;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maks),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Pil(
                children: [
                  _ItemNav(
                    tab: TabUtama.beranda,
                    ikon: Ikon.home,
                    label: 'Beranda',
                    lebar: _lebar(TabUtama.beranda),
                    aktifSekarang: widget.aktif,
                  ),
                  _ItemNav(
                    tab: TabUtama.riwayat,
                    ikon: Ikon.list,
                    label: 'Riwayat',
                    lebar: _lebar(TabUtama.riwayat),
                    aktifSekarang: widget.aktif,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              const _TombolCatatPanen(),
              const SizedBox(width: 10),
              _Pil(
                children: [
                  _ItemNav(
                    tab: TabUtama.laporan,
                    ikon: Ikon.chart,
                    label: 'Laporan',
                    lebar: _lebar(TabUtama.laporan),
                    aktifSekarang: widget.aktif,
                  ),
                  _ItemNav(
                    tab: TabUtama.komoditas,
                    ikon: Ikon.leaf,
                    label: 'Komoditas',
                    lebar: _lebar(TabUtama.komoditas),
                    aktifSekarang: widget.aktif,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pil extends StatelessWidget {
  const _Pil({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return KotakKaca(
      radius: 32,
      padding: const EdgeInsets.all(5),
      bayangan: AppShadows.nav,
      child: Row(mainAxisSize: MainAxisSize.min, children: [children[0], const SizedBox(width: 4), children[1]]),
    );
  }
}

class _ItemNav extends StatefulWidget {
  const _ItemNav({
    required this.tab,
    required this.ikon,
    required this.label,
    required this.lebar,
    required this.aktifSekarang,
  });

  final TabUtama tab;
  final Ikon ikon;
  final String label;

  /// 0 = hanya ikon, 1 = ikon + nama.
  final double lebar;

  /// Tab yang sedang terbuka, untuk arah transisi.
  final TabUtama? aktifSekarang;

  static const _rute = {
    TabUtama.beranda: Rute.beranda,
    TabUtama.riwayat: Rute.riwayat,
    TabUtama.laporan: Rute.laporan,
    TabUtama.komoditas: Rute.komoditas,
  };

  @override
  State<_ItemNav> createState() => _ItemNavState();
}

class _ItemNavState extends State<_ItemNav> {
  var _ditekan = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.lebar.clamp(0.0, 1.3);
    final nyala = e.clamp(0.0, 1.0);
    final dipilih = widget.lebar >= 0.5;
    final warnaIkon = Color.lerp(AppColors.ikonNav, AppColors.ikonHijau, nyala)!;
    return Semantics(
      button: true,
      selected: dipilih,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _ditekan = true),
        onTapCancel: () => setState(() => _ditekan = false),
        // Tab yang sedang menyala tetap bisa diketuk (mis. dari M04 kembali ke M03).
        onTap: () {
          setState(() => _ditekan = false);
          final dari = widget.aktifSekarang;
          ArahTab.arah = dari == null ? 0 : (widget.tab.index - dari.index).sign;
          context.go(_ItemNav._rute[widget.tab]!);
        },
        // Ditekan: sedikit mengempis, lalu memantul kembali.
        child: AnimatedScale(
          scale: _ditekan ? 0.88 : 1,
          duration: Duration(milliseconds: _ditekan ? 90 : 450),
          curve: _ditekan ? Curves.easeOut : Curves.elasticOut,
          child: Container(
            height: 52,
            constraints: const BoxConstraints(minWidth: 52),
            padding: EdgeInsets.symmetric(horizontal: 13 + 3 * nyala),
            decoration: BoxDecoration(
              color: AppColors.navAktif.withValues(alpha: AppColors.navAktif.a * nyala),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.navAktifGaris.withValues(alpha: AppColors.navAktifGaris.a * nyala)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(widget.ikon, size: 24, color: warnaIkon),
                if (e > 0.01)
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: e,
                      child: Opacity(
                        opacity: nyala,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            softWrap: false,
                            style: AppText.gaya(14, FontWeight.w800, AppColors.ikonHijau),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TombolCatatPanen extends StatelessWidget {
  const _TombolCatatPanen();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 62,
      child: KotakKaca(
        radius: 31,
        gradien: AppGradien.hijauBulat,
        warnaGaris: const Color(0x59FFFFFF), // putih 35%
        tebalGaris: 1.5,
        bayangan: AppShadows.tombolBulat,
        sorotan: const Color(0x4DFFFFFF), // putih 30%
        sorotanDy: 2,
        sorotanBlur: 3,
        kaburKaca: null,
        label: 'Catat Panen',
        onTap: () {
          // Pusat lingkaran transisi = tengah tombol ini, dalam koordinat Navigator.
          final kotak = context.findRenderObject() as RenderBox?;
          final nav = Navigator.of(context).context.findRenderObject() as RenderBox?;
          if (kotak != null && nav != null) {
            AsalLingkaran.pusat = kotak.localToGlobal(kotak.size.center(Offset.zero), ancestor: nav);
          }
          context.push(Rute.catatPanen);
        },
        child: const Center(child: AppIcon(Ikon.plus, size: 28, color: Color(0xFFFFFFFF))),
      ),
    );
  }
}
