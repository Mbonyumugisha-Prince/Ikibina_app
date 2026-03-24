import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../groups/group_setup_screen.dart';
import 'login_screen.dart';

const _bg     = Color(0xFFF5F5F5);
const _ink    = Color(0xFF1A1A1A);
const _grey   = Color(0xFF888888);
const _border = Color(0xFFE0E0E0);

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String name;
  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  // 6 controllers + focus nodes, one per OTP digit
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _sending  = true;   // true while sending OTP on init
  bool _loading  = false;  // true while verifying
  bool _resending = false;

  // Resend cooldown — 60 seconds
  int  _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // ── Send / Resend OTP ─────────────────────────────────────
  Future<void> _sendOtp({bool isResend = false}) async {
    if (isResend) setState(() => _resending = true);

    final ok = await context.read<AuthProvider>().sendOtp(
          email: widget.email,
          name: widget.name,
        );

    if (!mounted) return;

    setState(() {
      _sending  = false;
      _resending = false;
    });

    if (ok) {
      _startCooldown();
      if (isResend) {
        _snack(context.read<LocaleProvider>().strings.verificationEmailResent);
      }
    } else {
      final err = context.read<AuthProvider>().error ?? '';
      _snack(err.isNotEmpty ? err : context.read<LocaleProvider>().strings.failedToSend);
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) t.cancel();
      });
    });
  }

  // ── Verify OTP ────────────────────────────────────────────
  Future<void> _verify() async {
    final otp = _controllers.map((c) => c.text).join();
    final s   = context.read<LocaleProvider>().strings;

    if (otp.length < 6) {
      _snack(s.otpEnterAll);
      return;
    }

    setState(() => _loading = true);
    final ok = await context.read<AuthProvider>().verifyOtp(otp);
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GroupSetupScreen()),
        (_) => false,
      );
    } else {
      final err = context.read<AuthProvider>().error ?? s.otpInvalid;
      // Strip Firebase prefix for cleaner messages
      final msg = err.replaceAll(RegExp(r'\[.*?\]\s*'), '');
      _snack(msg.isNotEmpty ? msg : s.otpInvalid);
      // Clear boxes on wrong code
      for (final c in _controllers) { c.clear(); }
      _focusNodes[0].requestFocus();
    }
  }

  void _signOut() {
    context.read<AuthProvider>().signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.sora(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s       = context.watch<LocaleProvider>().strings;
    final canResend = _resendCooldown <= 0 && !_resending && !_sending;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 72),

              // ── Icon ──
              Center(
                child: Container(
                  width: 80,
                  height: 80,
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
                    Icons.mark_email_unread_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Title ──
              Center(
                child: Text(
                  s.otpTitle,
                  style: GoogleFonts.sora(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Subtitle + email ──
              Center(
                child: Text(
                  '${s.otpSubtitle}\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    color: _grey,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── 6 OTP boxes ──
              if (_sending)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                            color: _ink, strokeWidth: 2.5),
                      ),
                      const SizedBox(height: 12),
                      Text(s.otpSending,
                          style: GoogleFonts.sora(
                              fontSize: 13, color: _grey)),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => _OtpBox(
                    controller: _controllers[i],
                    focusNode:  _focusNodes[i],
                    onChanged: (val) {
                      if (val.isNotEmpty && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      }
                      // Auto-submit when last digit filled
                      if (i == 5 && val.isNotEmpty) _verify();
                    },
                    onBackspace: () {
                      if (i > 0) {
                        _controllers[i - 1].clear();
                        _focusNodes[i - 1].requestFocus();
                      }
                    },
                  )),
                ),

              const SizedBox(height: 12),

              // ── Expiry hint ──
              if (!_sending)
                Center(
                  child: Text(
                    s.otpExpiry,
                    style: GoogleFonts.sora(
                        fontSize: 12, color: _grey),
                  ),
                ),

              const SizedBox(height: 36),

              // ── Verify button ──
              if (!_sending)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _ink,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          _ink.withValues(alpha: 0.45),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            s.otpVerify,
                            style: GoogleFonts.sora(
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                  ),
                ),

              const SizedBox(height: 14),

              // ── Resend button / countdown ──
              if (!_sending)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: canResend
                        ? () => _sendOtp(isResend: true)
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _ink,
                      disabledForegroundColor: _grey,
                      side: BorderSide(
                        color: canResend ? _ink : _border,
                        width: 1.5,
                      ),
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
                            _resendCooldown > 0
                                ? '${s.otpResendIn} $_resendCooldown ${s.otpSeconds}'
                                : s.otpResend,
                            style: GoogleFonts.sora(
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),

              const SizedBox(height: 28),

              // ── Back to login ──
              Center(
                child: TextButton(
                  onPressed: _signOut,
                  child: Text(
                    context
                        .read<LocaleProvider>()
                        .strings
                        .backToLogin,
                    style: GoogleFonts.sora(
                        fontSize: 13,
                        color: _grey,
                        fontWeight: FontWeight.w500),
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

// ── Single OTP digit box ─────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextField(
          controller:   controller,
          focusNode:    focusNode,
          textAlign:    TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength:    1,
          style: GoogleFonts.sora(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            filled:      true,
            fillColor:   Colors.white,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF1A1A1A), width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
