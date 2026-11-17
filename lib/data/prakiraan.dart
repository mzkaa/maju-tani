import 'dart:math' as math;

/// Metode peramalan harga bulan depan dari deret harga rata-rata per bulan.
enum MetodePrakiraan {
  rataRataBergerak('Rata-rata bergerak 3 bulan'),
  pemulusanEksponensial('Pemulusan eksponensial'),
  trenLinear('Tren linear');

  const MetodePrakiraan(this.label);
  final String label;
}

/// Hasil peramalan harga satu komoditas untuk bulan berikutnya.
class HasilPrakiraan {
  const HasilPrakiraan({
    required this.hargaPerKg,
    required this.metode,
    required this.jumlahData,
    required this.mape,
  });

  /// Prakiraan harga bulan depan (rupiah per kg).
  final int hargaPerKg;
  final MetodePrakiraan metode;
  final int jumlahData;

  /// Rata-rata galat persentase mutlak (MAPE, dalam %) dari uji mundur; null bila data belum cukup untuk diuji.
  final double? mape;

  /// Kepercayaan kasar dari MAPE: di bawah 5% tinggi, 5–10% cukup, di atasnya rendah.
  /// Null bila belum bisa diukur.
  String? get kepercayaan => switch (mape) {
    null => null,
    < 5 => 'Tinggi',
    < 10 => 'Cukup',
    _ => 'Rendah',
  };
}

/// Perhitungan prakiraan harga. Semua metode dihitung dari deret bulanan [y] (lama → baru).
///
/// Tiga metode dicoba dan dipilih yang galatnya terkecil pada uji mundur
/// (meramal tiap bulan dari bulan-bulan sebelumnya lalu dibandingkan dengan harga sebenarnya).
abstract final class Prakiraan {
  /// Bulan minimum untuk menampilkan prakiraan.
  static const minimumData = 2;

  /// Bulan minimum agar metode bisa dibandingkan dengan uji mundur.
  static const minimumUjiMundur = 4;

  static const _alpha = 0.5;
  static const _jendela = 3;

  /// Rata-rata [_jendela] bulan terakhir.
  static double rataRataBergerak(List<double> y) {
    final ambil = y.sublist(math.max(0, y.length - _jendela));
    return ambil.reduce((a, b) => a + b) / ambil.length;
  }

  /// Pemulusan eksponensial tunggal: S₁ = y₁, Sₜ = α·yₜ + (1−α)·Sₜ₋₁ dengan α = 0,5.
  /// Prakiraan bulan depan = Sₜ terakhir.
  static double pemulusanEksponensial(List<double> y) {
    var s = y.first;
    for (final nilai in y.skip(1)) {
      s = _alpha * nilai + (1 - _alpha) * s;
    }
    return s;
  }

  /// Garis tren kuadrat terkecil ŷ = a + b·x (x = 0, 1, 2, …) dihitung untuk x berikutnya.
  static double trenLinear(List<double> y) {
    final n = y.length;
    if (n == 1) return y.first;
    final rataX = (n - 1) / 2;
    final rataY = y.reduce((a, b) => a + b) / n;
    var atas = 0.0;
    var bawah = 0.0;
    for (var x = 0; x < n; x++) {
      atas += (x - rataX) * (y[x] - rataY);
      bawah += (x - rataX) * (x - rataX);
    }
    final b = atas / bawah;
    final a = rataY - b * rataX;
    return a + b * n;
  }

  static double _ramal(MetodePrakiraan m, List<double> y) => switch (m) {
    MetodePrakiraan.rataRataBergerak => rataRataBergerak(y),
    MetodePrakiraan.pemulusanEksponensial => pemulusanEksponensial(y),
    MetodePrakiraan.trenLinear => trenLinear(y),
  };

  /// MAPE uji mundur: meramal yₜ dari y₀..yₜ₋₁ untuk tiap t ≥ 2, lalu rata-rata |yₜ − ŷₜ| / yₜ × 100.
  static double? mape(MetodePrakiraan m, List<double> y) {
    if (y.length < minimumUjiMundur) return null;
    var jumlah = 0.0;
    var banyak = 0;
    for (var t = 2; t < y.length; t++) {
      if (y[t] == 0) continue;
      jumlah += ((y[t] - _ramal(m, y.sublist(0, t))).abs() / y[t]) * 100;
      banyak++;
    }
    return banyak == 0 ? null : jumlah / banyak;
  }

  /// Prakiraan harga bulan depan dari harga per kg tiap bulan (lama → baru); null bila data kurang dari [minimumData].
  ///
  /// Data 2–3 bulan: tren linear saja (belum bisa diuji). Data ≥ 4 bulan: metode dengan MAPE terkecil.
  static HasilPrakiraan? hitung(List<int> harga) {
    if (harga.length < minimumData) return null;
    final y = [for (final h in harga) h.toDouble()];

    var terbaik = MetodePrakiraan.trenLinear;
    double? mapeTerbaik;
    if (y.length >= minimumUjiMundur) {
      for (final m in MetodePrakiraan.values) {
        final galat = mape(m, y);
        if (galat != null && (mapeTerbaik == null || galat < mapeTerbaik)) {
          terbaik = m;
          mapeTerbaik = galat;
        }
      }
    }
    final nilai = math.max(0, _ramal(terbaik, y)).round();
    return HasilPrakiraan(hargaPerKg: nilai, metode: terbaik, jumlahData: y.length, mape: mapeTerbaik);
  }
}
