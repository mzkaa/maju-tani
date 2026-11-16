
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/app_store.dart';
import 'data/database.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'widgets/app_icon.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat konfigurasi environment.
  await dotenv.load(fileName: '.env');

  // Inisialisasi Supabase.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Nama hari & bulan dalam bahasa Indonesia.
  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID');
  await AppIcon.muat();

  // Database lokal sementara.
  final store = await _bukaData();

  // Provider untuk seluruh aplikasi.
  runApp(
    ChangeNotifierProvider(
      create: (_) => store,
      child: const MajuTaniApp(),
    ),
  );
}

Future<AppStore> _bukaData() async {
  // Web: tanpa web worker.
  final db = await Penyimpanan.buka(
    factory: kIsWeb ? databaseFactoryFfiWebNoWebWorker : null,
  );

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
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        final skala = context.select<AppStore, double>(
          (s) => s.ukuranHuruf.skala,
        );

        final mq = MediaQuery.of(context);

        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(
              mq.textScaler.scale(1) * skala,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
