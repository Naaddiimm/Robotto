import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/theme/app_theme.dart';
import 'features/user/screens/splash_screen.dart';
import 'features/learning/data/favourites_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // sqflite only works natively on Android/iOS.
  // For web, Windows, Linux, macOS — use sqflite_common_ffi.
  if (!kIsWeb) {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // Pre-load the favourites cache (mobile + desktop only)
    await FavouritesRepository.instance.init();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROBOTTO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const SplashScreen(),
    );
  }
}
