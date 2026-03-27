import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/contribution_model.dart';
import '../../models/group_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/locale_provider.dart';

const _bg   = Color(0xFFF5F5F5);
const _ink  = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

class AddContributionScreen extends StatefulWidget {
  /// When provided, contributions go to this specific group.
  /// When null, falls back to GroupProvider.currentGroup.
  final GroupModel? group;

  const AddContributionScreen({super.key, this.group});

  @override
  State<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends State<AddContributionScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _amountCtrl     = TextEditingController();
  final _noteCtrl       = TextEditingController();
  bool _isSubmitting    = false;

  GroupModel? get _group =>
      widget.group ?? context.read<GroupProvider>().currentGroup;

  bool get _isGoalGroup => _group?.groupType == 'goal';

  bool _isSuspended(GroupModel group, String userId) =>
      group.suspendedMembers.contains(userId);

  @override
  void initState() {
    super.initState();
    // For ikimina groups pre-fill the fixed amount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final g = _group;
      if (g != null && g.groupType == 'ikimina') {
        _amountCtrl.text = g.contributionAmount.toStringAsFixed(0);
      }
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final group = _group;
    if (group == null) {
      _showError('No group selected. Please select a group first.');
      return;
    }

    final auth = context.read<AuthProvider>();

    setState(() => _isSubmitting = true);

    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount greater than 0');
      setState(() => _isSubmitting = false);
      return;
    }

    final contribution = ContributionModel(
      id: const Uuid().v4(),
      groupId: group.id,
      userId: auth.user!.id,
      userName: auth.user!.name,
      amount: amount,
      date: DateTime.now(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    try {
      final groupProvider = context.read<GroupProvider>();
      final s = context.read<LocaleProvider>().strings;
      final success = await groupProvider.addContribution(contribution);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Contribution added successfully!',
              style: GoogleFonts.sora(color: Colors.white)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ));
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        _showError(groupProvider.contributionError ?? s.failedToAddContribution);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.sora()),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final s            = context.watch<LocaleProvider>().strings;
    final group        = widget.group ?? groupProvider.currentGroup;
    final auth         = context.watch<AuthProvider>();

    // Suspension gate – show a blocking message instead of the form
    if (group != null && auth.user != null &&
        _isSuspended(group, auth.user!.id)) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(s.addContribution,
              style: GoogleFonts.sora(
                  fontSize: 20, fontWeight: FontWeight.w700, color: _ink)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block, color: Colors.red, size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  'Account Suspended',
                  style: GoogleFonts.sora(
                      fontSize: 20, fontWeight: FontWeight.w700, color: _ink),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your account has been suspended by the group admin. You cannot make contributions until your account is reinstated.',
                  style: GoogleFonts.sora(fontSize: 14, color: _grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(s.cancel,
                        style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _ink)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(s.addContribution,
            style: GoogleFonts.sora(
                fontSize: 20, fontWeight: FontWeight.w700, color: _ink)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group info card
                if (group != null) ...[
                  _GroupInfoCard(group: group),
                  const SizedBox(height: 28),
                ],

                // Amount field
                Text(
                  _isGoalGroup ? 'Amount *' : 'Contribution Amount',
                  style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ink),
                ),
                const SizedBox(height: 8),

                if (!_isGoalGroup && group != null) ...[
                  // Ikimina: fixed amount, read-only display
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFE0E0E0), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline,
                            color: _grey, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'RWF ${group.contributionAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _ink),
                        ),
                        const Spacer(),
                        Text(
                          'Fixed amount',
                          style: GoogleFonts.sora(
                              fontSize: 12, color: _grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The contribution amount is fixed by the group admin.',
                    style: GoogleFonts.sora(fontSize: 12, color: _grey),
                  ),
                ] else ...[
                  // Goal group: free-form amount
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    enabled: !_isSubmitting,
                    decoration: _inputDeco(
                      hint: 'Enter amount in RWF',
                      icon: Icons.payments_outlined,
                    ),
                    style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _ink),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Amount is required';
                      final n = double.tryParse(v);
                      if (n == null) return 'Please enter a valid number';
                      if (n <= 0) return 'Amount must be greater than 0';
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // Note field
                Text('Note (Optional)',
                    style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _ink)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  enabled: !_isSubmitting,
                  decoration: _inputDeco(
                    hint: 'Add a note for this contribution (optional)',
                    icon: Icons.note_outlined,
                    alignLabelWithHint: true,
                  ),
                  style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _ink),
                ),

                const SizedBox(height: 32),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _ink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: _grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('Submitting...',
                                  style: GoogleFonts.sora(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          )
                        : Text(s.save,
                            style: GoogleFonts.sora(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFFE0E0E0), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(s.cancel,
                        style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _ink)),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    bool alignLabelWithHint = false,
  }) {
    const border = Color(0xFFE0E0E0);
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      alignLabelWithHint: alignLabelWithHint,
      hintStyle: GoogleFonts.sora(fontSize: 14, color: _grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _ink, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _GroupInfoCard extends StatelessWidget {
  final GroupModel group;
  const _GroupInfoCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final subtitle = group.groupType == 'goal'
        ? 'Goal: RWF ${group.goalAmount.toStringAsFixed(0)}'
        : 'RWF ${group.contributionAmount.toStringAsFixed(0)} / ${group.contributionFrequency}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                group.name[0].toUpperCase(),
                style: GoogleFonts.sora(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name,
                    style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _ink)),
                Text(subtitle,
                    style: GoogleFonts.sora(fontSize: 12, color: _grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
