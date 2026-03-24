import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/contribution_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';
import '../contributions/add_contribution_screen.dart';
import '../contributions/contributions_screen.dart';
import '../groups/create_group_screen.dart';
import '../groups/invite_member_screen.dart';
import '../groups/members_screen.dart';
import '../transactions/transactions_screen.dart';

const _bg   = Color(0xFFF5F5F5);
const _ink  = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<GroupProvider>().loadUserGroups(auth.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final groupP = context.watch<GroupProvider>();
    final s      = context.watch<LocaleProvider>().strings;
    final group  = groupP.currentGroup;
    final user   = auth.user;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
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
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    icon: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child:
                          const Icon(Icons.more_vert, color: _ink, size: 20),
                    ),
                    onSelected: (val) {
                      if (val == 'signout') {
                        context.read<AuthProvider>().signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (_) => false,
                        );
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'signout',
                        child: Row(
                          children: [
                            const Icon(Icons.logout, size: 18, color: _ink),
                            const SizedBox(width: 10),
                            Text(s.signOut,
                                style: GoogleFonts.sora(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              if (groupP.loading && !groupP.hasAttemptedLoad)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      const CircularProgressIndicator(color: _ink),
                      const SizedBox(height: 16),
                      Text(s.loadingGroup,
                          style: GoogleFonts.sora(color: _grey)),
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
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            color: _grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CreateGroupScreen(),
                                ),
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
                    ],
                  ),
                )
              else if (group != null)
                StreamBuilder<List<ContributionModel>>(
                  stream: FirestoreService().getGroupContributions(group.id),
                  builder: (context, snap) {
                    final contributions = snap.data ?? [];
                    final groupTotal = contributions.fold(0.0, (sum, c) => sum + c.amount);

                    // Per-member totals map: userId -> {name, total}
                    final memberTotals = <String, Map<String, dynamic>>{};
                    for (final c in contributions) {
                      memberTotals.update(
                        c.userId,
                        (m) {
                          m['total'] = (m['total'] as double) + c.amount;
                          return m;
                        },
                        ifAbsent: () => {'name': c.userName, 'total': c.amount},
                      );
                    }
                    final memberList = memberTotals.values.toList()
                      ..sort((a, b) => (b['total'] as double).compareTo(a['total'] as double));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Group overview card ──
                        Container(
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
                                style: GoogleFonts.sora(
                                    fontSize: 13, color: Colors.white60),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _statChip(
                                      'RWF ${groupTotal.toStringAsFixed(0)}',
                                      s.totalSavings),
                                  const SizedBox(width: 12),
                                  _statChip('${group.memberCount}', s.members),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Member contributions breakdown ──
                        if (memberList.isNotEmpty) ...[
                          Text(
                            'Member Contributions',
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...memberList.map((m) {
                            final name = m['name'] as String;
                            final total = m['total'] as double;
                            final initials = name.trim().split(' ')
                                .map((w) => w.isNotEmpty ? w[0] : '')
                                .take(2)
                                .join()
                                .toUpperCase();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFE0E0E0), width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _bg,
                                        borderRadius: BorderRadius.circular(10),
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
                                      child: Text(
                                        name,
                                        style: GoogleFonts.sora(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _ink,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      'RWF ${total.toStringAsFixed(0)}',
                                      style: GoogleFonts.sora(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                        ],

                        // ── Invite code ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFFE0E0E0), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.watch<LocaleProvider>().strings.groupInviteCode,
                                    style: GoogleFonts.sora(
                                      fontSize: 10,
                                      color: _grey,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    group.inviteCode.isEmpty
                                        ? '------'
                                        : group.inviteCode,
                                    style: GoogleFonts.sora(
                                      fontSize: 24,
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
                                  Clipboard.setData(
                                      ClipboardData(text: group.inviteCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.read<LocaleProvider>().strings.codeCopiedMessage,
                                        style: GoogleFonts.sora()),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy_outlined, color: _ink),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            context.watch<LocaleProvider>().strings.shareCodeWithMembers,
                            style: GoogleFonts.sora(fontSize: 12, color: _grey),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Invite member button ──
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => InviteMemberScreen(
                                  groupId:    group.id,
                                  groupName:  group.name,
                                  inviteCode: group.inviteCode,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.person_add_outlined, size: 20),
                            label: Text(
                              s.inviteMember,
                              style: GoogleFonts.sora(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _ink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Quick actions ──
                        Text(
                          s.quickActions,
                          style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionCard(
                                icon: Icons.add_card_outlined,
                                label: s.addContribution,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const AddContributionScreen()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionCard(
                                icon: Icons.people_outline,
                                label: s.groupMembers,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MembersScreen(
                                      groupId: group.id,
                                      groupName: group.name,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionCard(
                                icon: Icons.bar_chart_outlined,
                                label: s.myContributions,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ContributionsScreen(groupId: group.id),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionCard(
                                icon: Icons.account_balance_wallet_outlined,
                                label: s.transactions,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TransactionsScreen(groupId: group.id),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.sora(fontSize: 11, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1A1A1A), size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
