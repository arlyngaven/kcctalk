// lib/main.dart
//
// App entry point.
// On launch:
//   - If a profile already exists → go directly to HomeScreen
//   - If no profile → show OnboardingScreen

import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const KCCTalkApp());
}

class KCCTalkApp extends StatelessWidget {
  const KCCTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KCCTalk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          background: const Color(0xFFFFF8F0),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}