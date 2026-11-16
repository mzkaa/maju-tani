import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/komoditas.dart';
import '../models/transaksi.dart';

/// Satu-satunya akun pemilik di HP ini.
typedef AkunTersimpan = ({String namaPengguna, String garam, String hashSandi});

/// Isi database saat aplikasi dibuka.
typedef DataTersimpan = ({
  List<Transaksi> transaksi,
  List<Komoditas> komoditas,
  Map<String, String> pengaturan,
  Set<String> notifDibaca,
  AkunTersimpan? akun,
});

/// Database lokal (SQLite) di HP. Semua tanggal disimpan sebagai milidetik.
class Penyimpanan {
  Penyimpanan._(this._factory, this._db);

  final DatabaseFactory _factory;
  final Database _db;

  /// Komoditas awal saat aplikasi pertama kali dipasang.
  static const _komoditasAwal = ['Sawi', 'Bayam', 'Kangkung', 'Selada', 'Daun Bawang'];

  /// Membuka database aplikasi; [lokasi] diisi saat test (mis. [inMemoryDatabasePath]).
  static Future<Penyimpanan> buka({String? lokasi, DatabaseFactory? factory}) async {
    final f = factory ?? databaseFactory;
    final path = lokasi ?? p.join(await f.getDatabasesPath(), 'maju_tani.db');
    final db = await f.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, versi) async {
          await _buatTabel(db);
          await _buatTabelAkun(db);
        },
        onUpgrade: (db, lama, baru) async {
          if (lama < 2) await _buatTabelAkun(db);
        },
      ),
    );
    return Penyimpanan._(f, db);
  }

  /// Versi 2: akun pemilik (hanya satu baris).
  static Future<void> _buatTabelAkun(Database db) => db.execute('''
    CREATE TABLE akun (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      nama_pengguna TEXT NOT NULL,
      garam TEXT NOT NULL,
      hash_sandi TEXT NOT NULL
    )''');

  static Future<void> _buatTabel(Database db) async {
    final b = db.batch()
      ..execute('''
        CREATE TABLE komoditas (
          nama TEXT PRIMARY KEY,
          aktif INTEGER NOT NULL,
          satuan TEXT NOT NULL,
          harga_acuan INTEGER
        )''')
      ..execute('''
        CREATE TABLE transaksi (
          id TEXT PRIMARY KEY,
          nomor TEXT NOT NULL,
          komoditas TEXT NOT NULL,
          tanggal_panen INTEGER NOT NULL,
          berat_panen_kg INTEGER NOT NULL,
          tanggal_jual INTEGER,
          berat_terjual_kg INTEGER,
          harga_per_kg INTEGER,
          pembeli TEXT
        )''')
      ..execute('''
        CREATE TABLE pembayaran (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transaksi_id TEXT NOT NULL REFERENCES transaksi(id) ON DELETE CASCADE,
          tanggal INTEGER NOT NULL,
          jumlah INTEGER NOT NULL
        )''')
      ..execute('CREATE TABLE pengaturan (kunci TEXT PRIMARY KEY, nilai TEXT NOT NULL)')
      ..execute('CREATE TABLE notif_dibaca (id TEXT PRIMARY KEY)');
    for (final nama in _komoditasAwal) {
      b.insert('komoditas', _barisKomoditas(Komoditas(nama: nama)));
    }
    await b.commit(noResult: true);
  }

  Future<DataTersimpan> muat() async {
    final bayar = <String, List<Pembayaran>>{};
    for (final r in await _db.query('pembayaran', orderBy: 'tanggal, id')) {
      bayar
          .putIfAbsent(r['transaksi_id']! as String, () => [])
          .add(Pembayaran(tanggal: _tanggal(r['tanggal'])!, jumlah: r['jumlah']! as int));
    }
    return (
      transaksi: [
        for (final r in await _db.query('transaksi'))
          Transaksi(
            id: r['id']! as String,
            nomor: r['nomor']! as String,
            komoditas: r['komoditas']! as String,
            tanggalPanen: _tanggal(r['tanggal_panen'])!,
            beratPanenKg: r['berat_panen_kg']! as int,
            tanggalJual: _tanggal(r['tanggal_jual']),
            beratTerjualKg: r['berat_terjual_kg'] as int?,
            hargaPerKg: r['harga_per_kg'] as int?,
            pembeli: r['pembeli'] as String?,
            pembayaran: bayar[r['id']] ?? const [],
          ),
      ],
      // Urutan rowid = urutan ditambahkan (tetap walau nama diubah).
      komoditas: [
        for (final r in await _db.query('komoditas', orderBy: 'rowid'))
          Komoditas(
            nama: r['nama']! as String,
            aktif: r['aktif'] == 1,
            satuan: r['satuan']! as String,
            hargaAcuan: r['harga_acuan'] as int?,
          ),
      ],
      pengaturan: {
        for (final r in await _db.query('pengaturan')) r['kunci']! as String: r['nilai']! as String,
      },
      notifDibaca: {for (final r in await _db.query('notif_dibaca')) r['id']! as String},
      akun: [
        for (final r in await _db.query('akun'))
          (
            namaPengguna: r['nama_pengguna']! as String,
            garam: r['garam']! as String,
            hashSandi: r['hash_sandi']! as String,
          ),
      ].firstOrNull,
    );
  }

  /// Menyimpan satu catatan beserta seluruh pembayarannya.
  Future<void> simpanTransaksi(Transaksi t) => _db.transaction((tx) async {
    await tx.insert('transaksi', {
      'id': t.id,
      'nomor': t.nomor,
      'komoditas': t.komoditas,
      'tanggal_panen': t.tanggalPanen.millisecondsSinceEpoch,
      'berat_panen_kg': t.beratPanenKg,
      'tanggal_jual': t.tanggalJual?.millisecondsSinceEpoch,
      'berat_terjual_kg': t.beratTerjualKg,
      'harga_per_kg': t.hargaPerKg,
      'pembeli': t.pembeli,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await tx.delete('pembayaran', where: 'transaksi_id = ?', whereArgs: [t.id]);
    for (final b in t.pembayaran) {
      await tx.insert('pembayaran', {
        'transaksi_id': t.id,
        'tanggal': b.tanggal.millisecondsSinceEpoch,
        'jumlah': b.jumlah,
      });
    }
  });

  Future<void> tambahKomoditas(Komoditas k) => _db.insert('komoditas', _barisKomoditas(k));

  /// Mengubah komoditas; bila namanya berubah, catatan panennya ikut diganti.
  Future<void> ubahKomoditas(String namaLama, Komoditas k) => _db.transaction((tx) async {
    await tx.update('komoditas', _barisKomoditas(k), where: 'nama = ?', whereArgs: [namaLama]);
    if (k.nama != namaLama) {
      await tx.update('transaksi', {'komoditas': k.nama}, where: 'komoditas = ?', whereArgs: [namaLama]);
    }
  });

  Future<void> simpanPengaturan(String kunci, String nilai) =>
      _db.insert('pengaturan', {'kunci': kunci, 'nilai': nilai}, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> hapusPengaturan(String kunci) => _db.delete('pengaturan', where: 'kunci = ?', whereArgs: [kunci]);

  Future<void> simpanAkun(AkunTersimpan a) => _db.insert('akun', {
    'id': 1,
    'nama_pengguna': a.namaPengguna,
    'garam': a.garam,
    'hash_sandi': a.hashSandi,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> tandaiNotifDibaca(String id) =>
      _db.insert('notif_dibaca', {'id': id}, conflictAlgorithm: ConflictAlgorithm.ignore);

  /// Isi file database, untuk dicadangkan.
  Future<Uint8List> cadangan() => _factory.readDatabaseBytes(_db.path);

  Future<void> tutup() => _db.close();

  static Map<String, Object?> _barisKomoditas(Komoditas k) => {
    'nama': k.nama,
    'aktif': k.aktif ? 1 : 0,
    'satuan': k.satuan,
    'harga_acuan': k.hargaAcuan,
  };

  static DateTime? _tanggal(Object? ms) => ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms as int);
}
