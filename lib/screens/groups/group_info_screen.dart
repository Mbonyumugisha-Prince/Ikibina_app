import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/formatters.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';

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

  bool get _isAdmin => widget.group.adminId == widget.currentUserId;

  List<String> get _tabs {
    if (_isAdmin) {
      return ['Members', 'Late Payments', 'Loan Request', 'Info', 'Contributions'];
    }
    return ['Members', 'Loan Request', 'Info'];
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
          group: widget.group,
          currentUserId: widget.currentUserId,
          search: _search,
        );
      case 'Late Payments':
        return _LatePaymentsTab(group: widget.group);
      case 'Loan Request':
        return _LoanRequestTab(group: widget.group);
      case 'Info':
        return _InfoTab(group: widget.group, isAdmin: _isAdmin);
      case 'Contributions':
        return _ContributionsTab(group: widget.group);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
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
      ),
      body: Column(
        children: [
          // Section 1: Group profile header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: _ink,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.sora(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
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
                    _PillBadge(text: group.contributionFrequency),
                    const SizedBox(width: 8),
                    _PillBadge(
                      text: 'RWF ${group.contributionAmount.toStringAsFixed(0)}/cycle',
                    ),
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

  const _MemberTile({
    required this.member,
    required this.streak,
    required this.isAdmin,
    required this.hasLoanRequest,
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

    return Container(
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
                if (hasLoanRequest) ...[
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

// ── Loan Request Tab ──
class _LoanRequestTab extends StatelessWidget {
  final GroupModel group;

  const _LoanRequestTab({required this.group});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('groupId', isEqualTo: group.id)
          .where('type', isEqualTo: 'loan')
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _ink));
        }

        final docs = snap.data?.docs ?? [];

        // Sort in Dart by date descending
        final sorted = [...docs];
        sorted.sort((a, b) {
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

        if (sorted.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.request_page_outlined, size: 64, color: _grey),
                const SizedBox(height: 12),
                Text(
                  'No loan requests',
                  style: GoogleFonts.sora(fontSize: 14, color: _grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            final data = sorted[i].data() as Map<String, dynamic>;
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
                          userName,
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Loan Request',
                          style: GoogleFonts.sora(
                              fontSize: 12, color: _grey),
                        ),
                        if (date != null)
                          Text(
                            Formatters.date(date),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Pending',
                          style: GoogleFonts.sora(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[800],
                          ),
                        ),
                      ),
                    ],
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
