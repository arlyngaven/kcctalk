import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════════════════════

class KCCColors {
  static const Color green   = Color(0xFF22C55E);
  static const Color yellow  = Color(0xFFFBBF24);
  static const Color coral   = Color(0xFFF43F5E);
  static const Color lightBlue = Color(0xFF38BDF8);
  static const Color bgLight = Color(0xFFFFF7ED);   // warm cream bg
  static const Color blue    = Color(0xFF6366F1);   // fun indigo-purple
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color teal    = Color(0xFF2DD4BF);
  static const Color cardBg  = Color(0xFFFFFFFF);
  static const Color purple  = Color(0xFFA855F7);
  static const Color orange  = Color(0xFFF97316);
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class KCCBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const KCCBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    icon: const Icon(Icons.arrow_back, color: Colors.white),
  );
}

class KCCClockIcon extends StatelessWidget {
  final double size;
  final Color color;
  const KCCClockIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.access_time,
    size: size,
    color: color,
  );
}

class KCCCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  const KCCCard({super.key, required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: KCCColors.cardBg,
      borderRadius: BorderRadius.circular(24),
      border: borderColor != null
          ? Border.all(color: borderColor!, width: 2)
          : null,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6366F1).withAlpha((255*(0.08)).round()),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

class KCCBookIcon extends StatelessWidget {
  final double size;
  final Color color;
  const KCCBookIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.book,
    size: size,
    color: color,
  );
}

class KCCLockIcon extends StatelessWidget {
  final double size;
  final Color color;
  const KCCLockIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.lock,
    size: size,
    color: color,
  );
}

class KCCHouseIcon extends StatelessWidget {
  final double size;
  final Color color;
  const KCCHouseIcon({super.key, required this.size, this.color = Colors.white});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.home,
    size: size,
    color: color,
  );
}

class KCCPersonIcon extends StatelessWidget {
  final double size;
  final Color color;
  const KCCPersonIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.person,
    size: size,
    color: color,
  );
}

class KCCStarIcon extends StatelessWidget {
  final double size;
  final Color color;
  const KCCStarIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.star,
    size: size,
    color: color,
  );
}

class KCCChartIcon extends StatelessWidget {
  final double size;
  final Color color;
  const KCCChartIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.bar_chart,
    size: size,
    color: color,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMPLEX WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class KCCBackground extends StatelessWidget {
  final Widget child;
  const KCCBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF818CF8), Color(0xFF38BDF8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: child,
  );
}

class KCCDecoCircles extends StatelessWidget {
  const KCCDecoCircles({super.key});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(top: 40, left: 20,
        child: _Blob(size: 110, color: KCCColors.yellow.withAlpha((255*(0.22)).round()))),
      Positioned(top: 160, right: 30,
        child: _Blob(size: 90, color: KCCColors.coral.withAlpha((255*(0.18)).round()))),
      Positioned(bottom: 200, left: 40,
        child: _Blob(size: 70, color: KCCColors.green.withAlpha((255*(0.20)).round()))),
      Positioned(bottom: 100, right: 20,
        child: _Blob(size: 60, color: KCCColors.purple.withAlpha((255*(0.18)).round()))),
    ],
  );
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class KCCButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  const KCCButton({super.key, required this.label, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? KCCColors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        shadowColor: (color ?? KCCColors.blue).withAlpha((255*(0.40)).round()),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 17,
            fontWeight: FontWeight.w800, letterSpacing: 0.3),
      ),
    ),
  );
}

class KCCStepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const KCCStepIndicator({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    const dotColors = [KCCColors.yellow, KCCColors.coral, KCCColors.green];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: index < current ? 22 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: index < current
                ? dotColors[index % dotColors.length]
                : Colors.white.withAlpha((255*(0.35)).round()),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}

class KCCTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final FocusNode? focusNode;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;
  final Widget? prefixIcon;
  const KCCTextField({
    super.key,
    this.controller,
    this.hint,
    this.focusNode,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    textCapitalization: textCapitalization,
    onSubmitted: onSubmitted,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
        color: KCCColors.darkNavy),
    decoration: InputDecoration(
      hintText: hint,
      errorText: errorText,
      prefixIcon: prefixIcon,
      hintStyle: const TextStyle(color: KCCColors.textMuted, fontWeight: FontWeight.w400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: KCCColors.blue, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: KCCColors.coral, width: 2),
      ),
      filled: true,
      fillColor: KCCColors.cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
  );
}

class KCCProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? fillColor;
  final Widget? child;
  const KCCProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.fillColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          strokeWidth: strokeWidth,
          backgroundColor: KCCColors.bgLight,
          valueColor: AlwaysStoppedAnimation<Color>(fillColor ?? KCCColors.blue),
        ),
        // ignore: use_null_aware_elements
        if (child != null) child!,
      ],
    ),
  );
}

