import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/error_banner.dart';
import '../home/member_home_screen.dart';

const _bg     = Color(0xFFF5F5F5);
const _ink    = Color(0xFF1A1A1A);
const _grey   = Color(0xFF888888);
const _border = Color(0xFFE0E0E0);

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});
  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _codeController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showError(String msg) => setState(() => _errorMessage = msg);

  Future<void> _join() async {
    setState(() => _errorMessage = null);
    final s = context.read<LocaleProvider>().strings;
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      _showError(s.invalidInviteCode);
      return;
    }
    final uid   = context.read<AuthProvider>().user?.id ?? '';
    final group = await context.read<GroupProvider>().joinGroup(code, uid);
    if (!mounted) return;
    if (group != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MemberHomeScreen()),
        (_) => false,
      );
    } else {
      _showError(context.read<GroupProvider>().error ?? s.groupNotFound);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final loading = context.watch<GroupProvider>().loading;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: _ink),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),

              // Icon
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
                      )
                    ],
                  ),
                  child: const Icon(Icons.vpn_key_outlined,
                      color: Colors.white, size: 34),
                ),
              ),

              const SizedBox(height: 28),
              Center(
                child: Text(
                  s.joinGroupTitle,
                  style: GoogleFonts.sora(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  s.joinGroupSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                      fontSize: 14, color: _grey, height: 1.6),
                ),
              ),

              const SizedBox(height: 44),

              Text(
                s.inviteCodeLabel,
                style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ink),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: 8,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  hintText: s.inviteCodeHint,
                  hintStyle: GoogleFonts.sora(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFDDDDDD),
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: _border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: _border, width: 1.5),
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

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : _join,
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
                          'Join Group',
                          style: GoogleFonts.sora(
                              fontSize: 16, fontWeight: FontWeight.w700),
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
