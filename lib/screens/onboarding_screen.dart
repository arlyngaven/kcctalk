// lib/screens/onboarding_screen.dart
//
// A 3-step onboarding flow for the guardian to set up the child profile.
// Step 1: Welcome
// Step 2: Enter child's name
// Step 3: Enter child's age → show screen time summary → Save

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form inputs
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _nameFocus = FocusNode();
  final _ageFocus = FocusNode();

  String _nameError = '';
  String _ageError = '';

  // Animation
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _nameFocus.dispose();
    _ageFocus.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 1 && !_validateName()) return;
    if (_currentPage == 2 && !_validateAge()) return;

    if (_currentPage < 3) {
      _fadeCtrl.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _fadeCtrl.forward();
    }
  }

  bool _validateName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Pakiusap ilagay ang pangalan ng bata.');
      return false;
    }
    if (name.length < 2) {
      setState(() => _nameError = 'Ang pangalan ay dapat may 2 titik man lang.');
      return false;
    }
    setState(() => _nameError = '');
    return true;
  }

  bool _validateAge() {
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) {
      setState(() => _ageError = 'Pakiusap ilagay ang edad ng bata.');
      return false;
    }
    final age = int.tryParse(ageText);
    if (age == null || age < 2 || age > 20) {
      setState(() => _ageError = 'Ang edad ay dapat nasa pagitan ng 2 at 20.');
      return false;
    }
    setState(() => _ageError = '');
    return true;
  }

  Future<void> _saveAndProceed() async {
    if (!_validateName() || !_validateAge()) return;

    final profile = ChildProfile(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
    );

    await ProfileService.saveProfile(profile);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _buildWelcomePage(),
              _buildNamePage(),
              _buildAgePage(),
              _buildSummaryPage(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Page 1: Welcome ────────────────────────────────────────────────────────

  Widget _buildWelcomePage() {
    return _PageWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo / mascot area
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD166),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD166).withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.mic, size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'KCCTALK',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A2E),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Salamat sa paggamit ng KCCTalk!\nItong app ay para sa mga batang\nnangangailangan ng tulong sa pagsasalita.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF555577),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),
          _PrimaryButton(
            label: 'Magsimula →',
            onPressed: _nextPage,
          ),
          const SizedBox(height: 20),
          const Text(
            'Para sa magulang o guro',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFAAAAAA),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 2: Child's Name ────────────────────────────────────────────────────

  Widget _buildNamePage() {
    return _PageWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIndicator(current: 1, total: 3),
          const SizedBox(height: 32),
          const Text(
            'Ano ang pangalan\nng bata?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ito ang gagamitin ng app para batiin ang bata.',
            style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 32),
          _KCCTextField(
            controller: _nameController,
            focusNode: _nameFocus,
            hint: 'Halimbawa: Juan',
            icon: Icons.child_care_rounded,
            errorText: _nameError,
            onSubmitted: (_) => _nextPage(),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 32),
          _PrimaryButton(label: 'Susunod →', onPressed: _nextPage),
        ],
      ),
    );
  }

  // ─── Page 3: Child's Age ─────────────────────────────────────────────────────

  Widget _buildAgePage() {
    return _PageWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIndicator(current: 2, total: 3),
          const SizedBox(height: 32),
          const Text(
            'Ilang taon na\nang bata?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ginagamit ito para itakda ang tamang oras ng paggamit.',
            style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 32),
          _KCCTextField(
            controller: _ageController,
            focusNode: _ageFocus,
            hint: 'Halimbawa: 8',
            icon: Icons.cake_rounded,
            errorText: _ageError,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _nextPage(),
          ),
          const SizedBox(height: 16),
          // Age-based time hint
          ValueListenableBuilder(
            valueListenable: _ageController,
            builder: (context, _, __) {
              final age = int.tryParse(_ageController.text.trim());
              if (age == null) return const SizedBox.shrink();
              final mins = age <= 2 ? 15 : 40;
              return _TimeLimitHint(minutes: mins, age: age);
            },
          ),
          const SizedBox(height: 32),
          _PrimaryButton(label: 'Susunod →', onPressed: _nextPage),
        ],
      ),
    );
  }

  // ─── Page 4: Summary ─────────────────────────────────────────────────────────

  Widget _buildSummaryPage() {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final profile = ChildProfile(name: name, age: age);

    return _PageWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StepIndicator(current: 3, total: 3),
          const SizedBox(height: 32),
          const Icon(Icons.check_circle, size: 56, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Handa na!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 24),
          _SummaryCard(
            name: name,
            age: age,
            limitMinutes: profile.screenTimeLimitMinutes,
          ),
          const SizedBox(height: 12),
          const Text(
            'Awtomatikong mag-lock ang app\npagkatapos ng limitang oras bawat araw.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),
          _PrimaryButton(
            label: 'Simulan ang App ✓',
            onPressed: _saveAndProceed,
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ──────────────────────────────────────────────────────────

class _PageWrapper extends StatelessWidget {
  final Widget child;
  const _PageWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: child,
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i < current;
        final isCurrent = i == current - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          width: isCurrent ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active || isCurrent
                ? const Color(0xFFFF6B6B)
                : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

class _KCCTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final String errorText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;

  const _KCCTextField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.errorText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorText.isNotEmpty
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFFE8E8E8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onSubmitted: onSubmitted,
            textCapitalization: textCapitalization,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFCCCCCC),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFFFF6B6B), size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
        if (errorText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  size: 14, color: Color(0xFFFF6B6B)),
              const SizedBox(width: 4),
              Text(
                errorText,
                style: const TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TimeLimitHint extends StatelessWidget {
  final int minutes;
  final int age;
  const _TimeLimitHint({required this.minutes, required this.age});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD166).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 20, color: Color(0xFF885500)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ang bata na $age taong gulang ay maaaring gumamit ng app nang $minutes minuto bawat araw.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF885500),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String name;
  final int age;
  final int limitMinutes;
  const _SummaryCard(
      {required this.name, required this.age, required this.limitMinutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.child_care,
            label: 'Pangalan ng Bata',
            value: name.isEmpty ? '—' : name,
          ),
          const Divider(height: 24),
          _SummaryRow(
            icon: Icons.cake,
            label: 'Edad',
            value: age == 0 ? '—' : '$age taong gulang',
          ),
          const Divider(height: 24),
          _SummaryRow(
            icon: Icons.access_time,
            label: 'Limitasyon sa Oras',
            value: '$limitMinutes minuto / araw',
            valueColor: const Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF666666)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFAAAAAA))),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: const Color(0xFFFF6B6B).withOpacity(0.4),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}