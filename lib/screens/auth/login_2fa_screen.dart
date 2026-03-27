import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/error_banner.dart';
import '../groups/group_setup_screen.dart';
import '../home/admin_home_screen.dart';
import '../home/member_home_screen.dart';

const _bg   = Color(0xFFF5F5F5);
const _ink  = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);
const _hint = Color(0xFFBBBBBB);
const _border = Color(0xFFE0E0E0);

class Login2FAScreen extends StatefulWidget {
  final String email;

  const Login2FAScreen({super.key, required this.email});

  @override
  State<Login2FAScreen> createState() => _Login2FAScreenState();
}

class _Login2FAScreenState extends State<Login2FAScreen> {
  final _otpController = TextEditingController();
  String? _errorMessage;
  bool _isSending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      setState(() => _errorMessage = 'Please enter the 6-digit code sent to your email.');
      return;
    }

    setState(() => _errorMessage = null);
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyLogin2FAOtp(otp);
    if (!mounted) return;

    if (!success) {
      setState(() => _errorMessage = auth.error ?? 'Incorrect code. Please try again.');
      return;
    }

    // OTP verified — route to the appropriate home screen
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

  Future<void> _resend() async {
    setState(() {
      _isSending = true;
      _errorMessage = null;
      _otpController.clear();
    });

    final auth = context.read<AuthProvider>();
    final success = await auth.sendLogin2FAOtp();
    if (!mounted) return;

    setState(() => _isSending = false);

    if (!success) {
      setState(() => _errorMessage = auth.error ?? 'Failed to resend code. Try again.');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new code has been sent to your email.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _ink),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _ink,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _ink.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lock_outline, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Center(
                child: Text(
                  'Two-Factor Authentication',
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'A 6-digit code was sent to\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    color: _grey,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // OTP label
              Text(
                'Verification Code',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 8),

              // OTP input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 10,
                  color: _ink,
                ),
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: GoogleFonts.sora(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 10,
                    color: _hint,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 18),
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

              if (_errorMessage != null) ...[
                ErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (loading || _isSending) ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ink,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _ink.withValues(alpha: 0.45),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: (loading && !_isSending)
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Verify & Continue',
                          style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Resend
              Center(
                child: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _ink,
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          text: "Didn't receive the code? ",
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            color: _grey,
                          ),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: (loading || _isSending) ? null : _resend,
                                child: Text(
                                  'Resend',
                                  style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _ink,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
