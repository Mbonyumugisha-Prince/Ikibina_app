import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

// ─────────────────────────────────────────
//  COLOURS
// ─────────────────────────────────────────
const _bg = Color(0xFFF2F2F2);
const _ink = Color(0xFF1A1A1A);
const _muted = Color(0xFF666666);
const _dimmed = Color(0xFF999999);
const _dotInactive = Color(0xFFC8C8C8);
const _badgeBg = Color(0xFFE8E8E8);

// ─────────────────────────────────────────
//  ONBOARDING FLOW
// ─────────────────────────────────────────
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Swipeable pages ──
            PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                const _Page1(),
                const _Page2(),
                _Page3(
                  onGetStarted: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const RegisterScreen()),
                  ),
                  onLogin: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                ),
              ],
            ),

            // ── Skip button — pages 0 & 1 only ──
            if (_currentPage < 2)
              Positioned(
                top: 16,
                right: 16,
                child: TextButton(
                  onPressed: () => _goToPage(2),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: _dimmed,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // ── Next button — pages 0 & 1 only ──
            if (_currentPage < 2)
              Positioned(
                bottom: 80,
                right: 24,
                child: GestureDetector(
                  onTap: () => _goToPage(_currentPage + 1),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: _ink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

            // ── Dot indicators — all pages ──
            Positioned(
              bottom: 52,
              left: 0,
              right: 0,
              child: _DotsIndicator(currentPage: _currentPage),
            ),

            // ── Secure label — all pages ──
            const Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: _SecureLabel(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  PAGE 1 — Brand Splash
// ─────────────────────────────────────────
class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),

          // ── Logo stack ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: _ink.withValues(alpha: 0.2),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
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
                    color: _badgeBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.group,
                    color: _ink,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Title ──
          const Text(
            'Ikimina',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: _ink,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          // ── Subtitle ──
          const Text(
            'Smart Group Savings, Made Simple',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: _muted,
            ),
          ),

          const Spacer(flex: 2),
          // Space for positioned bottom widgets
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  PAGE 2 — Save Together, Grow Together
// ─────────────────────────────────────────
class _Page2 extends StatelessWidget {
  const _Page2();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // ── Illustration box ──
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _ink.withValues(alpha: 0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.people_alt,
              color: Colors.white,
              size: 80,
            ),
          ),

          const SizedBox(height: 36),

          // ── Title ──
          const Text(
            'Save Together,\nGrow Together',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _ink,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 14),

          // ── Subtitle ──
          const Text(
            'Create or join a savings group with\nfriends, family or colleagues.\nEveryone contributes, everyone benefits.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _muted,
              height: 1.6,
            ),
          ),

          const Spacer(flex: 3),
          // Space for positioned bottom widgets (dots + next + secure)
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  PAGE 3 — Track & Withdraw Anytime (CTA)
// ─────────────────────────────────────────
class _Page3 extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  const _Page3({required this.onGetStarted, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // ── Illustration box ──
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _ink.withValues(alpha: 0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 56,
                ),
                SizedBox(height: 8),
                Icon(
                  Icons.bar_chart,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // ── Title ──
          const Text(
            'Track Savings &\nWithdraw Anytime',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _ink,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 14),

          // ── Subtitle ──
          const Text(
            'Monitor your group\'s progress in\nreal time. Request withdrawals\nwhenever you\'re ready.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _muted,
              height: 1.6,
            ),
          ),

          const Spacer(flex: 2),

          // ── CTA Buttons ──
          const SizedBox(height: 40),

          // Primary — Get Started
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary — Already have an account
          TextButton(
            onPressed: onLogin,
            child: const Text(
              'I already have an account',
              style: TextStyle(
                color: _dimmed,
                fontSize: 14,
              ),
            ),
          ),

          // Space for positioned dots + secure label
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SHARED — Dot Indicators
// ─────────────────────────────────────────
class _DotsIndicator extends StatelessWidget {
  final int currentPage;
  const _DotsIndicator({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? _ink : _dotInactive,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────
//  SHARED — Secure Label
// ─────────────────────────────────────────
class _SecureLabel extends StatelessWidget {
  const _SecureLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.lock_outline, size: 12, color: _dimmed),
        SizedBox(width: 5),
        Text(
          'SECURE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _dimmed,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
