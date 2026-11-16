import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_store.dart';
import '../data/format.dart';
import '../models/transaksi.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_layout.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import '../widgets/app_icon.dart';
import '../widgets/badge_status.dart';
import '../widgets/bilah_tombol.dart';
import '../widgets/header_ringkas.dart';
import '../widgets/indikator_langkah.dart';
import '../widgets/isi_formulir.dart';
import '../widgets/isian_kaca.dart';
import '../widgets/kerangka_halaman.dart';
import '../widgets/kotak_kaca.dart';
import '../widgets/kotak_lembut.dart';
import '../widgets/tombol.dart';
import 'penjualan_pembayaran_screens.dart';

// ---------------------------------------------------------------------------
// M05 Catat Panen – 1 Pilih Sayur

class PilihSayurScreen extends StatefulWidget {
  const PilihSayurScreen({super.key});

  @override
  State<PilihSayurScreen> createState() => _PilihSayurScreenState();
}

class _PilihSayurScreenState extends State<PilihSayurScreen> {
  bool _galat = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final dipilih = store.draftPanen.komoditas;
    // Sayur di draft bisa tidak sah lagi (komoditas diganti nama/dinonaktifkan): wajib pilih ulang.
    void lanjut() {
      setState(() => _galat = !store.sayurDraftSah);
      if (store.sayurDraftSah) context.push(Rute.catatPanenBerat);
    }

    return KerangkaHalaman(
      header: const HeaderRingkas(
        judul: 'Catat Hasil Panen',
        keterangan: 'Isi setelah sayur ditimbang pengepul',
        kiri: TombolKembali(),
      ),
      bilahBawah: BilahTombol(
        tombol: [TombolUtama(label: 'Lanjut', ikon: Ikon.arrowRight, onTap: lanjut)],
      ),
      isi: IsiFormulir(
        bawah: 94 - 17,
        jarak: 14,
        children: [
          const IndikatorLangkah(langkah: 1, teks: 'Langkah 1 dari 3: Pilih sayur'),
          Text('Sayur apa yang dipanen?', style: AppText.judulBagian),
          if (_galat && !store.sayurDraftSah)
            Text(
              store.komoditasAktif.isEmpty
                  ? 'Belum ada sayur aktif. Tambahkan atau aktifkan dulu di menu Komoditas.'
                  : 'Pilih dulu sayur yang dipanen.',
              style: AppText.pesanBantuan.copyWith(color: AppColors.galat),
            ),
          LayoutBuilder(
            builder: (context, c) {
              // Di Figma tiap pilihan 165 dari lebar 356 (sisa 14 di kanan).
              final lebar = (c.maxWidth - 26) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final k in store.komoditasAktif)
                    _PilihanSayur(
                      nama: k.nama,
                      lebar: lebar,
                      dipilih: k.nama == dipilih,
                      onTap: () => store.ubahDraft((d) => d.komoditas = k.nama),
                    ),
                ],
              );
            },
          ),
          KotakLembut(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIcon(Ikon.info, size: 24, color: AppColors.teksKedua),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sayur tidak ada di daftar? Tambahkan dulu di menu Komoditas.',
                    style: AppText.pesanBantuan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PilihanSayur extends StatelessWidget {
  const _PilihanSayur({required this.nama, required this.lebar, required this.dipilih, required this.onTap});

  final String nama;
  final double lebar;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isi = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dipilih ? AppColors.headerTengah : AppColors.pilihanIkonLatar,
            shape: BoxShape.circle,
          ),
          child: AppIcon(
            dipilih ? Ikon.check : Ikon.leaf,
            size: 28,
            color: dipilih ? const Color(0xFFFFFFFF) : AppColors.hijauTuaAlt,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          nama,
          style: AppText.judulBagian.copyWith(color: dipilih ? AppColors.hijauTuaAlt : AppColors.teksJudul),
          textAlign: TextAlign.center,
        ),
        if (dipilih) ...[const SizedBox(height: 10), Text('Dipilih', style: AppText.dipilih)],
      ],
    );

    if (!dipilih) {
      return KotakKaca(
        radius: 16,
        width: lebar,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        onTap: onTap,
        label: nama,
        child: isi,
      );
    }
    return Semantics(
      button: true,
      selected: true,
      label: nama,
      child: Container(
        width: lebar,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.lunasLatar,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.headerTengah, width: 3),
        ),
        child: isi,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M06 Catat Panen – 2 Berat & Tanggal

class BeratTanggalScreen extends StatefulWidget {
  const BeratTanggalScreen({super.key});

  @override
  State<BeratTanggalScreen> createState() => _BeratTanggalScreenState();
}

class _BeratTanggalScreenState extends State<BeratTanggalScreen> {
  late final AppStore _store = context.read<AppStore>();
  late final _berat = TextEditingController(text: _store.draftPanen.beratKg?.toString() ?? '');
  late final _pengepul = TextEditingController(text: _store.draftPanen.pengepul);
  String? _galatBerat;

  @override
  void dispose() {
    _berat.dispose();
    _pengepul.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final d = _store.draftPanen;
    final hasil = await showDatePicker(
      context: context,
      initialDate: d.tanggal,
      firstDate: DateTime(_store.hariIni.year - 1),
      lastDate: _store.hariIni,
    );
    if (hasil != null) _store.ubahDraft((d) => d.tanggal = hasil);
  }

  void _lanjut() {
    final berat = int.tryParse(_berat.text.trim());
    if (berat == null || berat <= 0) {
      setState(() => _galatBerat = 'Isi berat dalam kg, misalnya 120');
      return;
    }
    setState(() => _galatBerat = null);
    _store.ubahDraft((d) {
      d.beratKg = berat;
      d.pengepul = _pengepul.text;
    });
    FocusScope.of(context).unfocus();
    context.push(Rute.catatPanenPeriksa);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final d = store.draftPanen;

    return KerangkaHalaman(
      header: HeaderRingkas(
        judul: 'Catat Hasil Panen',
        keterangan: 'Sayur dipilih: ${d.komoditas}',
        kiri: const TombolKembali(),
      ),
      bilahBawah: BilahTombol(
        tombol: [
          TombolUtama(label: 'Lanjut', ikon: Ikon.arrowRight, onTap: _lanjut),
          TombolGaris(label: 'Kembali', ikon: Ikon.arrowLeft, onTap: () => context.kembali()),
        ],
      ),
      isi: IsiFormulir(
        bawah: 145 - 17,
        jarak: 15,
        children: [
          const IndikatorLangkah(langkah: 2, teks: 'Langkah 2 dari 3: Isi berat & tanggal'),
          IsianKaca(
            label: 'Tanggal panen',
            ikon: Ikon.calendar,
            nilaiTetap: Format.tanggalIsian(d.tanggal, store.hariIni),
            onTap: _pilihTanggal,
            akhiran: const AppIcon(Ikon.chevronDown, size: 24, color: AppColors.teksKedua),
            bantuan: 'Tekan untuk mengganti tanggal',
          ),
          IsianKaca(
            label: 'Berat hasil panen',
            ikon: Ikon.scale,
            controller: _berat,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            akhiran: Text('kg', style: AppText.akhiranIsian),
            bantuan: 'Lihat angka di timbangan pengepul',
            galat: _galatBerat,
          ),
          IsianKaca(
            label: 'Nama pengepul (boleh dikosongkan)',
            ikon: Ikon.truck,
            controller: _pengepul,
            textInputAction: TextInputAction.done,
            akhiran: const AppIcon(Ikon.chevronDown, size: 24, color: AppColors.teksKedua),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M07 Catat Panen – 3 Periksa & Simpan

class PeriksaPanenScreen extends StatelessWidget {
  const PeriksaPanenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final d = store.draftPanen;
    final baris = [
      ('Sayur', d.komoditas),
      ('Tanggal panen', Format.hariTanggal(d.tanggal)),
      ('Berat', Format.kg(d.beratKg ?? 0)),
      ('Pengepul', d.pengepul.trim().isEmpty ? '-' : d.pengepul.trim()),
    ];

    return KerangkaHalaman(
      header: const HeaderRingkas(judul: 'Catat Hasil Panen', keterangan: 'Periksa sekali lagi', kiri: TombolKembali()),
      bilahBawah: BilahTombol(
        tombol: [
          TombolUtama(
            label: 'Ya, Simpan Data Panen',
            ikon: Ikon.check,
            onTap: () => context.go(Rute.catatPanenBerhasil(store.simpanPanen())),
          ),
          TombolGaris(label: 'Ada yang salah, ubah', ikon: Ikon.pencil, onTap: () => context.kembali()),
        ],
      ),
      isi: IsiFormulir(
        bawah: 145 - 17,
        jarak: 14,
        children: [
          const IndikatorLangkah(langkah: 3, teks: 'Langkah 3 dari 3: Periksa & simpan'),
          Text('Apakah data ini sudah benar?', style: AppText.judulBagian),
          KotakKaca(
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                for (final (i, (label, nilai)) in baris.indexed)
                  BarisRingkasan(label: label, nilai: nilai, garisBawah: i < baris.length - 1),
              ],
            ),
          ),
          const CatatanBiru(
            'Harga jual diisi nanti, setelah pengepul menjual sayur di pasar. Status awal: Menunggu Penjualan.',
          ),
        ],
      ),
    );
  }
}

/// Satu baris label (kiri) + nilai tebal (kanan), dengan garis bawah opsional.
class BarisRingkasan extends StatelessWidget {
  const BarisRingkasan({super.key, required this.label, required this.nilai, this.garisBawah = true});

  final String label;
  final String nilai;
  final bool garisBawah;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: garisBawah
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.garisPemisah, width: 1.5)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.keteranganKartu),
          const SizedBox(width: 12),
          Expanded(
            child: Text(nilai, style: AppText.nilaiAngka, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M08 Berhasil Disimpan

class PanenTersimpanScreen extends StatelessWidget {
  const PanenTersimpanScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final t = store.cariTransaksi(id);

    return KerangkaHalaman(
      statusBarGelap: true,
      bilahBawah: BilahTombol(
        tombol: [
          TombolUtama(label: 'Kembali ke Beranda', ikon: Ikon.home, onTap: () => context.go(Rute.beranda)),
          TombolGaris(
            label: 'Catat Panen Lagi',
            ikon: Ikon.plus,
            onTap: () {
              store.mulaiPanenBaru();
              context.go(Rute.catatPanen);
            },
          ),
        ],
      ),
      isi: Padding(
        padding: EdgeInsets.fromLTRB(17, 79 + AppLayout.ekstraAtas(context), 17, 145 + AppLayout.ekstraBawah(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: LingkaranSukses()),
            const SizedBox(height: 11),
            Text('Data panen tersimpan', style: AppText.judulSukses, textAlign: TextAlign.center),
            if (t != null) ...[
              const SizedBox(height: 11),
              Text(
                '${t.komoditas} ${Format.kg(t.beratPanenKg)}, panen ${Format.hariTanggalTanpaKoma(t.tanggalPanen)}, sudah masuk ke Riwayat.',
                style: AppText.keteranganKartu,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 11),
              KartuStatusGelap(
                status: t.status,
                catatan: 'Nanti, setelah ada kabar harga dari pengepul, tekan "Lengkapi Penjualan" di Beranda.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lingkaran centang besar di layar "berhasil" (M08, M14, M27).
class LingkaranSukses extends StatelessWidget {
  const LingkaranSukses({
    super.key,
    this.warnaDalam = AppColors.headerTengah,
    this.ukuranCentang = 45,
    this.tebalCentang = 2,
  });

  final Color warnaDalam;
  final double ukuranCentang;
  final double tebalCentang;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x739CE8BF), // 45%
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xB3FFFFFF)), // putih 70%
      ),
      child: Container(
        width: 76,
        height: 76,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: warnaDalam,
          shape: BoxShape.circle,
          boxShadow: [AppShadows.figma(const Color(0x4D0D4026), y: 10, blur: 24, spread: -6)],
        ),
        child: AppIcon(Ikon.check, size: ukuranCentang, color: const Color(0xFFFFFFFF), tebal: tebalCentang),
      ),
    );
  }
}

/// Kartu gelap berisi status dan catatan (M08, M14).
class KartuStatusGelap extends StatelessWidget {
  const KartuStatusGelap({super.key, required this.status, required this.catatan});

  final StatusTransaksi status;
  final String catatan;

  @override
  Widget build(BuildContext context) {
    final warnaTitik = status == StatusTransaksi.lunas ? AppColors.langkahSelesai : AppColors.titikMenunggu;
    return KotakKaca(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      gradien: const GradienFigma(
        awal: Offset(0, 0),
        akhir: Offset(0.6, 0.8),
        colors: [Color(0xF217422E), Color(0xF20D291C)], // 95%
      ),
      warnaGaris: const Color(0x2EFFFFFF), // putih 18%
      bayangan: [AppShadows.figma(const Color(0x40081F12), y: 14, blur: 32, spread: -10)],
      sorotan: null,
      kaburKaca: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 20,
            child: Row(
              children: [
                Text('Status', style: AppText.labelGelap),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: warnaTitik,
                    shape: BoxShape.circle,
                    boxShadow: [AppShadows.figma(warnaTitik.withValues(alpha: 0.8), blur: 8)],
                  ),
                ),
                const SizedBox(width: 8),
                Text(status.label, style: AppText.nilaiGelap),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0x24FFFFFF)), // putih 14%
          const SizedBox(height: 12),
          Text(catatan, style: AppText.catatanGelap),
        ],
      ),
    );
  }
}
