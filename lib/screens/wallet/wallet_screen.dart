import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/group_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/transaction_model.dart';
import '../../models/contribution_model.dart';
import '../contributions/add_contribution_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isAdminView = false;
  bool _isBalanceVisible = false;
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final user = context.watch<AuthProvider>().user;
    final group = context.watch<GroupProvider>().currentGroup;
    final isAdmin = user?.activeGroupRole == 'admin';

    final filters = [
      s.filterAll,
      s.filterContributions,
      s.filterPayouts,
      s.filterWithdrawals,
    ];

    if (group == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(s.noGroupsYet,
              style: GoogleFonts.inter(color: Colors.black)),
        ),
      );
    }

    return StreamBuilder<List<ContributionModel>>(
        // Fetch specifically all contributions for the current group
        stream: FirestoreService().getGroupContributions(group.id),
        builder: (context, snapshot) {
          final allContributions = snapshot.data ?? [];

          // Convert contributions to a generic transaction format for display
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

          // For calculations and list display
          final isGroupWallet = isAdmin && _isAdminView;

          // Balance calculation based on realtime firebase data
          double balance = 0.0;
          if (isGroupWallet) {
            balance = group
                .totalSavings; // Realtime group total savings from GroupModel
          } else {
            // Calculate individual member balance
            balance = allTransactions
                .where((t) =>
                    t.userId == user?.id &&
                    t.type.toLowerCase() == 'contribution')
                .fold(0.0, (sum, t) => sum + t.amount);

            // Subtract withdrawals from member
            final withdrawn = allTransactions
                .where((t) =>
                    t.userId == user?.id &&
                    t.type.toLowerCase() == 'withdrawal')
                .fold(0.0, (sum, t) => sum + t.amount);

            balance -= withdrawn;
          }

          // List filtering by user (if not viewing group wallet)
          Iterable<TransactionModel> displayedList = allTransactions;
          if (!isGroupWallet) {
            displayedList = displayedList.where((t) => t.userId == user?.id);
          }

          // Apply Tab Filter logic
          if (_selectedFilterIndex == 1) {
            // Contributions
            displayedList = displayedList
                .where((t) => t.type.toLowerCase() == 'contribution');
          } else if (_selectedFilterIndex == 2) {
            // Payouts
            displayedList =
                displayedList.where((t) => t.type.toLowerCase() == 'payout');
          } else if (_selectedFilterIndex == 3) {
            // Withdrawals
            displayedList = displayedList
                .where((t) => t.type.toLowerCase() == 'withdrawal');
          }

          // Real data requirement: limit it to 10 latest transactions
          final recentTransactions = displayedList.take(10).toList();

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: isAdmin
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isAdminView = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isAdminView
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: !_isAdminView
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                  width: 1.5),
                            ),
                            child: Text(s.myWallet,
                                style: GoogleFonts.inter(
                                  color: !_isAdminView
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: !_isAdminView
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 14,
                                )),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _isAdminView = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isAdminView
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _isAdminView
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                  width: 1.5),
                            ),
                            child: Text(s.groupWallet,
                                style: GoogleFonts.inter(
                                  color: _isAdminView
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: _isAdminView
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 14,
                                )),
                          ),
                        ),
                      ],
                    )
                  : Text(s.myWallet,
                      style: GoogleFonts.inter(
                          color: Colors.black, fontWeight: FontWeight.bold)),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.totalBalance,
                              style: GoogleFonts.inter(
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
                                ))
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isBalanceVisible
                              ? 'RWF ${NumberFormat('#,###').format(balance)}'
                              : 'RWF *****',
                          style: GoogleFonts.inter(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3 Action Cards with STRICT black and white styling logic
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionCard(
                        icon: Icons.add,
                        label: s.deposit,
                        isPrimary: false,
                        onTap: () {
                          // Push to AddContributionScreen conditionally (member view navigation!)
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
                        isPrimary: false,
                        onTap: () {},
                      ),
                      _buildActionCard(
                        icon: Icons.account_balance,
                        label: s.loan,
                        isPrimary: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Transaction History
                  Text(
                    s.transactionHistory,
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 16),

                  // Pills options applying black and white color styles
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
                                setState(() => _selectedFilterIndex = index);
                              }
                            },
                            // Making precisely sure it conforms to strictly black and white logic
                            selectedColor: Colors.black,
                            backgroundColor: Colors.white,
                            labelStyle: GoogleFonts.inter(
                              color: isSelected ? Colors.white : Colors.black,
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
                                  width: 1.5),
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
                        child: CircularProgressIndicator(color: Colors.black))
                  else if (recentTransactions.isEmpty)
                    // Empty State styled correctly for black and white constraints
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
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: const Icon(Icons.receipt_long_outlined,
                                  size: 48, color: Colors.black),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No records found.',
                              style: GoogleFonts.inter(
                                  color: Colors.black, fontSize: 16),
                            ),
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
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                          subtitle: Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(t.date),
                              style: GoogleFonts.inter(
                                  color: Colors.black54, fontSize: 12)),
                          trailing: Text(
                            'RWF ${NumberFormat('#,###').format(t.amount)}',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        );
                      },
                    )
                ],
              ),
            ),
          );
        });
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
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        height: 104,
        decoration: BoxDecoration(
          color: isPrimary ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.grey.shade800 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 28, color: isPrimary ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : Colors.black,
                )),
          ],
        ),
      ),
    );
  }
}
