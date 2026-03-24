import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';

const _bg   = Color(0xFFF5F5F5);
const _ink  = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class MembersScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  const MembersScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
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
          'Members',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('activeGroupId', isEqualTo: groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _ink),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load members.',
                style: GoogleFonts.sora(color: _grey),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline, size: 48, color: _grey),
                  const SizedBox(height: 12),
                  Text(
                    'No members yet.',
                    style: GoogleFonts.sora(fontSize: 14, color: _grey),
                  ),
                ],
              ),
            );
          }

          final members = docs.map((d) {
            return UserModel.fromMap(d.id, d.data() as Map<String, dynamic>);
          }).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _MemberTile(member: members[i]),
          );
        },
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final UserModel member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final initials = member.name.isNotEmpty
        ? member.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    final isAdmin = member.activeGroupRole == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
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
                ),
                Text(
                  member.email,
                  style: GoogleFonts.sora(fontSize: 12, color: _grey),
                ),
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
