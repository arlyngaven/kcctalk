// lib/main.dart
//
// App entry point.
// On launch:
//   - If a profile already exists → go directly to HomeScreen
//   - If no profile → show OnboardingScreen

import 'package:flutter/material.dart';
import 'models/child_profile.dart';
import 'services/profile_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

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
          seedColor: const Color(0xFFFF6B6B),
          background: const Color(0xFFFFF8F0),
        ),
        useMaterial3: true,
        fontFamily: 'Nunito', // Add Nunito to pubspec.yaml (Google Fonts)
      ),
      home: const _SplashRouter(),
    );
  }
}

/// Decides whether to show onboarding or home screen.
class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    // Small delay to show splash logo
    await Future.delayed(const Duration(milliseconds: 800));
    final ChildProfile? profile = await ProfileService.loadProfile();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => profile == null
            ? const OnboardingScreen()
            : HomeScreen(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF8F0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🗣️', style: TextStyle(fontSize: 72)),
            SizedBox(height: 16),
            Text(
              'KCCTALK',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A2E),
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: Color(0xFFFF6B6B),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}