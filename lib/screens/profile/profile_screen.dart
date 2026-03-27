import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/locale_provider.dart';
import '../language/language_selection_screen.dart';
import '../auth/login_screen.dart';
import 'kyc_verification_screen.dart';
import 'penalties_info_screen.dart';
import 'payment_methods_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_information_screen.dart';
import 'security_2fa_screen.dart';
import 'contact_us_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    IconData? leadingIcon,
    String? subtitle,
    Widget? trailing,
    Color? subtitleColor,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (leadingIcon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      leadingIcon,
                      color: isDestructive ? Colors.red : Colors.black87,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDestructive ? Colors.red : Colors.black,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: subtitleColor ?? Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final s = localeProvider.strings;
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          s.profileAndSettings,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  _ProfileAvatar(photoUrl: user.photoUrl, name: user.name),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (user.emailVerified) ...[
                    const SizedBox(height: 4),
                    Text(
                      s.verifiedMember,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader(s.account),
            _buildSectionContainer([
              _buildListTile(
                title: s.profileInformation,
                leadingIcon: Icons.person_outline,
                subtitle: s.nameEmailPhone,
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.black54),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileInformationScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                title: s.kycVerification,
                leadingIcon: Icons.badge_outlined,
                subtitle: user.emailVerified ? s.approved : s.denied,
                subtitleColor: user.emailVerified ? Colors.green : Colors.red,
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.black54),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const KycVerificationScreen(),
                    ),
                  );
                },
                showDivider: false,
              ),
            ]),

            _buildSectionHeader(s.securityAndFinance),
            _buildSectionContainer([
              _buildListTile(
                title: s.securityAnd2FA,
                leadingIcon: Icons.lock_outline,
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.black54),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const Security2FAScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                title: s.paymentMethods,
                leadingIcon: Icons.credit_card_outlined,
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.black54),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PaymentMethodsScreen(),
                    ),
                  );
                },
                showDivider: false,
              ),
            ]),

            _buildSectionHeader(s.preferences),
            _buildSectionContainer([
              _buildListTile(
                title: s.language,
                leadingIcon: Icons.language_outlined,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localeProvider.languageName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.black54),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LanguageSelectionScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                title: s.notifications,
                leadingIcon: Icons.notifications_none_outlined,
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.black54),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
                showDivider: false,
              ),
            ]),

            _buildSectionHeader(s.support),
            _buildSectionContainer([
              _buildListTile(
                title: s.penalties,
                leadingIcon: Icons.gavel_outlined,
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.black54),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PenaltiesInfoScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                title: s.contactUs,
                leadingIcon: Icons.support_agent_outlined,
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.black54),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ContactUsScreen(),
                    ),
                  );
                },
                showDivider: false,
              ),
            ]),

            const SizedBox(height: 40),

            // Footer Section
            Center(
              child: TextButton.icon(
                onPressed: () {
                  context.read<GroupProvider>().reset();
                  auth.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  s.signOut,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Version 1.0.0+1',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;

  const _ProfileAvatar({required this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          key: ValueKey(photoUrl),
          imageUrl: photoUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initials(),
          errorWidget: (_, __, ___) => _initials(),
        ),
      );
    }
    return _initials();
  }

  Widget _initials() => CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      );
}
