// lib/widgets/kcc_widgets.dart
// Shared na kulay, icon painters, at reusable widgets para sa buong KCCTalk app.
// Walang emoji. Lahat ng icons ay gawa sa Flutter shapes. Ganap na offline.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════════════════════
class KCCColors {
  static const blue      = Color(0xFF1A73E8);
  static const teal      = Color(0xFF0D9488);
  static const lightBlue = Color(0xFF7EC8E3);
  static const coral     = Color(0xFFFF6B6B);
  static const yellow    = Color(0xFFFFD166);
  static const green     = Color(0xFF2ECC71);
  static const darkNavy  = Color(0xFF1A1A2E);
  static const textMuted = Color(0xFF8E92A3);
  static const bgLight   = Color(0xFFF4F7FC);
  static const cardBg    = Color(0xFFFFFFFF);
}

// ═══════════════════════════════════════════════════════════════════════════════
// GRADIENT BACKGROUND (onboarding pages)
// ═══════════════════════════════════════════════════════════════════════════════
class KCCBackground extends StatelessWidget {
  final Widget child;
  const KCCBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, height: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF1A73E8), Color(0xFF0D9488)],
      ),
    ),
    child: child,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// DECO CIRCLES
// ═══════════════════════════════════════════════════════════════════════════════
class KCCDecoCircles extends StatelessWidget {
  const KCCDecoCircles({super.key});
  @override
  Widget build(BuildContext context) => Stack(children: [
    Positioned(top:-60, left:-60,
        child:_DC(220, Colors.white.withAlpha((255*(0.07)).round()))),
    Positioned(bottom:-80, right:-40,
        child:_DC(260, Colors.white.withAlpha((255*(0.05)).round()))),
    Positioned(top:80, right:28,
        child:_DC(80, Colors.white.withAlpha((255*(0.08)).round()))),
    Positioned(bottom:180, left:18,
        child:_DC(50, Colors.white.withAlpha((255*(0.10)).round()))),
  ]);
}
class _DC extends StatelessWidget {
  final double size; final Color color;
  const _DC(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
    width:size, height:size,
    decoration: BoxDecoration(color:color, shape:BoxShape.circle));
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARD
// ═══════════════════════════════════════════════════════════════════════════════
class KCCCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const KCCCard({super.key, required this.child, this.padding});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: KCCColors.cardBg,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(
          color: Colors.black.withAlpha((255*(0.07)).round()),
          blurRadius: 16, offset: const Offset(0,5))],
    ),
    child: child,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIMARY BUTTON
// ═══════════════════════════════════════════════════════════════════════════════
class KCCButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  const KCCButton({super.key, required this.label,
      required this.onPressed, this.color});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 54,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? KCCColors.yellow,
        foregroundColor: KCCColors.darkNavy,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        shadowColor: (color ?? KCCColors.yellow).withAlpha((255*(0.35)).round()),
      ),
      child: Text(label,
          style: const TextStyle(fontSize:16,
              fontWeight:FontWeight.w800, letterSpacing:0.4)),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// BACK BUTTON — arrow shape, walang emoji
// ═══════════════════════════════════════════════════════════════════════════════
class KCCBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  const KCCBackButton({super.key, required this.onPressed,
      this.color = Colors.white});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onPressed,
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha((255*(0.15)).round()),
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha((255*(0.30)).round()), width: 1.5),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(16, 16),
          painter: _BackArrowPainter(color: color),
        ),
      ),
    ),
  );
}
class _BackArrowPainter extends CustomPainter {
  final Color color;
  const _BackArrowPainter({required this.color});
  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..color = color..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(s.width*0.65, s.height*0.15)
        ..lineTo(s.width*0.25, s.height*0.50)
        ..lineTo(s.width*0.65, s.height*0.85),
      paint);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// TEXT FIELD
// ═══════════════════════════════════════════════════════════════════════════════
class KCCTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final String errorText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;
  final Widget? prefixIcon;
  const KCCTextField({
    super.key,
    required this.controller, required this.focusNode,
    required this.hint, required this.errorText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters, this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: errorText.isNotEmpty
                  ? KCCColors.coral
                  : Colors.white.withAlpha((255*(0.40)).round()),
              width: 2),
          boxShadow: [BoxShadow(
              color: Colors.black.withAlpha((255*(0.06)).round()),
              blurRadius: 10, offset: const Offset(0,3))],
        ),
        child: TextField(
          controller: controller, focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onSubmitted: onSubmitted,
          textCapitalization: textCapitalization,
          style: const TextStyle(fontSize:17,
              fontWeight:FontWeight.w700, color:KCCColors.darkNavy),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color:KCCColors.textMuted, fontWeight:FontWeight.w400),
            prefixIcon: prefixIcon,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal:18, vertical:18),
          ),
        ),
      ),
      if (errorText.isNotEmpty) ...[
        const SizedBox(height:7),
        Row(children: [
          CustomPaint(size:const Size(13,13),
              painter:_ErrDot()),
          const SizedBox(width:5),
          Expanded(child:Text(errorText,
              style: const TextStyle(
                  color:KCCColors.coral, fontSize:12))),
        ]),
      ],
    ],
  );
}
class _ErrDot extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawCircle(Offset(s.width/2,s.height/2),
        s.width/2, Paint()..color=KCCColors.coral);
    final wp = Paint()..color=Colors.white..strokeWidth=1.4
      ..style=PaintingStyle.stroke..strokeCap=StrokeCap.round;
    canvas.drawLine(Offset(s.width/2,s.height*0.26),
        Offset(s.width/2,s.height*0.60), wp);
    canvas.drawCircle(Offset(s.width/2,s.height*0.78),
        1.2, Paint()..color=Colors.white);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// STEP INDICATOR
// ═══════════════════════════════════════════════════════════════════════════════
class KCCStepIndicator extends StatelessWidget {
  final int current, total;
  const KCCStepIndicator(
      {super.key, required this.current, required this.total});
  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(total, (i) => AnimatedContainer(
      duration: const Duration(milliseconds:300),
      margin: const EdgeInsets.only(right:8),
      width: i == current - 1 ? 30 : 10, height: 10,
      decoration: BoxDecoration(
        color: i < current
            ? KCCColors.yellow
            : Colors.white.withAlpha((255*(0.30)).round()),
        borderRadius: BorderRadius.circular(5),
      ),
    )),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ICON PAINTERS — walang emoji, walang font icons
// ═══════════════════════════════════════════════════════════════════════════════

class KCCClockIcon extends StatelessWidget {
  final double size; final Color color;
  const KCCClockIcon({super.key, required this.size, required this.color});
  @override Widget build(BuildContext context) =>
      CustomPaint(size:Size(size,size), painter:_ClockP(color));
}
class _ClockP extends CustomPainter {
  final Color c; const _ClockP(this.c);
  @override void paint(Canvas canvas, Size s) {
    final cx=s.width/2,cy=s.height/2,r=s.width/2-1.5;
    canvas.drawCircle(Offset(cx,cy),r,
        Paint()..color=c..style=PaintingStyle.stroke..strokeWidth=s.width*0.12);
    final h=Paint()..color=c..strokeWidth=s.width*0.10..strokeCap=StrokeCap.round;
    canvas.drawLine(Offset(cx,cy),Offset(cx,cy-r*0.52),h);
    canvas.drawLine(Offset(cx,cy),Offset(cx+r*0.38,cy+r*0.14),h);
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}

class KCCPersonIcon extends StatelessWidget {
  final double size; final Color color;
  const KCCPersonIcon({super.key, required this.size, required this.color});
  @override Widget build(BuildContext context) =>
      CustomPaint(size:Size(size,size), painter:_PersonP(color));
}
class _PersonP extends CustomPainter {
  final Color c; const _PersonP(this.c);
  @override void paint(Canvas canvas, Size s) {
    final p=Paint()..color=c;
    canvas.drawCircle(Offset(s.width/2,s.height*0.28),s.width*0.22,p);
    canvas.drawPath(
      Path()
        ..moveTo(s.width*0.10,s.height)
        ..quadraticBezierTo(s.width*0.10,s.height*0.57,s.width/2,s.height*0.57)
        ..quadraticBezierTo(s.width*0.90,s.height*0.57,s.width*0.90,s.height)
        ..close(),p);
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}

class KCCHouseIcon extends StatelessWidget {
  final double size; final Color color;
  const KCCHouseIcon({super.key, required this.size, required this.color});
  @override Widget build(BuildContext context) =>
      CustomPaint(size:Size(size,size), painter:_HouseP(color));
}
class _HouseP extends CustomPainter {
  final Color c; const _HouseP(this.c);
  @override void paint(Canvas canvas, Size s) {
    final p=Paint()..color=c;
    canvas.drawPath(
      Path()
        ..moveTo(s.width*0.50,s.height*0.08)
        ..lineTo(s.width*0.96,s.height*0.48)
        ..lineTo(s.width*0.04,s.height*0.48)
        ..close(),p);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(s.width*0.12,s.height*0.46,
            s.width*0.76,s.height*0.48),
        bottomLeft:const Radius.circular(3),
        bottomRight:const Radius.circular(3)),p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width*0.38,s.height*0.64,
            s.width*0.24,s.height*0.30),
        const Radius.circular(2)),
      Paint()..color=Colors.white.withAlpha((255*(0.90)).round()));
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}

class KCCBookIcon extends StatelessWidget {
  final double size; final Color color;
  const KCCBookIcon({super.key, required this.size, required this.color});
  @override Widget build(BuildContext context) =>
      CustomPaint(size:Size(size,size), painter:_BookP(color));
}
class _BookP extends CustomPainter {
  final Color c; const _BookP(this.c);
  @override void paint(Canvas canvas, Size s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width*0.12,s.height*0.08,
            s.width*0.76,s.height*0.84),
        const Radius.circular(4)),
      Paint()..color=c);
    final lp=Paint()..color=Colors.white.withAlpha((255*(0.85)).round())
      ..strokeWidth=s.width*0.08..strokeCap=StrokeCap.round;
    for(final dy in [0.35,0.52,0.68])
      canvas.drawLine(Offset(s.width*0.28,s.height*dy),
          Offset(s.width*0.72,s.height*dy),lp);
    canvas.drawLine(
      Offset(s.width*0.12,s.height*0.08),
      Offset(s.width*0.12,s.height*0.92),
      Paint()..color=Colors.black.withAlpha((255*(0.14)).round())
        ..strokeWidth=s.width*0.07);
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}

class KCCLockIcon extends StatelessWidget {
  final double size; final Color color;
  const KCCLockIcon({super.key, required this.size, required this.color});
  @override Widget build(BuildContext context) =>
      CustomPaint(size:Size(size,size), painter:_LockP(color));
}
class _LockP extends CustomPainter {
  final Color c; const _LockP(this.c);
  @override void paint(Canvas canvas, Size s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width*0.14,s.height*0.46,
            s.width*0.72,s.height*0.48),
        const Radius.circular(4)),
      Paint()..color=c);
    canvas.drawArc(
      Rect.fromLTWH(s.width*0.24,s.height*0.10,
          s.width*0.52,s.height*0.54),
      pi, pi, false,
      Paint()..color=c..style=PaintingStyle.stroke
        ..strokeWidth=s.width*0.13..strokeCap=StrokeCap.butt);
    canvas.drawCircle(Offset(s.width/2,s.height*0.70),
        s.width*0.09,Paint()..color=Colors.white.withAlpha((255*(0.85)).round()));
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}

class KCCStarIcon extends StatelessWidget {
  final double size; final Color color;
  const KCCStarIcon({super.key, required this.size, required this.color});
  @override Widget build(BuildContext context) =>
      CustomPaint(size:Size(size,size), painter:_StarP(color));
}
class _StarP extends CustomPainter {
  final Color c; const _StarP(this.c);
  @override void paint(Canvas canvas, Size s) {
    final cx=s.width/2,cy=s.height/2,r=s.width/2;
    final path=Path();
    for(int i=0;i<5;i++){
      final oa=(i*4*pi/5)-pi/2, ia=oa+(2*pi/10);
      if(i==0) path.moveTo(cx+r*cos(oa),cy+r*sin(oa));
      else path.lineTo(cx+r*cos(oa),cy+r*sin(oa));
      path.lineTo(cx+(r*0.42)*cos(ia),cy+(r*0.42)*sin(ia));
    }
    path.close();
    canvas.drawPath(path,Paint()..color=c);
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}

class KCCChartIcon extends StatelessWidget {
  final double size; final Color color;
  const KCCChartIcon({super.key, required this.size, required this.color});
  @override Widget build(BuildContext context) =>
      CustomPaint(size:Size(size,size), painter:_ChartP(color));
}
class _ChartP extends CustomPainter {
  final Color c; const _ChartP(this.c);
  @override void paint(Canvas canvas, Size s) {
    const bars=[0.45,0.70,0.55,0.90];
    final bw=s.width*0.16;
    final gap=(s.width-bars.length*bw)/(bars.length+1);
    for(int i=0;i<bars.length;i++){
      final x=gap+i*(bw+gap), h=s.height*0.78*bars[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x,s.height*0.82-h,bw,h),
          const Radius.circular(3)),
        Paint()..color=c);
    }
    canvas.drawLine(Offset(0,s.height*0.82),Offset(s.width,s.height*0.82),
        Paint()..color=c..strokeWidth=s.width*0.07..strokeCap=StrokeCap.round);
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROGRESS RING
// ═══════════════════════════════════════════════════════════════════════════════
class KCCProgressRing extends StatelessWidget {
  final double size, progress, strokeWidth;
  final Color trackColor, fillColor;
  final Widget? child;
  const KCCProgressRing({
    super.key,
    required this.size, required this.progress, required this.fillColor,
    this.trackColor = const Color(0xFFE8EFF8),
    this.strokeWidth = 8, this.child,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width:size, height:size,
    child:Stack(alignment:Alignment.center, children:[
      CustomPaint(size:Size(size,size),
          painter:_RingP(progress,fillColor,trackColor,strokeWidth)),
      if(child!=null) child!,
    ]),
  );
}
class _RingP extends CustomPainter {
  final double progress, strokeWidth;
  final Color trackColor, fillColor;
  const _RingP(this.progress,this.fillColor,this.trackColor,this.strokeWidth);
  @override void paint(Canvas canvas, Size s) {
    final cx=s.width/2,cy=s.height/2,r=(s.width-strokeWidth)/2;
    canvas.drawCircle(Offset(cx,cy),r,
        Paint()..color=trackColor..strokeWidth=strokeWidth
          ..style=PaintingStyle.stroke..strokeCap=StrokeCap.round);
    canvas.drawArc(
      Rect.fromCircle(center:Offset(cx,cy),radius:r),
      -pi/2, 2*pi*progress.clamp(0.0,1.0), false,
      Paint()..color=fillColor..strokeWidth=strokeWidth
        ..style=PaintingStyle.stroke..strokeCap=StrokeCap.round);
  }
  @override bool shouldRepaint(covariant CustomPainter o)=>true;
}

