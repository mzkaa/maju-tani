import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/format.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';
import 'kotak_kaca.dart';

/// Isian formulir (komponen "Input V2" versi kaca di frame Figma):
/// label di atas, kotak kaca tinggi 64 berisi ikon + nilai + akhiran,
/// dan teks bantuan opsional di bawah.
///
/// Kondisi "Fokus" di frame Figma tampil sama dengan kondisi biasa,
/// jadi tidak ada perubahan tampilan saat isian sedang diketik.
class IsianKaca extends StatefulWidget {
  const IsianKaca({
    super.key,
    required this.label,
    required this.ikon,
    this.controller,
    this.nilaiTetap,
    this.onTap,
    this.galat,
    this.akhiran,
    this.bantuan,
    this.sembunyikanTeks = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.inputFormatters,
    this.otomatis = false,
    this.fokusBiru = false,
    this.focusNode,
  });

  final String label;
  final Ikon ikon;
  final TextEditingController? controller;

  /// Nilai yang hanya ditampilkan (bukan diketik), mis. tanggal; pakai bersama [onTap].
  final String? nilaiTetap;
  final VoidCallback? onTap;

  /// Pesan galat merah pengganti teks bantuan (varian "Error" Input V2).
  final String? galat;

  /// Widget di kanan nilai, misalnya tombol "Lihat" atau satuan "kg".
  final Widget? akhiran;
  final String? bantuan;
  final bool sembunyikanTeks;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  /// Varian "Otomatis": nilai dihitung sendiri, kotak putih 50% tanpa bayangan.
  final bool otomatis;

  /// Garis biru tebal 3 saat sedang diketik (hanya M17 Cari Catatan di Figma).
  final bool fokusBiru;
  final FocusNode? focusNode;

  @override
  State<IsianKaca> createState() => _IsianKacaState();
}

class _IsianKacaState extends State<IsianKaca> {
  FocusNode? _milik;
  FocusNode get _fokus => widget.focusNode ?? (_milik ??= FocusNode());

  @override
  void dispose() {
    _milik?.dispose();
    super.dispose();
  }

  /// Mengetuk di mana pun di dalam kotak bulat (bukan hanya baris teksnya) membuka keyboard.
  void _ketukKotak() {
    _fokus.requestFocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  /// Isian yang diketik: seluruh kotak menangkap ketukan. Isian tanggal ([IsianKaca.onTap]) sudah punya aksi sendiri.
  Widget _tangkapKetukan(Widget kotak) => widget.onTap != null || widget.nilaiTetap != null
      ? kotak
      : GestureDetector(behavior: HitTestBehavior.opaque, onTap: _ketukKotak, child: kotak);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: AppText.labelIsian),
        const SizedBox(height: 8),
        _tangkapKetukan(
          KotakKaca(
            radius: 16,
            height: 64,
            warna: widget.otomatis ? const Color(0x80FFFFFF) : const Color(0xADFFFFFF),
            garis: widget.otomatis ? null : AppGradien.garisKaca,
            warnaGaris: widget.fokusBiru ? AppColors.fokusBiru : (widget.otomatis ? const Color(0xD9FFFFFF) : null),
            tebalGaris: widget.fokusBiru ? 3 : 1,
            bayangan: widget.otomatis ? const [] : null,
            sorotan: widget.otomatis ? null : const Color(0xB3FFFFFF),
            kaburKaca: widget.otomatis ? 16 : 10,
            onTap: widget.onTap,
            label: widget.onTap == null ? null : '${widget.label}: ${widget.nilaiTetap}',
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                AppIcon(widget.ikon, size: 24, color: AppColors.teksKedua),
                const SizedBox(width: 12),
                Expanded(
                  child: widget.nilaiTetap != null
                      ? Text(
                          widget.nilaiTetap!,
                          style: AppText.nilaiIsian,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Semantics(
                          label: widget.label,
                          child: TextField(
                            controller: widget.controller,
                            focusNode: _fokus,
                            obscureText: widget.sembunyikanTeks,
                            style: AppText.nilaiIsian,
                            cursorColor: AppColors.hijauTua,
                            keyboardType: widget.keyboardType,
                            textInputAction: widget.textInputAction,
                            autofillHints: widget.autofillHints,
                            onSubmitted: widget.onSubmitted,
                            inputFormatters: widget.inputFormatters,
                            scrollPadding: const EdgeInsets.only(bottom: 120),
                            decoration: const InputDecoration.collapsed(hintText: null),
                          ),
                        ),
                ),
                if (widget.akhiran != null) ...[const SizedBox(width: 12), widget.akhiran!],
              ],
            ),
          ),
        ),
        if (widget.galat != null) ...[
          const SizedBox(height: 8),
          Text(widget.galat!, style: AppText.bantuanIsian.copyWith(color: AppColors.galat)),
        ] else if (widget.bantuan != null) ...[
          const SizedBox(height: 8),
          Text(widget.bantuan!, style: AppText.bantuanIsian),
        ],
      ],
    );
  }
}

/// Teks akhiran yang bisa diketuk, misalnya "Lihat" di isian kata sandi.
class AkhiranTombol extends StatelessWidget {
  const AkhiranTombol({super.key, required this.teks, required this.onTap});

  final String teks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Text(teks, style: AppText.akhiranIsian),
      ),
    );
  }
}

/// Memformat isian uang menjadi "Rp 5.200" saat diketik.
class FormatRupiahInput extends TextInputFormatter {
  const FormatRupiahInput();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final nilai = Format.angka(newValue.text);
    if (nilai == null) return TextEditingValue.empty;
    final teks = Format.rupiah(nilai);
    return TextEditingValue(
      text: teks,
      selection: TextSelection.collapsed(offset: teks.length),
    );
  }
}
