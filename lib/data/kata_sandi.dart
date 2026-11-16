import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Kata sandi tidak pernah disimpan sebagai teks asli: yang disimpan hanya
/// hasil PBKDF2-HMAC-SHA256 dengan garam acak per akun.
abstract final class KataSandi {
  static const _putaran = 100000;

  /// Syarat kata sandi baru (sama dengan M23): minimal 8 huruf/angka dan ada angkanya.
  static bool cukupKuat(String sandi) => sandi.length >= 8 && sandi.contains(RegExp('[0-9]'));

  static String garamBaru() {
    final acak = Random.secure();
    return base64Encode([for (var i = 0; i < 16; i++) acak.nextInt(256)]);
  }

  /// Dihitung di isolate terpisah agar layar tidak tersendat.
  static Future<String> hash(String sandi, String garam) =>
      kIsWeb ? Future.value(_pbkdf2(sandi, garam)) : Isolate.run(() => _pbkdf2(sandi, garam));

  /// Perbandingan dengan waktu tetap.
  static bool sama(String a, String b) {
    if (a.length != b.length) return false;
    var beda = 0;
    for (var i = 0; i < a.length; i++) {
      beda |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return beda == 0;
  }

  static String _pbkdf2(String sandi, String garam) {
    final hmac = Hmac(sha256, utf8.encode(sandi));
    var u = hmac.convert([...base64Decode(garam), 0, 0, 0, 1]).bytes;
    final hasil = Uint8List.fromList(u);
    for (var i = 1; i < _putaran; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < hasil.length; j++) {
        hasil[j] ^= u[j];
      }
    }
    return base64Encode(hasil);
  }
}
