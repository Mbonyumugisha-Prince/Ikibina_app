import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/contribution_model.dart';
import '../../models/group_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/firestore_service.dart';
import '../contributions/add_contribution_screen.dart';

const _bg = Color(0xFFF5F5F5);
const _ink = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

// ── Wallet picker (bottom-nav tab) ───────────────────────────────────────────
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

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
                'Wallets',
                style: GoogleFonts.sora(
                    fontSize: 22, fontWeight: FontWeight.w700, color: _ink),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Text(
                '${groupP.groups.length} group${groupP.groups.length == 1 ? '' : 's'}',
                style: GoogleFonts.sora(fontSize: 13, color: _grey),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: groupP.loading
                  ? const Center(child: CircularProgressIndicator(color: _ink))
                  : groupP.groups.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 64,
                                color: _grey,
                              ),
                              const SizedBox(height: 12),
                              Text('No wallets yet',
                                  style: GoogleFonts.sora(
                                      fontSize: 15, color: _grey)),
                              const SizedBox(height: 4),
                              Text('Join or create a group to get started',
                                  style: GoogleFonts.sora(
                                      fontSize: 12, color: _grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: groupP.groups.length,
                          itemBuilder: (_, i) {
                            final g = groupP.groups[i];
                            return GestureDetector(
                              onTap: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => WalletDetailScreen(
                                    group: g, userId: userId),
                              )),
                              child: _WalletGroupCard(
                                  group: g, userId: userId),
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

class _WalletGroupCard extends StatelessWidget {
  final GroupModel group;
  final String userId;

  const _WalletGroupCard({required this.group, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isAdmin = group.adminId == userId;
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
                        color: isAdmin
                            ? _ink
                            : const Color(0xFFF0F0F0),
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
                const SizedBox(height: 6),
                StreamBuilder<List<ContributionModel>>(
                  stream:
                      FirestoreService().getGroupContributions(group.id),
                  builder: (ctx, snap) {
                    final myTotal = (snap.data ?? [])
                        .where((c) => c.userId == userId)
                        .fold(0.0, (sum, c) => sum + c.amount);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Group total: RWF ${NumberFormat('#,###').format(group.totalSavings)}',
                          style:
                              GoogleFonts.sora(fontSize: 12, color: _grey),
                        ),
                        Text(
                          'Your savings: RWF ${NumberFormat('#,###').format(myTotal)}',
                          style: GoogleFonts.sora(
                              fontSize: 12,
                              color: _ink,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    );
                  },
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

// ── Wallet detail screen ─────────────────────────────────────────────────────
class WalletDetailScreen extends StatefulWidget {
  final GroupModel group;
  final String userId;

  const WalletDetailScreen(
      {super.key, required this.group, required this.userId});

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  bool _isAdminView = false;
  bool _isBalanceVisible = false;
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final isAdmin = widget.group.adminId == widget.userId;

    final filters = [
      s.filterAll,
      s.filterContributions,
      s.filterPayouts,
      s.filterWithdrawals,
    ];

    return StreamBuilder<List<ContributionModel>>(
      stream: FirestoreService().getGroupContributions(widget.group.id),
      builder: (context, snapshot) {
        final allContributions = snapshot.data ?? [];

        final allTransactions = allContributions
            .map((c) => TransactionModel(
                id: c.id,
                groupId: c.groupId,
                userId: c.userId,
                userName: c.userName,
                type: 'contribution',
                amount: c.amount,
                date: c.date,
                description: c.note))
            .toList();

        final isGroupWallet = isAdmin && _isAdminView;

        double balance = 0.0;
        if (isGroupWallet) {
          balance = widget.group.totalSavings;
        } else {
          balance = allTransactions
              .where((t) =>
                  t.userId == widget.userId &&
                  t.type.toLowerCase() == 'contribution')
              .fold(0.0, (sum, t) => sum + t.amount);
          final withdrawn = allTransactions
              .where((t) =>
                  t.userId == widget.userId &&
                  t.type.toLowerCase() == 'withdrawal')
              .fold(0.0, (sum, t) => sum + t.amount);
          balance -= withdrawn;
        }

        Iterable<TransactionModel> displayedList = allTransactions;
        if (!isGroupWallet) {
          displayedList =
              displayedList.where((t) => t.userId == widget.userId);
        }

        if (_selectedFilterIndex == 1) {
          displayedList = displayedList
              .where((t) => t.type.toLowerCase() == 'contribution');
        } else if (_selectedFilterIndex == 2) {
          displayedList =
              displayedList.where((t) => t.type.toLowerCase() == 'payout');
        } else if (_selectedFilterIndex == 3) {
          displayedList = displayedList
              .where((t) => t.type.toLowerCase() == 'withdrawal');
        }

        final recentTransactions = displayedList.take(10).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: _ink),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: isAdmin
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _toggleBtn(s.myWallet, !_isAdminView,
                          () => setState(() => _isAdminView = false)),
                      const SizedBox(width: 8),
                      _toggleBtn(s.groupWallet, _isAdminView,
                          () => setState(() => _isAdminView = true)),
                    ],
                  )
                : Text(
                    widget.group.name,
                    style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _ink),
                  ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        isGroupWallet
                            ? widget.group.name
                            : 'My Wallet · ${widget.group.name}',
                        style:
                            GoogleFonts.sora(fontSize: 12, color: _grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.totalBalance,
                            style: GoogleFonts.sora(
                                color: Colors.black, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() =>
                                _isBalanceVisible = !_isBalanceVisible),
                            child: Icon(
                              _isBalanceVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isBalanceVisible
                            ? 'RWF ${NumberFormat('#,###').format(balance)}'
                            : 'RWF *****',
                        style: GoogleFonts.sora(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionCard(
                      icon: Icons.add,
                      label: s.deposit,
                      onTap: () {
                        if (!isGroupWallet) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const AddContributionScreen()),
                          );
                        }
                      },
                    ),
                    _buildActionCard(
                        icon: Icons.swap_horiz,
                        label: s.transfer,
                        onTap: () {}),
                    _buildActionCard(
                        icon: Icons.account_balance,
                        label: s.loan,
                        onTap: () {}),
                  ],
                ),
                const SizedBox(height: 40),

                // Transaction History
                Text(
                  s.transactionHistory,
                  style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 16),

                // Filter pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(filters.length, (index) {
                      final isSelected = _selectedFilterIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: ChoiceChip(
                          label: Text(filters[index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(
                                  () => _selectedFilterIndex = index);
                            }
                          },
                          selectedColor: Colors.black,
                          backgroundColor: Colors.white,
                          labelStyle: GoogleFonts.sora(
                            color: isSelected
                                ? Colors.white
                                : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 24),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(
                      child:
                          CircularProgressIndicator(color: Colors.black))
                else if (recentTransactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.black, width: 1.5),
                            ),
                            child: const Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          Text('No records found.',
                              style: GoogleFonts.sora(
                                  color: Colors.black, fontSize: 16)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentTransactions.length,
                    itemBuilder: (context, i) {
                      final t = recentTransactions[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(_getIconForType(t.type),
                              color: Colors.white, size: 20),
                        ),
                        title: Text(
                          t.userName.isNotEmpty
                              ? t.userName
                              : t.type.toUpperCase(),
                          style: GoogleFonts.sora(
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        subtitle: Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(t.date),
                          style: GoogleFonts.sora(
                              color: Colors.black54, fontSize: 12),
                        ),
                        trailing: Text(
                          'RWF ${NumberFormat('#,###').format(t.amount)}',
                          style: GoogleFonts.sora(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.black : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.sora(
            color: active ? Colors.white : Colors.black,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    if (type.toLowerCase() == 'contribution') return Icons.add;
    if (type.toLowerCase() == 'withdrawal') return Icons.arrow_downward;
    if (type.toLowerCase() == 'payout') return Icons.arrow_upward;
    if (type.toLowerCase() == 'loan') return Icons.account_balance;
    return Icons.receipt_outlined;
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        height: 104,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
