import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';

const _bg   = Color(0xFFF5F5F5);
const _ink  = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final s = context.watch<LocaleProvider>().strings;
    final user = auth.user;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          s.profile,
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFE0E0E0),
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            user.name[0].toUpperCase(),
                            style: GoogleFonts.sora(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user.name,
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    user.email,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _grey,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  height: 1,
                  color: const Color(0xFFE0E0E0),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_outlined, color: _ink, size: 20),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.phone,
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _grey,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.phone ?? 'Not set',
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: const Color(0xFFE0E0E0),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => auth.signOut(),
                    icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                    label: Text(
                      s.signOut,
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
