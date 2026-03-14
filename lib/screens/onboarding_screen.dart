// lib/screens/onboarding_screen.dart
// Filipino lamang. Back button sa bawat hakbang maliban sa unang pahina.
// Walang emoji. Lahat ng icons ay shapes. Ganap na offline.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/kcc_widgets.dart';
import '../models/child_profile.dart';
import '../services/profile_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  final _page     = PageController();
  int   _cur      = 0; // 0=maligayang pagdating, 1=pangalan, 2=edad, 3=buod

  final _nameCtrl = TextEditingController();
  final _ageCtrl  = TextEditingController();
  final _nameFN   = FocusNode();
  final _ageFN    = FocusNode();
  String _nameErr = '', _ageErr = '';

  late AnimationController _fadeCtrl;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync:this, duration:const Duration(milliseconds:450));
    _fade = CurvedAnimation(parent:_fadeCtrl, curve:Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _page.dispose(); _nameCtrl.dispose(); _ageCtrl.dispose();
    _nameFN.dispose(); _ageFN.dispose(); _fadeCtrl.dispose();
    super.dispose();
  }

  // ─── Navigation ─────────────────────────────────────────────────────────────
  void _next() {
    if (_cur == 1 && !_checkName()) return;
    if (_cur == 2 && !_checkAge())  return;
    if (_cur < 3) {
      _fadeCtrl.reset();
      _page.nextPage(
          duration:const Duration(milliseconds:380), curve:Curves.easeInOut);
      setState(() => _cur++);
      _fadeCtrl.forward();
    }
  }

  void _back() {
    if (_cur > 0) {
      _fadeCtrl.reset();
      _page.previousPage(
          duration:const Duration(milliseconds:380), curve:Curves.easeInOut);
      setState(() => _cur--);
      _fadeCtrl.forward();
    }
  }

  // ─── Validation ─────────────────────────────────────────────────────────────
  bool _checkName() {
    final n = _nameCtrl.text.trim();
    if (n.isEmpty) {
      setState(() => _nameErr = 'Pakiusap ilagay ang pangalan ng bata.');
      return false;
    }
    if (n.length < 2) {
      setState(() => _nameErr = 'Ang pangalan ay dapat may dalawang titik man lang.');
      return false;
    }
    setState(() => _nameErr = '');
    return true;
  }

  bool _checkAge() {
    final t   = _ageCtrl.text.trim();
    final age = int.tryParse(t);
    if (t.isEmpty) {
      setState(() => _ageErr = 'Pakiusap ilagay ang edad ng bata.');
      return false;
    }
    if (age == null || age < 2 || age > 20) {
      setState(() => _ageErr = 'Ang edad ay dapat nasa pagitan ng 2 at 20.');
      return false;
    }
    setState(() => _ageErr = '');
    return true;
  }

  Future<void> _save() async {
    if (!_checkName() || !_checkAge()) return;
    final p = ChildProfile(
      name: _nameCtrl.text.trim(),
      age:  int.parse(_ageCtrl.text.trim()),
    );
    await ProfileService.saveProfile(p);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds:500),
      pageBuilder: (_,a,_) =>
          FadeTransition(opacity:a, child:HomeScreen(profile:p)),
    ));
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      if (_cur > 0) { _back(); return false; }
      return false; // hindi makakaalis sa onboarding
    },
    child: Scaffold(
      body: KCCBackground(
        child: SafeArea(
          child: Stack(children:[
            const KCCDecoCircles(),
            FadeTransition(
              opacity: _fade,
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                children: [_welcome(), _namePage(), _agePage(), _summary()],
              ),
            ),
            // Back button — lahat ng pahina maliban sa welcome (pahina 0)
            if (_cur > 0)
              Positioned(
                top:12, left:16,
                child: KCCBackButton(onPressed:_back),
              ),
          ]),
        ),
      ),
    ),
  );

  // ─── Pahina 1: Maligayang Pagdating ─────────────────────────────────────────
  Widget _welcome() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(28,24,28,32),
    child: Column(children:[
      const SizedBox(height:16),
      SizedBox(width:120,height:120,
          child:CustomPaint(painter:_MascotP())),
      const SizedBox(height:20),
      Row(mainAxisAlignment:MainAxisAlignment.center,
          children:_colorLetters('KCCTALK',36)),
      const SizedBox(height:8),
      Container(
        padding:const EdgeInsets.symmetric(horizontal:14,vertical:6),
        decoration:BoxDecoration(
          color:Colors.white.withOpacity(0.15),
          borderRadius:BorderRadius.circular(20),
          border:Border.all(color:Colors.white.withOpacity(0.30))),
        child:const Text('Tulong sa Pagsasalita para sa mga Bata',
            style:TextStyle(color:Colors.white,fontSize:13,
                fontWeight:FontWeight.w500)),
      ),
      const SizedBox(height:24),
      KCCCard(child:Column(children:[
        const Text('Maligayang pagdating!',
            style:TextStyle(fontSize:18,fontWeight:FontWeight.w800,
                color:KCCColors.darkNavy)),
        const SizedBox(height:8),
        const Text(
          'Ang KCCTalk ay isang gabay sa pagsasalita para sa mga batang '
          'nangangailangan ng tulong. Gamitin kasama ang isang magulang o guro.',
          textAlign:TextAlign.center,
          style:TextStyle(fontSize:14,color:KCCColors.textMuted,height:1.6)),
      ])),
      const SizedBox(height:24),
      KCCButton(label:'Magsimula', onPressed:_next),
      const SizedBox(height:10),
      const Text('Para sa magulang o guro',
          style:TextStyle(color:Colors.white60,fontSize:13)),
    ]),
  );

  // ─── Pahina 2: Pangalan ──────────────────────────────────────────────────────
  Widget _namePage() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(28,72,28,32),
    child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      KCCStepIndicator(current:1, total:3),
      const SizedBox(height:28),
      const Text('Ano ang pangalan\nng bata?',
          style:TextStyle(fontSize:28,fontWeight:FontWeight.w800,
              color:Colors.white,height:1.3)),
      const SizedBox(height:6),
      const Text('Ito ang gagamitin ng app para batiin ang bata.',
          style:TextStyle(fontSize:14,color:Colors.white70)),
      const SizedBox(height:28),
      KCCTextField(
        controller:_nameCtrl, focusNode:_nameFN,
        hint:'Halimbawa: Juan', errorText:_nameErr,
        onSubmitted:(_)=>_next(),
        textCapitalization:TextCapitalization.words,
        prefixIcon:Padding(padding:const EdgeInsets.all(14),
            child:KCCPersonIcon(size:20,color:KCCColors.blue)),
      ),
      const SizedBox(height:28),
      KCCButton(label:'Susunod', onPressed:_next),
    ]),
  );

  // ─── Pahina 3: Edad ──────────────────────────────────────────────────────────
  Widget _agePage() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(28,72,28,32),
    child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      KCCStepIndicator(current:2, total:3),
      const SizedBox(height:28),
      const Text('Ilang taon na\nang bata?',
          style:TextStyle(fontSize:28,fontWeight:FontWeight.w800,
              color:Colors.white,height:1.3)),
      const SizedBox(height:6),
      const Text('Gagamitin ito para itakda ang limitasyon ng oras.',
          style:TextStyle(fontSize:14,color:Colors.white70)),
      const SizedBox(height:28),
      KCCTextField(
        controller:_ageCtrl, focusNode:_ageFN,
        hint:'Halimbawa: 8', errorText:_ageErr,
        keyboardType:TextInputType.number,
        inputFormatters:[FilteringTextInputFormatter.digitsOnly],
        onSubmitted:(_)=>_next(),
        prefixIcon:Padding(padding:const EdgeInsets.all(14),
            child:KCCClockIcon(size:20,color:KCCColors.teal)),
      ),
      const SizedBox(height:12),
      ValueListenableBuilder(
        valueListenable:_ageCtrl,
        builder:(_,_,_){
          final age = int.tryParse(_ageCtrl.text.trim());
          if (age==null) return const SizedBox.shrink();
          return _TimeLimitHint(age:age, minutes:age<=2?15:40);
        },
      ),
      const SizedBox(height:28),
      KCCButton(label:'Susunod', onPressed:_next),
    ]),
  );

  // ─── Pahina 4: Buod ──────────────────────────────────────────────────────────
  Widget _summary() {
    final name = _nameCtrl.text.trim();
    final age  = int.tryParse(_ageCtrl.text.trim()) ?? 0;
    final prof = ChildProfile(name:name, age:age);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28,72,28,32),
      child: Column(children:[
        KCCStepIndicator(current:3, total:3),
        const SizedBox(height:24),
        Container(
          width:76,height:76,
          decoration:const BoxDecoration(
              color:KCCColors.green,shape:BoxShape.circle),
          child:Center(child:CustomPaint(
              size:const Size(34,34), painter:_CheckP())),
        ),
        const SizedBox(height:12),
        const Text('Handa na!',
            style:TextStyle(fontSize:30,fontWeight:FontWeight.w900,
                color:Colors.white)),
        const SizedBox(height:4),
        const Text('Suriin ang impormasyon bago magsimula.',
            style:TextStyle(color:Colors.white70,fontSize:14)),
        const SizedBox(height:20),
        KCCCard(child:Column(children:[
          _sRow(KCCPersonIcon(size:20,color:KCCColors.blue),
              'Pangalan ng Bata', name.isEmpty?'—':name),
          const Divider(height:22,color:Color(0xFFEEEEEE)),
          _sRow(KCCClockIcon(size:20,color:KCCColors.teal),
              'Edad', age==0?'—':'$age taong gulang'),
          const Divider(height:22,color:Color(0xFFEEEEEE)),
          _sRow(KCCClockIcon(size:20,color:KCCColors.coral),
              'Limitasyon sa Oras',
              '${prof.screenTimeLimitMinutes} minuto bawat araw',
              vc:KCCColors.coral),
        ])),
        const SizedBox(height:10),
        Text(
          'Awtomatikong mag-lock ang app pagkatapos ng limitang oras bawat araw.',
          textAlign:TextAlign.center,
          style:TextStyle(color:Colors.white.withOpacity(0.65),
              fontSize:13,height:1.5)),
        const SizedBox(height:22),
        KCCButton(label:'Simulan ang App', onPressed:_save),
      ]),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  Widget _sRow(Widget icon, String lbl, String val, {Color? vc}) =>
      Row(children:[
        icon, const SizedBox(width:14),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,
            children:[
              Text(lbl,style:const TextStyle(
                  fontSize:12,color:KCCColors.textMuted)),
              Text(val,style:TextStyle(fontSize:16,fontWeight:FontWeight.w700,
                  color:vc??KCCColors.darkNavy)),
            ])),
      ]);

  List<Widget> _colorLetters(String word, double size) {
    const colors = [KCCColors.yellow, KCCColors.coral, KCCColors.lightBlue];
    return word.split('').asMap().entries.map((e) => Text(e.value,
        style:TextStyle(fontSize:size, fontWeight:FontWeight.w900,
          color:colors[e.key % colors.length],
          shadows:[Shadow(color:Colors.black.withOpacity(0.20),
              offset:const Offset(2,3))]))).toList();
  }
}

class _TimeLimitHint extends StatelessWidget {
  final int age, minutes;
  const _TimeLimitHint({required this.age, required this.minutes});
  @override Widget build(BuildContext context) => Container(
    padding:const EdgeInsets.symmetric(horizontal:16,vertical:12),
    decoration:BoxDecoration(
      color:KCCColors.yellow.withOpacity(0.18),
      borderRadius:BorderRadius.circular(12),
      border:Border.all(color:KCCColors.yellow.withOpacity(0.50),width:1.5)),
    child:Row(children:[
      KCCClockIcon(size:22,color:KCCColors.yellow),
      const SizedBox(width:12),
      Expanded(child:Text(
        'Ang batang $age taong gulang ay makakagamit ng $minutes minuto bawat araw.',
        style:const TextStyle(fontSize:13,color:Colors.white,height:1.4))),
    ]),
  );
}

class _MascotP extends CustomPainter {
  @override void paint(Canvas canvas, Size s) {
    final cx=s.width/2,cy=s.height/2;
    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromCenter(center:Offset(cx,cy+8),width:72,height:78),
      topLeft:const Radius.circular(36),topRight:const Radius.circular(36),
      bottomLeft:const Radius.circular(28),bottomRight:const Radius.circular(28)),
      Paint()..color=const Color(0xFF7EC8E3));
    canvas.drawOval(Rect.fromCenter(center:Offset(cx,cy+14),width:36,height:42),
        Paint()..color=Colors.white.withOpacity(0.28));
    canvas.drawCircle(Offset(cx,cy-20),30,Paint()..color=const Color(0xFF93D8EE));
    for(final dx in [-23.0,23.0]){
      canvas.drawCircle(Offset(cx+dx,cy-38),10,Paint()..color=const Color(0xFF6BB8D4));
      canvas.drawCircle(Offset(cx+dx,cy-38),6,Paint()..color=const Color(0xFFFFB8C8));
    }
    for(final dx in [-10.0,10.0]){
      canvas.drawCircle(Offset(cx+dx,cy-22),7,Paint()..color=Colors.white);
      canvas.drawCircle(Offset(cx+dx,cy-22),4,Paint()..color=const Color(0xFF1A1A2E));
      canvas.drawCircle(Offset(cx+dx+(dx>0?2:-2),cy-24),1.8,Paint()..color=Colors.white);
    }
    for(final dx in [-19.0,19.0]) {
      canvas.drawCircle(Offset(cx+dx,cy-13),6,
          Paint()..color=const Color(0xFFFF9BAD).withOpacity(0.45));
    }
    canvas.drawPath(
      Path()..moveTo(cx-9,cy-8)..quadraticBezierTo(cx,cy-2,cx+9,cy-8),
      Paint()..color=const Color(0xFF1A1A2E)..style=PaintingStyle.stroke
        ..strokeWidth=2.0..strokeCap=StrokeCap.round);
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}

class _CheckP extends CustomPainter {
  @override void paint(Canvas canvas, Size s) {
    canvas.drawPath(
      Path()
        ..moveTo(s.width*0.15,s.height*0.50)
        ..lineTo(s.width*0.40,s.height*0.75)
        ..lineTo(s.width*0.85,s.height*0.25),
      Paint()..color=Colors.white..strokeWidth=3.5
        ..style=PaintingStyle.stroke
        ..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}