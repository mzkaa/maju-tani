import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import 'latar_halaman.dart';
import 'nav_bawah.dart';
import 'transisi.dart';

/// Kerangka layar bersama: latar gradien, isi yang digulir bersama gumpalan
/// warna, header tetap di atas, dan (opsional) nav bawah melayang atau
/// bilah tombol tetap di bawah.
///
/// [isi] mengatur sendiri jarak atasnya (mengikuti padding "Isi" di Figma).
class KerangkaHalaman extends StatelessWidget {
  const KerangkaHalaman({
    super.key,
    this.header,
    required this.isi,
    this.nav = false,
    this.navAktif,
    this.bilahBawah,
    this.statusBarGelap = false,
  });

  /// Header tetap di atas; `null` untuk layar tanpa header (mis. M08).
  final Widget? header;
  final Widget isi;

  /// Tampilkan nav bawah melayang (dengan pudar di belakangnya).
  final bool nav;
  final TabUtama? navAktif;

  /// Bilah tetap di bawah layar, misalnya tombol "Lanjut" di formulir.
  final Widget? bilahBawah;

  /// Ikon status bar gelap, untuk layar tanpa header hijau.
  final bool statusBarGelap;

  @override
  Widget build(BuildContext context) {
    final kanan = MediaQuery.sizeOf(context).width - 390;
    final atas = AppLayout.ekstraAtas(context);
    final bawah = AppLayout.ekstraBawah(context);
    // Saat keyboard terbuka, bilah tombol disembunyikan agar tidak menutupi isian;
    // muncul lagi setelah keyboard ditutup (ketuk di luar isian atau geser layar).
    final keyboardTerbuka = MediaQuery.viewInsetsOf(context).bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarGelap ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.latarBawah,
        body: Stack(
          children: [
            // Latar langsung menutupi layar lama; isi dan header layar tab masuk di atasnya
            // (meluncur + memudar) sementara nav bawah tetap diam.
            const Positioned.fill(child: LatarGradien()),
            Positioned.fill(
              child: _MungkinMasukTab(
                aktif: navAktif != null,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                        child: SingleChildScrollView(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ...gumpalanStandar(kanan: kanan, atas: atas),
                              isi,
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (header != null) Positioned(top: 0, left: 0, right: 0, child: header!),
                  ],
                ),
              ),
            ),
            if (nav) ...[
              const Positioned(left: 0, right: 0, bottom: 0, child: PudarBawah()),
              Positioned(
                left: 0,
                right: 0,
                bottom: 22.4 + bawah,
                child: Center(child: NavBawah(aktif: navAktif)),
              ),
            ],
            if (bilahBawah != null && !keyboardTerbuka) Positioned(left: 0, right: 0, bottom: 0, child: bilahBawah!),
          ],
        ),
      ),
    );
  }
}

class _MungkinMasukTab extends StatelessWidget {
  const _MungkinMasukTab({required this.aktif, required this.child});

  final bool aktif;
  final Widget child;

  @override
  Widget build(BuildContext context) => aktif ? MasukTab(child: child) : child;
}
