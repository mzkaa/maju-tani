/// Isian Catat Panen yang sedang dikerjakan (M05 → M06 → M07).
class DraftPanen {
  DraftPanen({required this.komoditas, required this.tanggal, this.beratKg, this.pengepul = ''});

  String komoditas;
  DateTime tanggal;
  int? beratKg;

  /// Nama pengepul; boleh kosong.
  String pengepul;
}
