import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../groups/group_info_screen.dart';

const _bg = Color(0xFFF5F5F5);
const _ink = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupP = context.watch<GroupProvider>();
    final auth = context.watch<AuthProvider>();
    final userId = auth.user?.id ?? '';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'My Groups',
                style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _ink),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Text(
                '${groupP.groups.length} active',
                style: GoogleFonts.sora(fontSize: 13, color: _grey),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: groupP.loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _ink))
                  : groupP.groups.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.group_outlined,
                                  size: 64, color: _grey),
                              const SizedBox(height: 12),
                              Text(
                                'No groups yet',
                                style: GoogleFonts.sora(
                                    fontSize: 15, color: _grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: groupP.groups.length,
                          itemBuilder: (_, i) {
                            final g = groupP.groups[i];
                            return GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GroupInfoScreen(
                                    group: g,
                                    currentUserId: userId,
                                  ),
                                ),
                              ),
                              child:
                                  _GroupListCard(group: g, userId: userId),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupListCard extends StatelessWidget {
  final GroupModel group;
  final String userId;

  const _GroupListCard({required this.group, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isAdmin = group.adminId == userId;
    final memberCount = group.members.isEmpty ? 1 : group.members.length;
    final target = group.contributionAmount * memberCount;
    final progress =
        target > 0 ? (group.totalSavings / target).clamp(0.0, 1.0) : 0.0;
    final initials = group.name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                const BoxDecoration(color: _ink, shape: BoxShape.circle),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.name,
                        style: GoogleFonts.sora(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _ink),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
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
                const SizedBox(height: 2),
                Text(group.contributionFrequency,
                    style: GoogleFonts.sora(fontSize: 12, color: _grey)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_ink),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(progress * 100).toInt()}% of goal',
                        style:
                            GoogleFonts.sora(fontSize: 11, color: _grey)),
                    Text('${group.members.length} members',
                        style:
                            GoogleFonts.sora(fontSize: 11, color: _grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: _grey, size: 20),
        ],
      ),
    );
  }
}
