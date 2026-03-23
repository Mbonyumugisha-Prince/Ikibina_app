import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../screens/home/home_screen.dart';

const _bg   = Color(0xFFF5F5F5);
const _ink  = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _checkTimer;
  bool _resending = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Auto-check every 4 seconds in the background
    _checkTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _autoCheck();
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _autoCheck() async {
    final auth = context.read<AuthProvider>();
    final verified = await auth.checkEmailVerified();
    if (verified && mounted) {
      _checkTimer?.cancel();
      _navigateHome();
    }
  }

  Future<void> _manualCheck() async {
    setState(() => _checking = true);
    final auth = context.read<AuthProvider>();
    final verified = await auth.checkEmailVerified();
    if (!mounted) return;
    setState(() => _checking = false);
    if (verified) {
      _navigateHome();
    } else {
      _snack(context.read<LocaleProvider>().strings.emailNotVerifiedYet);
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _resending = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendVerificationEmail();
    if (!mounted) return;
    setState(() => _resending = false);
    final s = context.read<LocaleProvider>().strings;
    _snack(ok ? s.verificationEmailResent : (auth.error ?? s.failedToSend));
  }

  void _navigateHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _signOut() {
    context.read<AuthProvider>().signOut();
    Navigator.of(context).pop();
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
    final s = context.watch<LocaleProvider>().strings;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 80),

              // ── Icon ──
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: _ink,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _ink.withValues(alpha: 0.18),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              const SizedBox(height: 36),

              // ── Title ──
              Text(
                s.verifyEmailTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 12),

              // ── Subtitle ──
              Text(
                s.verifyEmailSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  color: _grey,
                  height: 1.65,
                ),
              ),

              const SizedBox(height: 20),

              // ── Email badge ──
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_outlined, size: 18, color: _ink),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.email,
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ── Primary: I've verified ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _checking ? null : _manualCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ink,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _ink.withValues(alpha: 0.45),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _checking
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          s.iHaveVerified,
                          style: GoogleFonts.sora(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Secondary: Resend ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _resending ? null : _resendEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ink,
                    side: const BorderSide(color: _ink, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _resending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: _ink, strokeWidth: 2.5),
                        )
                      : Text(
                          s.resendEmail,
                          style: GoogleFonts.sora(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Sign out link ──
              TextButton(
                onPressed: _signOut,
                child: Text(
                  s.backToLogin,
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    color: _grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
