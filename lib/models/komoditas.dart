/// Jenis sayur yang dipanen (M12 Data Komoditas).
class Komoditas {
  const Komoditas({required this.nama, this.aktif = true, this.satuan = 'Kilogram (kg)', this.hargaAcuan});

  final String nama;

  /// Aktif = ditampilkan saat Catat Panen.
  final bool aktif;
  final String satuan;

  /// Harga per kg yang dipakai bila belum pernah terjual.
  final int? hargaAcuan;

  Komoditas copyWith({String? nama, bool? aktif, String? satuan}) => Komoditas(
    nama: nama ?? this.nama,
    aktif: aktif ?? this.aktif,
    satuan: satuan ?? this.satuan,
    hargaAcuan: hargaAcuan,
  );
}
