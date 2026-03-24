import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import 'create_group_screen.dart';
import 'join_group_screen.dart';

const _bg   = Color(0xFFF5F5F5);
const _ink  = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class GroupSetupScreen extends StatelessWidget {
  const GroupSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),

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
                  child: const Icon(Icons.savings, color: Colors.white, size: 36),
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Center(
                child: Text(
                  s.getStarted,
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
                  s.setupGroupOrJoin,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(fontSize: 14, color: _grey, height: 1.6),
                ),
              ),

              const SizedBox(height: 48),

              // Create Group card
              _OptionCard(
                icon: Icons.group_add_outlined,
                title: s.createNewGroup,
                subtitle: s.createNewGroupDesc,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                ),
              ),

              const SizedBox(height: 16),

              // Join Group card
              _OptionCard(
                icon: Icons.login_outlined,
                title: s.joinExistingGroup,
                subtitle: s.joinExistingGroupDesc,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _ink,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      color: _grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}
