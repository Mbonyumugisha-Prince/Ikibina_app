import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Unsplash/on_boarding_screen.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _ink    = Color(0xFF1A1A1A);
  static const _muted  = Color(0xFF999999);
  static const _badge  = Color(0xFFE8E8E8);

  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _pulseController;

  late final Animation<double> _bgFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset>  _textSlide;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _bgController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _bgFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _bgController, curve: Curves.easeIn));

    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _textFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
            CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  Future<void> _startSequence() async {
    await _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 280));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final prefs     = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('selected_language');
    if (!mounted) return;

    // First time → show onboarding (which leads to language → login)
    // Returning  → go straight to login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => savedLang == null
            ? const OnboardingFlow()
            : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _bgFade,
        child: Stack(
          children: [
            // Centered logo + text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildText(),
                ],
              ),
            ),
            // Bottom dots + SECURE
            _buildBottomLoader(),
          ],
        ),
      ),
    );
  }

  // ── Logo ──────────────────────────────────
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (_, __) => FadeTransition(
        opacity: _logoFade,
        child: Transform.scale(
          scale: _logoScale.value * _pulse.value,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main dark box
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: _ink.withValues(alpha: 0.22),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.savings,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              // Badge top-right
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _badge,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.group, color: _ink, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── App name + tagline ────────────────────
  Widget _buildText() {
    return FadeTransition(
      opacity: _textFade,
      child: SlideTransition(
        position: _textSlide,
        child: Column(
          children: [
            Text(
              'Ikimina',
              style: GoogleFonts.sora(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: _ink,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Group Savings, Made Simple',
              style: GoogleFonts.sora(
                fontSize: 14,
                color: _muted,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom loader ─────────────────────────
  Widget _buildBottomLoader() {
    return Positioned(
      bottom: 52,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _textFade,
        child: Column(
          children: [
            const _AnimatedDots(),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 12, color: _muted),
                const SizedBox(width: 5),
                Text(
                  'SECURE',
                  style: GoogleFonts.sora(
                    fontSize: 11,
                    letterSpacing: 2.0,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  ANIMATED LOADING DOTS
// ─────────────────────────────────────────
class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with TickerProviderStateMixin {
  static const _ink = Color(0xFF1A1A1A);

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true),
    );

    for (var i = 0; i < 3; i++) {
      final index = i;
      Future.delayed(Duration(milliseconds: index * 200), () {
        if (mounted) _controllers[index].forward();
      });
    }

    _anims = _controllers
        .map((c) => Tween<double>(begin: 0.15, end: 1.0).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (i) => AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _ink.withValues(alpha: _anims[i].value),
            ),
          ),
        ),
      ),
    );
  }
}
