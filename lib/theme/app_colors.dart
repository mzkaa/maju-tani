import 'package:flutter/painting.dart';

/// Warna yang dipakai di frame Figma "V2 Mobile – Prototype".
///
/// Nilai diambil dari frame, bukan dari variabel "Warna V2" di file Figma,
/// karena frame tidak memakai variabel itu dan nilainya berbeda.
abstract final class AppColors {
  // Teks
  static const teksUtama = Color(0xFF0F1F19); // angka besar, harga
  static const teksJudul = Color(0xFF102019); // judul kartu & seksi
  static const teksKedua = Color(0xFF55665B); // keterangan di bawah judul
  static const teksKeduaAlt = Color(0xFF54665C); // keterangan di kartu saldo
  static const teksSamar = Color(0xFF73857A); // satuan, label bulan grafik
  static const teksLabel = Color(0xFF31724F); // label kapital (MENU CEPAT)

  // Hijau
  static const hijauTua = Color(0xFF11452E);
  static const hijau = Color(0xFF327C53);
  static const hijauTombolTeks = Color(0xFF1C5E3E);
  static const ikonHijau = Color(0xFF0A5E2E);
  static const ikonNav = Color(0xFF405247);
  static const ikonGelap = Color(0xFF102A1C);

  static const hijauTuaAlt = Color(0xFF12452E); // ikon telepon di M01

  // Tombol utama (gradien)
  static const tombolAwal = Color(0xFF1E6540);
  static const tombolAkhir = Color(0xFF12452E);
  static const bayanganTombol = Color(0x400D6626); // 25%

  // Latar halaman (gradien atas → bawah)
  static const latarAtas = Color(0xFFA9D8C1);
  static const latarTengah = Color(0xFFBADCAB);
  static const latarBawah = Color(0xFFDBF2F2);

  // Header hijau melengkung (gradien)
  static const headerAwal = Color(0xFF0E2D22);
  static const headerTengah = Color(0xFF1C5E3E);
  static const headerAkhir = Color(0xFF3F835A);

  // Gumpalan warna di latar (transparansi 80%)
  static const gumpalanHijau = Color(0xCC55BB7C);
  static const gumpalanLimau = Color(0xCC8FCC3D);
  static const gumpalanToska = Color(0xCC459D9A);
  static const gumpalanDaun = Color(0xCC5EC353);
  static const gumpalanKuning = Color(0xCCF2D966);

  // Pudar bawah di belakang nav (rgb 175,210,197)
  static const pudar = Color(0xFFAFD2C5);

  // Nav bawah
  static const navAktif = Color(0xF29BD7B6); // 95%
  static const navAktifGaris = Color(0x59327C53); // 35%

  // Status transaksi
  static const biruIkon = Color(0xFF1D4ED8);
  static const biruLatar = Color(0xFFDBEAFE);
  static const biruAngka = Color(0xFF1C4FD9);
  static const biruGaris = Color(0xFF2663EB);
  static const kuningIkon = Color(0xFFB45309);
  static const kuningLatar = Color(0xFFFEF3C7);
  static const oranyeIkon = Color(0xFFC2410C);
  static const oranyeLatar = Color(0xFFFFEDD5);
  static const oranyeAngka = Color(0xFFB5540A);
  static const oranyeGaris = Color(0xFFF59E21);
  static const unguIkon = Color(0xFF7C3AED);
  static const kuningTitik = Color(0xFFFBBF24); // titik notifikasi

  // M00 Layar Pembuka
  static const splashAtas = Color(0xFF1B4733);
  static const splashTengah = Color(0xFF123526);
  static const splashBawah = Color(0xFF0A1E16);
  static const splashGumpalanHijau = Color(0x733FA06B); // 45%
  static const splashGumpalanTua = Color(0x732E7D5B); // 45%
  static const splashGumpalanKuning = Color(0x1FF2B544); // 12%
  static const logoAwal = Color(0xFF5CBF85);
  static const logoAkhir = Color(0xFF2A7A52);
  static const titikAktif = Color(0xFFF2B544);

  // Badge status (teks & ikon)
  static const biruTeks = Color(0xFF1E40AF);
  static const kuningTeks = Color(0xFF8A4B08);
  static const oranyeTeks = Color(0xFF9A3412);
  static const lunasLatar = Color(0xFF9BE8C0);

  // Kartu transaksi & detail
  static const garisPemisah = Color(0xFFB7C9BE);
  static const garisTombolRincian = Color(0x401C5E3D); // 25%
  static const garisChip = Color(0xFF8FA396);
  static const perjalananAwal = Color(0xF517422E); // 96%
  static const perjalananAkhir = Color(0xF50D291C); // 96%
  static const langkahSelesai = Color(0xFF9CE8BF);
  static const langkahSebagian = Color(0xFFF2B545);
  static const ikonLangkah = Color(0xFF0D3321);

  // Catat Panen (M05–M08)
  static const pilihanIkonLatar = Color(0xFFBCCFC2);
  static const galat = Color(0xFFB91C1C);
  static const titikMenunggu = Color(0xFF8CB2FF);

  // Laporan & Komoditas (M11–M13)
  static const belumBatang = Color(0xFFA16207);
  static const daunLatar = Color(0xFFB5E8C9);
  static const hijauAktif = Color(0xFF2A7A52);
  static const ikonDaun = Color(0xFF56665C);
  static const garisTombolRekap = Color(0xFF15803D);
  static const teksTombolRekap = Color(0xFF0B5E2E);

  // Layar tambahan (M15–M30)
  static const fokusBiru = Color(0xFF2563EB);
  static const biruIkonTambahan = Color(0xFF2663EB);
  static const pdfAwal = Color(0xFFED5C4D);
  static const pdfAkhir = Color(0xFFBF3329);
  static const statusDicicil = Color(0xFFE0A030);

  // Lain-lain
  static const bulatPanah = Color(0xFFC0CEC6); // bulatan panah di kartu tugas
  static const garisGrafik = Color(0x1411452E); // garis bantu grafik (8%)
}
