import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/profile_service.dart';
import '../widgets/kcc_widgets.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class WelcomeBackScreen extends StatefulWidget {
  final ChildProfile profile;
  const WelcomeBackScreen({super.key, required this.profile});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // ✅ FIXED: restoreProfile() → loginAs(id)
    await ProfileService.loginAs(widget.profile.id!);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, a, __) => FadeTransition(
        opacity: a,
        child: HomeScreen(profile: widget.profile),
      ),
    ));
  }

  Future<void> _switchProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: KCCColors.coral.withAlpha((255 * 0.10).round()),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    size: 32, color: KCCColors.coral),
              ),
              const SizedBox(height: 16),
              const Text('Palitan ang Profile?',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: KCCColors.darkNavy)),
              const SizedBox(height: 8),
              const Text(
                'Mabubura ang lahat ng data at progreso ng kasalukuyang '
                'profile. Hindi ito mababawi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: KCCColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: KCCColors.textMuted),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Huwag',
                        style: TextStyle(
                            color: KCCColors.textMuted,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KCCColors.coral,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: const Text('Oo, palitan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
    if (confirm != true || !mounted) return;
    await ProfileService.deleteProfile(widget.profile.id!);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, a, __) =>
          FadeTransition(opacity: a, child: const OnboardingScreen()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final name    = widget.profile.name.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF0D9488)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((255 * 0.15).round()),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withAlpha((255 * 0.30).round()),
                            width: 2.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Maligayang pagbabalik,',
                        style: TextStyle(
                            color: Colors.white.withAlpha((255 * 0.80).round()),
                            fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((255 * 0.15).round()),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withAlpha((255 * 0.25).round()),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            KCCClockIcon(
                                size: 14, color: const Color(0xFFFFD166)),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.profile.age} taong gulang  •  '
                              '${widget.profile.screenTimeLimitMinutes} min/araw',
                              style: TextStyle(
                                  color: Colors.white
                                      .withAlpha((255 * 0.85).round()),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 6,
                            shadowColor: Colors.black26,
                          ),
                          child: const Text(
                            'Pumasok',
                            style: TextStyle(
                              color: Color(0xFF1A73E8),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _switchProfile,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Hindi ikaw? Palitan ang profile',
                            style: TextStyle(
                                color: Colors.white
                                    .withAlpha((255 * 0.65).round()),
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white38),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}