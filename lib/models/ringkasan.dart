import 'transaksi.dart';

/// Penjualan satu sayur dalam periode (batang di M11, kartu di M20).
class RingkasanSayur {
  const RingkasanSayur({
    required this.nama,
    required this.kaliPanen,
    required this.panenKg,
    required this.terjualKg,
    required this.penjualan,
    required this.dibayar,
  });

  final String nama;
  final int kaliPanen;
  final int panenKg;
  final int terjualKg;
  final int penjualan;
  final int dibayar;

  int get belumDibayar => penjualan - dibayar;
  int get rataRataPerKg => terjualKg == 0 ? 0 : (penjualan / terjualKg).round();
}

/// Rekap catatan yang panennya jatuh dalam satu periode (M11 Laporan, M20).
class Ringkasan {
  Ringkasan(this.transaksi);

  final List<Transaksi> transaksi;

  Iterable<Transaksi> get _terjual => transaksi.where((t) => t.sudahDijual);

  int get totalPenjualan => _terjual.fold(0, (s, t) => s + t.totalPenjualan);
  int get sudahDibayar => _terjual.fold(0, (s, t) => s + t.totalDibayar);
  int get belumDibayar => totalPenjualan - sudahDibayar;
  int get hasilPanenKg => transaksi.fold(0, (s, t) => s + t.beratPanenKg);
  int get terjualKg => _terjual.fold(0, (s, t) => s + t.beratTerjualKg!);
  int get menungguKg => transaksi.where((t) => !t.sudahDijual).fold(0, (s, t) => s + t.beratPanenKg);
  int get rataRataPerKg => terjualKg == 0 ? 0 : (totalPenjualan / terjualKg).round();

  /// Nama sayur yang masih punya tagihan, mis. ["Bayam", "Kangkung"].
  List<String> get sayurBelumLunas => [
    for (final t in _terjual)
      if (t.sisaTagihan > 0 && !_dup(t)) t.komoditas,
  ];
  bool _dup(Transaksi t) =>
      _terjual.takeWhile((x) => x != t).any((x) => x.komoditas == t.komoditas && x.sisaTagihan > 0);

  /// Per sayur, urut dari penjualan terbesar.
  List<RingkasanSayur> get perSayur {
    final nama = <String>{for (final t in transaksi) t.komoditas};
    return [
      for (final n in nama)
        () {
          final ts = transaksi.where((t) => t.komoditas == n);
          final jual = ts.where((t) => t.sudahDijual);
          return RingkasanSayur(
            nama: n,
            kaliPanen: ts.length,
            panenKg: ts.fold(0, (s, t) => s + t.beratPanenKg),
            terjualKg: jual.fold(0, (s, t) => s + t.beratTerjualKg!),
            penjualan: jual.fold(0, (s, t) => s + t.totalPenjualan),
            dibayar: jual.fold(0, (s, t) => s + t.totalDibayar),
          );
        }(),
    ]..sort((a, b) => b.penjualan.compareTo(a.penjualan));
  }
}
