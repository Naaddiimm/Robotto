import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cybernetic Orbit Base Colors
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
        // Ensuring a consistent, smooth native transition to eliminate visual jumping
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
