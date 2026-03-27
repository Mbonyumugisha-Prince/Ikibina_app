import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/formatters.dart';
import '../../models/group_model.dart';
import '../../models/loan_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../loans/pay_loan_screen.dart';
import '../loans/request_loan_screen.dart';
import 'edit_group_screen.dart';
import 'group_penalties_screen.dart';
import 'invite_member_screen.dart';
import 'member_detail_screen.dart';

const _bg = Color(0xFFF5F5F5);
const _ink = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class GroupInfoScreen extends StatefulWidget {
  final GroupModel group;
  final String currentUserId;

  const GroupInfoScreen({
    super.key,
    required this.group,
    required this.currentUserId,
  });

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  int _tabIndex = 0;
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  late GroupModel _group;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
  }

  bool get _isAdmin => _group.adminId == widget.currentUserId;

  bool get _isGoalGroup => _group.groupType == 'goal';

  List<String> get _tabs {
    if (_isGoalGroup) {
      // Goal groups get Leaderboard + Milestones instead of Late Payments/Loan
      return _isAdmin
          ? ['Members', 'Leaderboard', 'Milestones', 'Info', 'Contributions']
          : ['Members', 'Leaderboard', 'Milestones', 'Info'];
    }
    return _isAdmin
        ? ['Members', 'Late Payments', 'Loan Request', 'Info', 'Penalties', 'Contributions']
        : ['Members', 'Loan Request', 'Info', 'Penalties'];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    final tab = _tabs[_tabIndex];
    switch (tab) {
      case 'Members':
        return _MembersTab(
          group: _group,
          currentUserId: widget.currentUserId,
          search: _search,
        );
      case 'Late Payments':
        return _LatePaymentsTab(group: _group);
      case 'Loan Request':
        return _LoanRequestTab(group: _group, currentUserId: widget.currentUserId);
      case 'Leaderboard':
        return _LeaderboardTab(group: _group);
      case 'Milestones':
        return _MilestonesTab(group: _group);
      case 'Info':
        return _InfoTab(group: _group, isAdmin: _isAdmin);
      case 'Penalties':
        return GroupPenaltiesTab(
          group: _group,
          isAdmin: _isAdmin,
          currentUserId: widget.currentUserId,
        );
      case 'Contributions':
        return _ContributionsTab(group: _group);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    final initials = group.name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: _ink),
        ),
        title: Text(
          'Group Information',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        actions: [
          if (_isAdmin) ...[
            IconButton(
              tooltip: 'Edit group',
              icon: const Icon(Icons.edit_outlined, color: _ink),
              onPressed: () async {
                final oldImageUrl = _group.imageUrl;
                final updated = await Navigator.of(context).push<GroupModel>(
                  MaterialPageRoute(
                    builder: (_) => EditGroupScreen(group: _group),
                  ),
                );
                if (updated != null && mounted) {
                  // Evict old image from cache so the new one is fetched fresh
                  if (oldImageUrl != null && oldImageUrl != updated.imageUrl) {
                    // Evict from disk cache (CachedNetworkImage)
                    await CachedNetworkImage.evictFromCache(oldImageUrl);
                    // Evict from Flutter's in-memory image cache
                    imageCache.evict(NetworkImage(oldImageUrl));
                    imageCache.clearLiveImages();
                  }
                  setState(() => _group = updated);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Invite member',
                icon: const Icon(Icons.person_add_alt_1_outlined, color: _ink),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InviteMemberScreen(
                      groupId:    group.id,
                      groupName:  group.name,
                      inviteCode: group.inviteCode,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Section 1: Group profile header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                // Avatar: photo if available, otherwise initials
                ClipOval(
                  child: group.imageUrl != null && group.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          key: ValueKey(group.imageUrl),
                          imageUrl: group.imageUrl!,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 88,
                            height: 88,
                            color: _ink,
                            child: Center(
                              child: Text(initials,
                                  style: GoogleFonts.sora(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 88,
                            height: 88,
                            color: _ink,
                            child: Center(
                              child: Text(initials,
                                  style: GoogleFonts.sora(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ),
                          ),
                        )
                      : Container(
                          width: 88,
                          height: 88,
                          color: _ink,
                          child: Center(
                            child: Text(initials,
                                style: GoogleFonts.sora(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  group.name,
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isGoalGroup) ...[
                      _PillBadge(text: 'Goal Group'),
                      const SizedBox(width: 8),
                      _PillBadge(
                          text:
                              'RWF ${group.goalAmount.toStringAsFixed(0)} goal'),
                    ] else ...[
                      if (group.contributionFrequency.isNotEmpty)
                        _PillBadge(text: group.contributionFrequency),
                      const SizedBox(width: 8),
                      _PillBadge(
                        text:
                            'RWF ${group.contributionAmount.toStringAsFixed(0)}/cycle',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Section 2: Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              style: GoogleFonts.sora(fontSize: 14, color: _ink),
              decoration: InputDecoration(
                hintText: 'Search members...',
                hintStyle: GoogleFonts.sora(fontSize: 14, color: _grey),
                prefixIcon: const Icon(Icons.search, color: _grey, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _ink, width: 1.5),
                ),
              ),
            ),
          ),

          // Section 3: Pill tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final selected = _tabIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _tabIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? _ink : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? _ink : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        _tabs[i],
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : _grey,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Section 4: Spacer
          const SizedBox(height: 12),

          // Section 5: Tab content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final String text;
  const _PillBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.sora(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _grey,
        ),
      ),
    );
  }
}

// ── Members Tab ──
class _MembersTab extends StatelessWidget {
  final GroupModel group;
  final String currentUserId;
  final String search;

  const _MembersTab({
    required this.group,
    required this.currentUserId,
    required this.search,
  });

  @override
  Widget build(BuildContext context) {
    if (group.members.isEmpty) {
      return Center(
        child: Text(
          'No members yet.',
          style: GoogleFonts.sora(fontSize: 14, color: _grey),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: group.members)
          .snapshots(),
      builder: (ctx, usersSnap) {
        if (usersSnap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _ink),
          );
        }

        final users = (usersSnap.data?.docs ?? [])
            .map((d) => UserModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('contributions')
              .where('groupId', isEqualTo: group.id)
              .snapshots(),
          builder: (ctx, contribSnap) {
            if (contribSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _ink),
              );
            }

            // Build streak map: userId → count
            final streakMap = <String, int>{};
            for (final doc in contribSnap.data?.docs ?? []) {
              final data = doc.data() as Map<String, dynamic>;
              final uid = data['userId'] as String? ?? '';
              if (uid.isNotEmpty) {
                streakMap[uid] = (streakMap[uid] ?? 0) + 1;
              }
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('groupId', isEqualTo: group.id)
                  .where('type', isEqualTo: 'loan')
                  .snapshots(),
              builder: (ctx, txSnap) {
                if (txSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _ink),
                  );
                }

                final loanUserIds = <String>{};
                for (final doc in txSnap.data?.docs ?? []) {
                  final data = doc.data() as Map<String, dynamic>;
                  final uid = data['userId'] as String? ?? '';
                  if (uid.isNotEmpty) loanUserIds.add(uid);
                }

                // Filter by search
                final filtered = users.where((u) {
                  if (search.isEmpty) return true;
                  return u.name.toLowerCase().contains(search);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No members found.',
                      style: GoogleFonts.sora(fontSize: 14, color: _grey),
                    ),
                  );
                }

                // Separate admin from regular members
                UserModel? adminUser;
                final regularMembers = <UserModel>[];
                for (final u in filtered) {
                  if (u.id == group.adminId) {
                    adminUser = u;
                  } else {
                    regularMembers.add(u);
                  }
                }
                regularMembers.sort((a, b) => a.name.compareTo(b.name));

                final isViewerAdmin = currentUserId == group.adminId;
                final suspendedIds = Set<String>.from(group.suspendedMembers);

                return ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  children: [
                    if (adminUser != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Admin',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _MemberTile(
                          member: adminUser,
                          streak: streakMap[adminUser.id] ?? 0,
                          isAdmin: true,
                          hasLoanRequest: loanUserIds.contains(adminUser.id),
                          isSuspended: suspendedIds.contains(adminUser.id),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Members',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _grey,
                        ),
                      ),
                    ),
                    ...regularMembers.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _MemberTile(
                          member: m,
                          streak: streakMap[m.id] ?? 0,
                          isAdmin: false,
                          hasLoanRequest: loanUserIds.contains(m.id),
                          isSuspended: suspendedIds.contains(m.id),
                          onTap: isViewerAdmin
                              ? () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => MemberDetailScreen(
                                        group: group,
                                        member: m,
                                      ),
                                    ),
                                  )
                              : null,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

// ── Member Tile ──
class _MemberTile extends StatelessWidget {
  final UserModel member;
  final int streak;
  final bool isAdmin;
  final bool hasLoanRequest;
  final bool isSuspended;
  final VoidCallback? onTap;

  const _MemberTile({
    required this.member,
    required this.streak,
    required this.isAdmin,
    required this.hasLoanRequest,
    this.isSuspended = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = member.name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isAdmin ? _ink : const Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isAdmin ? Colors.white : _ink,
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
                  member.name,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Streak: $streak Contributions',
                  style: GoogleFonts.sora(fontSize: 11, color: _grey),
                ),
                if (isSuspended) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Suspended',
                      style: GoogleFonts.sora(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ] else if (hasLoanRequest) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Requested a loan',
                      style: GoogleFonts.sora(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAdmin ? _ink : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAdmin ? 'Admin' : 'Member',
              style: GoogleFonts.sora(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isAdmin ? Colors.white : _grey,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ── Late Payments Tab ──
class _LatePaymentsTab extends StatelessWidget {
  final GroupModel group;

  const _LatePaymentsTab({required this.group});

  int get _cycleDays {
    final freq = group.contributionFrequency.toLowerCase();
    if (freq.contains('bi') && freq.contains('week')) return 14;
    if (freq.contains('week')) return 7;
    return 30;
  }

  @override
  Widget build(BuildContext context) {
    if (group.members.isEmpty) {
      return Center(
        child: Text(
          'No members yet.',
          style: GoogleFonts.sora(fontSize: 14, color: _grey),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: group.members)
          .snapshots(),
      builder: (ctx, usersSnap) {
        if (usersSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _ink));
        }

        final users = (usersSnap.data?.docs ?? [])
            .map((d) => UserModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('contributions')
              .where('groupId', isEqualTo: group.id)
              .snapshots(),
          builder: (ctx, contribSnap) {
            if (contribSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _ink));
            }

            // Build map of userId → most recent contribution date
            final latestDateMap = <String, DateTime>{};
            for (final doc in contribSnap.data?.docs ?? []) {
              final data = doc.data() as Map<String, dynamic>;
              final uid = data['userId'] as String? ?? '';
              if (uid.isEmpty) continue;
              DateTime? date;
              final raw = data['date'];
              if (raw is Timestamp) {
                date = raw.toDate();
              } else if (raw is String) {
                date = DateTime.tryParse(raw);
              }
              if (date != null) {
                if (!latestDateMap.containsKey(uid) ||
                    date.isAfter(latestDateMap[uid]!)) {
                  latestDateMap[uid] = date;
                }
              }
            }

            final now = DateTime.now();
            final cycleDays = _cycleDays;

            // Find late members
            final lateMembers = users.where((u) {
              final latest = latestDateMap[u.id];
              if (latest == null) return true;
              return now.difference(latest).inDays >= cycleDays;
            }).toList();

            if (lateMembers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 64),
                    const SizedBox(height: 12),
                    Text(
                      'All members are up to date!',
                      style: GoogleFonts.sora(fontSize: 14, color: _grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: lateMembers.length,
              itemBuilder: (_, i) {
                final m = lateMembers[i];
                final initials = m.name
                    .trim()
                    .split(' ')
                    .map((w) => w.isNotEmpty ? w[0] : '')
                    .take(2)
                    .join()
                    .toUpperCase();

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0F0F0),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: GoogleFonts.sora(
                              fontSize: 15,
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
                              m.name,
                              style: GoogleFonts.sora(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Late - No contribution in $cycleDays days',
                                style: GoogleFonts.sora(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ── Loan Request Tab ──────────────────────────────────────────────
class _LoanRequestTab extends StatelessWidget {
  final GroupModel group;
  final String currentUserId;

  const _LoanRequestTab({required this.group, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LoanModel>>(
      stream: FirestoreService().getGroupLoans(group.id),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _ink));
        }

        final loans = snap.data ?? [];
        final myLoans     = loans.where((l) => l.userId == currentUserId).toList();
        final activeMyLoan  = myLoans.where((l) => l.status == 'approved').toList();
        final myPending     = myLoans.where((l) => l.status == 'pending').toList();
        final pendingOthers = loans
            .where((l) => l.userId != currentUserId && l.status == 'pending')
            .toList();
        final history = loans
            .where((l) => l.status == 'completed' || l.status == 'rejected')
            .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Request button — only if no active or pending loan
            if (activeMyLoan.isEmpty && myPending.isEmpty) ...[
              _RequestLoanButton(group: group),
              const SizedBox(height: 20),
            ],

            // My pending request (with cancel option)
            if (myPending.isNotEmpty) ...[
              _sectionLabel('Your Pending Request'),
              const SizedBox(height: 8),
              ...myPending.map((l) => _PendingLoanCard(
                    loan: l,
                    currentUserId: currentUserId,
                    memberCount: group.members.length,
                    showVote: false,
                    onCancel: () async {
                      final confirmed = await showDialog<bool>(
                        context: ctx,
                        builder: (dCtx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: Text('Cancel Request',
                              style: GoogleFonts.sora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _ink)),
                          content: Text(
                            'Cancel your loan request of RWF ${l.amount.toStringAsFixed(0)}?',
                            style: GoogleFonts.sora(
                                fontSize: 13, color: _grey, height: 1.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dCtx).pop(false),
                              child: Text('Keep',
                                  style: GoogleFonts.sora(
                                      color: _grey,
                                      fontWeight: FontWeight.w600)),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dCtx).pop(true),
                              child: Text('Cancel Request',
                                  style: GoogleFonts.sora(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await FirestoreService().cancelLoan(l.id);
                      }
                    },
                  )),
              const SizedBox(height: 20),
            ],

            // My active loan being repaid
            if (activeMyLoan.isNotEmpty) ...[
              _sectionLabel('Your Active Loan'),
              const SizedBox(height: 8),
              ...activeMyLoan.map((l) => _ActiveLoanCard(
                    loan: l,
                    onPay: () => Navigator.of(ctx).push(MaterialPageRoute(
                      builder: (_) => PayLoanScreen(loan: l),
                    )),
                  )),
              const SizedBox(height: 20),
            ],

            // Others' pending loans — everyone votes
            if (pendingOthers.isNotEmpty) ...[
              _sectionLabel('Pending Approvals'),
              const SizedBox(height: 8),
              ...pendingOthers.map((l) => _PendingLoanCard(
                    loan: l,
                    currentUserId: currentUserId,
                    memberCount: group.members.length,
                    showVote: true,
                  )),
              const SizedBox(height: 20),
            ],

            // History
            if (history.isNotEmpty) ...[
              _sectionLabel('History'),
              const SizedBox(height: 8),
              ...history.map((l) => _HistoryLoanCard(loan: l)),
            ],

            // Empty state
            if (loans.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.account_balance_outlined,
                          size: 64, color: _grey),
                      const SizedBox(height: 12),
                      Text('No loans yet',
                          style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _ink)),
                      const SizedBox(height: 6),
                      Text('Tap "Request a Loan" to get started',
                          style: GoogleFonts.sora(
                              fontSize: 12, color: _grey)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.sora(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _grey,
            letterSpacing: 0.5),
      );
}

// ── Request loan button ──────────────────────────────────────────
class _RequestLoanButton extends StatelessWidget {
  final GroupModel group;
  const _RequestLoanButton({required this.group});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RequestLoanScreen(group: group)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _ink,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_outlined,
                color: Colors.white, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request a Loan',
                      style: GoogleFonts.sora(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text('Up to 50% of group savings',
                      style: GoogleFonts.sora(
                          fontSize: 11, color: Colors.white60)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white60, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Pending loan card (with voting) ─────────────────────────────
class _PendingLoanCard extends StatefulWidget {
  final LoanModel loan;
  final String currentUserId;
  final int memberCount;
  final bool showVote;
  final Future<void> Function()? onCancel;

  const _PendingLoanCard({
    required this.loan,
    required this.currentUserId,
    required this.memberCount,
    required this.showVote,
    this.onCancel,
  });

  @override
  State<_PendingLoanCard> createState() => _PendingLoanCardState();
}

class _PendingLoanCardState extends State<_PendingLoanCard> {
  bool _voting = false;

  Future<void> _vote(bool approve) async {
    setState(() => _voting = true);
    try {
      await FirestoreService().voteOnLoan(
        loanId: widget.loan.id,
        voterId: widget.currentUserId,
        approve: approve,
        totalMemberCount: widget.memberCount,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e', style: GoogleFonts.sora()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } finally {
      if (mounted) setState(() => _voting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.loan;
    final votingMembers =
        (widget.memberCount - 1).clamp(1, widget.memberCount);
    final needed = (votingMembers / 2).ceil();
    final hasApproved = l.approvedBy.contains(widget.currentUserId);
    final hasRejected = l.rejectedBy.contains(widget.currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _loanInitials(l.userName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.userName,
                        style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _ink),
                        overflow: TextOverflow.ellipsis),
                    Text(
                        'RWF ${l.amount.toStringAsFixed(0)}  ·  ${l.durationWeeks}w',
                        style: GoogleFonts.sora(
                            fontSize: 12, color: _grey)),
                  ],
                ),
              ),
              _loanStatusBadge('Pending', Colors.amber.shade700,
                  const Color(0xFFFFF8E1)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('${l.approvedBy.length}/$needed approvals',
                  style: GoogleFonts.sora(fontSize: 11, color: _grey)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: needed == 0
                        ? 1
                        : (l.approvedBy.length / needed).clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_ink),
                    minHeight: 5,
                  ),
                ),
              ),
            ],
          ),
          if (widget.showVote) ...[
            const SizedBox(height: 12),
            _voting
                ? const Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: _ink, strokeWidth: 2)))
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              hasRejected ? null : () => _vote(false),
                          icon: const Icon(Icons.close,
                              size: 16, color: Colors.red),
                          label: Text(
                              hasRejected ? 'Rejected' : 'Reject',
                              style: GoogleFonts.sora(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.red, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              hasApproved ? null : () => _vote(true),
                          icon: const Icon(Icons.check,
                              size: 16, color: Colors.white),
                          label: Text(
                              hasApproved ? 'Approved ✓' : 'Approve',
                              style: GoogleFonts.sora(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                hasApproved ? Colors.green : _ink,
                            disabledBackgroundColor: Colors.green,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
          // Cancel button — only for the requester's own pending loan
          if (widget.onCancel != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text('Cancel Request',
                    style: GoogleFonts.sora(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Active loan card ─────────────────────────────────────────────
class _ActiveLoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onPay;
  const _ActiveLoanCard({required this.loan, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final l = loan;
    final isOverdue = l.isOverdue;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isOverdue
                ? Colors.red.shade200
                : const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RWF ${l.amount.toStringAsFixed(0)}',
                  style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _ink)),
              _loanStatusBadge(
                isOverdue ? 'Overdue' : 'Active',
                isOverdue ? Colors.red.shade700 : Colors.green.shade700,
                isOverdue ? Colors.red.shade50 : Colors.green.shade50,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${l.durationWeeks}w  ·  Due ${_loanFmtDate(l.dueDate)}  ·  ${(l.interestRate * 100).toInt()}% interest',
            style: GoogleFonts.sora(fontSize: 11, color: _grey),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: l.progress,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(
                  isOverdue ? Colors.red : _ink),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(l.progress * 100).toInt()}% repaid',
                  style: GoogleFonts.sora(fontSize: 11, color: _grey)),
              Text('RWF ${l.remaining.toStringAsFixed(0)} left',
                  style: GoogleFonts.sora(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _ink)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOverdue ? Colors.red : _ink,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Pay Loan',
                  style: GoogleFonts.sora(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── History loan card ────────────────────────────────────────────
class _HistoryLoanCard extends StatelessWidget {
  final LoanModel loan;
  const _HistoryLoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final l = loan;
    final isCompleted = l.status == 'completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          _loanInitials(l.userName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.userName,
                    style: GoogleFonts.sora(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _ink),
                    overflow: TextOverflow.ellipsis),
                Text('RWF ${l.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.sora(fontSize: 12, color: _grey)),
              ],
            ),
          ),
          _loanStatusBadge(
            isCompleted ? 'Repaid' : 'Rejected',
            isCompleted ? Colors.green.shade700 : Colors.red.shade700,
            isCompleted ? Colors.green.shade50 : Colors.red.shade50,
          ),
        ],
      ),
    );
  }
}

// ── Loan helpers (file-level) ─────────────────────────────────────
Widget _loanInitials(String name) {
  final txt = name
      .trim()
      .split(' ')
      .map((w) => w.isNotEmpty ? w[0] : '')
      .take(2)
      .join()
      .toUpperCase();
  return Container(
    width: 44,
    height: 44,
    decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0), shape: BoxShape.circle),
    child: Center(
      child: Text(txt,
          style: GoogleFonts.sora(
              fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
    ),
  );
}

Widget _loanStatusBadge(String label, Color text, Color bg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.sora(
              fontSize: 10, fontWeight: FontWeight.w700, color: text)),
    );

String _loanFmtDate(DateTime d) {
  const m = ['Jan','Feb','Mar','Apr','May','Jun',
              'Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${m[d.month - 1]} ${d.day}';
}

// ── Info Tab ──
class _InfoTab extends StatelessWidget {
  final GroupModel group;
  final bool isAdmin;

  const _InfoTab({required this.group, required this.isAdmin});

  Widget _infoCard(String label, String value, {bool isCode = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.sora(fontSize: 13, color: _grey),
          ),
          if (isCode)
            Text(
              value,
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _ink,
                letterSpacing: 4,
              ),
            )
          else
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _infoCard('Group Name', group.name),
          _infoCard(
            'Description',
            group.description.isEmpty ? 'No description' : group.description,
          ),
          _infoCard(
            'Contribution Amount',
            'RWF ${group.contributionAmount.toStringAsFixed(0)}',
          ),
          _infoCard('Frequency', group.contributionFrequency),
          _infoCard(
            'Total Savings',
            'RWF ${group.totalSavings.toStringAsFixed(0)}',
          ),
          _infoCard('Members', '${group.members.length} members'),
          _infoCard('Created', Formatters.date(group.createdAt)),
          if (isAdmin) _infoCard('Invite Code', group.inviteCode, isCode: true),
        ],
      ),
    );
  }
}

// ── Leaderboard Tab (goal groups) ──
class _LeaderboardTab extends StatelessWidget {
  final GroupModel group;
  const _LeaderboardTab({required this.group});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contributions')
          .where('groupId', isEqualTo: group.id)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _ink));
        }

        // Aggregate total contributions per user
        final totals = <String, double>{};
        final names  = <String, String>{};
        for (final doc in snap.data?.docs ?? []) {
          final data   = doc.data() as Map<String, dynamic>;
          final uid    = data['userId']   as String? ?? '';
          final name   = data['userName'] as String? ?? '';
          final amount = (data['amount']  ?? 0).toDouble();
          if (uid.isEmpty) continue;
          totals[uid] = (totals[uid] ?? 0) + amount;
          names[uid]  = name;
        }

        final ranked = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (ranked.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.leaderboard_outlined, size: 64, color: _grey),
                const SizedBox(height: 12),
                Text('No contributions yet.',
                    style: GoogleFonts.sora(fontSize: 14, color: _grey)),
              ],
            ),
          );
        }

        final medals = ['🥇', '🥈', '🥉'];

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: ranked.length,
          itemBuilder: (_, i) {
            final entry = ranked[i];
            final name  = names[entry.key] ?? 'Unknown';
            final initials = name.trim().split(' ')
                .map((w) => w.isNotEmpty ? w[0] : '')
                .take(2).join().toUpperCase();
            final isTop3 = i < 3;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: i == 0
                    ? const Color(0xFFFFFDE7)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: i == 0
                      ? const Color(0xFFFFD54F)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      isTop3 ? medals[i] : '${i + 1}',
                      style: GoogleFonts.sora(
                          fontSize: isTop3 ? 22 : 14,
                          fontWeight: FontWeight.w700,
                          color: _grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: i == 0 ? const Color(0xFFFFD54F) : const Color(0xFFF0F0F0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(initials,
                          style: GoogleFonts.sora(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _ink)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(name,
                        style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _ink),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    'RWF ${entry.value.toStringAsFixed(0)}',
                    style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Milestones Tab (goal groups) ──
class _MilestonesTab extends StatelessWidget {
  final GroupModel group;
  const _MilestonesTab({required this.group});

  @override
  Widget build(BuildContext context) {
    final milestones = group.milestones;

    if (milestones.isEmpty) {
      return Center(
        child: Text('No milestones set.',
            style: GoogleFonts.sora(fontSize: 14, color: _grey)),
      );
    }

    // Build cumulative targets so we know which milestone is current/done
    final cumulativeTargets = <double>[];
    double acc = 0;
    for (final m in milestones) {
      acc += m.targetAmount;
      cumulativeTargets.add(acc);
    }
    final saved = group.totalSavings;
    final goalAmount = cumulativeTargets.last;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall progress header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Goal',
                        style: GoogleFonts.sora(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.7))),
                    Text('RWF ${goalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.sora(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Saved so far',
                        style: GoogleFonts.sora(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.7))),
                    Text('RWF ${saved.toStringAsFixed(0)}',
                        style: GoogleFonts.sora(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goalAmount > 0
                        ? (saved / goalAmount).clamp(0.0, 1.0)
                        : 0,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Milestones',
              style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _ink)),
          const SizedBox(height: 12),

          // Milestone list with connecting line
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: List.generate(milestones.length, (i) {
                final m              = milestones[i];
                final cumTarget      = cumulativeTargets[i];
                final prevTarget     = i == 0 ? 0.0 : cumulativeTargets[i - 1];
                final isCompleted    = saved >= cumTarget;
                final isCurrent      = !isCompleted && saved >= prevTarget;
                final remaining      = (cumTarget - saved).clamp(0.0, double.infinity);
                final milestoneProgress = isCurrent && m.targetAmount > 0
                    ? ((saved - prevTarget) / m.targetAmount).clamp(0.0, 1.0)
                    : (isCompleted ? 1.0 : 0.0);

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon + connecting line column
                      SizedBox(
                        width: 36,
                        child: Column(
                          children: [
                            _MilestoneIcon(
                                completed: isCompleted, current: isCurrent),
                            if (i < milestones.length - 1)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4),
                                  color: isCompleted
                                      ? _ink
                                      : const Color(0xFFE0E0E0),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: i < milestones.length - 1 ? 20 : 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      m.name,
                                      style: GoogleFonts.sora(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _ink,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationColor: _grey,
                                      ),
                                    ),
                                  ),
                                  if (isCurrent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _ink,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text('CURRENT',
                                          style: GoogleFonts.sora(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (isCompleted)
                                Text('Completed',
                                    style: GoogleFonts.sora(
                                        fontSize: 12, color: _grey))
                              else if (isCurrent)
                                Text(
                                  'RWF ${remaining.toStringAsFixed(0)} remaining',
                                  style: GoogleFonts.sora(
                                      fontSize: 12, color: _grey),
                                )
                              else
                                Row(
                                  children: [
                                    const Icon(Icons.lock_outline,
                                        size: 12, color: _grey),
                                    const SizedBox(width: 4),
                                    Text('Locked',
                                        style: GoogleFonts.sora(
                                            fontSize: 12, color: _grey)),
                                  ],
                                ),
                              if (isCurrent) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: milestoneProgress,
                                    minHeight: 6,
                                    backgroundColor:
                                        const Color(0xFFEEEEEE),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            _ink),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneIcon extends StatelessWidget {
  final bool completed;
  final bool current;
  const _MilestoneIcon({required this.completed, required this.current});

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: _ink,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    }
    if (current) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _ink, width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: _ink,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
      ),
    );
  }
}

// ── Contributions Tab ──
class _ContributionsTab extends StatelessWidget {
  final GroupModel group;

  const _ContributionsTab({required this.group});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contributions')
          .where('groupId', isEqualTo: group.id)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _ink));
        }

        final cutoff = DateTime.now().subtract(const Duration(days: 7));

        // Filter in Dart for last 7 days
        final recent = (snap.data?.docs ?? []).where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final raw = data['date'];
          DateTime? date;
          if (raw is Timestamp) date = raw.toDate();
          if (date == null) return false;
          return date.isAfter(cutoff);
        }).toList();

        // Sort by date descending in Dart
        recent.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          DateTime? aDate;
          DateTime? bDate;
          final aRaw = aData['date'];
          final bRaw = bData['date'];
          if (aRaw is Timestamp) aDate = aRaw.toDate();
          if (bRaw is Timestamp) bDate = bRaw.toDate();
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                "This Week's Contributions",
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
            if (recent.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No contributions this week.',
                    style: GoogleFonts.sora(fontSize: 14, color: _grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 0),
                  itemCount: recent.length,
                  itemBuilder: (_, i) {
                    final data =
                        recent[i].data() as Map<String, dynamic>;
                    final userName = data['userName'] as String? ?? '';
                    final amount = (data['amount'] ?? 0).toDouble();
                    DateTime? date;
                    final raw = data['date'];
                    if (raw is Timestamp) date = raw.toDate();

                    final initials = userName
                        .trim()
                        .split(' ')
                        .map((w) => w.isNotEmpty ? w[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFE0E0E0)),
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
                                  userName,
                                  style: GoogleFonts.sora(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _ink,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Contribution',
                                  style: GoogleFonts.sora(
                                      fontSize: 11, color: _grey),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'RWF ${amount.toStringAsFixed(0)}',
                                style: GoogleFonts.sora(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                              if (date != null)
                                Text(
                                  Formatters.relativeTime(date),
                                  style: GoogleFonts.sora(
                                      fontSize: 11, color: _grey),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
