import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

enum OtpResult { success, invalid, expired, notFound, alreadyUsed }

class OtpService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const _resendUrl = 'https://api.resend.com/emails';
  static String get _apiKey => dotenv.env['RESEND_API_KEY'] ?? '';

  String _generateOtp() =>
      List.generate(6, (_) => Random.secure().nextInt(10)).join();

  // ── Send OTP: save to Firestore + send via Resend ─────────────
  Future<void> sendOtp(
    String uid,
    String email, {
    String name = '',
  }) async {
    final displayName = name.isNotEmpty ? name : email.split('@')[0];
    final otp = _generateOtp();
    final expires = DateTime.now().add(const Duration(minutes: 15));

    // Save to Firestore first
    await _db.collection('otps').doc(email).set({
      'uid': uid,
      'otp': otp,
      'email': email,
      'expiresAt': Timestamp.fromDate(expires),
      'verified': false,
      'attempts': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Send via Resend API
    final response = await http.post(
      Uri.parse(_resendUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'from': 'Ikimina <noreply@ikimina.app>',
        'to': [email],
        'subject': 'Your Ikimina verification code',
        'html': _buildOtpHtml(displayName, otp),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      // Clean up Firestore if email failed
      await _db.collection('otps').doc(email).delete();
      throw Exception('Failed to send OTP email. Please try again.');
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────
  Future<OtpResult> verifyOtp(String email, String enteredOtp) async {
    try {
      final doc = await _db.collection('otps').doc(email).get();
      if (!doc.exists) return OtpResult.notFound;

      final data = doc.data()!;
      final storedOtp = data['otp'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final verified = data['verified'] as bool? ?? false;
      final attempts = data['attempts'] as int? ?? 0;
      final uid = data['uid'] as String? ?? '';

      if (verified) return OtpResult.alreadyUsed;

      if (attempts >= 5) {
        await _db.collection('otps').doc(email).delete();
        return OtpResult.expired;
      }

      if (DateTime.now().isAfter(expiresAt)) {
        await _db.collection('otps').doc(email).delete();
        return OtpResult.expired;
      }

      if (enteredOtp.trim() != storedOtp) {
        await _db.collection('otps').doc(email).update({
          'attempts': FieldValue.increment(1),
        });
        return OtpResult.invalid;
      }

      // Correct — mark verified + update user document
      await Future.wait([
        _db.collection('otps').doc(email).update({'verified': true}),
        if (uid.isNotEmpty)
          _db.collection('users').doc(uid).update({'emailVerified': true}),
      ]);

      return OtpResult.success;
    } catch (_) {
      return OtpResult.notFound;
    }
  }

  // ── Send Group Invite Email ───────────────────────────────────
  Future<void> sendInvite({
    required String toEmail,
    required String groupName,
    required String inviteCode,
    required String adminName,
  }) async {
    final response = await http.post(
      Uri.parse(_resendUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'from': 'Ikimina <noreply@ikimina.app>',
        'to': [toEmail],
        'subject': 'You\'ve been invited to join $groupName on Ikimina',
        'html': _buildInviteHtml(
          toEmail: toEmail,
          groupName: groupName,
          inviteCode: inviteCode,
          adminName: adminName,
        ),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send invite email. Please try again.');
    }
  }

  // ── Invite Email HTML ─────────────────────────────────────────
  String _buildInviteHtml({
    required String toEmail,
    required String groupName,
    required String inviteCode,
    required String adminName,
  }) {
    final year = DateTime.now().year;
    final codeDigits = inviteCode.split('').map((d) => '''
      <td style="padding-right:8px;">
        <div style="width:44px;height:56px;background:#ffffff;
          border:2px solid #e0e0db;text-align:center;line-height:56px;
          font-family:'Sora',Arial,sans-serif;
          font-size:24px;font-weight:800;color:#1A1A1A;">$d</div>
      </td>''').join();

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>You've been invited to $groupName</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body style="margin:0;padding:0;background:#ffffff;font-family:'Sora',Arial,sans-serif;-webkit-text-size-adjust:100%;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#ffffff;">
    <tr><td align="center" style="padding:40px 16px;">
      <table role="presentation" width="560" cellpadding="0" cellspacing="0" border="0" style="max-width:560px;width:100%;">

        <!-- LOGO -->
        <tr><td style="padding-bottom:40px;">
          <span style="font-size:22px;font-weight:800;letter-spacing:0.5px;color:#1A1A1A;">Ikimina</span><br/>
          <span style="font-size:10px;font-weight:400;letter-spacing:3px;color:#aaaaaa;text-transform:uppercase;">Smart Group Savings</span>
        </td></tr>

        <!-- GREETING -->
        <tr><td style="font-size:15px;color:#111111;padding-bottom:12px;font-weight:500;">
          Hello,
        </td></tr>

        <!-- MESSAGE -->
        <tr><td style="font-size:15px;color:#111111;line-height:1.7;padding-bottom:28px;">
          <strong>$adminName</strong> has invited you to join the savings group
          <strong>&ldquo;$groupName&rdquo;</strong> on Ikimina &mdash; the smart way
          to save together with friends, family, and colleagues.
        </td></tr>

        <!-- STEPS BOX -->
        <tr><td style="padding-bottom:28px;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr><td style="background:#f5f5f3;padding:28px 24px;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr><td style="font-size:10px;font-weight:600;letter-spacing:3px;color:#aaaaaa;text-transform:uppercase;padding-bottom:16px;">
                  How to join
                </td></tr>
                <tr><td style="font-size:14px;font-weight:500;color:#333333;line-height:2.2;">
                  1.&nbsp;&nbsp;Download or open the <strong>Ikimina</strong> app<br/>
                  2.&nbsp;&nbsp;Sign Up or Log In<br/>
                  3.&nbsp;&nbsp;Tap <strong>&ldquo;Join a Group&rdquo;</strong><br/>
                  4.&nbsp;&nbsp;Enter the invite code below
                </td></tr>
              </table>
            </td></tr>
          </table>
        </td></tr>

        <!-- CODE LABEL -->
        <tr><td style="font-size:15px;color:#111111;line-height:1.7;padding-bottom:20px;">
          Use this code to join <strong>$groupName</strong>:
        </td></tr>

        <!-- INVITE CODE BOX -->
        <tr><td style="padding-bottom:28px;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr><td style="background:#f5f5f3;padding:32px 24px;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr><td style="font-size:10px;font-weight:600;letter-spacing:3px;color:#aaaaaa;text-transform:uppercase;padding-bottom:8px;">
                  Your Invite Code
                </td></tr>
                <tr><td style="font-size:12px;color:#888888;padding-bottom:16px;">
                  Enter this code in the Ikimina app
                </td></tr>
                <tr><td style="padding-bottom:8px;">
                  <table role="presentation" cellpadding="0" cellspacing="0" border="0">
                    <tr>$codeDigits</tr>
                  </table>
                </td></tr>
              </table>
            </td></tr>
          </table>
        </td></tr>

        <!-- NOTICE -->
        <tr><td style="font-size:14px;color:#555555;line-height:1.7;padding-bottom:36px;">
          If you did not expect this invitation, you can safely ignore this email.
        </td></tr>

        <!-- DIVIDER -->
        <tr><td style="padding-bottom:20px;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr><td style="border-top:1px solid #e0e0db;font-size:0;line-height:0;">&nbsp;</td></tr>
          </table>
        </td></tr>

        <!-- FOOTER -->
        <tr><td style="font-size:13px;padding-bottom:40px;">
          <span style="color:#1A1A1A;font-weight:700;">Ikimina</span>
          <span style="color:#aaaaaa;"> &copy; $year &mdash; Smart Group Savings</span>
        </td></tr>

      </table>
    </td></tr>
  </table>
</body>
</html>''';
  }

  Future<void> deleteOtp(String email) async {
    try {
      await _db.collection('otps').doc(email).delete();
    } catch (_) {}
  }

  // ── OTP + Welcome Email HTML ──────────────────────────────────
  String _buildOtpHtml(String name, String otp) {
    final year = DateTime.now().year;
    final digits = otp.split('').map((d) => '''
      <td style="padding-right:8px;">
        <div style="width:44px;height:56px;background:#ffffff;
          border:2px solid #e0e0db;text-align:center;line-height:56px;
          font-family:'Sora',Arial,sans-serif;
          font-size:24px;font-weight:800;color:#1A1A1A;">$d</div>
      </td>''').join();

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Welcome to Ikimina – Verify your email</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body style="margin:0;padding:0;background:#ffffff;font-family:'Sora',Arial,sans-serif;-webkit-text-size-adjust:100%;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#ffffff;">
    <tr><td align="center" style="padding:40px 16px;">
      <table role="presentation" width="560" cellpadding="0" cellspacing="0" border="0" style="max-width:560px;width:100%;">

        <!-- LOGO -->
        <tr><td style="padding-bottom:40px;">
          <span style="font-size:22px;font-weight:800;letter-spacing:0.5px;color:#1A1A1A;">Ikimina</span><br/>
          <span style="font-size:10px;font-weight:400;letter-spacing:3px;color:#aaaaaa;text-transform:uppercase;">Smart Group Savings</span>
        </td></tr>

        <!-- GREETING -->
        <tr><td style="font-size:15px;color:#111111;padding-bottom:12px;font-weight:500;">
          Hello $name,
        </td></tr>

        <!-- WELCOME MESSAGE -->
        <tr><td style="font-size:15px;color:#111111;line-height:1.7;padding-bottom:28px;">
          Welcome to <strong>Ikimina</strong> — the smart way to save together with
          friends, family, and colleagues. We're glad to have you on board.
          <br/><br/>
          To get started, please verify your email address using the code below.
        </td></tr>

        <!-- WHAT YOU CAN DO BOX -->
        <tr><td style="padding-bottom:28px;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr><td style="background:#f5f5f3;padding:28px 24px;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr><td style="font-size:10px;font-weight:600;letter-spacing:3px;color:#aaaaaa;text-transform:uppercase;padding-bottom:16px;">
                  What you can do with Ikimina
                </td></tr>
                <tr><td style="font-size:14px;font-weight:500;color:#333333;line-height:2;padding-bottom:4px;">
                  &mdash;&nbsp;&nbsp;Create or join a savings group<br/>
                  &mdash;&nbsp;&nbsp;Track contributions in real time<br/>
                  &mdash;&nbsp;&nbsp;Request withdrawals anytime<br/>
                  &mdash;&nbsp;&nbsp;Your funds are safe and transparent
                </td></tr>
              </table>
            </td></tr>
          </table>
        </td></tr>

        <!-- OTP SECTION LABEL -->
        <tr><td style="font-size:15px;color:#111111;line-height:1.7;padding-bottom:20px;">
          Use the code below to verify your email address:
        </td></tr>

        <!-- OTP BOX -->
        <tr><td style="padding-bottom:28px;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr><td style="background:#f5f5f3;padding:32px 24px;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr><td style="font-size:10px;font-weight:600;letter-spacing:3px;color:#aaaaaa;text-transform:uppercase;padding-bottom:8px;">
                  Verification Code
                </td></tr>
                <tr><td style="font-size:12px;color:#888888;padding-bottom:16px;">
                  Enter this code in the Ikimina app
                </td></tr>
                <tr><td style="padding-bottom:20px;">
                  <table role="presentation" cellpadding="0" cellspacing="0" border="0">
                    <tr>$digits</tr>
                  </table>
                </td></tr>
                <tr><td style="font-size:12px;color:#888888;">
                  Expires in <strong style="color:#111111;">15 minutes</strong>
                </td></tr>
              </table>
            </td></tr>
          </table>
        </td></tr>

        <!-- NOTICE -->
        <tr><td style="font-size:14px;color:#555555;line-height:1.7;padding-bottom:36px;">
          If you did not create an Ikimina account, you can safely ignore this email.
          Never share this code with anyone.
        </td></tr>

        <!-- DIVIDER -->
        <tr><td style="padding-bottom:20px;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr><td style="border-top:1px solid #e0e0db;font-size:0;line-height:0;">&nbsp;</td></tr>
          </table>
        </td></tr>

        <!-- FOOTER -->
        <tr><td style="font-size:13px;padding-bottom:40px;">
          <span style="color:#1A1A1A;font-weight:700;">Ikimina</span>
          <span style="color:#aaaaaa;"> &copy; $year &mdash; Smart Group Savings</span>
        </td></tr>

      </table>
    </td></tr>
  </table>
</body>
</html>''';
  }
}
