// lib/screens/profile_screen.dart
// Pahina ng Profil — pangalan, progreso, bituin, istatistika.
// Filipino lamang. Walang emoji. Shapes lang. Ganap na offline.
// Ang back button ay nasa AppBar ng HomeScreen (ipinakita kapag nasa tab na ito).

import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/progress_model.dart';
import '../services/screen_time_service.dart';
import '../services/profile_service.dart';
import '../services/progress_service.dart';
import '../widgets/kcc_widgets.dart';
import 'profile_selector_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChildProfile profile;
  const ProfileScreen({super.key, required this.profile});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {

  int  _usedSeconds = 0;
  bool _loaded      = false;

  // Real progress from SQLite
  ProgressSummary _summary = const ProgressSummary(
    totalStars: 0, totalActivitiesDone: 0,
    levelsUnlocked: 1, bestScorePerActivity: {},
  );

  late AnimationController _ringCtrl;
  late Animation<double>   _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync:this, duration:const Duration(milliseconds:900));
    _ringAnim = CurvedAnimation(parent:_ringCtrl, curve:Curves.easeOut);
    _loadData();
  }

  Future<void> _loadData() async {
    final used    = await ScreenTimeService.getUsedSecondsToday(widget.profile.id ?? 0);
    final summary = await ProgressService.getSummary(widget.profile.id ?? 0);
    if (!mounted) return;
    setState(() { _usedSeconds = used; _summary = summary; _loaded = true; });
    _ringCtrl.forward();
  }

  @override void dispose() { _ringCtrl.dispose(); super.dispose(); }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: KCCColors.blue.withAlpha((255*(0.10)).round()),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  size: 36, color: KCCColors.blue),
            ),
            const SizedBox(height: 16),
            const Text('Mag-sign out?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                    color: KCCColors.darkNavy)),
            const SizedBox(height: 8),
            const Text(
              'Mase-save ang lahat ng iyong progreso at mga bituin. '
              'Maaari kang bumalik anumang oras.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: KCCColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: KCCColors.green.withAlpha((255*(0.10)).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_outline,
                    size: 16, color: KCCColors.green),
                const SizedBox(width: 6),
                Text('Hindi mabubura ang data',
                    style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w700, color: KCCColors.green)),
              ]),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Hindi',
                      style: TextStyle(color: KCCColors.textMuted,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KCCColors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Oo, sign out',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
    if (confirm != true || !mounted) return;
    await ProfileService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, a, __) => FadeTransition(
            opacity: a, child: const ProfileSelectorScreen()),
      ),
      (_) => false,
    );
  }

  Future<void> _switchProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSelectorScreen(fromInsideApp: true),
      ),
    );
  }

  String _fmtTime(int s) {
    final m = s ~/ 60, sec = s % 60;
    if (m == 0) return '$sec segundo';
    return '$m minuto${sec>0?' at $sec segundo':''}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(
        child:CircularProgressIndicator(color:KCCColors.blue));

    final limitSec   = widget.profile.screenTimeLimitMinutes * 60;
    final usageRatio = limitSec > 0
        ? (_usedSeconds / limitSec).clamp(0.0, 1.0) : 0.0;

    final starsEarned    = _summary.totalStars;
    final totalStars     = 10;
    final levelsFinished = _summary.levelsUnlocked;
    final totalLevels    = ProgressSummary.totalLevels;
    final activitiesDone = _summary.totalActivitiesDone;

    final levelRatio = levelsFinished / totalLevels;
    final starRatio  = totalStars > 0
        ? (starsEarned / totalStars).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding:const EdgeInsets.fromLTRB(20,20,20,32),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[

        // ── Header ng Profil ─────────────────────────────────────────────
        KCCCard(child:Row(children:[
          Container(
            width:72,height:72,
            decoration:const BoxDecoration(
              gradient:LinearGradient(
                  colors:[Color(0xFF1A73E8),Color(0xFF0D9488)]),
              shape:BoxShape.circle),
            child:Center(child:CustomPaint(
                size:const Size(44,44),painter:_MedMascotP())),
          ),
          const SizedBox(width:16),
          Expanded(child:Column(
              crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(widget.profile.name,
                style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900,
                    color:KCCColors.darkNavy)),
            const SizedBox(height:3),
            Text('${widget.profile.age} taong gulang',
                style:const TextStyle(fontSize:14,color:KCCColors.textMuted)),
            const SizedBox(height:6),
            Container(
              padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
              decoration:BoxDecoration(
                color:KCCColors.blue.withAlpha((255*(0.10)).round()),
                borderRadius:BorderRadius.circular(20)),
              child:Row(mainAxisSize:MainAxisSize.min,children:[
                KCCClockIcon(size:12,color:KCCColors.blue),
                const SizedBox(width:5),
                Text('${widget.profile.screenTimeLimitMinutes} min / araw',
                    style:const TextStyle(fontSize:12,
                        fontWeight:FontWeight.w700,color:KCCColors.blue)),
              ]),
            ),
          ])),
        ])),

        const SizedBox(height:20),

        // ── Progreso ngayon ──────────────────────────────────────────────
        const Text('Progreso Ngayon',
            style:TextStyle(fontSize:16,fontWeight:FontWeight.w800,
                color:KCCColors.darkNavy)),
        const SizedBox(height:12),

        Row(children:[
          Expanded(child:_RingCard(
            anim:_ringAnim, progress:levelRatio,
            fillColor:KCCColors.teal,
            label:'Mga Antas\nNatapos',
            value:'$levelsFinished/$totalLevels',
            icon:KCCBookIcon(size:18,color:KCCColors.teal),
          )),
          const SizedBox(width:16),
          Expanded(child:_RingCard(
            anim:_ringAnim, progress:starRatio,
            fillColor:KCCColors.yellow,
            label:'Mga Bituin\nNatanggap',
            value:'$starsEarned/$totalStars',
            icon:KCCStarIcon(size:18,color:KCCColors.yellow),
          )),
        ]),

        const SizedBox(height:20),

        // ── Progress bar ng oras ─────────────────────────────────────────
        KCCCard(child:Column(
            crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[
            KCCChartIcon(size:18,color:KCCColors.blue),
            const SizedBox(width:8),
            const Text('Oras ng Paggamit Ngayon',
                style:TextStyle(fontSize:14,fontWeight:FontWeight.w800,
                    color:KCCColors.darkNavy)),
          ]),
          const SizedBox(height:14),
          ClipRRect(
            borderRadius:BorderRadius.circular(8),
            child:AnimatedBuilder(
              animation:_ringAnim,
              builder:(_,__) => LinearProgressIndicator(
                value:usageRatio*_ringAnim.value,
                minHeight:12,
                backgroundColor:KCCColors.bgLight,
                valueColor:AlwaysStoppedAnimation<Color>(
                    usageRatio>0.85?KCCColors.coral:KCCColors.blue),
              ),
            ),
          ),
          const SizedBox(height:10),
          Row(children:[
            Expanded(
              child: Text('Nagamit: ${_fmtTime(_usedSeconds)}',
                  overflow: TextOverflow.ellipsis,
                  style:const TextStyle(fontSize:12,color:KCCColors.textMuted)),
            ),
            const SizedBox(width:12),
            const SizedBox(width:12),
            Text('Limitasyon: ${widget.profile.screenTimeLimitMinutes} min',
                style:const TextStyle(fontSize:12,color:KCCColors.textMuted)),
          ]),
        ])),

        const SizedBox(height:20),

        // ── Mga Gantimpala ───────────────────────────────────────────────
        const Text('Mga Gantimpala',
            style:TextStyle(fontSize:16,fontWeight:FontWeight.w800,
                color:KCCColors.darkNavy)),
        const SizedBox(height:12),

        KCCCard(child:Column(children:[
          FittedBox(
            child: Row(mainAxisAlignment:MainAxisAlignment.center,
                children:List.generate(totalStars,(i)=>Padding(
              padding:const EdgeInsets.symmetric(horizontal:3),
              child:KCCStarIcon(
                size:26,
                color:i<starsEarned?KCCColors.yellow:KCCColors.bgLight),
            ))),
          ),
          const SizedBox(height:14),
          Text('$starsEarned sa $totalStars na bituin ang nakuha mo!',
              textAlign:TextAlign.center,
              style:const TextStyle(fontSize:14,fontWeight:FontWeight.w700,
                  color:KCCColors.darkNavy)),
          const SizedBox(height:4),
          const Text(
            'Magpatuloy sa pagsasanay para makakuha ng mas maraming bituin.',
            textAlign:TextAlign.center,
            style:TextStyle(fontSize:12,color:KCCColors.textMuted,height:1.5)),
        ])),

        const SizedBox(height:20),

        // ── Mga Istatistika ──────────────────────────────────────────────
        const Text('Mga Istatistika',
            style:TextStyle(fontSize:16,fontWeight:FontWeight.w800,
                color:KCCColors.darkNavy)),
        const SizedBox(height:12),

        KCCCard(child:Column(children:[
          _StatRow(icon:KCCBookIcon(size:18,color:KCCColors.teal),
              label:'Mga Antas na Natapos',
              value:'$levelsFinished antas', color:KCCColors.teal),
          const Divider(height:20,color:Color(0xFFEEEEEE)),
          _StatRow(icon:KCCStarIcon(size:18,color:KCCColors.yellow),
              label:'Kabuuang Bituin',
              value:'$starsEarned bituin', color:KCCColors.yellow),
          const Divider(height:20,color:Color(0xFFEEEEEE)),
          _StatRow(icon:KCCChartIcon(size:18,color:KCCColors.blue),
              label:'Mga Aktibidad na Ginawa',
              value:'$activitiesDone gawain', color:KCCColors.blue),
          const Divider(height:20,color:Color(0xFFEEEEEE)),
          _StatRow(icon:KCCClockIcon(size:18,color:KCCColors.coral),
              label:'Oras na Nagamit Ngayon',
              value:_fmtTime(_usedSeconds), color:KCCColors.coral),
        ])),

        const SizedBox(height:20),

        // ── Mensahe ng Pagpapalakas ──────────────────────────────────────
        Container(
          width:double.infinity,
          padding:const EdgeInsets.all(20),
          decoration:BoxDecoration(
            gradient:const LinearGradient(
                colors:[Color(0xFF1A73E8),Color(0xFF0D9488)]),
            borderRadius:BorderRadius.circular(20)),
          child:Column(children:[
            Row(mainAxisAlignment:MainAxisAlignment.center,children:[
              KCCStarIcon(size:20,color:KCCColors.yellow),
              const SizedBox(width:6),
              KCCStarIcon(size:26,color:KCCColors.yellow),
              const SizedBox(width:6),
              KCCStarIcon(size:20,color:KCCColors.yellow),
            ]),
            const SizedBox(height:12),
            Text('Napakagaling mo, ${widget.profile.name}!',
                textAlign:TextAlign.center,
                style:const TextStyle(fontSize:16,
                    fontWeight:FontWeight.w900,color:Colors.white)),
            const SizedBox(height:6),
            const Text(
              'Huwag tumigil sa pagsasanay. Bawat araw ay isang bagong '
              'pagkakataon para lumago at matuto.',
              textAlign:TextAlign.center,
              style:TextStyle(fontSize:13,color:Colors.white70,height:1.5)),
          ]),
        ),
        const SizedBox(height:20),

        // ── Switch Profile button ────────────────────────────────────────
        GestureDetector(
          onTap: _switchProfile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: KCCColors.blue.withAlpha((255*(0.07)).round()),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: KCCColors.blue.withAlpha((255*(0.25)).round()), width: 1.5),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: KCCColors.blue.withAlpha((255*(0.12)).round()),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.switch_account_rounded,
                    size: 18, color: KCCColors.blue),
              ),
              const SizedBox(width: 12),
              const Text('Lumipat ng Profile',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                      color: KCCColors.blue)),
            ]),
          ),
        ),

        const SizedBox(height: 10),

        // ── Sign-out button ──────────────────────────────────────────────
        GestureDetector(
          onTap: _signOut,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: KCCColors.coral.withAlpha((255*(0.08)).round()),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: KCCColors.coral.withAlpha((255*(0.35)).round()), width: 1.5),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: KCCColors.coral.withAlpha((255*(0.15)).round()),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, size: 18, color: KCCColors.coral),
              ),
              const SizedBox(width: 12),
              const Text('Mag-sign Out',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                      color: KCCColors.coral)),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('Mase-save ang lahat ng progreso mo.',
              style: TextStyle(fontSize: 11, color: KCCColors.textMuted)),
        ),

      ]),
    );
  }
}

// ─── Ring card widget ─────────────────────────────────────────────────────────
class _RingCard extends StatelessWidget {
  final Animation<double> anim;
  final double progress; final Color fillColor;
  final String label, value; final Widget icon;
  const _RingCard({required this.anim,required this.progress,
      required this.fillColor,required this.label,
      required this.value,required this.icon});
  @override
  Widget build(BuildContext context) => KCCCard(
    padding:const EdgeInsets.symmetric(horizontal:12,vertical:20),
    child:Column(children:[
      AnimatedBuilder(
        animation:anim,
        builder:(_,__) => KCCProgressRing(
          size:76,strokeWidth:8,
          progress:progress*anim.value,
          fillColor:fillColor,
          child:icon,
        ),
      ),
      const SizedBox(height:12),
      Text(value,
          textAlign:TextAlign.center,
          style:TextStyle(fontSize:15,
              fontWeight:FontWeight.w900,color:fillColor)),
      const SizedBox(height:4),
      Text(label,textAlign:TextAlign.center,
          style:const TextStyle(fontSize:11,
              color:KCCColors.textMuted,height:1.3)),
    ]),
  );
}

// ─── Stat row ─────────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  final Widget icon; final String label, value; final Color color;
  const _StatRow({required this.icon,required this.label,
      required this.value,required this.color});
  @override
  Widget build(BuildContext context) => Row(children:[
    Container(
      width:36,height:36,
      decoration:BoxDecoration(color:color.withAlpha((255*(0.10)).round()),
          borderRadius:BorderRadius.circular(10)),
      child:Center(child:icon),
    ),
    const SizedBox(width:12),
    Expanded(child:Text(label,
        style:const TextStyle(fontSize:13,color:KCCColors.textMuted))),
    Text(value,style:TextStyle(fontSize:13,
        fontWeight:FontWeight.w800,color:color)),
  ]);
}

// ─── Medium mascot painter ────────────────────────────────────────────────────
class _MedMascotP extends CustomPainter {
  @override void paint(Canvas canvas,Size s){
    final cx=s.width/2,cy=s.height/2;
    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromCenter(center:Offset(cx,cy+5),width:28,height:30),
      topLeft:const Radius.circular(14),topRight:const Radius.circular(14),
      bottomLeft:const Radius.circular(11),bottomRight:const Radius.circular(11)),
      Paint()..color=const Color(0xFF7EC8E3));
    canvas.drawCircle(Offset(cx,cy-10),14,Paint()..color=const Color(0xFF93D8EE));
    for(final dx in [-10.0,10.0]){
      canvas.drawCircle(Offset(cx+dx,cy-20),5,Paint()..color=const Color(0xFF6BB8D4));
      canvas.drawCircle(Offset(cx+dx,cy-20),3,Paint()..color=const Color(0xFFFFB8C8));
    }
    for(final dx in [-5.0,5.0]){
      canvas.drawCircle(Offset(cx+dx,cy-11),4.5,Paint()..color=Colors.white);
      canvas.drawCircle(Offset(cx+dx,cy-11),2.8,Paint()..color=const Color(0xFF1A1A2E));
      canvas.drawCircle(Offset(cx+dx+(dx>0?1.5:-1.5),cy-13),1.2,Paint()..color=Colors.white);
    }
    for(final dx in [-9.0,9.0])
      canvas.drawCircle(Offset(cx+dx,cy-4),3.5,
          Paint()..color=const Color(0xFFFF9BAD).withAlpha((255*(0.45)).round()));
    canvas.drawPath(
      Path()..moveTo(cx-5,cy+1)..quadraticBezierTo(cx,cy+5,cx+5,cy+1),
      Paint()..color=const Color(0xFF1A1A2E)..style=PaintingStyle.stroke
        ..strokeWidth=1.6..strokeCap=StrokeCap.round);
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}

