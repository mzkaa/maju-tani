import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'data/app_store.dart';
import 'data/database.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'widgets/app_icon.dart';
import 'widgets/skala_tampilan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nama hari & bulan dalam bahasa Indonesia ("Kamis", "Okt").
  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID');
  await AppIcon.muat();

  // Data tersimpan di database lokal: SQLite di HP, atau SQLite (wasm) di browser.
  final store = await _bukaData();

  // Provider: satu AppStore untuk seluruh aplikasi.
  runApp(ChangeNotifierProvider(create: (_) => store, child: const MajuTaniApp()));
}

Future<AppStore> _bukaData() async {
  // Web: tanpa web worker (shared worker tidak tersedia di semua browser/panel pratinjau).
  final db = await Penyimpanan.buka(factory: kIsWeb ? databaseFactoryFfiWebNoWebWorker : null);
  return AppStore.dariDatabase(db, await db.muat());
}

class MajuTaniApp extends StatelessWidget {
  const MajuTaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mitra Maju Tani',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.terang,
      routerConfig: appRouter,
      // Bahasa Indonesia untuk komponen bawaan (mis. kalender pilih tanggal).
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Ukuran huruf dari Pengaturan (M30); "Besar" = ukuran desain Figma.
      builder: (context, child) {
        final skala = context.select<AppStore, double>((s) => s.ukuranHuruf.skala);
        final skalaLayar = context.select<AppStore, double>((s) => s.ukuranTampilan.skala);
        final mq = MediaQuery.of(context);
        // Urutan penting: skala tampilan di dalam, supaya ukuran/padding/keyboard yang diperkecil
        // tidak tertimpa MediaQuery asli.
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(mq.textScaler.scale(1) * skala)),
          child: SkalaTampilan(skala: skalaLayar, child: child!),
        );
      },
    );
  }
}
