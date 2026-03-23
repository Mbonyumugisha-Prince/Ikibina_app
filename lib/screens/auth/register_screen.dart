import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';
import '../../widgets/auth/country_picker_field.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';

const _bg     = Color(0xFFF5F5F5);
const _ink    = Color(0xFF1A1A1A);
const _grey   = Color(0xFF888888);
const _hint   = Color(0xFFBBBBBB);
const _border = Color(0xFFE0E0E0);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _phoneController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  String _countryCode     = '+250';
  bool   _obscurePassword = true;
  bool   _obscureConfirm  = true;
  bool   _agreedToTerms   = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp(AppStrings s) async {
    final name     = _nameController.text.trim();
    final email    = _emailController.text.trim();
    final phone    = '$_countryCode${_phoneController.text.trim()}';
    final password = _passwordController.text;
    final confirm  = _confirmController.text;

    if (name.isEmpty || email.isEmpty ||
        _phoneController.text.trim().isEmpty || password.isEmpty) {
      _snack(s.fillAllFields);
      return;
    }
    if (password != confirm) {
      _snack(s.passwordsNoMatch);
      return;
    }
    if (!_agreedToTerms) {
      _snack(s.acceptTerms);
      return;
    }

    final auth    = context.read<AuthProvider>();
    final success = await auth.signUp(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: email),
        ),
      );
    } else {
      _snack(auth.error ?? s.loginFailed);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.sora()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
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
              _inputField(
                label: s.fullName,
                hint: s.enterFullName,
                icon: Icons.person_outline,
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              _inputField(
                label: s.email,
                hint: s.enterEmail,
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              _label(s.phoneNumber),
              const SizedBox(height: 8),
              CountryPickerField(
                phoneController: _phoneController,
                onCountryChanged: (c) => _countryCode = c,
              ),
              const SizedBox(height: 16),
              _passwordField(
                label: s.password,
                hint: s.createPassword,
                controller: _passwordController,
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              _passwordField(
                label: s.confirmPassword,
                hint: s.repeatPassword,
                controller: _confirmController,
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              _terms(s),
              const SizedBox(height: 24),
              _signUpButton(s, loading),
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
      padding: const EdgeInsets.only(top: 52, bottom: 36),
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
              s.createYourAccount,
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
              s.registerSubtitle,
              style: GoogleFonts.sora(
                  fontSize: 14, color: _grey, height: 1.4),
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

  // ── Generic input ────────────────────────
  Widget _inputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.sora(fontSize: 15, color: _ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.sora(color: _hint, fontSize: 14),
            prefixIcon: Icon(icon, color: _hint, size: 20),
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
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Password field ───────────────────────
  Widget _passwordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.sora(fontSize: 15, color: _ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.sora(color: _hint, fontSize: 14),
            prefixIcon:
                const Icon(Icons.lock_outline, color: _hint, size: 20),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure
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
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Terms checkbox ───────────────────────
  Widget _terms(AppStrings s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreedToTerms,
          activeColor: _ink,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)),
          onChanged: (val) =>
              setState(() => _agreedToTerms = val ?? false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                text: s.iAgreeTo,
                style: GoogleFonts.sora(fontSize: 13, color: _grey),
                children: [
                  TextSpan(
                    text: s.termsOfService,
                    style: GoogleFonts.sora(
                        fontWeight: FontWeight.w700, color: _ink),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  TextSpan(
                    text: s.and,
                    style: GoogleFonts.sora(color: _grey),
                  ),
                  TextSpan(
                    text: s.privacyPolicy,
                    style: GoogleFonts.sora(
                        fontWeight: FontWeight.w700, color: _ink),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sign Up button ───────────────────────
  Widget _signUpButton(AppStrings s, bool loading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (_agreedToTerms && !loading) ? () => _handleSignUp(s) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _ink,
          disabledBackgroundColor: const Color(0xFFCCCCCC),
          foregroundColor: Colors.white,
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
                s.createAccount,
                style: GoogleFonts.sora(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  // ── Footer ───────────────────────────────
  Widget _footer(AppStrings s) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 32),
        child: RichText(
          text: TextSpan(
            text: s.haveAccountPrefix,
            style: GoogleFonts.sora(fontSize: 14, color: _grey),
            children: [
              TextSpan(
                text: s.logIn,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
