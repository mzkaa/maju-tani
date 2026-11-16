import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../theme/app_gradients.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import 'app_icon.dart';
import 'kotak_kaca.dart';

/// Tab di nav bawah.
enum TabUtama { beranda, riwayat, laporan, komoditas }

/// Nav bawah melayang: dua pil kaca + tombol bulat Catat Panen di tengah.
/// Dipakai di M02, M03, M04, M11, dan M12.
class NavBawah extends StatelessWidget {
  const NavBawah({super.key, required this.aktif});

  /// Tab yang sedang terbuka; `null` bila layar bukan tab (misalnya M04).
  final TabUtama? aktif;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pil(
          children: [
            _ItemNav(tab: TabUtama.beranda, ikon: Ikon.home, label: 'Beranda', aktif: aktif),
            _ItemNav(tab: TabUtama.riwayat, ikon: Ikon.list, label: 'Riwayat', aktif: aktif),
          ],
        ),
        const SizedBox(width: 14),
        const _TombolCatatPanen(),
        const SizedBox(width: 14),
        _Pil(
          children: [
            _ItemNav(tab: TabUtama.laporan, ikon: Ikon.chart, label: 'Laporan', aktif: aktif),
            _ItemNav(tab: TabUtama.komoditas, ikon: Ikon.leaf, label: 'Komoditas', aktif: aktif),
          ],
        ),
      ],
    );
  }
}

class _Pil extends StatelessWidget {
  const _Pil({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return KotakKaca(
      radius: 36,
      padding: const EdgeInsets.all(6),
      bayangan: AppShadows.nav,
      child: Row(mainAxisSize: MainAxisSize.min, children: [children[0], const SizedBox(width: 4), children[1]]),
    );
  }
}

class _ItemNav extends StatelessWidget {
  const _ItemNav({required this.tab, required this.ikon, required this.label, required this.aktif});

  final TabUtama tab;
  final Ikon ikon;
  final String label;
  final TabUtama? aktif;

  static const _rute = {
    TabUtama.beranda: Rute.beranda,
    TabUtama.riwayat: Rute.riwayat,
    TabUtama.laporan: Rute.laporan,
    TabUtama.komoditas: Rute.komoditas,
  };

  @override
  Widget build(BuildContext context) {
    final dipilih = tab == aktif;
    return Semantics(
      button: true,
      selected: dipilih,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Tab yang sedang menyala tetap bisa diketuk (mis. dari M04 kembali ke M03).
        onTap: () => context.go(_rute[tab]!),
        child: Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: dipilih
              ? BoxDecoration(
                  color: AppColors.navAktif,
                  borderRadius: BorderRadius.circular(29),
                  border: Border.all(color: AppColors.navAktifGaris),
                )
              : null,
          child: AppIcon(ikon, size: 28, color: dipilih ? AppColors.ikonHijau : AppColors.ikonNav),
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
      dimension: 70,
      child: KotakKaca(
        radius: 35,
        gradien: AppGradien.hijauBulat,
        warnaGaris: const Color(0x59FFFFFF), // putih 35%
        tebalGaris: 1.5,
        bayangan: AppShadows.tombolBulat,
        sorotan: const Color(0x4DFFFFFF), // putih 30%
        sorotanDy: 2,
        sorotanBlur: 3,
        kaburKaca: null,
        label: 'Catat Panen',
        onTap: () => context.push(Rute.catatPanen),
        child: const Center(child: AppIcon(Ikon.plus, size: 32, color: Color(0xFFFFFFFF))),
      ),
    );
  }
}
