import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../theme/app_layout.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';
import 'header_hijau.dart';

/// "Header ringkas" di M03–M30: judul + keterangan, tombol bulat opsional
/// di kiri (biasanya kembali) dan di kanan (aksi).
class HeaderRingkas extends StatelessWidget {
  const HeaderRingkas({super.key, required this.judul, required this.keterangan, this.kiri, this.kanan});

  final String judul;
  final String keterangan;
  final Widget? kiri;
  final Widget? kanan;

  @override
  Widget build(BuildContext context) {
    return HeaderHijau(
      ekstraAtas: AppLayout.ekstraAtas(context),
      bayangan: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 50,
            child: Row(
              children: [
                if (kiri != null) ...[kiri!, const SizedBox(width: 12)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(judul, style: AppText.judulHeader, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(keterangan, style: AppText.keteranganHeader, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (kanan != null) ...[const SizedBox(width: 12), kanan!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol bulat putih transparan di header (46 × 46).
class TombolBulatHeader extends StatelessWidget {
  const TombolBulatHeader({super.key, required this.ikon, required this.label, required this.onTap});

  final Ikon ikon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0x29FFFFFF), // putih 16%
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x59FFFFFF)), // putih 35%
          ),
          child: AppIcon(ikon, size: 22, color: const Color(0xFFFFFFFF), tebal: 1.8333),
        ),
      ),
    );
  }
}

/// Tombol kembali di header: ke layar sebelumnya, atau ke Beranda bila tidak ada.
class TombolKembali extends StatelessWidget {
  const TombolKembali({super.key});

  @override
  Widget build(BuildContext context) {
    return TombolBulatHeader(
      ikon: Ikon.chevronLeft,
      label: 'Kembali',
      onTap: () => context.canPop() ? context.pop() : context.go(Rute.beranda),
    );
  }
}
