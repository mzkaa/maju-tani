import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/app_store.dart';
import 'data/dokumen.dart';

import 'models/transaksi.dart';
import 'screens/akun_screens.dart';
import 'screens/beranda_screen.dart';
import 'screens/catat_panen_screens.dart';
import 'screens/detail_transaksi_screen.dart';
import 'screens/dokumen_screens.dart';
import 'screens/harga_rekap_screens.dart';
import 'screens/komoditas_screens.dart';
import 'screens/laporan_screen.dart';
import 'screens/masuk_screen.dart';
import 'screens/notifikasi_cari_screens.dart';
import 'screens/penjualan_pembayaran_screens.dart';
import 'screens/riwayat_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/ubah_transaksi_screen.dart';

/// Alamat semua layar (kode M sesuai nama frame di Figma).
abstract final class Rute {
  /// Layar tujuan saat sebuah catatan diketuk, sesuai prototype:
  /// belum dijual → M09, belum dibayar → M10, selain itu → M04.
  static String tindakan(Transaksi t) => switch (t.status) {
    StatusTransaksi.menungguPenjualan => lengkapiPenjualan(t.id),
    StatusTransaksi.menungguPembayaran => catatPembayaran(t.id),
    _ => detail(t.id),
  };

  static const splash = '/splash'; // M00
  static const masuk = '/masuk'; // M01
  static const beranda = '/beranda'; // M02
  static const riwayat = '/riwayat'; // M03
  static String detail(String id) => '/transaksi/$id'; // M04
  static const catatPanen = '/catat-panen'; // M05
  static const catatPanenBerat = '/catat-panen/berat'; // M06
  static const catatPanenPeriksa = '/catat-panen/periksa'; // M07
  static String catatPanenBerhasil(String id) => '/catat-panen/berhasil/$id'; // M08
  static String lengkapiPenjualan(String id) => '/penjualan/$id'; // M09
  static String catatPembayaran(String id) => '/pembayaran/$id'; // M10
  static const laporan = '/laporan'; // M11
  static const komoditas = '/komoditas'; // M12
  static const tambahKomoditas = '/komoditas/tambah'; // M13
  static String pembayaranTersimpan(String id) => '/pembayaran/$id/tersimpan'; // M14
  static const akun = '/akun'; // M15
  static const notifikasi = '/notifikasi'; // M16
  static const cari = '/cari'; // M17
  static String ubahTransaksi(String id) => '/transaksi/$id/ubah'; // M18
  static const riwayatHarga = '/harga'; // M19
  static const rekapSayur = '/laporan/rekap'; // M20
  // Nama di-encode agar "/", "#", "?" di nama sayur tidak merusak alamat.
  static String ubahKomoditas(String nama) => '/komoditas/ubah/${Uri.encodeComponent(nama)}'; // M21
  static const lupaSandi = '/lupa-sandi'; // M22
  static const ubahSandi = '/akun/ubah-sandi'; // M23
  static const pilihPeriode = '/laporan/periode'; // M24
  static const cetakLaporan = '/laporan/cetak'; // M25
  static const pratinjauDokumen = '/laporan/pratinjau'; // M26
  static const dokumenBerhasil = '/laporan/berhasil'; // M27
  static String notaPembayaran(String id) => '/pembayaran/$id/nota'; // M28
  static const filterKomoditas = '/komoditas/filter'; // M29
  static const pengaturan = '/akun/pengaturan'; // M30
}

/// Durasi transisi dari prototype Figma (semua EASE OUT).
const _durasiGeser = Duration(milliseconds: 300); // MOVE IN / MOVE OUT
const _durasiTab = Duration(milliseconds: 200); // DISSOLVE antar tab nav bawah
const _durasiSplash = Duration(milliseconds: 400); // DISSOLVE M00 → M01

/// Transisi DISSOLVE.
Page<void> _pudar(GoRouterState state, Widget child, Duration durasi) => CustomTransitionPage<void>(
  key: state.pageKey,
  child: child,
  transitionDuration: durasi,
  reverseTransitionDuration: durasi,
  transitionsBuilder: (context, animasi, _, child) => FadeTransition(
    opacity: CurvedAnimation(parent: animasi, curve: Curves.easeOut),
    child: child,
  ),
);

/// Transisi MOVE IN (layar baru masuk dari kanan; kembali = MOVE OUT).
Page<void> _geser(GoRouterState state, Widget child) => CustomTransitionPage<void>(
  key: state.pageKey,
  child: child,
  transitionDuration: _durasiGeser,
  reverseTransitionDuration: _durasiGeser,
  transitionsBuilder: (context, animasi, _, child) => SlideTransition(
    position: Tween(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animasi, curve: Curves.easeOut)),
    child: child,
  ),
);

/// [pudar] diisi untuk layar yang dibuka dengan DISSOLVE; selain itu MOVE IN.
GoRoute _layar(String path, Widget Function(GoRouterState s) builder, {Duration? pudar}) => GoRoute(
  path: path,
  pageBuilder: (context, state) => pudar != null ? _pudar(state, builder(state), pudar) : _geser(state, builder(state)),
);

final appRouter = buatRouter();

/// Layar yang boleh dibuka sebelum masuk.
const _tanpaMasuk = {Rute.splash, Rute.masuk, Rute.lupaSandi};

/// Belum masuk → ke Masuk; sudah masuk tapi membuka Masuk → ke Beranda.
/// Langkah Catat Panen yang dibuka langsung (mis. halaman dimuat ulang) kembali ke langkah yang belum lengkap.
String? _penjaga(BuildContext context, GoRouterState state) {
  final store = context.read<AppStore>();
  final lokasi = state.matchedLocation;
  if (!store.sudahMasuk) return _tanpaMasuk.contains(lokasi) ? null : Rute.masuk;
  if (lokasi == Rute.masuk) return Rute.beranda;
  if (lokasi == Rute.catatPanenBerat && !store.sayurDraftSah) return Rute.catatPanen;
  if (lokasi == Rute.catatPanenPeriksa && !store.draftSiap) return Rute.catatPanen;
  return null;
}

extension Kembali on BuildContext {
  /// Ke layar sebelumnya; bila tidak ada (mis. halaman dimuat ulang di browser), ke Beranda.
  void kembali() => canPop() ? pop() : go(Rute.beranda);
}

/// Membuat router; [awal] bisa diganti untuk tes atau pratinjau satu layar.
GoRouter buatRouter({String awal = Rute.splash}) => GoRouter(
  initialLocation: awal,
  redirect: _penjaga,
  routes: [
    _layar(Rute.splash, (_) => const SplashScreen(), pudar: _durasiTab),
    _layar(Rute.masuk, (_) => const MasukScreen(), pudar: _durasiSplash),
    _layar(Rute.beranda, (_) => const BerandaScreen(), pudar: _durasiTab),
    _layar(Rute.riwayat, (_) => const RiwayatScreen(), pudar: _durasiTab),
    _layar('/transaksi/:id', (s) => DetailTransaksiScreen(id: s.pathParameters['id']!)),
    _layar(Rute.catatPanen, (_) => const PilihSayurScreen()),
    _layar(Rute.catatPanenBerat, (_) => const BeratTanggalScreen()),
    _layar(Rute.catatPanenPeriksa, (_) => const PeriksaPanenScreen()),
    _layar('/catat-panen/berhasil/:id', (s) => PanenTersimpanScreen(id: s.pathParameters['id']!)),
    _layar('/penjualan/:id', (s) => LengkapiPenjualanScreen(id: s.pathParameters['id']!)),
    _layar('/pembayaran/:id', (s) => CatatPembayaranScreen(id: s.pathParameters['id']!)),
    _layar(Rute.laporan, (_) => const LaporanScreen(), pudar: _durasiTab),
    _layar(Rute.komoditas, (_) => const DataKomoditasScreen(), pudar: _durasiTab),
    _layar(Rute.tambahKomoditas, (_) => const FormKomoditasScreen()),
    _layar('/pembayaran/:id/tersimpan', (s) => PembayaranTersimpanScreen(id: s.pathParameters['id']!)),
    _layar(Rute.akun, (_) => const AkunScreen()),
    _layar(Rute.notifikasi, (_) => const NotifikasiScreen()),
    _layar(Rute.cari, (_) => const CariScreen()),
    _layar('/transaksi/:id/ubah', (s) => UbahTransaksiScreen(id: s.pathParameters['id']!)),
    _layar(Rute.riwayatHarga, (_) => const RiwayatHargaScreen()),
    _layar(Rute.rekapSayur, (_) => const RekapSayurScreen()),
    _layar('/komoditas/ubah/:nama', (s) => FormKomoditasScreen(namaLama: s.pathParameters['nama'])),
    _layar(Rute.lupaSandi, (_) => const LupaSandiScreen()),
    _layar(Rute.ubahSandi, (_) => const UbahSandiScreen()),
    _layar(Rute.pilihPeriode, (_) => const PilihPeriodeScreen()),
    _layar(Rute.cetakLaporan, (_) => const CetakLaporanScreen()),
    _layar(Rute.pratinjauDokumen, (_) => const PratinjauDokumenScreen()),
    _layar(Rute.dokumenBerhasil, (s) => DokumenBerhasilScreen(file: s.extra as FileDokumen?)),
    _layar('/pembayaran/:id/nota', (s) => NotaPembayaranScreen(id: s.pathParameters['id']!)),
    _layar(Rute.filterKomoditas, (_) => const FilterKomoditasScreen()),
    _layar(Rute.pengaturan, (_) => const PengaturanScreen()),
  ],
);
