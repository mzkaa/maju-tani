import 'package:flutter_test/flutter_test.dart';
import 'package:maju_tani/data/app_store.dart';

void main() {
  // Angka ringkasan Beranda harus sama dengan desain Figma M02.
  test('Ringkasan Beranda dari data contoh', () {
    final store = AppStore();
    expect(store.uangMasuk, 1491000);
    expect(store.belumDibayar, 534000);
    expect((store.persenSudahMasuk * 100).round(), 74);
    expect(store.hasilPanenKg, 500);
    expect(store.jumlahBelumLunas, 2);
    expect(store.perluDiurus.map((t) => t.komoditas), ['Sawi', 'Bayam', 'Kangkung']);
  });
}
