import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/contribution_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_contribution_screen.dart';

const _bg   = Color(0xFFF5F5F5);
const _ink  = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class ContributionsScreen extends StatefulWidget {
  final String groupId;
  const ContributionsScreen({super.key, required this.groupId});

  @override
  State<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends State<ContributionsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          s.myContributions,
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AddContributionScreen()),
              ),
              icon: const Icon(Icons.add, color: _ink, size: 18),
              label: Text(
                'Add',
                style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ink),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<ContributionModel>>(
        stream: FirestoreService().getGroupContributions(widget.groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _ink));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(s.failedToLoadContributions,
                  style: GoogleFonts.sora(color: _grey)),
            );
          }

          final items = snapshot.data ?? [];
          
          // Calculate totals
          double userTotal = 0;
          double groupTotal = 0;
          final memberTotals = <String, double>{};
          
          for (var item in items) {
            groupTotal += item.amount;
            if (item.userId == auth.user?.id) {
              userTotal += item.amount;
            }
            memberTotals.update(
              item.userName,
              (val) => val + item.amount,
              ifAbsent: () => item.amount,
            );
          }

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox_outlined, size: 48, color: _grey),
                  const SizedBox(height: 12),
                  Text(s.noContributionsYet,
                      style: GoogleFonts.sora(fontSize: 14, color: _grey)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Your contribution summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Total Contribution',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'RWF ${userTotal.toStringAsFixed(0)}',
                      style: GoogleFonts.sora(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Group Total: RWF ${groupTotal.toStringAsFixed(0)}',
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        color: _grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Group breakdown (all members)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Group Contributions',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  Text(
                    '${items.length} entries',
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      color: _grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Member totals summary
              ...memberTotals.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'RWF ${entry.value.toStringAsFixed(0)}',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                ),
              )),

              const SizedBox(height: 24),

              // All contributions list
              Text(
                'All Contributions',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),

              ...List.generate(
                items.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ContributionTile(
                    item: items[i],
                    isCurrentUser: items[i].userId == auth.user?.id,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ContributionTile extends StatelessWidget {
  final ContributionModel item;
  final bool isCurrentUser;
  
  const _ContributionTile({
    required this.item,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = item.userName.isNotEmpty
        ? item.userName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    final dateStr = '${item.date.day}/${item.date.month}/${item.date.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFF0F8FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser ? Colors.blue : const Color(0xFFE0E0E0),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue.withValues(alpha: 0.15) : _bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isCurrentUser ? Colors.blue : _ink,
                ),
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
                    Flexible(
                      child: Text(
                        item.userName,
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'You',
                          style: GoogleFonts.sora(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  item.note?.isNotEmpty == true ? item.note! : dateStr,
                  style: GoogleFonts.sora(fontSize: 12, color: _grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RWF ${item.amount.toStringAsFixed(0)}',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isCurrentUser ? Colors.blue : _ink,
                ),
              ),
              if (item.note?.isNotEmpty == true)
                Text(
                  dateStr,
                  style: GoogleFonts.sora(fontSize: 11, color: _grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
