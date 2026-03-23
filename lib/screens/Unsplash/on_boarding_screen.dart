import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../auth/login_screen.dart';
import '../language/language_selection_screen.dart';

//  COLOURS
const _bg = Color(0xFFF2F2F2);
const _ink = Color(0xFF1A1A1A);
const _muted = Color(0xFF666666);
const _dimmed = Color(0xFF999999);
const _dotInactive = Color(0xFFC8C8C8);


//  ONBOARDING FLOW  (2 pages — splash already covers the brand intro)
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Total pages = 2
  static const _totalPages = 2;

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

  void _goToLanguage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Swipeable pages (Page 2 + Page 3 from original flow)
            PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _PageSaveTogether(s: s),
                _PageTrackWithdraw(
                  s: s,
                  onGetStarted: _goToLanguage,
                  onLogin: _goToLogin,
                ),
              ],
            ),

            // Skip button — page 0 only
            if (!isLastPage)
              Positioned(
                top: 16,
                right: 16,
                child: TextButton(
                  onPressed: () => _goToPage(_totalPages - 1),
                  child: Text(
                    s.skip,
                    style: const TextStyle(
                      color: _dimmed,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // Next arrow button — page 0 only
            if (!isLastPage)
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

            // Dot indicators — all pages
            Positioned(
              bottom: 52,
              left: 0,
              right: 0,
              child: _DotsIndicator(
                currentPage: _currentPage,
                totalPages: _totalPages,
              ),
            ),

            // Secure label — all pages
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: _SecureLabel(label: s.secure),
            ),
          ],
        ),
      ),
    );
  }
}

//  PAGE 1 — Save Together, Grow Together
class _PageSaveTogether extends StatelessWidget {
  final dynamic s;
  const _PageSaveTogether({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),

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
            child: const Icon(Icons.people_alt, color: Colors.white, size: 80),
          ),

          const SizedBox(height: 36),

          Text(
            s.onboardingTitle2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _ink,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            s.onboardingSubtitle2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: _muted,
              height: 1.6,
            ),
          ),

          const Spacer(flex: 3),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}


//  PAGE 2 — Track & Withdraw Anytime (CTA)
class _PageTrackWithdraw extends StatelessWidget {
  final dynamic s;
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  const _PageTrackWithdraw({
    required this.s,
    required this.onGetStarted,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Spacer(flex: 2),

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
                Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 56),
                SizedBox(height: 8),
                Icon(Icons.bar_chart, color: Colors.white, size: 32),
              ],
            ),
          ),

          const SizedBox(height: 36),

          Text(
            s.onboardingTitle3,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _ink,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            s.onboardingSubtitle3,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: _muted,
              height: 1.6,
            ),
          ),

          const Spacer(flex: 2),
          const SizedBox(height: 40),

          // Primary — Get Started → Language Selection
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
                s.getStarted,
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary — Already have an account → Login
          TextButton(
            onPressed: onLogin,
            child: Text(
              s.alreadyHaveAccount,
              style: const TextStyle(color: _dimmed, fontSize: 14),
            ),
          ),

          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

//  SHARED — Dot Indicators
class _DotsIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  const _DotsIndicator({required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
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

//  SHARED — Secure Label
class _SecureLabel extends StatelessWidget {
  final String label;
  const _SecureLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline, size: 12, color: _dimmed),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
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
