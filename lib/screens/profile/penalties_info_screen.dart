import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/penalty_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/penalty_service.dart';

/// Read-only screen in Profile → Penalties.
/// Shows what each penalty level means and lists any active penalties
/// the current user has across their groups.
class PenaltiesInfoScreen extends StatelessWidget {
  const PenaltiesInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().user?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Penalties',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'How penalties work',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ikimina group admins configure penalty rules during group creation or in the group settings. Penalties escalate automatically when contribution deadlines are missed.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // ── 4 level cards ──────────────────────────────────────
            _PenaltyLevelCard(
              level: 1,
              title: 'Gentle Reminder',
              trigger: '24 h after deadline',
              action: 'Push notification & email sent',
              icon: Icons.notifications_outlined,
              borderColor: Colors.black12,
            ),
            const SizedBox(height: 12),
            _PenaltyLevelCard(
              level: 2,
              title: 'Late Fee',
              trigger: '3 days late',
              action: 'A percentage of your contribution is charged as a fine',
              icon: Icons.percent_outlined,
              borderColor: Colors.orange.shade200,
            ),
            const SizedBox(height: 12),
            _PenaltyLevelCard(
              level: 3,
              title: 'Account Freeze',
              trigger: '1 cycle missed',
              action: 'No loans or payouts until you catch up',
              icon: Icons.lock_outline,
              borderColor: Colors.deepOrange.shade200,
            ),
            const SizedBox(height: 12),
            _PenaltyLevelCard(
              level: 4,
              title: 'Expulsion',
              trigger: '3 cycles missed',
              action: 'Permanent removal from the group',
              icon: Icons.exit_to_app_outlined,
              borderColor: Colors.red.shade300,
            ),

            const SizedBox(height: 32),

            // ── User's active penalties ────────────────────────────
            Text(
              'Your penalties',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            if (userId.isEmpty)
              _emptyState('Sign in to see your penalties.')
            else
              StreamBuilder<List<PenaltyRecordModel>>(
                stream: PenaltyService().getUserPenaltyRecords(userId),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2),
                      ),
                    );
                  }
                  final records = snap.data ?? [];
                  if (records.isEmpty) {
                    return _emptyState('No penalties on your account.');
                  }
                  return Column(
                    children: records
                        .map((r) => _PenaltyRecordTile(record: r))
                        .toList(),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String msg) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            msg,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
          ),
        ),
      );
}

// ── Level card ────────────────────────────────────────────────────

class _PenaltyLevelCard extends StatelessWidget {
  final int level;
  final String title;
  final String trigger;
  final String action;
  final IconData icon;
  final Color borderColor;

  const _PenaltyLevelCard({
    required this.level,
    required this.title,
    required this.trigger,
    required this.action,
    required this.icon,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'LEVEL $level',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Trigger: $trigger',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Penalty record tile ───────────────────────────────────────────

class _PenaltyRecordTile extends StatelessWidget {
  final PenaltyRecordModel record;
  const _PenaltyRecordTile({required this.record});

  static const _typeLabel = {
    AppConstants.penaltyGentleReminder: 'Gentle Reminder',
    AppConstants.penaltyLateFee: 'Late Fee',
    AppConstants.penaltyAccountFreeze: 'Account Freeze',
    AppConstants.penaltyExpulsion: 'Expulsion',
  };

  static const _typeIcon = {
    AppConstants.penaltyGentleReminder: Icons.notifications_outlined,
    AppConstants.penaltyLateFee: Icons.percent_outlined,
    AppConstants.penaltyAccountFreeze: Icons.lock_outline,
    AppConstants.penaltyExpulsion: Icons.exit_to_app_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final label = _typeLabel[record.type] ?? record.type;
    final icon = _typeIcon[record.type] ?? Icons.gavel_outlined;
    final isHighSeverity = record.type == AppConstants.penaltyAccountFreeze ||
        record.type == AppConstants.penaltyExpulsion;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighSeverity
                  ? Colors.red.shade50
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isHighSeverity ? Colors.red : Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (record.amount > 0)
                      Text(
                        'RWF ${record.amount.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  record.groupName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  record.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(record.appliedAt),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
