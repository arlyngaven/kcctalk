// lib/screens/profile_selector_screen.dart
//
// Shown when logged out — lists all saved profiles so any child can
// tap their name to enter. Also accessible via "Switch Profile" in the Profile tab.

import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/profile_service.dart';
import '../widgets/kcc_widgets.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class ProfileSelectorScreen extends StatefulWidget {
  /// If true, shows a back button (called from inside the app).
  final bool fromInsideApp;
  const ProfileSelectorScreen({super.key, this.fromInsideApp = false});

  @override
  State<ProfileSelectorScreen> createState() => _ProfileSelectorScreenState();
}

class _ProfileSelectorScreenState extends State<ProfileSelectorScreen>
    with SingleTickerProviderStateMixin {

  List<ChildProfile> _profiles = [];
  bool _loading = true;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  // Avatar colors — assigned by index
  static const _avatarColors = [
    Color(0xFF1A73E8),
    Color(0xFF0D9488),
    Color(0xFFFF6B6B),
    Color(0xFFFFD166),
    Color(0xFFA855F7),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final profiles = await ProfileService.loadAllProfiles();
    if (!mounted) return;
    setState(() { _profiles = profiles; _loading = false; });
    _fadeCtrl.forward();
  }

  Future<void> _selectProfile(ChildProfile profile) async {
    await ProfileService.loginAs(profile.id!);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, a, __) =>
            FadeTransition(opacity: a, child: HomeScreen(profile: profile)),
      ),
      (_) => false,
    );
  }

  Future<void> _addProfile() async {
    if (_profiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Maximum 3 profiles na ang pinapayagan.'),
          backgroundColor: KCCColors.coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen(addingProfile: true)));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.fromInsideApp,
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
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(children: [

                      // ── Back button (only when called from inside app) ──
                      if (widget.fromInsideApp)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 24),

                      // ── Title ───────────────────────────────────────────
                      const SizedBox(height: 12),
                      const Text('Sino ka?',
                          style: TextStyle(color: Colors.white,
                              fontSize: 30, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('Piliin ang iyong profile para pumasok.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 14)),

                      const SizedBox(height: 40),

                      // ── Profile cards ───────────────────────────────────
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ..._profiles.asMap().entries.map((e) {
                                final i = e.key;
                                final profile = e.value;
                                return _ProfileCard(
                                  profile: profile,
                                  color: _avatarColors[i % _avatarColors.length],
                                  onTap: () => _selectProfile(profile),
                                );
                              }),

                              // ── Add profile button ──────────────────────
                              if (_profiles.length < 3)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: GestureDetector(
                                    onTap: _addProfile,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.white.withOpacity(0.30),
                                            width: 1.5,
                                            style: BorderStyle.solid),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 36, height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.20),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.white, size: 22),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text('Magdagdag ng Profile',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ]),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Single profile card ───────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final ChildProfile profile;
  final Color color;
  final VoidCallback onTap;
  const _ProfileCard({
    required this.profile, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              profile.name.characters.first.toUpperCase(),
              style: const TextStyle(color: Colors.white,
                  fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Info
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(profile.name,
              style: const TextStyle(color: Colors.white,
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text('${profile.age} taong gulang  •  '
               '${profile.screenTimeLimitMinutes} min/araw',
              style: TextStyle(color: Colors.white.withOpacity(0.70),
                  fontSize: 12)),
        ])),
        // Arrow
        Icon(Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.60), size: 26),
      ]),
    ),
  );
}