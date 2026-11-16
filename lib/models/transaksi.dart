/// Status sebuah catatan panen, dihitung dari data penjualan & pembayaran.
enum StatusTransaksi { menungguPenjualan, menungguPembayaran, dibayarSebagian, lunas }

/// Satu pembayaran dari pembeli.
class Pembayaran {
  const Pembayaran({required this.tanggal, required this.jumlah});

  final DateTime tanggal;
  final int jumlah; // rupiah
}

/// Satu catatan panen beserta penjualan dan pembayarannya.
class Transaksi {
  const Transaksi({
    required this.id,
    required this.nomor,
    required this.komoditas,
    required this.tanggalPanen,
    required this.beratPanenKg,
    this.tanggalJual,
    this.beratTerjualKg,
    this.hargaPerKg,
    this.pembeli,
    this.pembayaran = const [],
  });

  final String id;

  /// Nomor catatan, mis. "PJ-011".
  final String nomor;
  final String komoditas;

  /// Tanggal & jam panen dicatat.
  final DateTime tanggalPanen;
  final int beratPanenKg;

  // Diisi saat "Lengkapi Penjualan"; null berarti belum dijual.
  final DateTime? tanggalJual;
  final int? beratTerjualKg;
  final int? hargaPerKg;
  final String? pembeli;

  final List<Pembayaran> pembayaran;

  Transaksi copyWith({
    String? komoditas,
    DateTime? tanggalPanen,
    int? beratPanenKg,
    DateTime? tanggalJual,
    int? beratTerjualKg,
    int? hargaPerKg,
    String? pembeli,
    List<Pembayaran>? pembayaran,
  }) => Transaksi(
    id: id,
    nomor: nomor,
    komoditas: komoditas ?? this.komoditas,
    tanggalPanen: tanggalPanen ?? this.tanggalPanen,
    beratPanenKg: beratPanenKg ?? this.beratPanenKg,
    tanggalJual: tanggalJual ?? this.tanggalJual,
    beratTerjualKg: beratTerjualKg ?? this.beratTerjualKg,
    hargaPerKg: hargaPerKg ?? this.hargaPerKg,
    pembeli: pembeli ?? this.pembeli,
    pembayaran: pembayaran ?? this.pembayaran,
  );

  bool get sudahDijual => hargaPerKg != null && beratTerjualKg != null;

  int get totalPenjualan => sudahDijual ? beratTerjualKg! * hargaPerKg! : 0;

  int get totalDibayar => pembayaran.fold(0, (s, p) => s + p.jumlah);

  int get sisaTagihan => totalPenjualan - totalDibayar;

  StatusTransaksi get status {
    if (!sudahDijual) return StatusTransaksi.menungguPenjualan;
    if (totalDibayar == 0) return StatusTransaksi.menungguPembayaran;
    if (sisaTagihan > 0) return StatusTransaksi.dibayarSebagian;
    return StatusTransaksi.lunas;
  }
}
