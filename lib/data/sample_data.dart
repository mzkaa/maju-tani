import '../models/harga_bulanan.dart';
import '../models/komoditas.dart';
import '../models/transaksi.dart';

/// DATA CONTOH. Nanti diganti database.
///
/// Angkanya disusun agar sama dengan semua layar Figma untuk periode
/// 1 Okt – 5 Nov 2026: panen 500 kg (375 kg terjual, 120 kg menunggu),
/// penjualan Rp 2.025.000, sudah dibayar Rp 1.491.000, belum Rp 534.000.
abstract final class SampleData {
  /// "Hari ini" di data contoh (Kamis, 5 November 2026, pagi).
  static final hariIni = DateTime(2026, 11, 5, 8);

  /// Awal periode ringkasan Beranda & Laporan.
  static final periodeAwal = DateTime(2026, 10, 1);

  static const namaPemilik = 'Pak Pemilik';

  /// Akun contoh untuk layar Masuk (login sungguhan dikerjakan nanti).
  static const namaPengguna = 'pemilik';
  static const kataSandi = 'tani2026';

  /// Isian awal Catat Panen, sama seperti contoh di Figma (M06).
  static const contohBeratPanen = 120;
  static const contohPengepul = 'Pak Dadang';

  /// Isian awal Lengkapi Penjualan, sama seperti contoh di Figma (M09).
  static const contohBeratTerjual = 118;
  static const contohHargaJual = 5200;

  static const komoditas = <Komoditas>[
    Komoditas(nama: 'Sawi'),
    Komoditas(nama: 'Bayam'),
    Komoditas(nama: 'Kangkung'),
    Komoditas(nama: 'Selada'),
    Komoditas(nama: 'Daun Bawang'),
    Komoditas(nama: 'Kol', aktif: false, hargaAcuan: 3500),
  ];

  static final transaksi = <Transaksi>[
    Transaksi(
      id: 't1',
      nomor: 'PJ-011',
      komoditas: 'Sawi',
      tanggalPanen: DateTime(2026, 11, 3, 15, 40),
      beratPanenKg: 120,
    ),
    Transaksi(
      id: 't2',
      nomor: 'PJ-010',
      komoditas: 'Bayam',
      tanggalPanen: DateTime(2026, 11, 1, 7, 30),
      beratPanenKg: 95,
      tanggalJual: DateTime(2026, 11, 1, 10, 15),
      beratTerjualKg: 92,
      hargaPerKg: 4500,
      pembeli: 'Pak Dadang',
    ),
    Transaksi(
      id: 't3',
      nomor: 'PJ-009',
      komoditas: 'Kangkung',
      tanggalPanen: DateTime(2026, 10, 30, 16, 20),
      beratPanenKg: 80,
      tanggalJual: DateTime(2026, 11, 1, 9, 10),
      beratTerjualKg: 80,
      hargaPerKg: 4000,
      pembeli: 'Pak Ujang',
      pembayaran: [Pembayaran(tanggal: DateTime(2026, 11, 2, 14, 5), jumlah: 200000)],
    ),
    Transaksi(
      id: 't4',
      nomor: 'PJ-008',
      komoditas: 'Selada',
      tanggalPanen: DateTime(2026, 10, 28, 7, 0),
      beratPanenKg: 60,
      tanggalJual: DateTime(2026, 10, 28, 12, 30),
      beratTerjualKg: 58,
      hargaPerKg: 7000,
      pembeli: 'Bu Euis',
      pembayaran: [Pembayaran(tanggal: DateTime(2026, 10, 29, 10, 0), jumlah: 406000)],
    ),
    Transaksi(
      id: 't5',
      nomor: 'PJ-007',
      komoditas: 'Daun Bawang',
      tanggalPanen: DateTime(2026, 10, 22, 6, 30),
      beratPanenKg: 40,
      tanggalJual: DateTime(2026, 10, 22, 13, 20),
      beratTerjualKg: 40,
      hargaPerKg: 9000,
      pembeli: 'Pak Asep',
      pembayaran: [Pembayaran(tanggal: DateTime(2026, 10, 23, 8, 45), jumlah: 360000)],
    ),
    Transaksi(
      id: 't6',
      nomor: 'PJ-006',
      komoditas: 'Sawi',
      tanggalPanen: DateTime(2026, 10, 15, 6, 50),
      beratPanenKg: 105,
      tanggalJual: DateTime(2026, 10, 15, 11, 0),
      beratTerjualKg: 105,
      hargaPerKg: 5000,
      pembeli: 'Bu Imas',
      pembayaran: [Pembayaran(tanggal: DateTime(2026, 10, 16, 9, 30), jumlah: 525000)],
    ),
  ];

  /// Riwayat harga jual per kg, Mei–Oktober 2026 (Sawi sesuai Figma; lainnya contoh).
  static final hargaBulanan = <String, List<HargaBulanan>>{
    'Sawi': _seri([4200, 4500, 4300, 4600, 4800, 5000]),
    'Bayam': _seri([4000, 4200, 4100, 4300, 4400, 4500]),
    'Kangkung': _seri([3600, 3800, 3700, 3900, 4100, 4000]),
    'Selada': _seri([6200, 6500, 6400, 6800, 7200, 7000]),
    'Daun Bawang': _seri([8000, 8400, 8200, 8600, 8800, 9000]),
  };

  static List<HargaBulanan> _seri(List<int> harga) => [
    for (final (i, h) in harga.indexed) HargaBulanan(bulan: DateTime(2026, 5 + i), hargaPerKg: h),
  ];

  /// Waktu cadangan data terakhir (M30), sesuai teks di Figma.
  static final terakhirDicadangkan = DateTime(2026, 11, 10);
}
