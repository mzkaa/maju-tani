/// Rata-rata harga jual sebuah komoditas dalam satu bulan.
class HargaBulanan {
  const HargaBulanan({required this.bulan, required this.hargaPerKg});

  final DateTime bulan; // tanggal 1 pada bulan tersebut
  final int hargaPerKg;
}
