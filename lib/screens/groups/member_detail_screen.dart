import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

const _bg = Color(0xFFF5F5F5);
const _ink = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class MemberDetailScreen extends StatefulWidget {
  final GroupModel group;
  final UserModel member;

  const MemberDetailScreen({
    super.key,
    required this.group,
    required this.member,
  });

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  bool _loading = false;

  String get _initials => widget.member.name
      .trim()
      .split(' ')
      .map((w) => w.isNotEmpty ? w[0] : '')
      .take(2)
      .join()
      .toUpperCase();

  Future<void> _toggleSuspend(bool currentlySuspended) async {
    setState(() => _loading = true);
    try {
      if (currentlySuspended) {
        await FirestoreService().unsuspendMember(
          widget.group.id,
          widget.member.id,
        );
      } else {
        await FirestoreService().suspendMember(
          widget.group.id,
          widget.member.id,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}',
                style: GoogleFonts.sora()),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove ${widget.member.name}?',
          style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will remove them from the group. They will lose access to all group data.',
          style: GoogleFonts.sora(fontSize: 13, color: _grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.sora(color: _grey, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove',
                style: GoogleFonts.sora(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await FirestoreService().removeMember(
        widget.group.id,
        widget.member.id,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove member: ${e.toString()}',
                style: GoogleFonts.sora()),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        setState(() => _loading = false);
      }
    }
  }

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
          'Member Details',
          style: GoogleFonts.sora(
              fontSize: 18, fontWeight: FontWeight.w700, color: _ink),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.group.id)
            .snapshots(),
        builder: (ctx, snap) {
          final data = snap.data?.data() as Map<String, dynamic>?;
          final suspendedList =
              List<String>.from(data?['suspendedMembers'] ?? []);
          final isSuspended = suspendedList.contains(widget.member.id);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Profile card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: _ink,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: GoogleFonts.sora(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Name
                      Text(
                        widget.member.name,
                        style: GoogleFonts.sora(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSuspended
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isSuspended ? 'Suspended' : 'Active',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSuspended
                                ? Colors.red
                                : const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Info rows ──
                _infoRow(Icons.email_outlined, 'Email', widget.member.email),
                const SizedBox(height: 10),
                _infoRow(
                  Icons.phone_outlined,
                  'Phone',
                  widget.member.phone?.isNotEmpty == true
                      ? widget.member.phone!
                      : 'Not provided',
                ),

                const SizedBox(height: 32),

                // ── Suspend / Unsuspend button ──
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(color: _ink),
                    ),
                  )
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleSuspend(isSuspended),
                      icon: Icon(
                        isSuspended
                            ? Icons.lock_open_outlined
                            : Icons.block_outlined,
                        size: 20,
                        color: isSuspended
                            ? const Color(0xFF2E7D32)
                            : Colors.orange[700],
                      ),
                      label: Text(
                        isSuspended
                            ? 'Unsuspend Account'
                            : 'Suspend Account',
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSuspended
                              ? const Color(0xFF2E7D32)
                              : Colors.orange[700],
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isSuspended
                              ? const Color(0xFF2E7D32)
                              : Colors.orange[700]!,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Remove from Group button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _confirmRemove,
                      icon: const Icon(
                        Icons.person_remove_outlined,
                        size: 20,
                        color: Colors.red,
                      ),
                      label: Text(
                        'Remove from Group',
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _grey, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.sora(fontSize: 11, color: _grey)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ink)),
            ],
          ),
        ],
      ),
    );
  }
}
