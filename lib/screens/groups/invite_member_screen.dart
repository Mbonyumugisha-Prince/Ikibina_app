import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/otp_service.dart';

const _bg     = Color(0xFFF5F5F5);
const _ink    = Color(0xFF1A1A1A);
const _grey   = Color(0xFF888888);
const _hint   = Color(0xFFBBBBBB);
const _border = Color(0xFFE0E0E0);

class InviteMemberScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String inviteCode;

  const InviteMemberScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.inviteCode,
  });

  @override
  State<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends State<InviteMemberScreen> {
  final _emailController = TextEditingController();
  bool _sending = false;
  bool _sent    = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    final s = context.read<LocaleProvider>().strings;
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _snack(s.validEmailRequired);
      return;
    }

    final adminName =
        context.read<AuthProvider>().user?.name ?? 'Your group admin';

    setState(() => _sending = true);
    try {
      await OtpService().sendInvite(
        toEmail:    email,
        groupName:  widget.groupName,
        inviteCode: widget.inviteCode,
        adminName:  adminName,
      );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sent    = true;
      });
      _emailController.clear();
      _snack('${s.inviteSentMessage} $email');
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      _snack(s.failedToSendInvite);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.sora(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          s.inviteMemberTitle,
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // ── Info card ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _ink,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group_add_outlined,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.groupName,
                          style: GoogleFonts.sora(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${s.groupInviteCode}: ${widget.inviteCode}',
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            color: Colors.white70,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              s.memberEmailLabel,
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller:   _emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.sora(fontSize: 15, color: _ink),
              onChanged: (_) {
                if (_sent) setState(() => _sent = false);
              },
              decoration: InputDecoration(
                hintText: s.memberEmailHint,
                hintStyle: GoogleFonts.sora(color: _hint, fontSize: 14),
                prefixIcon: const Icon(Icons.email_outlined,
                    color: _hint, size: 20),
                filled:    true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
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

            const SizedBox(height: 12),

            Text(
              s.sendInviteText,
              style:
                  GoogleFonts.sora(fontSize: 12, color: _grey, height: 1.6),
            ),

            const SizedBox(height: 32),

            // ── Send button ──
            SizedBox(
              width:  double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _sending ? null : _sendInvite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _ink.withValues(alpha: 0.45),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _sending
                    ? const SizedBox(
                        width:  22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Send Invite',
                        style: GoogleFonts.sora(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),

            if (_sent) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Color(0xFF2E7D32), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Invite sent! They will receive an email with the code to join.',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          color: const Color(0xFF2E7D32),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
