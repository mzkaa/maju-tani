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
class IsianKaca extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppText.labelIsian),
        const SizedBox(height: 8),
        KotakKaca(
          radius: 16,
          height: 64,
          warna: otomatis ? const Color(0x80FFFFFF) : const Color(0xADFFFFFF),
          garis: otomatis ? null : AppGradien.garisKaca,
          warnaGaris: fokusBiru ? AppColors.fokusBiru : (otomatis ? const Color(0xD9FFFFFF) : null),
          tebalGaris: fokusBiru ? 3 : 1,
          bayangan: otomatis ? const [] : null,
          sorotan: otomatis ? null : const Color(0xB3FFFFFF),
          kaburKaca: otomatis ? 16 : 10,
          onTap: onTap,
          label: onTap == null ? null : '$label: $nilaiTetap',
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              AppIcon(ikon, size: 24, color: AppColors.teksKedua),
              const SizedBox(width: 12),
              Expanded(
                child: nilaiTetap != null
                    ? Text(nilaiTetap!, style: AppText.nilaiIsian, maxLines: 1, overflow: TextOverflow.ellipsis)
                    : Semantics(
                        label: label,
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          obscureText: sembunyikanTeks,
                          style: AppText.nilaiIsian,
                          cursorColor: AppColors.hijauTua,
                          keyboardType: keyboardType,
                          textInputAction: textInputAction,
                          autofillHints: autofillHints,
                          onSubmitted: onSubmitted,
                          inputFormatters: inputFormatters,
                          decoration: const InputDecoration.collapsed(hintText: null),
                        ),
                      ),
              ),
              if (akhiran != null) ...[const SizedBox(width: 12), akhiran!],
            ],
          ),
        ),
        if (galat != null) ...[
          const SizedBox(height: 8),
          Text(galat!, style: AppText.bantuanIsian.copyWith(color: AppColors.galat)),
        ] else if (bantuan != null) ...[
          const SizedBox(height: 8),
          Text(bantuan!, style: AppText.bantuanIsian),
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
