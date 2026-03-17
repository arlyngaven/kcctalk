// lib/screens/splash_screen.dart

// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import '../services/profile_service.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'profile_selector_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // GIF controller
  late GifController _gifCtrl;

  // Bubble pop animations
  late AnimationController _bubble1Ctrl;
  late AnimationController _bubble2Ctrl;
  late AnimationController _bubble3Ctrl;

  // Title fade + slide up
  late AnimationController _titleCtrl;
  late Animation<double>   _titleFade;
  late Animation<Offset>   _titleSlide;

  // Loading dots
  late AnimationController _dotsCtrl;

  // Stars twinkling
  late AnimationController _starsCtrl;

  @override
  void initState() {
    super.initState();

    // ── GIF controller (loops automatically)
    _gifCtrl = GifController(vsync: this);

    // ── Speech bubbles appear sequentially
    _bubble1Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _bubble2Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _bubble3Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _bubble1Ctrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _bubble2Ctrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _bubble3Ctrl.forward();
    });

    // ── Title fade in
    _titleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _titleFade  = CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut);
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _titleCtrl.forward();
    });

    // ── Loading dots pulse
    _dotsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);

    // ── Stars twinkle
    _starsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final loggedIn    = await ProfileService.isLoggedIn();
    final hasProfiles = await ProfileService.hasAnyProfile();
    if (!mounted) return;

    Widget destination;
    if (loggedIn) {
      final profile = await ProfileService.loadActiveProfile();
      if (!mounted) return;
      if (profile != null) {
        destination = HomeScreen(profile: profile);
      } else {
        await ProfileService.logout();
        destination = hasProfiles
            ? const ProfileSelectorScreen()
            : const OnboardingScreen();
      }
    } else if (hasProfiles) {
      destination = const ProfileSelectorScreen();
    } else {
      destination = const OnboardingScreen();
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        // ignore: unnecessary_underscores
        // ignore: unnecessary_underscores
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: destination),
      ),
    );
  }

  @override
  void dispose() {
    _gifCtrl.dispose();
    _bubble1Ctrl.dispose();
    _bubble2Ctrl.dispose();
    _bubble3Ctrl.dispose();
    _titleCtrl.dispose();
    _dotsCtrl.dispose();
    _starsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A73E8),
              Color(0xFF0D9488),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Decorative background circles
            Positioned(top: -60, left: -60,
              child: _DecoCircle(size: 220,
                  // ignore: duplicate_ignore
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.07))),
            Positioned(bottom: -80, right: -40,
              child: _DecoCircle(size: 260,
                  // ignore: duplicate_ignore
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.06))),
            Positioned(top: 80, right: 30,
              child: _DecoCircle(size: 80,
                  // ignore: duplicate_ignore
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.08))),
            Positioned(bottom: 180, left: 20,
              child: _DecoCircle(size: 50,
                  // ignore: duplicate_ignore
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.1))),

            // ── Twinkling stars
            ..._buildStars(),

            // ── Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // ── Speech bubbles
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _AnimatedBubble(
                        controller: _bubble1Ctrl,
                        text: 'Huy!',
                        color: const Color(0xFFFFD166)),
                    const SizedBox(width: 10),
                    _AnimatedBubble(
                        controller: _bubble2Ctrl,
                        text: 'Kamusta?',
                        color: const Color(0xFF7EC8E3)),
                    const SizedBox(width: 10),
                    _AnimatedBubble(
                        controller: _bubble3Ctrl,
                        text: 'Magsanay!',
                        color: const Color(0xFFFF6B6B)),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Animated GIF mascot (replaces CustomPaint mascot)
                Gif(
                  image: const AssetImage('assets/animations/waving.gif'),
                  controller: _gifCtrl,
                  autostart: Autostart.loop,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 32),

                // ── App title
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: const _AppTitle(),
                  ),
                ),

                const SizedBox(height: 48),

                // ── Loading dots
                _LoadingDots(controller: _dotsCtrl),

                const SizedBox(height: 60),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStars() {
    final positions = [
      const Offset(60, 120),
      const Offset(300, 80),
      const Offset(340, 500),
      const Offset(50, 480),
      const Offset(370, 200),
    ];
    final sizes  = [10.0, 8.0, 12.0, 7.0, 9.0];
    final delays = [0.0, 0.3, 0.6, 0.2, 0.8];

    return List.generate(positions.length, (i) {
      return Positioned(
        left: positions[i].dx,
        top:  positions[i].dy,
        child: AnimatedBuilder(
          animation: _starsCtrl,
          // ignore: unnecessary_underscores
          builder: (_, __) {
            final phase = (_starsCtrl.value + delays[i]) % 1.0;
            return Opacity(
              opacity: 0.3 + 0.7 * phase,
              child: _StarShape(size: sizes[i]),
            );
          },
        ),
      );
    });
  }
}

// ─── App Title ────────────────────────────────────────────────────────────────

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ColorLetter('K', const Color(0xFFFFD166)),
            _ColorLetter('C', const Color(0xFFFF6B6B)),
            _ColorLetter('C', const Color(0xFF7EC8E3)),
            _ColorLetter('T', const Color(0xFFFFD166)),
            _ColorLetter('A', const Color(0xFFFF6B6B)),
            _ColorLetter('L', const Color(0xFF7EC8E3)),
            _ColorLetter('K', const Color(0xFFFFD166)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            // ignore: duplicate_ignore
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                // ignore: duplicate_ignore
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: const Text(
            'Gabay Sa Pagsasalita',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorLetter extends StatelessWidget {
  final String letter;
  final Color color;
  const _ColorLetter(this.letter, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      letter,
      style: TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w900,
        color: color,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 3),
            blurRadius: 0,
          ),
        ],
      ),
    );
  }
}

// ─── Animated Speech Bubble ───────────────────────────────────────────────────

class _AnimatedBubble extends StatelessWidget {
  final AnimationController controller;
  final String text;
  final Color color;
  const _AnimatedBubble(
      {required this.controller, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14)),
      ),
    );
  }
}

// ─── Loading Dots ─────────────────────────────────────────────────────────────

class _LoadingDots extends StatelessWidget {
  final AnimationController controller;
  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, _) {
            final phase = (controller.value + i * 0.3) % 1.0;
            final scale = 0.6 + 0.4 * sin(phase * pi);
            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5 + 0.5 * scale),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ─── Decorative Circle ────────────────────────────────────────────────────────

class _DecoCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _DecoCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─── Star Shape ───────────────────────────────────────────────────────────────

class _StarShape extends StatelessWidget {
  final double size;
  const _StarShape({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _StarPainter()),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.9);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 4 * pi / 5) - pi / 2;
      final innerAngle = outerAngle + (2 * pi / 10);
      final outerX = cx + r * cos(outerAngle);
      final outerY = cy + r * sin(outerAngle);
      final innerX = cx + (r * 0.4) * cos(innerAngle);
      final innerY = cy + (r * 0.4) * sin(innerAngle);
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}