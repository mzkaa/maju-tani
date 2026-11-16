import 'package:flutter/material.dart' show DateUtils;
import 'package:intl/intl.dart';

/// Format angka & tanggal gaya Indonesia, sesuai teks di Figma.
abstract final class Format {
  static final _angka = NumberFormat.decimalPattern('id_ID');

  /// 1491000 → "Rp 1.491.000"
  static String rupiah(int nilai) => 'Rp ${_angka.format(nilai)}';

  /// 525000 → "Rp 525 rb"
  static String rupiahRingkas(int nilai) => 'Rp ${_angka.format((nilai / 1000).round())} rb';

  /// → "1 Okt – 5 Nov 2026" (tahun hanya di akhir bila sama)
  static String rentang(DateTime awal, DateTime akhir) {
    final kiri = awal.year == akhir.year
        ? DateFormat('d MMM', 'id_ID').format(awal)
        : DateFormat('d MMM y', 'id_ID').format(awal);
    return '$kiri – ${DateFormat('d MMM y', 'id_ID').format(akhir)}';
  }

  /// 500 → "500 kg"
  static String kg(int nilai) => '${_angka.format(nilai)} kg';

  /// → "Kamis, 5 November 2026"
  static String tanggalPanjang(DateTime d) => DateFormat('EEEE, d MMMM y', 'id_ID').format(d);

  /// → "03 Nov 2026"
  static String tanggal(DateTime d) => DateFormat('dd MMM y', 'id_ID').format(d);

  /// → "30 Okt 2026, 16:20"
  static String tanggalJam(DateTime d) => DateFormat('dd MMM y, HH:mm', 'id_ID').format(d);

  /// → "Kamis, 5 Nov 2026"
  static String hariTanggal(DateTime d) => DateFormat('EEEE, d MMM y', 'id_ID').format(d);

  /// → "Kamis 5 Nov 2026" (tanpa koma, untuk kalimat)
  static String hariTanggalTanpaKoma(DateTime d) => DateFormat('EEEE d MMM y', 'id_ID').format(d);

  /// Nilai isian tanggal: "Hari ini, 5 Nov 2026" atau "Rabu, 4 Nov 2026".
  static String tanggalIsian(DateTime d, DateTime hariIni) =>
      DateUtils.isSameDay(d, hariIni) ? 'Hari ini, ${DateFormat('d MMM y', 'id_ID').format(d)}' : hariTanggal(d);

  /// → "5 Nov 2026"
  static String tanggalSingkat(DateTime d) => DateFormat('d MMM y', 'id_ID').format(d);

  /// Mengambil angka saja dari teks, mis. "Rp 5.200" → 5200.
  static int? angka(String teks) => int.tryParse(teks.replaceAll(RegExp(r'[^0-9]'), ''));

  /// → "03 Nov"
  static String tanggalPendek(DateTime d) => DateFormat('dd MMM', 'id_ID').format(d);

  /// → "2 Nov"
  static String tanggalPendekTanpaNol(DateTime d) => DateFormat('d MMM', 'id_ID').format(d);

  /// → "Oktober 2026"
  static String bulanTahun(DateTime d) => DateFormat('MMMM y', 'id_ID').format(d);

  /// 648000 → "Rp648.000" (tanpa spasi, gaya dokumen cetak)
  static String rupiahRapat(int nilai) => 'Rp${_angka.format(nilai)}';

  /// → "15/10"
  static String tanggalAngka(DateTime d) => DateFormat('dd/MM', 'id_ID').format(d);

  /// → "1 – 31 Oktober 2026" bila satu bulan, selain itu "1 Okt – 5 Nov 2026".
  static String rentangPanjang(DateTime awal, DateTime akhir) => awal.year == akhir.year && awal.month == akhir.month
      ? '${awal.day} – ${DateFormat('d MMMM y', 'id_ID').format(akhir)}'
      : rentang(awal, akhir);

  /// → "Okt", "Agu"
  static String bulanPendek(DateTime d) => DateFormat('MMM', 'id_ID').format(d);

  /// Sapaan menurut jam.
  static String sapaan(DateTime d) {
    final jam = d.hour;
    if (jam < 11) return 'Selamat pagi,';
    if (jam < 15) return 'Selamat siang,';
    if (jam < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }
}
