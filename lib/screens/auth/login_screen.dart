import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';
import '../../widgets/common/error_banner.dart';
import '../groups/group_setup_screen.dart';
import '../home/admin_home_screen.dart';
import '../home/member_home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'email_verification_screen.dart';
import 'login_2fa_screen.dart';

const _bg     = Color(0xFFF5F5F5);
const _ink    = Color(0xFF1A1A1A);
const _grey   = Color(0xFF888888);
const _hint   = Color(0xFFBBBBBB);
const _border = Color(0xFFE0E0E0);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool   _obscurePassword   = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String msg) => setState(() => _errorMessage = msg);

  Future<void> _handleLogin(AppStrings s) async {
    setState(() => _errorMessage = null);
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showError(s.fillAllFields);
      return;
    }

    final auth    = context.read<AuthProvider>();
    final success = await auth.signIn(email: email, password: password);
    if (!mounted) return;

    if (!success) {
      _showError(auth.error ?? s.loginFailed);
      return;
    }

    // Check email verification
    if (!auth.isEmailVerified) {
      final displayName = auth.user?.name ?? '';
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            email: email,
            name: displayName,
          ),
        ),
      );
      return;
    }

    // Check 2FA — send OTP and redirect to challenge screen
    if (auth.twoFactorEnabled) {
      final otpSent = await auth.sendLogin2FAOtp();
      if (!mounted) return;
      if (!otpSent) {
        _showError(auth.error ?? 'Failed to send 2FA code. Please try again.');
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => Login2FAScreen(email: email),
        ),
      );
      return;
    }

    // Fully verified → route based on role
    final role = auth.user?.activeGroupRole;
    final Widget destination;
    if (role == 'admin') {
      destination = const AdminHomeScreen();
    } else if (role == 'member') {
      destination = const MemberHomeScreen();
    } else {
      destination = const GroupSetupScreen();
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (_) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    final s       = context.watch<LocaleProvider>().strings;
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(s),
              _emailField(s),
              const SizedBox(height: 20),
              _passwordField(s),
              _forgotPassword(s),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                ErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],
              _loginButton(s, loading),
              const SizedBox(height: 32),
              _footer(s),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────
  Widget _header(AppStrings s) {
    return Padding(
      padding: const EdgeInsets.only(top: 72, bottom: 44),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _ink,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _ink.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.savings, color: Colors.white, size: 38),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              s.welcomeBack,
              style: GoogleFonts.sora(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: _ink,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              s.loginSubtitle,
              style: GoogleFonts.sora(fontSize: 14, color: _grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Label ────────────────────────────────
  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.sora(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
      );

  // ── Email field ──────────────────────────
  Widget _emailField(AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(s.email),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.sora(fontSize: 15, color: _ink),
          decoration: InputDecoration(
            hintText: s.emailHint,
            hintStyle: GoogleFonts.sora(color: _hint, fontSize: 14),
            prefixIcon:
                const Icon(Icons.email_outlined, color: _hint, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _ink, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Password field ───────────────────────
  Widget _passwordField(AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(s.password),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: GoogleFonts.sora(fontSize: 15, color: _ink),
          decoration: InputDecoration(
            hintText: s.enterPassword,
            hintStyle: GoogleFonts.sora(color: _hint, fontSize: 14),
            prefixIcon:
                const Icon(Icons.lock_outline, color: _hint, size: 20),
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _hint,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _ink, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Forgot password ──────────────────────
  Widget _forgotPassword(AppStrings s) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 4)),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
        ),
        child: Text(
          s.forgotPassword,
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _ink,
          ),
        ),
      ),
    );
  }

  // ── Log In button ────────────────────────
  Widget _loginButton(AppStrings s, bool loading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : () => _handleLogin(s),
        style: ElevatedButton.styleFrom(
          backgroundColor: _ink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _ink.withValues(alpha: 0.45),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                s.logIn,
                style: GoogleFonts.sora(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  // ── Sign Up footer ───────────────────────
  Widget _footer(AppStrings s) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: RichText(
          text: TextSpan(
            text: s.noAccountPrefix,
            style: GoogleFonts.sora(fontSize: 14, color: _grey),
            children: [
              TextSpan(
                text: s.signUp,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
