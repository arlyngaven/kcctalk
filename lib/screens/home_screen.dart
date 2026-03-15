// lib/screens/home_screen.dart
// Filipino lamang. Back button sa Aktibidad at Profil na tab.
// Walang emoji. Shapes lang. Ganap na offline.

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/screen_time_service.dart';
import '../widgets/kcc_widgets.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final ChildProfile profile;
  const HomeScreen({super.key, required this.profile});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  int  _remaining = 0;
  bool _loaded = false;
  int  _navIdx = 0; // 0=Tahanan, 1=Aktibidad, 2=Profil

  // Shorthand — falls back to 0 if profile has no id yet (shouldn't happen)
  int get _profileId => widget.profile.id ?? 0;

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final r = await ScreenTimeService.remainingSeconds(
        _profileId, widget.profile.screenTimeLimitMinutes);
    if (!mounted) return;
    setState(() { _remaining = r; _loaded = true; });
    // ── LOCK MECHANISM — COMMENTED OUT FOR TESTING
    // Kapag tapos ka na sa testing, alisin ang comment sa dalawang linya:
    // setState(() { _remaining = r; _locked = r <= 0; _loaded = true; });
    // if (_locked) return; // huwag simulan ang timer kung lock na
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await ScreenTimeService.addOneSecond(_profileId);
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) _remaining--;
        // ── LOCK MECHANISM — COMMENTED OUT FOR TESTING
        // Kapag tapos ka na sa testing, alisin ang comment sa dalawang linya:
        // if (_remaining <= 0) { _locked = true; _timer?.cancel(); }
      });
    });
  }

  void _pauseTimer() { _timer?.cancel(); _timer = null; }

  /// Called automatically by WidgetsBindingObserver when the app goes
  /// background/foreground. This is how pause/resume works — no extra code needed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground — re-read saved usage and resume timer
      _init();
    } else if (state == AppLifecycleState.paused ||
               state == AppLifecycleState.inactive ||
               state == AppLifecycleState.detached) {
      // App going to background or closed — stop the timer
      // ScreenTimeService already saved every second, so no data is lost
      _pauseTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(int s) =>
      '${(s~/60).toString().padLeft(2,'0')}:${(s%60).toString().padLeft(2,'0')}';



  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
      backgroundColor:KCCColors.bgLight,
      body:Center(child:CircularProgressIndicator(color:KCCColors.blue)),
    );
    }

    return WillPopScope(
      onWillPop: () async {
        // Back button ng system: kung hindi Tahanan, bumalik sa Tahanan
        if (_navIdx != 0) { setState(() => _navIdx=0); return false; }
        return false; // huwag lumabas sa app
      },
      child: Stack(children:[
        Scaffold(
          backgroundColor: KCCColors.bgLight,
          // ── AppBar ──────────────────────────────────────────────────────
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF818CF8), Color(0xFF38BDF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(children:[
              // Back button — ipinakita lamang sa Aktibidad at Profil
              if (_navIdx != 0) ...[
                KCCBackButton(
                  onPressed: () => setState(() => _navIdx=0)),
                const SizedBox(width:10),
              ],
              // Pangalan ng app
              Row(children:_colorLetters('KCCTALK',20)),
              const Spacer(),
    
            ]),
          ),
          // ── Body ────────────────────────────────────────────────────────
          body: _buildBody(),
          // ── Bottom Nav ──────────────────────────────────────────────────
          bottomNavigationBar: _BottomNav(
            current: _navIdx,
            onTap: (i) => setState(() => _navIdx=i),
          ),
        ),
        // ── LOCK OVERLAY — COMMENTED OUT FOR TESTING ──────────────────────
        // Kapag tapos ka na sa testing, alisin ang comment sa line sa ibaba
        // at sa dalawang linya sa loob ng _init() / _startTimer():
        // if (_locked) _LockOverlay(fmt: _fmt),
        // ─────────────────────────────────────────────────────────────────
      ]),
    );
  }

  Widget _buildBody() {
    switch (_navIdx) {
      case 0: return _TahananTab(
          profile:widget.profile, remaining:_remaining, fmt:_fmt);
      case 1: return _AktibidadTab(profile:widget.profile);
      case 2: return ProfileScreen(profile:widget.profile);
      default: return const SizedBox.shrink();
    }
  }

  List<Widget> _colorLetters(String word, double size) {
    const colors=[KCCColors.yellow,KCCColors.coral,KCCColors.lightBlue];
    return word.split('').asMap().entries.map((e)=>Text(e.value,
        style:TextStyle(fontSize:size,fontWeight:FontWeight.w900,
            color:colors[e.key%colors.length]))).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 0 — TAHANAN  (redesigned hero-banner layout)
// ═══════════════════════════════════════════════════════════════════════════════
class _TahananTab extends StatefulWidget {
  final ChildProfile profile;
  final int remaining;
  final String Function(int) fmt;
  const _TahananTab({required this.profile, required this.remaining, required this.fmt});
  @override State<_TahananTab> createState() => _TahananTabState();
}

class _TahananTabState extends State<_TahananTab> {
  int _selectedCat = 0;
  static const _cats = ['Lahat', 'Tunog', 'Salita', 'Hayop', 'Kulay'];

  @override
  Widget build(BuildContext context) {
    final limit = widget.profile.screenTimeLimitMinutes * 60;
    final used  = (limit - widget.remaining).clamp(0, limit);
    final ratio = limit > 0 ? used / limit : 0.0;
    final timerColor = widget.remaining > 300
        ? KCCColors.green : widget.remaining > 60 ? KCCColors.yellow : KCCColors.coral;

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── HERO BANNER ──────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF0D9488)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(children: [
            // Deco circles
            Positioned(top: -20, right: -20,
              child: Container(width: 130, height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((255*(0.07)).round()), shape: BoxShape.circle))),
            Positioned(bottom: 10, left: -30,
              child: Container(width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((255*(0.06)).round()), shape: BoxShape.circle))),
            Positioned(top: 20, left: 100,
              child: Container(width: 50, height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD166).withAlpha((255*(0.18)).round()), shape: BoxShape.circle))),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 16, 0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                // Text side
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Day label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((255*(0.18)).round()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_dayLabel(),
                        style: const TextStyle(color: Colors.white70,
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Text('Kamusta,\n${widget.profile.name}!',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 26, fontWeight: FontWeight.w900,
                          height: 1.2)),
                  const SizedBox(height: 8),
                  Text('Handa ka na bang\nmagsanay ngayon?',
                      style: TextStyle(color: Colors.white.withAlpha((255*(0.80)).round()),
                          fontSize: 13, height: 1.5)),
                  const SizedBox(height: 18),
                  // Timer pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((255*(0.18)).round()),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withAlpha((255*(0.35)).round()), width: 1.5),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      KCCClockIcon(size: 14, color: timerColor),
                      const SizedBox(width: 6),
                      Text(widget.fmt(widget.remaining),
                          style: TextStyle(color: timerColor,
                              fontSize: 15, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 6),
                      Text('natitira',
                          style: TextStyle(color: Colors.white.withAlpha((255*(0.75)).round()),
                              fontSize: 11)),
                    ]),
                  ),
                  const SizedBox(height: 22),
                ])),

                // Child mascot
                SizedBox(
                  width: 140, height: 170,
                  child: CustomPaint(painter: _ChildMascotP()),
                ),
              ]),
            ),
          ]),
        ),

        // ── PROGRESS STRIP ───────────────────────────────────────────────
        Container(
          color: const Color(0xFF1A73E8),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white.withAlpha((255*(0.20)).round()),
                valueColor: AlwaysStoppedAnimation<Color>(
                    ratio > 0.85 ? KCCColors.coral : const Color(0xFFFFD166)),
              ),
            ),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: Text('${(ratio * 100).round()}% nagamit',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withAlpha((255*(0.75)).round()),
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Text('${widget.profile.screenTimeLimitMinutes} min / araw',
                  style: TextStyle(color: Colors.white.withAlpha((255*(0.75)).round()),
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),

        // White wave divider
        Container(
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF7ED),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),

        // ── CATEGORY CHIPS ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 0, 14),
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final sel = i == _selectedCat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCat = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFF1A73E8) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? const Color(0xFF1A73E8)
                              : const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: sel ? [BoxShadow(
                          color: const Color(0xFF1A73E8).withAlpha((255*(0.25)).round()),
                          blurRadius: 8, offset: const Offset(0, 3))] : [],
                    ),
                    child: Text(_cats[i],
                        style: TextStyle(
                          color: sel ? Colors.white : KCCColors.textMuted,
                          fontSize: 13, fontWeight: FontWeight.w700,
                        )),
                  ),
                );
              },
            ),
          ),
        ),

        // ── FEATURED CARD ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF7EC8E3), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(
                  color: const Color(0xFF0D9488).withAlpha((255*(0.30)).round()),
                  blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Stack(children: [
              // Deco blob
              Positioned(right: -20, bottom: -20,
                child: Container(width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((255*(0.10)).round()), shape: BoxShape.circle))),
              Positioned(right: 20, top: -10,
                child: Container(width: 70, height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD166).withAlpha((255*(0.20)).round()),
                    shape: BoxShape.circle))),
              // Speech bubbles deco
              Positioned(right: 18, top: 18,
                child: _MiniBubble(text: 'Ma!', color: const Color(0xFFFFD166))),
              Positioned(right: 70, top: 10,
                child: _MiniBubble(text: 'Ba!', color: const Color(0xFFFF6B6B))),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 110, 18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((255*(0.20)).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('PINAKABAGO',
                        style: TextStyle(color: Colors.white,
                            fontSize: 10, fontWeight: FontWeight.w800,
                            letterSpacing: 1.0)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Magsanay ng\nMga Tunog!',
                      style: TextStyle(color: Colors.white,
                          fontSize: 20, fontWeight: FontWeight.w900, height: 1.2)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Simulan',
                        style: TextStyle(color: Color(0xFF1A73E8),
                            fontSize: 13, fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
            ]),
          ),
        ),

        // ── SECTION HEADER ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mga Aktibidad',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
                      color: KCCColors.darkNavy)),
              Text('Tingnan lahat',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A73E8))),
            ],
          ),
        ),

        // ── ACTIVITY GRID ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.05,
            children: const [
              _ActivityCard(
                title: 'Mga Tunog',
                desc: 'Magsanay ng mga tunog',
                color: Color(0xFF1A73E8),
                iconColor: Color(0xFFFFD166),
                unlocked: true,
                emoji: 'T',
              ),
              _ActivityCard(
                title: 'Mga Salita',
                desc: 'Palakasin ang mga salita',
                color: Color(0xFF0D9488),
                iconColor: Color(0xFF7EC8E3),
                unlocked: true,
                emoji: 'S',
              ),
              _ActivityCard(
                title: 'Sa Bahay',
                desc: 'Mga bagay sa bahay',
                color: Color(0xFFFF6B6B),
                iconColor: Color(0xFFFF6B6B),
                unlocked: false,
                emoji: 'B',
              ),
              _ActivityCard(
                title: 'Sa Paaralan',
                desc: 'Mga gamit sa paaralan',
                color: Color(0xFFFFD166),
                iconColor: Color(0xFFFFD166),
                unlocked: false,
                emoji: 'P',
              ),
            ],
          ),
        ),
      ]),
    );
  }

  String _dayLabel() {
    const days = ['Linggo','Lunes','Martes','Miyerkules',
                  'Huwebes','Biyernes','Sabado'];
    return days[DateTime.now().weekday % 7];
  }
}

// ── Mini speech bubble (for featured card deco) ───────────────────────────────
class _MiniBubble extends StatelessWidget {
  final String text;
  final Color color;
  const _MiniBubble({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12), topRight: Radius.circular(12),
        bottomRight: Radius.circular(12), bottomLeft: Radius.circular(3),
      ),
      boxShadow: [BoxShadow(
          color: color.withAlpha((255*(0.4)).round()), blurRadius: 6, offset: const Offset(0, 2))],
    ),
    child: Text(text,
        style: const TextStyle(color: Colors.white,
            fontWeight: FontWeight.w900, fontSize: 13)),
  );
}

// ── Activity card (redesigned) ────────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final String title, desc, emoji;
  final Color color, iconColor;
  final bool unlocked;
  const _ActivityCard({
    required this.title, required this.desc, required this.emoji,
    required this.color, required this.iconColor, required this.unlocked,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: unlocked ? color : const Color(0xFFEEF2F7),
      borderRadius: BorderRadius.circular(22),
      boxShadow: unlocked ? [BoxShadow(
          color: color.withAlpha((255*(0.28)).round()), blurRadius: 14,
          offset: const Offset(0, 5))] : [],
    ),
    child: Stack(children: [
      // Deco circle bg
      Positioned(bottom: -12, right: -12,
        child: Container(width: 70, height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((255*(unlocked ? 0.10 : 0.40)).round()),
            shape: BoxShape.circle))),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            // Icon circle
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((255*(unlocked ? 0.20 : 0.60)).round()),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: unlocked
                    ? Text(emoji,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                            color: unlocked ? Colors.white : color))
                    : KCCLockIcon(size: 20, color: KCCColors.textMuted),
              ),
            ),
            if (unlocked)
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((255*(0.20)).round()), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded,
                    size: 18, color: Colors.white),
              ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                    color: unlocked ? Colors.white : KCCColors.textMuted)),
            const SizedBox(height: 2),
            Text(desc,
                style: TextStyle(fontSize: 11, height: 1.3,
                    color: unlocked
                        ? Colors.white.withAlpha((255*(0.80)).round())
                        : KCCColors.textMuted)),
          ]),
        ]),
      ),
    ]),
  );
}

// ── Child mascot CustomPainter ────────────────────────────────────────────────
class _ChildMascotP extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;

    // ── Legs
    final legP = Paint()..color = const Color(0xFF7EC8E3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 14, cy + 52), width: 18, height: 28),
        const Radius.circular(10)),
      legP);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 14, cy + 52), width: 18, height: 28),
        const Radius.circular(10)),
      legP);
    // shoes
    final shoeP = Paint()..color = const Color(0xFF1A73E8);
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx - 14, cy + 67), width: 24, height: 12), shoeP);
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx + 14, cy + 67), width: 24, height: 12), shoeP);

    // ── Body (t-shirt style)
    final bodyP = Paint()..color = const Color(0xFF7EC8E3);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(center: Offset(cx, cy + 20), width: 68, height: 58),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
        bottomLeft: const Radius.circular(12),
        bottomRight: const Radius.circular(12)),
      bodyP);

    // shirt stripe
    final stripeP = Paint()..color = Colors.white.withAlpha((255*(0.22)).round());
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + 20), width: 68, height: 10),
      stripeP);

    // ── Arms
    final armP = Paint()..color = const Color(0xFFFFDAB9); // skin
    // left arm raised
    canvas.save();
    canvas.translate(cx - 42, cy - 2);
    canvas.rotate(-0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 16, 34), const Radius.circular(9)),
      armP);
    canvas.restore();
    // right arm raised
    canvas.save();
    canvas.translate(cx + 26, cy - 2);
    canvas.rotate(0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 16, 34), const Radius.circular(9)),
      armP);
    canvas.restore();

    // ── Neck
    final skinP = Paint()..color = const Color(0xFFFFDAB9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 10), width: 22, height: 18),
        const Radius.circular(6)),
      skinP);

    // ── Head
    canvas.drawCircle(Offset(cx, cy - 33), 36, skinP);

    // ── Hair
    final hairP = Paint()..color = const Color(0xFF3B1E08);
    canvas.drawCircle(Offset(cx, cy - 62), 22, hairP);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 55), width: 72, height: 22),
      hairP);
    // hair tuft on top
    canvas.drawCircle(Offset(cx - 4, cy - 72), 10, hairP);
    canvas.drawCircle(Offset(cx + 8, cy - 70), 9, hairP);

    // ── Eyes
    final eyeWhite = Paint()..color = Colors.white;
    final pupilP   = Paint()..color = const Color(0xFF1A1A2E);
    final shineP   = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 12, cy - 36), 9, eyeWhite);
    canvas.drawCircle(Offset(cx - 12, cy - 36), 5.5, pupilP);
    canvas.drawCircle(Offset(cx - 9,  cy - 39), 2, shineP);
    canvas.drawCircle(Offset(cx + 12, cy - 36), 9, eyeWhite);
    canvas.drawCircle(Offset(cx + 12, cy - 36), 5.5, pupilP);
    canvas.drawCircle(Offset(cx + 15, cy - 39), 2, shineP);

    // ── Eyebrows
    final browP = Paint()
      ..color = const Color(0xFF3B1E08)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 16, cy - 47), Offset(cx - 7, cy - 45), browP);
    canvas.drawLine(Offset(cx + 7,  cy - 45), Offset(cx + 16, cy - 47), browP);

    // ── Rosy cheeks
    final cheekP = Paint()..color = const Color(0xFFFF9BAD).withAlpha((255*(0.45)).round());
    canvas.drawCircle(Offset(cx - 23, cy - 27), 7, cheekP);
    canvas.drawCircle(Offset(cx + 23, cy - 27), 7, cheekP);

    // ── Nose
    final noseP = Paint()
      ..color = const Color(0xFFE8A87C)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 30), width: 8, height: 6), noseP);

    // ── Big smile
    final smileP = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()..moveTo(cx - 11, cy - 18)
            ..quadraticBezierTo(cx, cy - 11, cx + 11, cy - 18),
      smileP);

    // ── Teeth
    final teethP = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 17), width: 14, height: 6),
        const Radius.circular(3)),
      teethP);

    // ── Book prop in left hand
    final bookP  = Paint()..color = const Color(0xFFFFD166);
    final bookP2 = Paint()..color = const Color(0xFFF59E0B);
    canvas.save();
    canvas.translate(cx - 60, cy + 10);
    canvas.rotate(-0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 22, 28),
          const Radius.circular(4)), bookP);
    canvas.drawRect(const Rect.fromLTWH(10, 0, 2, 28), bookP2);
    // lines on book
    final lineP = Paint()..color = Colors.white.withAlpha((255*(0.6)).round())
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(3, 8),  const Offset(8, 8),  lineP);
    canvas.drawLine(const Offset(3, 13), const Offset(8, 13), lineP);
    canvas.drawLine(const Offset(3, 18), const Offset(8, 18), lineP);
    canvas.restore();
  }

  @override bool shouldRepaint(covariant CustomPainter o) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1 — AKTIBIDAD
// ═══════════════════════════════════════════════════════════════════════════════
class _AktibidadTab extends StatelessWidget {
  final ChildProfile profile;
  const _AktibidadTab({required this.profile});

  static const _levels = [
    ('Mga Tunog',       'Matuto ng mga pangunahing tunog',   KCCColors.blue),
    ('Mga Salita',      'Palakasin ang mga salita',          KCCColors.teal),
    ('Sa Bahay',        'Mga bagay sa loob ng bahay',        KCCColors.coral),
    ('Sa Paaralan',     'Mga gamit sa paaralan',             KCCColors.yellow),
    ('Mga Hayop',       'Kilala ang mga hayop',              KCCColors.green),
    ('Mga Pagkain',     'Pangalan ng mga pagkain',           KCCColors.blue),
    ('Mga Kulay',       'Matuto ng mga kulay',               KCCColors.teal),
    ('Mga Bilang',      'Bilang mula isa hanggang sampu',    KCCColors.coral),
    ('Mga Parirala',    'Maikling mga parirala',             KCCColors.yellow),
    ('Mga Pangungusap', 'Buong mga pangungusap',             KCCColors.green),
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding:const EdgeInsets.fromLTRB(20,20,20,32),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Mga Antas ng Pagsasanay',
          style:TextStyle(fontSize:16,fontWeight:FontWeight.w800,
              color:KCCColors.darkNavy)),
      const SizedBox(height:4),
      const Text('Piliin ang antas para magsimula.',
          style:TextStyle(fontSize:13,color:KCCColors.textMuted)),
      const SizedBox(height:16),
      ...List.generate(_levels.length,(i){
        final (title,desc,color) = _levels[i];
        final unlocked = i<2;
        return _LevelRow(
          level:i+1,title:title,desc:desc,
          color:color,unlocked:unlocked);
      }),
    ]),
  );
}

class _LevelRow extends StatelessWidget {
  final int level; final String title,desc;
  final Color color; final bool unlocked;
  const _LevelRow({required this.level,required this.title,
      required this.desc,required this.color,required this.unlocked});
  @override
  Widget build(BuildContext context) => Container(
    margin:const EdgeInsets.only(bottom:12),
    padding:const EdgeInsets.symmetric(horizontal:16,vertical:14),
    decoration:BoxDecoration(
      color:KCCColors.cardBg,
      borderRadius:BorderRadius.circular(16),
      border:Border.all(
          color:unlocked?color.withAlpha((255*(0.25)).round()):KCCColors.bgLight,width:1.5),
      boxShadow:[BoxShadow(color:Colors.black.withAlpha((255*(0.05)).round()),
          blurRadius:8,offset:const Offset(0,3))]),
    child:Row(children:[
      Container(
        width:44,height:44,
        decoration:BoxDecoration(
          color:unlocked?color:KCCColors.bgLight,shape:BoxShape.circle),
        child:Center(child:unlocked
          ? Text('$level',style:const TextStyle(fontSize:16,
              fontWeight:FontWeight.w900,color:Colors.white))
          : KCCLockIcon(size:20,color:KCCColors.textMuted)),
      ),
      const SizedBox(width:14),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,
          children:[
        Text('Antas $level',style:TextStyle(fontSize:11,
            fontWeight:FontWeight.w600,
            color:unlocked?color:KCCColors.textMuted,letterSpacing:0.5)),
        Text(title,style:TextStyle(fontSize:15,fontWeight:FontWeight.w800,
            color:unlocked?KCCColors.darkNavy:KCCColors.textMuted)),
        const SizedBox(height:2),
        Text(desc,style:const TextStyle(fontSize:12,
            color:KCCColors.textMuted,height:1.4)),
      ])),
      if(unlocked) Container(
        width:28,height:28,
        decoration:BoxDecoration(
            color:color.withAlpha((255*(0.12)).round()),shape:BoxShape.circle),
        child:Center(child:CustomPaint(
            size:const Size(11,11),painter:_ArrowR(color:color))),
      ),
    ]),
  );
}

class _ArrowR extends CustomPainter {
  final Color color; const _ArrowR({required this.color});
  @override void paint(Canvas canvas,Size s){
    canvas.drawPath(
      Path()
        ..moveTo(s.width*0.25,s.height*0.15)
        ..lineTo(s.width*0.75,s.height*0.50)
        ..lineTo(s.width*0.25,s.height*0.85),
      Paint()..color=color..strokeWidth=2.0..style=PaintingStyle.stroke
        ..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM NAV
// ═══════════════════════════════════════════════════════════════════════════════
class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      boxShadow: [BoxShadow(
          color: KCCColors.blue.withAlpha((255*(0.12)).round()),
          blurRadius: 20, offset: const Offset(0, -6))],
    ),
    child: SafeArea(top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
          _NI(icon: KCCHouseIcon(size: 26,
              color: current == 0 ? KCCColors.blue : KCCColors.textMuted),
              label: 'Tahanan', selected: current == 0, onTap: () => onTap(0)),
          _NI(icon: KCCBookIcon(size: 26,
              color: current == 1 ? KCCColors.teal : KCCColors.textMuted),
              label: 'Aktibidad', selected: current == 1, selColor: KCCColors.teal, onTap: () => onTap(1)),
          _NI(icon: KCCPersonIcon(size: 26,
              color: current == 2 ? KCCColors.purple : KCCColors.textMuted),
              label: 'Profile', selected: current == 2, selColor: KCCColors.purple, onTap: () => onTap(2)),
        ]),
      ),
    ),
  );
}

class _NI extends StatelessWidget {
  final Widget icon; final String label;
  final bool selected; final VoidCallback onTap;
  final Color selColor;
  const _NI({required this.icon,required this.label,
      required this.selected,required this.onTap,
      this.selColor = KCCColors.blue});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap, behavior: HitTestBehavior.opaque,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? selColor.withAlpha((255*(0.12)).round()) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        icon, const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: selected ? selColor : KCCColors.textMuted)),
      ]),
    ),
  );
}

// ─── (mascot used in HomeScreen is now _ChildMascotP inside _TahananTab) ──────

