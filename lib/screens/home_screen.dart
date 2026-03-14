// lib/screens/home_screen.dart
//
// Main app screen shown after onboarding.
// - Shows a live countdown timer in the top bar.
// - Adds one second every second to daily usage.
// - When the limit is reached → shows a full-screen lock overlay.

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/screen_time_service.dart';

class HomeScreen extends StatefulWidget {
  final ChildProfile profile;
  const HomeScreen({super.key, required this.profile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isLocked = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  Future<void> _initTimer() async {
    final remaining = await ScreenTimeService.remainingSeconds(
        widget.profile.screenTimeLimitMinutes);
    if (!mounted) return;
    setState(() {
      _remainingSeconds = remaining;
      _isLocked = remaining <= 0;
      _isLoaded = true;
    });

    if (!_isLocked) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        await ScreenTimeService.addOneSecond();
        if (!mounted) return;
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          }
          if (_remainingSeconds <= 0) {
            _isLocked = true;
            _timer?.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _timerColor {
    if (_remainingSeconds > 300) return const Color(0xFF06D6A0); // green
    if (_remainingSeconds > 60) return const Color(0xFFFFD166);  // yellow
    return const Color(0xFFFF6B6B);                               // red
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8F0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFFFF8F0),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                const Text(
                  'KCCTALK',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A2E),
                    fontSize: 20,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                // Live countdown timer pill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _timerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _timerColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_rounded,
                          size: 16, color: _timerColor),
                      const SizedBox(width: 5),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _timerColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kamusta, ${widget.profile.name}! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mayroon kang ${_formatTime(_remainingSeconds)} na natitira ngayon.',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 32),
                // Placeholder content grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: const [
                      _ActivityCard(emoji: '🔤', label: 'Mga Salita'),
                      _ActivityCard(emoji: '🏠', label: 'Sa Bahay'),
                      _ActivityCard(emoji: '🏫', label: 'Sa Paaralan'),
                      _ActivityCard(emoji: '⭐', label: 'Mga Gantimpala'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Screen Time Lock Overlay ──────────────────────────────────────────
        if (_isLocked) const _ScreenTimeLockOverlay(),
      ],
    );
  }
}

// ─── Activity Card (placeholder for your app's content) ───────────────────────

class _ActivityCard extends StatelessWidget {
  final String emoji;
  final String label;
  const _ActivityCard({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Full-Screen Lock Overlay ──────────────────────────────────────────────────

class _ScreenTimeLockOverlay extends StatelessWidget {
  const _ScreenTimeLockOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E).withOpacity(0.95),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock icon with glow
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF6B6B).withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text('🔒', style: TextStyle(fontSize: 56)),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Tapos na ang\nPanahon ng Paggamit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Naabot mo na ang limitasyon ng iyong screen time ngayon.\nMangyaring bumalik bukas para magpatuloy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF9999BB),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD166).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFFFD166).withOpacity(0.5),
                        width: 1.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('☀️', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 10),
                      Text(
                        'Mag-reset bukas ng umaga',
                        style: TextStyle(
                          color: Color(0xFFFFD166),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}