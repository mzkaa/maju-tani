/// Jenis pemberitahuan di M16.
enum JenisNotifikasi { belumDijual, belumDibayar, pembayaranMasuk }

/// Satu pemberitahuan, dibuat dari data transaksi.
class Notifikasi {
  const Notifikasi({
    required this.id,
    required this.jenis,
    required this.judul,
    required this.keterangan,
    required this.transaksiId,
    this.dibacaAwal = false,
    this.dibaca = false,
  });

  final String id;
  final JenisNotifikasi jenis;
  final String judul;
  final String keterangan;
  final String transaksiId;

  /// Pembayaran masuk dianggap sudah dibaca sejak awal (seperti di Figma).
  final bool dibacaAwal;
  final bool dibaca;

  Notifikasi denganDibaca(bool d) => Notifikasi(
    id: id,
    jenis: jenis,
    judul: judul,
    keterangan: keterangan,
    transaksiId: transaksiId,
    dibacaAwal: dibacaAwal,
    dibaca: d,
  );
}
