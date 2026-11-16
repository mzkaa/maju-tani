import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Daftar ikon dari komponen `ikon/*` di Figma (assets/icons).
enum Ikon {
  alert,
  arrowLeft,
  arrowRight,
  banknote,
  bell,
  calendar,
  chart,
  check,
  checkCircle,
  chevronDown,
  chevronLeft,
  chevronRight,
  circle,
  clipboard,
  clock,
  dashboard,
  download,
  eye,
  eyeOff,
  fileText,
  filter,
  help,
  home,
  hourglass,
  info,
  leaf,
  list,
  lock,
  logout,
  menu,
  minus,
  more,
  pencil,
  phone,
  pieChart,
  plus,
  printer,
  receipt,
  scale,
  search,
  settings,
  sprout,
  sun,
  tag,
  trash,
  trendingUp,
  truck,
  user,
  wallet,
  x;

  /// Nama file: pieChart → pie-chart.svg
  String get file => name.replaceAllMapped(RegExp('[A-Z]'), (m) => '-${m[0]!.toLowerCase()}');
}

/// Ikon garis dari Figma dengan warna dan tebal garis yang bisa diatur.
///
/// File SVG aslinya berukuran 24 × 24 dengan garis 2. Di Figma, tebal garis
/// tiap ikon diatur dalam piksel layar (misalnya 2 atau 2,2), jadi tebal
/// garis dikonversi ke skala 24 sebelum digambar.
class AppIcon extends StatelessWidget {
  const AppIcon(this.ikon, {super.key, required this.size, required this.color, this.tebal = 2, this.warnaPerGaris});

  final Ikon ikon;
  final double size;
  final Color color;
  final double tebal;

  /// Warna tiap garis (path) secara berurutan, untuk ikon dua warna di Figma.
  /// Bila diisi, [color] tidak dipakai.
  final List<Color>? warnaPerGaris;

  static final _svg = <Ikon, String>{};

  /// Dipanggil sekali di main() supaya ikon langsung tampil tanpa kedip.
  static Future<void> muat() async {
    for (final i in Ikon.values) {
      _svg[i] = await rootBundle.loadString('assets/icons/${i.file}.svg');
    }
  }

  static String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  Widget build(BuildContext context) {
    final tebal24 = (tebal * 24 / size).toStringAsFixed(3);
    var svg = _svg[ikon]!.replaceAll('stroke-width="2"', 'stroke-width="$tebal24"');
    final warna = warnaPerGaris;
    if (warna != null) {
      var i = 0;
      svg = svg.replaceAllMapped('stroke="#000000"', (_) {
        final c = warna[i < warna.length ? i : warna.length - 1];
        i++;
        return 'stroke="${_hex(c)}" stroke-opacity="${c.a}"';
      });
      return SvgPicture.string(svg, width: size, height: size);
    }
    return SvgPicture.string(svg, width: size, height: size, colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
  }
}
