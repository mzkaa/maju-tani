import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart'
    show ChangeNotifier, DateUtils, ErrorDescription, FlutterError, FlutterErrorDetails;

import 'database.dart';
import 'dokumen.dart';
import 'format.dart';
import 'kata_sandi.dart';

import '../models/draft_panen.dart';
import '../models/harga_bulanan.dart';
import '../models/komoditas.dart';
import '../models/notifikasi.dart';
import '../models/ringkasan.dart';
import '../models/transaksi.dart';
import 'sample_data.dart';

/// Ukuran huruf aplikasi (M30). Desain Figma memakai "Besar".
enum UkuranHuruf {
  sedang(0.9),
  besar(1),
  sangatBesar(1.15);

  const UkuranHuruf(this.skala);
  final double skala;
}

/// Pilihan periode di Laporan.
enum PilihanPeriode { bulanIni, bulanLalu, pilihTanggal }

/// Sumber data aplikasi (Provider). Data dibaca dari memori; setiap
/// perubahan juga ditulis ke database lokal bila ada ([AppStore.dariDatabase]).
class AppStore extends ChangeNotifier {
  /// Data contoh di memori dengan tanggal tetap seperti Figma (test & pratinjau).
  AppStore()
    : _db = null,
      _transaksi = List.of(SampleData.transaksi),
      _komoditas = List.of(SampleData.komoditas),
      _hariIniTetap = SampleData.hariIni,
      _periodeAwalTetap = SampleData.periodeAwal,
      _hargaContoh = SampleData.hargaBulanan,
      _namaPengguna = SampleData.namaPengguna,
      _sudahMasuk = true;

  /// Data dari database lokal; tanggal mengikuti jam HP.
  AppStore.dariDatabase(Penyimpanan db, DataTersimpan data)
    : _db = db,
      _transaksi = List.of(data.transaksi),
      _komoditas = List.of(data.komoditas),
      _hariIniTetap = null,
      _periodeAwalTetap = null,
      _hargaContoh = null,
      _akun = data.akun,
      _namaPengguna = data.akun?.namaPengguna,
      _sudahMasuk = data.akun != null && data.pengaturan[_kunciSesi] == '1' {
    ukuranHuruf = UkuranHuruf.values.asNameMap()[data.pengaturan[_kunciUkuranHuruf]] ?? ukuranHuruf;
    _terakhirDicadangkan = DateTime.tryParse(data.pengaturan[_kunciCadangan] ?? '');
    _notifDibaca.addAll(data.notifDibaca);
  }

  final Penyimpanan? _db;
  final List<Transaksi> _transaksi;
  final List<Komoditas> _komoditas;
  final DateTime? _hariIniTetap;
  final DateTime? _periodeAwalTetap;
  final Map<String, List<HargaBulanan>>? _hargaContoh;

  /// True bila memakai data contoh (tanpa database).
  bool get dataContoh => _db == null;

  DateTime get hariIni => _hariIniTetap ?? DateTime.now();

  /// Awal periode ringkasan & laporan; akhirnya [hariIni]. Biasanya tanggal 1 bulan ini;
  /// di data contoh 1 Okt – 5 Nov 2026, sama seperti angka di Figma.
  DateTime get periodeAwal => _periodeAwalTetap ?? DateTime(hariIni.year, hariIni.month);

  Future<void> _antrean = Future.value();

  /// Menulis ke database berurutan di belakang layar; galat dilaporkan ke log.
  void _tulis(Future<void> Function(Penyimpanan db) aksi) {
    final db = _db;
    if (db == null) return;
    _antrean = _antrean.then((_) => aksi(db)).catchError((Object e, StackTrace s) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: s, context: ErrorDescription('saat menyimpan ke database')),
      );
    });
  }

  /// Selesai saat semua perubahan sudah tertulis ke database.
  Future<void> get selesaiMenyimpan => _antrean;

  /// Nama di sapaan Beranda & Akun: nama pengguna akun (data contoh: "Pak Pemilik").
  String get namaPemilik => dataContoh ? SampleData.namaPemilik : (_namaPengguna ?? '');

  // ---------------------------------------------------------------------------
  // Akun (M01, M15, M23). Satu akun pemilik per HP.

  static const _kunciSesi = 'sesi_masuk';

  AkunTersimpan? _akun;
  String? _namaPengguna;
  bool _sudahMasuk;

  /// Kata sandi akun contoh (hanya untuk data contoh, tanpa database).
  String _sandiContoh = SampleData.kataSandi;

  String? get namaPengguna => _namaPengguna;

  /// False saat aplikasi baru dipasang: layar Masuk meminta membuat akun.
  bool get punyaAkun => _namaPengguna != null;

  bool get sudahMasuk => _sudahMasuk;

  /// Nama pengguna tidak membedakan huruf besar/kecil.
  static String _rapikan(String nama) => nama.trim().toLowerCase();

  Future<void> buatAkun(String nama, String sandi) async {
    await _simpanSandi(sandi, namaPengguna: _rapikan(nama));
    _aturSesi(true);
  }

  /// Mengembalikan false bila nama pengguna atau kata sandi salah.
  Future<bool> masuk(String nama, String sandi) async {
    if (!punyaAkun || _rapikan(nama) != _namaPengguna || !await _sandiCocok(sandi)) return false;
    _aturSesi(true);
    return true;
  }

  void keluar() => _aturSesi(false);

  /// Mengembalikan false bila kata sandi lama salah.
  Future<bool> ubahSandi(String lama, String baru) async {
    if (!await _sandiCocok(lama)) return false;
    await _simpanSandi(baru, namaPengguna: _namaPengguna!);
    return true;
  }

  Future<bool> _sandiCocok(String sandi) async {
    if (dataContoh) return sandi == _sandiContoh;
    final akun = _akun;
    return akun != null && KataSandi.sama(await KataSandi.hash(sandi, akun.garam), akun.hashSandi);
  }

  Future<void> _simpanSandi(String sandi, {required String namaPengguna}) async {
    _namaPengguna = namaPengguna;
    if (dataContoh) {
      _sandiContoh = sandi;
      return;
    }
    final garam = KataSandi.garamBaru();
    final akun = (namaPengguna: namaPengguna, garam: garam, hashSandi: await KataSandi.hash(sandi, garam));
    _akun = akun;
    _tulis((db) => db.simpanAkun(akun));
  }

  void _aturSesi(bool masuk) {
    _sudahMasuk = masuk;
    _tulis((db) => masuk ? db.simpanPengaturan(_kunciSesi, '1') : db.hapusPengaturan(_kunciSesi));
    notifyListeners();
  }

  List<Transaksi> get transaksi => List.unmodifiable(_transaksi);

  Transaksi? cariTransaksi(String id) {
    for (final t in _transaksi) {
      if (t.id == id) return t;
    }
    return null;
  }

  bool _dalamPeriode(DateTime d) => !d.isBefore(periodeAwal) && !d.isAfter(hariIni.add(const Duration(days: 1)));

  // ---------------------------------------------------------------------------
  // Ringkasan Beranda & Laporan (dalam periode)

  /// Uang yang sudah diterima.
  int get uangMasuk =>
      _transaksi.expand((t) => t.pembayaran).where((p) => _dalamPeriode(p.tanggal)).fold(0, (s, p) => s + p.jumlah);

  /// Total tagihan yang belum dibayar pembeli.
  int get belumDibayar => _transaksi.fold(0, (s, t) => s + (t.sudahDijual ? t.sisaTagihan : 0));

  /// Bagian uang yang sudah masuk dibanding semua uang (masuk + belum dibayar).
  double get persenSudahMasuk {
    final total = uangMasuk + belumDibayar;
    return total == 0 ? 0 : uangMasuk / total;
  }

  /// Total berat panen.
  int get hasilPanenKg => _transaksi.where((t) => _dalamPeriode(t.tanggalPanen)).fold(0, (s, t) => s + t.beratPanenKg);

  int jumlahStatus(StatusTransaksi s) => _transaksi.where((t) => t.status == s).length;

  int get jumlahBelumLunas =>
      jumlahStatus(StatusTransaksi.menungguPembayaran) + jumlahStatus(StatusTransaksi.dibayarSebagian);

  /// Urutan tampil: belum dijual, belum dibayar, dibayar sebagian, lalu lunas; terbaru dulu.
  int _urutan(Transaksi a, Transaksi b) {
    final s = a.status.index.compareTo(b.status.index);
    return s != 0 ? s : b.tanggalPanen.compareTo(a.tanggalPanen);
  }

  /// Catatan yang perlu diurus (belum lunas).
  List<Transaksi> get perluDiurus => _transaksi.where((t) => t.status != StatusTransaksi.lunas).toList()..sort(_urutan);

  /// Catatan pertama yang menunggu status tertentu (untuk menu cepat).
  Transaksi? pertamaDenganStatus(Set<StatusTransaksi> status) {
    for (final t in perluDiurus) {
      if (status.contains(t.status)) return t;
    }
    return null;
  }

  /// Semua catatan untuk Riwayat.
  List<Transaksi> get riwayat => List.of(_transaksi)..sort(_urutan);

  /// Komoditas aktif pertama yang punya cukup riwayat harga untuk grafik (Beranda).
  String? get sayurHargaBeranda => sayurDenganRiwayatHarga.firstOrNull;

  /// Komoditas aktif yang punya minimal 2 bulan harga.
  List<String> get sayurDenganRiwayatHarga => [
    for (final k in komoditasAktif)
      if (riwayatHarga(k.nama).length >= 2) k.nama,
  ];

  List<HargaBulanan> riwayatHarga(String komoditas) =>
      _hargaContoh?[komoditas] ?? _hargaDariPenjualan(komoditas);

  /// Rata-rata harga per kg tiap bulan dari penjualan; 6 bulan terakhir yang ada penjualannya.
  List<HargaBulanan> _hargaDariPenjualan(String nama) {
    final perBulan = <DateTime, (int, int)>{}; // rupiah, kg
    for (final t in _transaksiSayur(nama)) {
      if (!t.sudahDijual || t.beratTerjualKg! <= 0) continue;
      final bulan = DateTime(t.tanggalJual!.year, t.tanggalJual!.month);
      final (rp, kg) = perBulan[bulan] ?? (0, 0);
      perBulan[bulan] = (rp + t.totalPenjualan, kg + t.beratTerjualKg!);
    }
    final bulan = perBulan.keys.toList()..sort();
    return [
      for (final b in bulan.skip(math.max(0, bulan.length - 6)))
        HargaBulanan(bulan: b, hargaPerKg: (perBulan[b]!.$1 / perBulan[b]!.$2).round()),
    ];
  }

  // ---------------------------------------------------------------------------
  // Penjualan & pembayaran (M09, M10)

  /// Waktu kejadian: tanggal yang dipilih + jam saat ini.
  DateTime _waktu(DateTime tanggal) => DateTime(tanggal.year, tanggal.month, tanggal.day, hariIni.hour, hariIni.minute);

  void _ganti(String id, Transaksi Function(Transaksi t) ubah) {
    final i = _transaksi.indexWhere((t) => t.id == id);
    if (i < 0) return;
    final baru = _transaksi[i] = ubah(_transaksi[i]);
    _tulis((db) => db.simpanTransaksi(baru));
    notifyListeners();
  }

  /// M09: status berubah menjadi Menunggu Pembayaran.
  void lengkapiPenjualan(String id, {required DateTime tanggal, required int beratKg, required int hargaPerKg}) =>
      _ganti(id, (t) => t.copyWith(tanggalJual: _waktu(tanggal), beratTerjualKg: beratKg, hargaPerKg: hargaPerKg));

  /// M10: menambah satu pembayaran (cicilan atau pelunasan).
  void catatPembayaran(String id, {required DateTime tanggal, required int jumlah}) => _ganti(
    id,
    (t) => t.copyWith(
      pembayaran: [
        ...t.pembayaran,
        Pembayaran(tanggal: _waktu(tanggal), jumlah: jumlah),
      ],
    ),
  );

  /// Rekap catatan yang dipanen antara [awal] dan [akhir] (termasuk).
  Ringkasan ringkasan(DateTime awal, DateTime akhir) {
    final batasAkhir = DateTime(akhir.year, akhir.month, akhir.day + 1);
    return Ringkasan(
      _transaksi.where((t) => !t.tanggalPanen.isBefore(awal) && t.tanggalPanen.isBefore(batasAkhir)).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Periode laporan (M11, M24)

  PilihanPeriode pilihanPeriode = PilihanPeriode.bulanIni;
  DateTime? _pilihAwal;
  DateTime? _pilihAkhir;

  /// "Bulan ini" di data contoh = [periodeAwal] – [hariIni] (1 Okt – 5 Nov 2026), seperti di Figma.
  (DateTime, DateTime) get periodeLaporan => switch (pilihanPeriode) {
    PilihanPeriode.bulanIni => (periodeAwal, hariIni),
    PilihanPeriode.bulanLalu => (
      DateTime(hariIni.year, hariIni.month - 1, 1),
      DateTime(hariIni.year, hariIni.month, 0),
    ),
    PilihanPeriode.pilihTanggal => (_pilihAwal ?? periodeAwal, _pilihAkhir ?? hariIni),
  };

  void aturPeriode(PilihanPeriode p, {DateTime? awal, DateTime? akhir}) {
    pilihanPeriode = p;
    if (awal != null) _pilihAwal = awal;
    if (akhir != null) _pilihAkhir = akhir;
    notifyListeners();
  }

  /// M18: mengubah data panen & penjualan.
  void ubahTransaksi(
    String id, {
    required DateTime tanggalPanen,
    required int beratPanenKg,
    String? pembeli,
    DateTime? tanggalJual,
    int? beratTerjualKg,
    int? hargaPerKg,
  }) => _ganti(
    id,
    (t) => t.copyWith(
      tanggalPanen: tanggalPanen,
      beratPanenKg: beratPanenKg,
      pembeli: pembeli,
      tanggalJual: tanggalJual,
      beratTerjualKg: beratTerjualKg,
      hargaPerKg: hargaPerKg,
    ),
  );

  // ---------------------------------------------------------------------------
  // Notifikasi (M16)

  final _notifDibaca = <String>{};

  /// Pemberitahuan dari data: belum dijual, belum dibayar, dan pembayaran 3 hari terakhir.
  List<Notifikasi> get notifikasi {
    int hari(DateTime d) => DateUtils.dateOnly(hariIni).difference(DateUtils.dateOnly(d)).inDays;
    final hasil = <Notifikasi>[
      for (final t in perluDiurus)
        if (t.status == StatusTransaksi.menungguPenjualan)
          Notifikasi(
            id: 'jual-${t.id}',
            jenis: JenisNotifikasi.belumDijual,
            judul: '${t.komoditas} ${t.beratPanenKg} kg belum ada harga jual',
            keterangan: 'Tekan untuk lengkapi penjualan · ${hari(t.tanggalPanen)} hari lalu',
            transaksiId: t.id,
          )
        else if (t.status == StatusTransaksi.menungguPembayaran)
          Notifikasi(
            id: 'bayar-${t.id}',
            jenis: JenisNotifikasi.belumDibayar,
            judul: '${t.komoditas} ${Format.rupiah(t.totalPenjualan)} belum dibayar',
            keterangan: '${t.pembeli ?? '-'} · sudah ${hari(t.tanggalJual ?? t.tanggalPanen)} hari',
            transaksiId: t.id,
          ),
      for (final t in _transaksi)
        for (final p in t.pembayaran)
          if (hari(p.tanggal) <= 3)
            Notifikasi(
              id: 'masuk-${t.id}-${p.tanggal.millisecondsSinceEpoch}',
              jenis: JenisNotifikasi.pembayaranMasuk,
              judul: 'Pembayaran ${t.komoditas} masuk',
              keterangan:
                  '${Format.rupiah(p.jumlah)} dari ${t.pembeli ?? '-'} · ${Format.tanggalPendekTanpaNol(p.tanggal)}',
              transaksiId: t.id,
              dibacaAwal: true,
            ),
    ];
    return [for (final n in hasil) n.denganDibaca(n.dibacaAwal || _notifDibaca.contains(n.id))];
  }

  void tandaiDibaca(String id) {
    if (!_notifDibaca.add(id)) return;
    _tulis((db) => db.tandaiNotifDibaca(id));
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Pengaturan (M30)

  static const _kunciUkuranHuruf = 'ukuran_huruf';

  UkuranHuruf ukuranHuruf = UkuranHuruf.besar;

  void aturUkuranHuruf(UkuranHuruf u) {
    ukuranHuruf = u;
    _tulis((db) => db.simpanPengaturan(_kunciUkuranHuruf, u.name));
    notifyListeners();
  }

  static const _kunciCadangan = 'terakhir_dicadangkan';

  DateTime? _terakhirDicadangkan;

  /// Null = belum pernah dicadangkan.
  DateTime? get terakhirDicadangkan => dataContoh ? SampleData.terakhirDicadangkan : _terakhirDicadangkan;

  /// Isi database setelah semua perubahan tertulis; null untuk data contoh.
  Future<Uint8List?> dataCadangan() async {
    await selesaiMenyimpan;
    return _db?.cadangan();
  }

  void tandaiDicadangkan() {
    final sekarang = DateTime.now();
    _terakhirDicadangkan = sekarang;
    _tulis((db) => db.simpanPengaturan(_kunciCadangan, sekarang.toIso8601String()));
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Cetak & Unduh (M25–M27)

  JenisDokumen jenisDokumen = JenisDokumen.penjualan;
  bool formatPdf = true;

  void aturDokumen({JenisDokumen? jenis, bool? pdf}) {
    if (jenis != null) jenisDokumen = jenis;
    if (pdf != null) formatPdf = pdf;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Komoditas

  List<Komoditas> get komoditas => List.unmodifiable(_komoditas);

  Iterable<Transaksi> _transaksiSayur(String nama) => _transaksi.where((t) => t.komoditas == nama);

  int kaliPanen(String nama) => _transaksiSayur(nama).length;

  int totalPanenKg(String nama) => _transaksiSayur(nama).fold(0, (s, t) => s + t.beratPanenKg);

  /// Harga jual terbaru; bila belum pernah terjual, pakai harga acuan komoditas.
  int? hargaTerakhir(String nama) {
    final terjual = _transaksiSayur(nama).where((t) => t.sudahDijual).toList()
      ..sort((a, b) => b.tanggalJual!.compareTo(a.tanggalJual!));
    if (terjual.isNotEmpty) return terjual.first.hargaPerKg;
    for (final k in _komoditas) {
      if (k.nama == nama) return k.hargaAcuan;
    }
    return null;
  }

  void tambahKomoditas(Komoditas k) {
    _komoditas.add(k);
    _tulis((db) => db.tambahKomoditas(k));
    notifyListeners();
  }

  /// Bila namanya berubah, catatan panen komoditas itu ikut memakai nama baru.
  void ubahKomoditas(String namaLama, Komoditas baru) {
    final i = _komoditas.indexWhere((k) => k.nama == namaLama);
    if (i < 0) return;
    _komoditas[i] = baru;
    if (baru.nama != namaLama) {
      for (final (j, t) in _transaksi.indexed) {
        if (t.komoditas == namaLama) _transaksi[j] = t.copyWith(komoditas: baru.nama);
      }
    }
    _tulis((db) => db.ubahKomoditas(namaLama, baru));
    notifyListeners();
  }

  /// Saringan daftar komoditas (M12, diatur di M29): null = semua, true = aktif, false = nonaktif.
  bool? saringKomoditas;

  void aturSaringKomoditas(bool? aktif) {
    saringKomoditas = aktif;
    notifyListeners();
  }

  /// Komoditas yang ditampilkan saat Catat Panen.
  List<Komoditas> get komoditasAktif => _komoditas.where((k) => k.aktif).toList();

  // ---------------------------------------------------------------------------
  // Catat Panen (M05–M08)

  DraftPanen? _draft;

  /// Isian Catat Panen yang sedang berjalan. Di data contoh terisi seperti di Figma.
  DraftPanen get draftPanen => _draft ??= DraftPanen(
    komoditas: komoditasAktif.firstOrNull?.nama ?? '',
    tanggal: hariIni,
    beratKg: dataContoh ? SampleData.contohBeratPanen : null,
    pengepul: dataContoh ? SampleData.contohPengepul : '',
  );

  void ubahDraft(void Function(DraftPanen d) ubah) {
    ubah(draftPanen);
    notifyListeners();
  }

  /// Menyimpan draft sebagai catatan baru (status Menunggu Penjualan); mengembalikan id-nya.
  String simpanPanen() {
    final d = draftPanen;
    final angka = _transaksi.map((t) => int.tryParse(t.nomor.substring(3)) ?? 0).fold(0, math.max) + 1;
    final id = 't$angka';
    _transaksi.add(
      Transaksi(
        id: id,
        nomor: 'PJ-${angka.toString().padLeft(3, '0')}',
        komoditas: d.komoditas,
        tanggalPanen: DateTime(d.tanggal.year, d.tanggal.month, d.tanggal.day, hariIni.hour, hariIni.minute),
        beratPanenKg: d.beratKg ?? 0,
        pembeli: d.pengepul.trim().isEmpty ? null : d.pengepul.trim(),
      ),
    );
    _draft = null;
    final baru = _transaksi.last;
    _tulis((db) => db.simpanTransaksi(baru));
    notifyListeners();
    return id;
  }

  /// Mulai Catat Panen dari awal (tombol "Catat Panen Lagi").
  void mulaiPanenBaru() {
    _draft = null;
    notifyListeners();
  }
}
