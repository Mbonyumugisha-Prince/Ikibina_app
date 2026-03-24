import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';
import '../../widgets/common/error_banner.dart';

const _bg     = Color(0xFFF5F5F5);
const _ink    = Color(0xFF1A1A1A);
const _grey   = Color(0xFF888888);
const _hint   = Color(0xFFBBBBBB);
const _border = Color(0xFFE0E0E0);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool    _sent         = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showError(String msg) => setState(() => _errorMessage = msg);

  Future<void> _submit(AppStrings s) async {
    setState(() => _errorMessage = null);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError(s.enterEmailFirst);
      return;
    }
    final auth    = context.read<AuthProvider>();
    final success = await auth.resetPassword(email);
    if (!mounted) return;
    if (success) {
      setState(() => _sent = true);
    } else {
      _showError(auth.error ?? s.failedToSend);
    }
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
          child: _sent ? _successView(s) : _formView(s, loading),
        ),
      ),
    );
  }

  // ── Form view ────────────────────────────
  Widget _formView(AppStrings s, bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 72),

        // ── Title ──
        Text(
          s.forgotPasswordTitle,
          style: GoogleFonts.sora(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: _ink,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 10),

        // ── Subtitle ──
        Text(
          s.forgotPasswordSubtitle,
          style: GoogleFonts.sora(
            fontSize: 14,
            color: _grey,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 40),

        // ── Email label ──
        Text(
          s.emailLabel,
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        const SizedBox(height: 8),

        // ── Email field ──
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

        const SizedBox(height: 32),

        if (_errorMessage != null) ...[
          ErrorBanner(message: _errorMessage!),
          const SizedBox(height: 16),
        ],

        // ── Send button ──
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: loading ? null : () => _submit(s),
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
                    s.sendResetLink,
                    style: GoogleFonts.sora(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Back to login ──
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 13, color: _ink),
                const SizedBox(width: 4),
                Text(
                  s.backToLogin,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Success view ─────────────────────────
  Widget _successView(AppStrings s) {
    return Column(
      children: [
        const SizedBox(height: 120),

        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _ink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _ink.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: Colors.white,
              size: 44,
            ),
          ),
        ),

        const SizedBox(height: 36),

        Center(
          child: Text(
            s.checkInbox,
            style: GoogleFonts.sora(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _ink,
              letterSpacing: -0.3,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Center(
          child: Text(
            '${s.checkInboxSubtitle}\n${_emailController.text.trim()}',
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(fontSize: 14, color: _grey, height: 1.6),
          ),
        ),

        const SizedBox(height: 48),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _ink,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              s.backToLogin,
              style: GoogleFonts.sora(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: Text(
            s.didntReceive,
            style: GoogleFonts.sora(fontSize: 13, color: _grey),
          ),
        ),
      ],
    );
  }
}
