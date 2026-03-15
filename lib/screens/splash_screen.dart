// lib/screens/splash_screen.dart
//
// Animated splash / loading screen for KCCTALK.
// Blue & teal theme, playful mascot built from Flutter shapes (no images needed).
// Fully offline — no external assets required.
//
// HOW TO USE:
// In your main.dart _SplashRouter, replace the existing build() body with:
//
//   return const SplashScreen();
//
// Then call Navigator.pushReplacement to OnboardingScreen or HomeScreen
// after the delay (already handled inside SplashScreen via initState).

import 'dart:math';
import 'package:flutter/material.dart';
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
  // Mascot bounce animation
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  // Arm wave animation
  late AnimationController _waveCtrl;
  late Animation<double> _waveAnim;

  // Bubble pop animations
  late AnimationController _bubble1Ctrl;
  late AnimationController _bubble2Ctrl;
  late AnimationController _bubble3Ctrl;

  // Title fade + slide up
  late AnimationController _titleCtrl;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  // Loading dots
  late AnimationController _dotsCtrl;

  // Stars twinkling
  late AnimationController _starsCtrl;

  @override
  void initState() {
    super.initState();

    // ── Mascot bounce (continuous loop)
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounceAnim = CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut);

    // ── Arm wave (continuous loop, slightly faster for playful feel)
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _waveAnim = Tween<double>(begin: -0.3, end: 0.5)
        .animate(CurvedAnimation(parent: _waveCtrl, curve: Curves.easeInOut));

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
    _titleFade =
        CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut);
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

    // ── Route after delay
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final loggedIn  = await ProfileService.isLoggedIn();
    final hasProfiles = await ProfileService.hasAnyProfile();
    if (!mounted) return;

    Widget destination;
    if (loggedIn) {
      // Active session — load that profile and go home
      final profile = await ProfileService.loadActiveProfile();
      if (!mounted) return;
      if (profile != null) {
        destination = HomeScreen(profile: profile);
      } else {
        // Edge case: session id points to a deleted profile
        await ProfileService.logout();
        destination = hasProfiles
            ? const ProfileSelectorScreen()
            : const OnboardingScreen();
      }
    } else if (hasProfiles) {
      // Logged out but profiles exist → show selector
      destination = const ProfileSelectorScreen();
    } else {
      // First launch — no profiles yet
      destination = const OnboardingScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: destination),
      ),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _waveCtrl.dispose();
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
          // Blue-to-teal vertical gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A73E8), // rich blue
              Color(0xFF0D9488), // teal
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Decorative background circles ──────────────────────────
            Positioned(
              top: -60,
              left: -60,
              child: _DecoCircle(size: 220, color: Colors.white.withOpacity(0.07)),
            ),
            Positioned(
              bottom: -80,
              right: -40,
              child: _DecoCircle(size: 260, color: Colors.white.withOpacity(0.06)),
            ),
            Positioned(
              top: 80,
              right: 30,
              child: _DecoCircle(size: 80, color: Colors.white.withOpacity(0.08)),
            ),
            Positioned(
              bottom: 180,
              left: 20,
              child: _DecoCircle(size: 50, color: Colors.white.withOpacity(0.1)),
            ),

            // ── Twinkling stars ─────────────────────────────────────────
            ..._buildStars(),

            // ── Main content ────────────────────────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Speech bubbles row
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

                // ── Mascot (bouncing + waving) ─────────────────────────
                AnimatedBuilder(
                  animation: _bounceAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -12 * _bounceAnim.value),
                      child: child,
                    );
                  },
                  child: _MascotWidget(waveAnim: _waveAnim),
                ),

                const SizedBox(height: 32),

                // ── App title ──────────────────────────────────────────
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: const _AppTitle(),
                  ),
                ),

                const SizedBox(height: 48),

                // ── Loading indicator ──────────────────────────────────
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
    final sizes = [10.0, 8.0, 12.0, 7.0, 9.0];
    final delays = [0.0, 0.3, 0.6, 0.2, 0.8];

    return List.generate(positions.length, (i) {
      return Positioned(
        left: positions[i].dx,
        top: positions[i].dy,
        child: AnimatedBuilder(
          animation: _starsCtrl,
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

// ─── Mascot: Filipina child with salakot, waving ──────────────────────────────

class _MascotWidget extends StatelessWidget {
  final Animation<double> waveAnim;
  const _MascotWidget({required this.waveAnim});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 220,
      child: AnimatedBuilder(
        animation: waveAnim,
        builder: (_, __) => CustomPaint(
          painter: _MascotPainter(waveAngle: waveAnim.value),
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final double waveAngle;
  const _MascotPainter({required this.waveAngle});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;

    // ── LEGS ──────────────────────────────────────────────────────────────
    final legP = Paint()..color = const Color(0xFFFFDAB9);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 16, cy + 62), width: 20, height: 34),
        const Radius.circular(10)), legP);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 16, cy + 62), width: 20, height: 34),
        const Radius.circular(10)), legP);
    // shoes
    final shoeP = Paint()..color = const Color(0xFF5C3A1E);
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx - 16, cy + 80), width: 28, height: 13), shoeP);
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx + 16, cy + 80), width: 28, height: 13), shoeP);

    // ── DRESS (Filipiniana-style, cream/yellow) ────────────────────────────
    final dressP = Paint()..color = const Color(0xFFFFF3C4);
    // main skirt (wider at bottom)
    final skirtPath = Path()
      ..moveTo(cx - 30, cy + 10)
      ..lineTo(cx - 42, cy + 78)
      ..lineTo(cx + 42, cy + 78)
      ..lineTo(cx + 30, cy + 10)
      ..close();
    canvas.drawPath(skirtPath, dressP);
    // bodice
    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 58, height: 36),
      topLeft: const Radius.circular(6), topRight: const Radius.circular(6),
      bottomLeft: const Radius.circular(2), bottomRight: const Radius.circular(2)),
      dressP);
    // butterfly sleeves (paro-paro)
    final sleeveP = Paint()..color = const Color(0xFFFFF3C4);
    // left sleeve
    canvas.save();
    canvas.translate(cx - 38, cy - 8);
    canvas.rotate(0.3);
    canvas.drawOval(const Rect.fromLTWH(0, 0, 30, 18), sleeveP);
    canvas.restore();
    // right sleeve
    canvas.save();
    canvas.translate(cx + 8, cy - 8);
    canvas.rotate(-0.3);
    canvas.drawOval(const Rect.fromLTWH(0, 0, 30, 18), sleeveP);
    canvas.restore();
    // dress outline
    final dressOutlineP = Paint()
      ..color = const Color(0xFFE8C84A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(skirtPath, dressOutlineP);

    // ── LEFT ARM (down, holding flag) ─────────────────────────────────────
    final armP = Paint()..color = const Color(0xFFFFDAB9);
    canvas.save();
    canvas.translate(cx - 30, cy - 4);
    canvas.rotate(0.2);
    canvas.drawRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 16, 38), const Radius.circular(9)), armP);
    canvas.restore();
    // flag pole
    final poleP = Paint()..color = const Color(0xFF8B4513)..strokeWidth = 3
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 28, cy + 34), Offset(cx - 38, cy - 18), poleP);
    // Philippine flag
    _drawFlag(canvas, Offset(cx - 38, cy - 18));

    // ── RIGHT ARM (raised, waving) ────────────────────────────────────────
    canvas.save();
    canvas.translate(cx + 26, cy - 10);
    canvas.rotate(waveAngle); // ← animated wave
    canvas.drawRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, -36, 16, 38), const Radius.circular(9)), armP);
    // hand
    canvas.drawCircle(const Offset(8, -38), 10, armP);
    canvas.restore();

    // ── NECK ──────────────────────────────────────────────────────────────
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 18), width: 20, height: 16),
        const Radius.circular(6)), armP);

    // ── HEAD ──────────────────────────────────────────────────────────────
    final skinP = Paint()..color = const Color(0xFFFFDAB9);
    canvas.drawCircle(Offset(cx, cy - 42), 38, skinP);

    // ── HAIR ──────────────────────────────────────────────────────────────
    final hairP = Paint()..color = const Color(0xFF1A0A00);
    // back hair
    canvas.drawCircle(Offset(cx, cy - 42), 38, hairP);
    // face over hair
    canvas.drawCircle(Offset(cx, cy - 40), 34, skinP);
    // side hair strands
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx - 34, cy - 38), width: 14, height: 28), hairP);
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx + 34, cy - 38), width: 14, height: 28), hairP);

    // ── SALAKOT (native Filipino hat) ─────────────────────────────────────
    _drawSalakot(canvas, cx, cy);

    // ── EYES (big, cute) ──────────────────────────────────────────────────
    final eyeWhite = Paint()..color = Colors.white;
    final pupilP   = Paint()..color = const Color(0xFF1A0A00);
    final shineP   = Paint()..color = Colors.white;
    // left eye
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx - 13, cy - 44), width: 18, height: 20), eyeWhite);
    canvas.drawCircle(Offset(cx - 13, cy - 44), 8, pupilP);
    canvas.drawCircle(Offset(cx - 9,  cy - 47), 3, shineP);
    // right eye
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx + 13, cy - 44), width: 18, height: 20), eyeWhite);
    canvas.drawCircle(Offset(cx + 13, cy - 44), 8, pupilP);
    canvas.drawCircle(Offset(cx + 17, cy - 47), 3, shineP);
    // eyelashes
    final lashP = Paint()..color = const Color(0xFF1A0A00)
      ..strokeWidth = 1.8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    for (final dx in [-16.0, -13.0, -10.0]) {
      canvas.drawLine(Offset(cx + dx, cy - 54), Offset(cx + dx - 1, cy - 57), lashP);
    }
    for (final dx in [10.0, 13.0, 16.0]) {
      canvas.drawLine(Offset(cx + dx, cy - 54), Offset(cx + dx + 1, cy - 57), lashP);
    }

    // ── ROSY CHEEKS ───────────────────────────────────────────────────────
    final cheekP = Paint()..color = const Color(0xFFFF9BAD).withOpacity(0.55);
    canvas.drawCircle(Offset(cx - 24, cy - 36), 9, cheekP);
    canvas.drawCircle(Offset(cx + 24, cy - 36), 9, cheekP);

    // ── NOSE ──────────────────────────────────────────────────────────────
    final noseP = Paint()..color = const Color(0xFFE8A87C)
      ..strokeWidth = 1.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx, cy - 36), width: 8, height: 5), noseP);

    // ── BIG OPEN SMILE ────────────────────────────────────────────────────
    final smileP = Paint()..color = const Color(0xFF1A0A00)
      ..strokeWidth = 2.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawPath(
        Path()..moveTo(cx - 13, cy - 26)
              ..quadraticBezierTo(cx, cy - 16, cx + 13, cy - 26), smileP);
    // teeth
    final teethP = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 24), width: 18, height: 8),
        const Radius.circular(4)), teethP);
    // mouth outline
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 24), width: 18, height: 8),
        const Radius.circular(4)),
        Paint()..color = const Color(0xFFE8A87C)
               ..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // ── SPEECH BUBBLE (chat icon from logo) ───────────────────────────────
    final chatP = Paint()..color = const Color(0xFF22C55E);
    final chatPath = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 62, cy - 52), width: 32, height: 24),
        const Radius.circular(8));
    canvas.drawRRect(chatPath, chatP);
    // bubble tail
    final tailPath = Path()
      ..moveTo(cx + 52, cy - 40)
      ..lineTo(cx + 48, cy - 34)
      ..lineTo(cx + 58, cy - 40)
      ..close();
    canvas.drawPath(tailPath, chatP);
    // dots inside chat bubble
    final dotP = Paint()..color = Colors.white;
    for (final dx in [-8.0, 0.0, 8.0]) {
      canvas.drawCircle(Offset(cx + 62 + dx, cy - 52), 3, dotP);
    }
  }

  void _drawSalakot(Canvas canvas, double cx, double cy) {
    // Salakot = wide conical Filipino hat made of woven material
    final hatP = Paint()..color = const Color(0xFF8B5E3C);
    // wide brim
    final brimPath = Path()
      ..moveTo(cx - 60, cy - 62)
      ..quadraticBezierTo(cx, cy - 56, cx + 60, cy - 62)
      ..quadraticBezierTo(cx + 30, cy - 70, cx, cy - 68)
      ..quadraticBezierTo(cx - 30, cy - 70, cx - 60, cy - 62)
      ..close();
    canvas.drawPath(brimPath, hatP);
    // cone top
    final coneP = Paint()..color = const Color(0xFF6B3F1E);
    final conePath = Path()
      ..moveTo(cx - 28, cy - 66)
      ..quadraticBezierTo(cx, cy - 110, cx + 28, cy - 66)
      ..close();
    canvas.drawPath(conePath, coneP);
    // hat stripes (woven texture lines)
    final stripeP = Paint()..color = const Color(0xFF5C3010)
      ..strokeWidth = 1.0..style = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      final t = i / 4;
      final y = cy - 68 + t * 8;
      final w = 20.0 + t * 30;
      canvas.drawLine(Offset(cx - w, y), Offset(cx + w, y), stripeP);
    }
    // brim outline
    final brimOutlineP = Paint()..color = const Color(0xFF4A2A0A)
      ..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawPath(brimPath, brimOutlineP);
  }

  void _drawFlag(Canvas canvas, Offset origin) {
    // Simplified Philippine flag
    final flagW = 36.0, flagH = 22.0;
    // white triangle (left)
    final triP = Paint()..color = Colors.white;
    canvas.drawPath(Path()
      ..moveTo(origin.dx, origin.dy)
      ..lineTo(origin.dx, origin.dy + flagH)
      ..lineTo(origin.dx + flagW * 0.4, origin.dy + flagH / 2)
      ..close(), triP);
    // blue stripe (top half)
    final blueP = Paint()..color = const Color(0xFF0038A8);
    canvas.drawRect(Rect.fromLTWH(
        origin.dx + flagW * 0.4, origin.dy, flagW * 0.6, flagH / 2), blueP);
    // red stripe (bottom half)
    final redP = Paint()..color = const Color(0xFFCE1126);
    canvas.drawRect(Rect.fromLTWH(
        origin.dx + flagW * 0.4, origin.dy + flagH / 2, flagW * 0.6, flagH / 2), redP);
    // sun (yellow, simplified)
    final sunP = Paint()..color = const Color(0xFFFCD116);
    canvas.drawCircle(Offset(origin.dx + flagW * 0.2, origin.dy + flagH / 2), 5, sunP);
    // flag outline
    canvas.drawRect(
        Rect.fromLTWH(origin.dx, origin.dy, flagW, flagH),
        Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter old) => old.waveAngle != waveAngle;
}

// ─── App Title ─────────────────────────────────────────────────────────────────

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // KCCTALK with colorful letters
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
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
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

// ─── Animated Speech Bubble ────────────────────────────────────────────────────

class _AnimatedBubble extends StatelessWidget {
  final AnimationController controller;
  final String text;
  final Color color;
  const _AnimatedBubble(
      {required this.controller,
      required this.text,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─── Loading Dots ──────────────────────────────────────────────────────────────

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
          builder: (_, __) {
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

// ─── Decorative Circle ─────────────────────────────────────────────────────────

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

// ─── Star Shape ────────────────────────────────────────────────────────────────

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
    final r = size.width / 2;

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