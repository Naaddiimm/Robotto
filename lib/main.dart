import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'learning/data/favourites_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-load the favourites cache so isFavourite() checks are synchronous
  // throughout the Learning module.
  await FavouritesRepository.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF091422);
    const Color primaryMint = Color(0xFF85FFDE);

    return MaterialApp(
      title: 'ROBOTTO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgColor,
        canvasColor: bgColor,
        colorScheme: const ColorScheme.dark(
          surface: bgColor,
          primary: primaryMint,
        ),
        fontFamily: 'Plus Jakarta Sans',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
