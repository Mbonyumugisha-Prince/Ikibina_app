import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/formatters.dart';
import '../../models/contribution_model.dart';
import '../../models/group_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/firestore_service.dart';
import '../contributions/add_contribution_screen.dart';
import '../groups/create_group_screen.dart';
import '../groups/group_info_screen.dart';
import '../groups/groups_screen.dart';
import '../groups/join_group_screen.dart';
import '../profile/profile_screen.dart';
import '../wallet/wallet_screen.dart';

const _bg = Color(0xFFF5F5F5);
const _ink = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final groupP = context.watch<GroupProvider>();
    final s = context.watch<LocaleProvider>().strings;
    final group = groupP.currentGroup;
    final user = auth.user;

    if (user != null && !groupP.hasAttemptedLoad && !groupP.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GroupProvider>().loadUserGroups(user.id);
      });
    }

    return Scaffold(
      backgroundColor: _bg,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${s.hello}, ${user?.name.split(' ').first ?? ''} 👋',
                              style: GoogleFonts.sora(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              s.groupAdmin,
                              style: GoogleFonts.sora(fontSize: 13, color: _grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  if (!groupP.hasAttemptedLoad || groupP.loading)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          const CircularProgressIndicator(color: _ink),
                          const SizedBox(height: 16),
                          Text(s.loadingGroup, style: GoogleFonts.sora(color: _grey)),
                        ],
                      ),
                    )
                  else if (groupP.error != null)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              groupP.error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.sora(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 180,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                if (auth.user != null) {
                                  context.read<GroupProvider>().loadUserGroups(auth.user!.id);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _ink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (group == null && groupP.hasAttemptedLoad)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Icon(Icons.group_add_outlined, color: _grey, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            s.noGroupsYet,
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              s.createOrJoinGroup,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.sora(fontSize: 13, color: _grey),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: 140,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                              ),
                              icon: const Icon(Icons.add, size: 20),
                              label: Text(
                                s.createGroup,
                                style: GoogleFonts.sora(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _ink,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (group != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Group overview card ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _ink,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.groupOverview,
                                style: GoogleFonts.sora(
                                  fontSize: 10,
                                  color: Colors.white60,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                group.name,
                                style: GoogleFonts.sora(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                group.contributionFrequency,
                                style: GoogleFonts.sora(fontSize: 13, color: Colors.white60),
                              ),
                              const SizedBox(height: 16),
                              StreamBuilder<List<ContributionModel>>(
                                stream: FirestoreService()
                                    .getGroupContributions(group.id),
                                builder: (ctx, snap) {
                                  final myTotal = (snap.data ?? [])
                                      .where((c) => c.userId == (user?.id ?? ''))
                                      .fold(0.0, (sum, c) => sum + c.amount);
                                  return Row(
                                    children: [
                                      Expanded(child: _statChip('RWF ${group.totalSavings.toStringAsFixed(0)}', s.totalSavings)),
                                      const SizedBox(width: 6),
                                      Expanded(child: _statChip('${group.members.length}', s.members)),
                                      const SizedBox(width: 6),
                                      Expanded(child: _statChip('RWF ${myTotal.toStringAsFixed(0)}', 'Your Savings')),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Quick Actions ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _CircleAction(
                              icon: Icons.group_add_outlined,
                              label: 'New Group',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                              ),
                            ),
                            _CircleAction(
                              icon: Icons.login,
                              label: 'Join',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
                              ),
                            ),
                            _CircleAction(
                              icon: Icons.add_circle_outline,
                              label: 'Add Contribution',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AddContributionScreen()),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ── Active Ikimina ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Active Ikimina',
                              style: GoogleFonts.sora(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _currentIndex = 1),
                              child: Text(
                                'See all',
                                style: GoogleFonts.sora(
                                  fontSize: 13,
                                  color: _grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        ...groupP.groups.map(
                          (g) => GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GroupInfoScreen(
                                  group: g,
                                  currentUserId: user?.id ?? '',
                                ),
                              ),
                            ),
                            child: _IkiminaCard(group: g, userId: user?.id ?? ''),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Recent Activity ──
                        Text(
                          'Recent Activity',
                          style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 12),

                        StreamBuilder<List<ContributionModel>>(
                          stream: FirestoreService().getGroupContributions(group.id),
                          builder: (ctx, snap) {
                            if (snap.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: CircularProgressIndicator(color: _ink, strokeWidth: 2),
                                ),
                              );
                            }
                            final recent = (snap.data ?? []).take(5).toList();
                            if (recent.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'No recent activity',
                                    style: GoogleFonts.sora(fontSize: 13, color: _grey),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: recent.map((c) => _ActivityItem(contribution: c)).toList(),
                            );
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Groups tab
          const GroupsScreen(),
          // Wallet tab
          const WalletScreen(),
          // Profile tab
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        backgroundColor: _bg,
        elevation: 0,
        indicatorColor: _ink.withValues(alpha: 0.1),
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: s.home),
          NavigationDestination(icon: const Icon(Icons.people_outline), label: s.groups),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: s.wallet,
          ),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: s.profile),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.sora(fontSize: 9, color: Colors.white60),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Circle quick action button ──
class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _ink, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ikimina card (shared for admin & member) ──
class _IkiminaCard extends StatelessWidget {
  final GroupModel group;
  final String userId;

  const _IkiminaCard({required this.group, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isAdmin = group.adminId == userId;
    final memberCount = group.members.isEmpty ? 1 : group.members.length;
    final target = group.contributionAmount * memberCount;
    final progress = target > 0
        ? (group.totalSavings / target).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + role badge
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAdmin ? 'Admin' : 'Member',
                  style: GoogleFonts.sora(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Ikimina type (frequency)
          Text(
            group.contributionFrequency,
            style: GoogleFonts.sora(fontSize: 13, color: _grey),
          ),

          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: const AlwaysStoppedAnimation<Color>(_ink),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% of goal',
                style: GoogleFonts.sora(fontSize: 11, color: _grey),
              ),
              Text(
                'RWF ${group.totalSavings.toStringAsFixed(0)}',
                style: GoogleFonts.sora(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
            ],
          ),

          // Invite code (only if user is admin of this group)
          if (isAdmin && group.inviteCode.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INVITE CODE',
                      style: GoogleFonts.sora(
                        fontSize: 10,
                        color: _grey,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.inviteCode,
                      style: GoogleFonts.sora(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                        letterSpacing: 6,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: group.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Code copied!', style: GoogleFonts.sora()),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined, color: _ink, size: 20),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Recent activity item ──
class _ActivityItem extends StatelessWidget {
  final ContributionModel contribution;

  const _ActivityItem({required this.contribution});

  @override
  Widget build(BuildContext context) {
    final name = contribution.userName;
    final initials = name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Contribution',
                  style: GoogleFonts.sora(fontSize: 11, color: _grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RWF ${contribution.amount.toStringAsFixed(0)}',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              Text(
                Formatters.relativeTime(contribution.date),
                style: GoogleFonts.sora(fontSize: 11, color: _grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
